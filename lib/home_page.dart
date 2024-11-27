import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/friends_event_list.dart';
import 'rounded_button.dart';
import 'friend_card.dart';
import 'friends_event_list.dart';
import 'event_list_page.dart';
import 'createEvent.dart';
class Friend {
  final String name;
  final int eventCount;


  Friend({required this.name, required this.eventCount});
}

class HomePage extends StatefulWidget {
  final int userid;
  final List<Map<String, dynamic>> Database;
  HomePage({required this.userid, required this.Database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> friendsList;


  @override
  void initState() {
    super.initState();
    // Initialize the friends list on page load based on the current user's data
    var currentUser = widget.Database.firstWhere((user) =>
    user['userid'] == widget.userid);

    friendsList = widget.Database.where((user) {
      return currentUser['friends'].contains(user['userid']);
    }).toList();

    // Add listener to search controller
    _searchController.addListener(() {
      _filterFriendsList(_searchController.text);
    });
  }

  void _filterFriendsList(String query) {
    var currentUser = widget.Database.firstWhere(
            (user) => user['userid'] == widget.userid);

    setState(() {
      friendsList = widget.Database.where((dynamic user) { // Explicitly define `user` type as `dynamic`
        // Ensure the user is a friend
        bool isFriend = currentUser['friends'].contains(user['userid']);

        // Check if the friend's name matches the query
        bool matchesSearch = user['name'].toLowerCase().contains(query.toLowerCase());

        // Check if any gift name in any event contains the search query
        bool hasMatchingGift = (user['events'] as List<dynamic>?)?.any((event) {
          return (event['gifts'] as List<dynamic>?)?.any((gift) {
            return gift['giftName'].toLowerCase().contains(query.toLowerCase());
          }) ?? false;
        }) ?? false;

        return isFriend && (matchesSearch || hasMatchingGift);
      }).toList();
    });
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

// Function to add a friend by phone number
  void _addFriendByPhoneNumber(String phoneNumber) {
    print("Attempting to add friend by phone number: $phoneNumber");

    // Retrieve current user
    var currentUser = widget.Database.firstWhere(
          (user) => user['userid'] == widget.userid,
      orElse: () => {}, // Return empty map if user is not found
    );

    if (currentUser.isEmpty) {
      print("Current user not found in the database.");
      return;
    }

    // Retrieve potential friend
    var potentialFriend = widget.Database.firstWhere(
          (user) => user['phonenumber'] == phoneNumber,
      orElse: () => {}, // Return empty map if user is not found
    );

    if (potentialFriend.isEmpty) {
      print("User with phone number $phoneNumber not found in the database.");
      return;
    }

    // Check if the potential friend is already in your friends list
    List<int> currentUserFriends = List<int>.from(currentUser['friends']);
    if (currentUserFriends.contains(potentialFriend['userid'])) {
      print("This user is already your friend.");
      return;
    }

    setState(() {
      // Add each other as friends
      (currentUser['friends'] as List).add(potentialFriend['userid']);
      (potentialFriend['friends'] as List).add(currentUser['userid']);

      // Update the friendsList to reflect the change
      friendsList = widget.Database.where((user) {
        return currentUser['friends'].contains(user['userid']);
      }).toList();
    });

    print("You are now friends with ${potentialFriend['name']}!");
  }




  @override
  Widget build(BuildContext context) {
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
                                    Database: widget.Database,
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
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      var friend = friendsList[index]; // Get the friend data
                      return FriendCard(
                        name: friend['name'],
                        eventCount: friend['events'].length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendsEventList(
                                    frienddata: friend,
                                    userid: widget.userid,
                                    Database: widget.Database
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

