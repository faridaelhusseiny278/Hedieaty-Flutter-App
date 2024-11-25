import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/friends_event_list.dart';
import 'rounded_button.dart';
import 'friend_card.dart';
import 'friends_event_list.dart';
import 'event_list_page.dart';
class Friend {
  final String name;
  final int eventCount;


  Friend({required this.name, required this.eventCount});
}

class HomePage extends StatelessWidget {
  final int userid;
  final List<Map<String, dynamic>> Database;
  HomePage({required this.userid, required this.Database});


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
                  // Add your manual friend adding logic here
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_phone),
                title: Text("Add from Contacts"),
                onTap: () {
                  // Add your contacts selection logic here
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find the current user's data
    var currentUser = this.Database.firstWhere((user) =>
    user['userid'] == this.userid);

    // Filter the list of friends based on the current user's friends
    List<Map<String, dynamic>> friendsList = this.Database.where((user) {
      return currentUser['friends'].contains(user['userid']);
    }).toList();

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
                      Text(
                        'Search friends or gift lists...',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
                        onTap: () {},
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
                    // Updated to display only friends
                    itemBuilder: (context, index) {
                      var friend = friendsList[index]; // Get the friend data
                      return FriendCard(
                        name: friend['name'],
                        eventCount: friend['events'].length,
                        // Calculate event count
                        onTap: () {
                          // Navigate to the gift list page and pass the clicked friend's data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsEventList(
                                  frienddata: friend), // Pass the friend data
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
