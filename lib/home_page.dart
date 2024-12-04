import 'package:flutter/material.dart';
// import 'package:hedieatyfinalproject/friends_event_list.dart';
import 'rounded_button.dart';
import 'friend_card.dart';
import 'friends_event_list.dart';
import 'createEvent.dart';
import 'database.dart';
import 'dart:async';
class Friend {
  final String name;
  final int eventCount;


  Friend({required this.name, required this.eventCount});
}

class HomePage extends StatefulWidget {
  final int userid;
  DatabaseService dbService = DatabaseService();

  HomePage({required this.userid, required this.dbService});

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
  Timer? _debounce;



  @override
  void initState() {
    print("in init state of home page now!");
    super.initState();
    _loadFriendsList();

    _searchController.addListener(() {

        _filterFriendsList(_searchController.text);

    });
  }

  Future<void> _loadFriendsList() async {
    var friendsIds = await widget.dbService.getUserFriendsIDs(widget.userid);

    // Clear friends list before adding new ones to avoid duplicates
    friendsList.clear();
    filteredFriendsList.clear();

    for (var id in friendsIds) {
      print("id is: $id");
      var friendData = await widget.dbService.getUserByIdforFriends(id);
      friendsList.add(friendData!);

      var eventcount = await widget.dbService.getEventCountForUserFriends(friendData['userid'].toString());
      eventCounts[friendData['userid']] = eventcount;
    }

    setState(() {
      filteredFriendsList = List.from(friendsList); // Set filtered list after loading
      isLoading = false; // Loading completed
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
      bool isFriend = await widget.dbService.areFriends(widget.userid, friend['userid']);

      // Check if the friend's name matches the query
      bool matchesSearch = friend['name'].toLowerCase().contains(query.toLowerCase());

      // Check if any gift name in any event contains the search query
      bool hasMatchingGift = false;
      var events = await widget.dbService.getEventsForUserFriends(friend['userid']);
      for (var event in events) {
        var gifts = await widget.dbService.getGiftsForEventFriends(event['eventId'], friend['userid']);
        for (var gift in gifts) {
          if (gift['giftName'].toLowerCase().contains(query.toLowerCase())) {
            hasMatchingGift = true;
            break;
          }
        }
        if (hasMatchingGift) break;
      }

      // Add the friend to the filtered list if they meet the criteria
      if (isFriend && (matchesSearch || hasMatchingGift)) {
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

                if (phoneNumber.isNotEmpty) {
                  _addFriendByPhoneNumber(phoneNumber); // Add friend by phone number
                }

                Navigator.of(context).pop(); // Close the dialog
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
    var potentialFriend = await widget.dbService.getUserByPhoneNumber(phoneNumber);

    if (potentialFriend == null) {
      print("User with phone number $phoneNumber not found in the database.");
      return;
    }

    // Check if the potential friend is already in the user's friends list
    var currentFriendsIds = await widget.dbService.getUserFriendsIDs(widget.userid);
    print("current friend ids: $currentFriendsIds for user: ${widget.userid}");

    if (currentFriendsIds.contains(potentialFriend['userid'])) {
      print("You are already friends with ${potentialFriend['name']}!");
      return;
    }

    // Add each other as friends in the database
    await widget.dbService.addFriend(widget.userid, potentialFriend['userid']);

     List<Map<String, dynamic>> tempList=[];
    // Refresh the friends list
    var updatedFriendsListids = await widget.dbService.getUserFriendsIDs(widget.userid);
    for (var friendid in updatedFriendsListids) {
      var friendData = await widget.dbService.getUserByIdforFriends(friendid);
      if (!tempList.contains(friendData)) {
        print("friendData: $friendData does not exist in TempList");
        tempList.add(friendData!);
        eventCounts[friendData['userid']] = await widget.dbService.getEventCountForUserFriends(friendData['userid'].toString());
      }
    }
    setState(() {
      filteredFriendsList = List.from(tempList);
      friendsList = List.from(tempList);
    });

    print("You are now friends with ${potentialFriend['name']}!");
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while data is loading
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
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
            top: 360,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        name: friend['name'],
                        eventCount: eventCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendsEventList(
                                    frienddata: friend,
                                    userid: widget.userid,
                                      dbService: widget.dbService
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog(context); // Show the dialog to add a friend
        },
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

