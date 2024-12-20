import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Controllers/event_controller.dart';
import 'package:hedieatyfinalproject/Controllers/friend_controller.dart';
import 'package:hedieatyfinalproject/Controllers/friend_event_controller.dart';
import 'package:hedieatyfinalproject/Controllers/gift_controller.dart';
import 'package:hedieatyfinalproject/Controllers/user_controller.dart';
import 'package:hedieatyfinalproject/Models/user_model.dart';
import 'rounded_button.dart';
import 'friend_card.dart';
import 'friends_event_list.dart';
import 'createEvent.dart';
import '../database.dart';
import 'dart:async';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import '../Controllers/NotificationService.dart';
import '../Models/Notification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Controllers/firebasedatabase_helper.dart';


class HomePage extends StatefulWidget {
  final int userid;
  UserModel user_model = UserModel();
  DatabaseService dbService = DatabaseService();
  UserController userController = UserController();
  FriendController friendController = FriendController();

  EventController eventController = EventController();
  GiftController giftController = GiftController();
  FriendEventController friendEventController = FriendEventController();

  late MotionTabBarController motionTabBarController;
  bool testing;

  HomePage({required this.userid, required this.dbService, required this.motionTabBarController,
  this.testing= false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> friendsList=[];
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  Map<int, int> eventCounts = {};
  late List<Map<String, dynamic>> filteredFriendsList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AppNotificationService _notificationService;
  List<AppNotification> _notifications = [];
  StreamSubscription<DatabaseEvent>? _notificationsSubscription;
  bool _isPressed = false;
  Color _buttonColor = Colors.deepPurple;





  @override
  void initState() {
    print("in init state of home page now!");
    super.initState();
    _loadFriendsList();
    // _initializeEvents();
    if (widget.testing == false){
      _requestNotificationPermissions();
      _notificationService = AppNotificationService(userid: widget.userid);
      _printDatabase();
      _loadNotifications();
    }


    _searchController.addListener(() {

        _filterFriendsList(_searchController.text);

    });
  }


  void _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions.');
    } else {
      print('User declined or did not accept notification permissions.');
    }
  }
  // Load notifications from the database
  void _loadNotifications() {
    final notificationsRef = FirebaseDatabaseHelper.getReference("Users/${widget.userid}/notifications");

    // Listen for changes in the notifications node
    notificationsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        List<AppNotification> updatedNotifications = [];
        if (data is Map) {
          data.forEach((key, value) {
            if (value != null && value is Map) {
              updatedNotifications.add(AppNotification(
                message: value['message'] ?? '',
                timestamp: DateTime.parse(value['timestamp'] ?? DateTime.now().toString()),
                isRead: value['isRead'] ?? false,
              ));
            }
          });
        }
        if (mounted) {
          setState(() {
            _notifications = updatedNotifications;
          });
        }
      }
    });
  }
  @override
  void dispose() {
    // Cancel the subscription to avoid calling setState after widget disposal
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  void _showNotificationHistory() {
    // Mark all notifications as read once they are displayed
    _notifications.forEach((notification) {
      if (!notification.isRead) {
        notification.isRead = true;
        _notificationService.markNotificationAsRead(notification);  // Update status in DB
      }
    });
    _scaffoldKey.currentState?.openDrawer();  // Open the drawer using the GlobalKey
  }





  Future <void> _printDatabase() async {
    await widget.dbService.printDatabase();
  }

  Future<void> _loadFriendsList() async {
    var friendsIds = await widget.friendController.getUserFriendsIDs(widget.userid);

    var friendsData = await Future.wait(friendsIds.map((id) async {
      var friendData = await widget.user_model.getUserByIdforFriends(id);
      var eventCount = await widget.eventController.getEventCountForUserFriends(
          friendData!['userid'].toString());
      return {
        'friend': friendData,
        'eventCount': eventCount,
      };
    }));

    setState(() {
      friendsList = friendsData
          .map((e) => e['friend'] as Map<String, dynamic>)
          .toList();

      eventCounts = {
        for (var friend in friendsData)
          (friend['friend'] as Map<String, dynamic>)['userid'] as int:
          friend['eventCount'] as int,
      };

      filteredFriendsList = List.from(friendsList);
      isLoading = false;
    });

  }



  void _filterFriendsList(String query) async {
    // Store the current query
    final currentQuery = query;

    // Set filteredFriendsList to the full list when the query is empty
    if (query.isEmpty) {
      setState(() {
        filteredFriendsList = List.from(friendsList);
      });
      return;
    }

    // Temporary list to store filtered friends
    List<Map<String, dynamic>> filteredList = [];

    for (var friend in friendsList) {
      // Ensure the user is a friend
      // bool isFriend = await widget.userController.areFriends(widget.userid, friend['userid']);

      // Check if the friend's name matches the query
      bool matchesSearch = friend['name'].toLowerCase().contains(query.toLowerCase());
      if (matchesSearch) {
        filteredList.add(friend);
        continue;
      }

      // Check if any gift name in any event contains the search query
      bool hasMatchingGift = false;
      var events = await widget.eventController.getEventsForUserFriends(friend['userid']);
      for (var event in events) {
        var gifts = await widget.giftController.getGiftsForEventFriends(event['eventId'], friend['userid']);
        for (var gift in gifts) {
          if (gift['giftName'].toLowerCase().contains(query.toLowerCase())) {
            hasMatchingGift = true;
            break;
          }
        }
        if (hasMatchingGift) break;
      }

      // Add the friend to the filtered list if they meet the criteria
      if ((matchesSearch || hasMatchingGift) && !filteredList.contains(friend)) {
        filteredList.add(friend);
      }
    }

    // Ensure the query hasn't changed before updating the state
    if (_searchController.text == currentQuery) {
      setState(() {
        filteredFriendsList = List.from(filteredList);
      });
    }
  }







  // Function to show the dialog for adding a friend
  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Friend"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone),
                title: Text("Add Manually"),
                onTap: () {
                  Navigator.of(context).pop(); // Close the current dialog
                  _showPhoneNumberDialog(context); // Show the phone number input dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_phone),
                title: Text("Add from Contacts"),
                onTap: () {
                  // Add your contacts selection logic here
                  Navigator.of(context).pop(); // Close the current dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }


// Function to show dialog for inputting phone number
  void _showPhoneNumberDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Phone Number"),
          content: TextField(
            controller: phoneController,
            decoration: InputDecoration(hintText: "Phone number"),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String phoneNumber = phoneController.text.trim();
                final phoneRegex = RegExp(r'^\+\d{10,15}$');

                if (phoneNumber.isEmpty) {
                  // Show an error for an empty phone number
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Phone number cannot be empty.")),
                  );
                } else if (!phoneRegex.hasMatch(phoneNumber)) {
                  // Show an error for an invalid phone number
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter a valid phone number starting with + and has from 10-15 digits.")),
                  );
                } else {
                  // Phone number is valid
                  _addFriendByPhoneNumber(phoneNumber);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text("Add Friend"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _addFriendByPhoneNumber(String phoneNumber) async {
    print("Attempting to add friend by phone number: $phoneNumber");

    // Retrieve potential friend by phone number
    var potentialFriend = await widget.user_model.getUserByPhoneNumber(phoneNumber);

    if (potentialFriend == null) {
      print("User with phone number $phoneNumber not found in the database.");
      // show a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User with phone number $phoneNumber not found.")),
      );
      return;
    }

    var currentFriendsIds = await widget.friendController.getUserFriendsIDs(widget.userid);
    print("current friend ids: $currentFriendsIds for user: ${widget.userid}");

    if (currentFriendsIds.contains(potentialFriend['userid'])) {
      print("You are already friends with ${potentialFriend['name']}!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are already friends with ${potentialFriend['name']}!")),
      );
      return;
    }

    // Add each other as friends in the database
    await widget.friendController.addFriend(widget.userid, potentialFriend['userid']);

     List<Map<String, dynamic>> tempList=[];
    // Refresh the friends list
    var updatedFriendsListids = await widget.friendController.getUserFriendsIDs(widget.userid);
    for (var friendid in updatedFriendsListids) {
      var friendData = await widget.user_model.getUserByIdforFriends(friendid);
      if (!tempList.contains(friendData)) {
        print("friendData: $friendData does not exist in TempList");
        tempList.add(friendData!);
        eventCounts[friendData['userid']] = await widget.eventController.getEventCountForUserFriends(friendData['userid'].toString());
      }
    }
    setState(() {
      filteredFriendsList = List.from(tempList);
      friendsList = List.from(tempList);
    });

    print("You are now friends with ${potentialFriend['name']}!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You are now friends with ${potentialFriend['name']}!")),
    );
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while data is loading
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home Page'),
        leading: IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications),
              if (_notifications.any((n) => !n.isRead))
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      _notifications.where((n) => !n.isRead).length.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            _showNotificationHistory();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80, // Set the desired height here
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Center(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            _notifications.isEmpty
                ? ListTile(
              title: Text('No notifications yet.'),
            )
                : Column(
              children: _notifications.map((notification) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notification.timestamp.toString()),
                  ),
                );
              }).toList(),
            ),
            ListTile(
              title: Text('Clear All'),
              onTap: () async {
                await _notificationService.clearNotifications();
                setState(() {
                  _notifications.clear();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Close'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9B0BEF), Color(0xFFBBAAF1)],
              ),
            ),
          ),
          Positioned.fill(
            top: 310,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Center(
                    child: Text(
                      "Hediaty",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Search box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search friends or gift lists...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    RoundedButton(
                      icon: Icons.add,
                      label: "Create Your Own Event/List",
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateEventPage(
                                  userid: widget.userid,
                                ),
                          ),
                        );
                        setState(() {
                          widget.motionTabBarController.index = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // List of friends with their gift lists and upcoming events
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredFriendsList.length,
                  itemBuilder: (context, index) {
                    var friend = filteredFriendsList[index]; // Get the friend data
                    // print("item count: ${filteredFriendsList.length}");
                    // print("Friend: $friend");
                    // print("eventCounts: $eventCounts");
                    int eventCount = eventCounts[friend['userid']] ?? 0; // Get pre-fetched event count
                    return FriendCard(
                      imageurl: friend['imageurl'],
                      name: friend['name'],
                      eventCount: eventCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => FriendsEventList(
                              frienddata: friend,
                              userid: widget.userid,
                              dbService: widget.dbService,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // Slide in from the right
                              const end = Offset.zero; // End at the current position
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300), // Duration of the transition
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: _isPressed ? 0.5 : 1.0, // Scale down when pressed
        duration: Duration(milliseconds: 350), // Duration of the animation
        curve: Curves.easeInOut, // Animation curve
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isPressed = true; // Set to pressed state
              _buttonColor = Colors.orange; // Change color when pressed
            });

            _showAddFriendDialog(context);

            // Reset scale and color back after animation completes
            Future.delayed(Duration(milliseconds: 350), () {
              setState(() {
                _isPressed = false; // Reset scale back to normal
                _buttonColor = Colors.deepPurple; // Reset color to original
              });
            });
          },
          child: Icon(Icons.add, size: 30),
          backgroundColor: _buttonColor, // Use the animated button color
        ),
      ),
    );
  }
}

