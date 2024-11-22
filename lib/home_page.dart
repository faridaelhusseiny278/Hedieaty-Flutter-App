import 'package:flutter/material.dart';
import 'rounded_button.dart';
import 'friend_card.dart';

class HomePage extends StatelessWidget {
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
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FriendCard(name: "John Doe", eventCount: 1),
                      FriendCard(name: "Jane Smith", eventCount: 0),
                      FriendCard(name: "Alex Green", eventCount: 2),
                    ],
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
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.grey.shade400,
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: Colors.white), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      //   ],
      // ),
    );
  }
}
