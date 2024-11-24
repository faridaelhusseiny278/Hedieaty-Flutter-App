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
  // Sample list of friends (this can later come from a database)
  List<Map<String, dynamic>> homePageData = [
    {
      'userid': 1,
      'name': 'Alice',
      'phonenumber': '+1234567890',
      'email': 'alice@example.com',
      'address': '123 Wonderland St, Fantasy City',
      'notification_preferences': [
        'Email Notifications',
      ],
      'pledgedgifts': [4],
      'events': [
        {
          'eventId': 1,
          'eventName': 'Birthday Bash',
          'eventDate': '2024-12-10',
          'eventLocation': 'Alice\'s House',
          'category': 'Birthday',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 1,
              'giftName': 'Smartwatch',
              'category': 'Tech',
              'pledged': true,
              'imageurl': 'https://example.com/smartwatch.jpg',
              'price': 200.0,
              'description': 'A sleek smartwatch with fitness tracking features.'
            },
            {
              'giftid': 2,
              'giftName': 'Fitness Tracker',
              'category': 'Health',
              'pledged': true,
              'imageurl': 'https://example.com/fitnesstracker.jpg',
              'price': 50.0,
              'description': 'A high-quality fitness tracker that helps monitor my workouts, heart rate, and daily activity.'

            },
          ],
        },
        {
          'eventId': 2,
          'eventName': 'Wedding Anniversary',
          'eventDate': '2024-10-05',
          'eventLocation': 'Luxury Hotel',
          'category': 'Social',
          'Status': 'past',
          'gifts': [
            {
              'giftid': 3,
              'giftName': 'Romantic Dinner Voucher',
              'category': 'Experience',
              'pledged': false,
              'imageurl': 'https://example.com/dinner.jpg',
              'price': 150.0,
              'description': 'A voucher for a romantic dinner at a 5-star restaurant.'
            },
          ],
        },
        {
          'eventId': 9,
          'eventName': 'Housewarming Party',
          'eventDate': '2024-11-15',
          'eventLocation': 'Alice\'s New Home',
          'category': 'Housewarming',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid':13 ,
              'giftName': 'Wine Glass Set',
              'category': 'Home',
              'pledged': false,
              'imageurl': 'https://example.com/wineglassset.jpg',
              'price': 40.0,
              'description': ''
            },
          ],
        },
        {
          'eventId': 10,
          'eventName': 'Christmas Celebration',
          'eventDate': '2024-12-25',
          'eventLocation': 'Alice\'s House',
          'category': 'Holiday',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 14,
              'giftName': 'Christmas Tree Decoration Set',
              'category': 'Home',
              'pledged': false,
              'imageurl': 'https://example.com/christmasdecorations.jpg',
              'price': 30.0,
              'description': 'A complete set of decorations for the perfect Christmas tree.'
            },
          ],
        },
        {
          'eventId': 11,
          'eventName': 'New Year Eve Party',
          'eventDate': '2024-12-31',
          'eventLocation': 'City Center',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 15,
              'giftName': 'Party Supplies',
              'category': 'Event',
              'pledged': false,
              'imageurl': 'https://example.com/partysupplies.jpg',
              'price': 50.0,
              'description': 'A complete set of party supplies including balloons, decorations, and tableware, perfect for hosting a fun and memorable event.'

            },
          ],
        },
      ],
      'friends': [2, 3, 6, 5, 4],
    },
    {
      'userid': 2,
      'name': 'Bob',
      'phonenumber': '+1987654321',
      'email': 'bob@example.com',
      'address': '456 Oak Ave, Citytown',
      'notification_preferences': [
        'Push Notifications',
      ],
      'pledgedgifts': [1, 2],
      'events': [
        {
          'eventId': 3,
          'eventName': 'Graduation Party',
          'eventDate': '2024-11-25',
          'eventLocation': 'Bob\'s College',
          'category': 'Celebration',
          'Status': 'Current',
          'gifts': [
            {
              'giftid': 4,
              'giftName': 'Laptop',
              'category': 'Tech',
              'pledged': true,
              'imageurl': 'https://example.com/laptop.jpg',
              'price': 1000.0,
              'description': 'A powerful laptop for all my work and play needs.'
            },
            {
              'giftid': 5,
              'giftName': 'Camera',
              'category': 'Tech',
              'pledged': false,
              'imageurl': 'https://example.com/camera.jpg',
              'price': 500.0,
              'description': 'A high-quality digital camera that captures stunning photos and videos.'
            },
          ],
        },
        {
          'eventId': 14,
          'eventName': 'Housewarming Party',
          'eventDate': '2024-07-15',
          'eventLocation': 'Bob\'s New Apartment',
          'category': 'Housewarming',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 16,
              'giftName': 'Smart Home Speaker',
              'category': 'Tech',
              'pledged': false,
              'imageurl': 'https://example.com/smartspeaker.jpg',
              'price': 150.0,
              'description': 'A cutting-edge smart speaker that integrates seamlessly with my home.'
            },
            {
              'giftid': 17,
              'giftName': 'Home Decor Set',
              'category': 'Home',
              'pledged': false,
              'imageurl': 'https://example.com/homedecor.jpg',
              'price': 75.0,
              'description': 'A stylish and elegant home decor set that includes decorative items such as candles, vases, and throw pillows.'
            },
          ],
        },
        {
          'eventId': 15,
          'eventName': 'Birthday Celebration',
          'eventDate': '2024-08-10',
          'eventLocation': 'Bob\'s Backyard',
          'category': 'Birthday',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 18,
              'giftName': 'Teddy Bear',
              'category': 'Toys',
              'pledged': false,
              'imageurl': 'https://example.com/giftcard.jpg',
              'price': 50.0,
              'description': 'A soft and cuddly teddy bear made from plush fabric.'
            },
          ],
        },
        {
          'eventId': 16,
          'eventName': 'New Year\'s Eve Party',
          'eventDate': '2024-12-31',
          'eventLocation': 'Bob\'s House',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 19,
              'giftName': 'Party Decorations',
              'category': 'Event',
              'pledged': false,
              'imageurl': 'https://example.com/partydecorations.jpg',
              'price': 40.0,
              'description': 'A complete set of vibrant party decorations, including balloons, banners, and streamers.'
            },
          ],
        },
        {
          'eventId': 17,
          'eventName': 'Christmas Dinner',
          'eventDate': '2024-12-25',
          'eventLocation': 'Bob\'s House',
          'category': 'Holiday',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 20,
              'giftName': 'Christmas Tree',
              'category': 'Home',
              'pledged': false,
              'imageurl': 'https://example.com/christmastree.jpg',
              'price': 100.0,
              'description': 'A complete set of decorations for the perfect Christmas tree.'
            },
          ],
        },
      ],
      'friends': [1, 3, 6, 4],
    },
    {
      'userid': 3,
      'name': 'Charlie',
      'phonenumber': '+1122334455',
      'email': 'charlie@example.com',
      'address': '789 Pine Rd, Suburbia',
      'notification_preferences': [
        'Push Notifications',
        'SMS Notifications',

      ],
      'pledgedgifts': [7],
      'events': [
        {
          'eventId': 4,
          'eventName': 'Housewarming',
          'eventDate': '2024-12-01',
          'eventLocation': 'Charlie\'s New House',
          'category': 'Social',
          'Status': 'Current',
          'gifts': [
            {
              'giftid': 6,
              'giftName': 'Wine Glass Set',
              'category': 'Home',
              'pledged': true,
              'imageurl': 'https://example.com/wineglasses.jpg',
              'price': 40.0,
              'description': ''
            },
          ],
        },
      ],
      'friends': [1, 2, 4, 6],
    },
    {
      'userid': 4,
      'name': 'David',
      'phonenumber': '+1998765432',
      'email': 'david@example.com',
      'address': '12 Elm St, Downtown',
      'notification_preferences': [
        'SMS Notifications',
        'Email Notifications',
      ],
      'pledgedgifts': [6],
      'events': [
        {
          'eventId': 5,
          'eventName': 'Christmas Party',
          'eventDate': '2024-12-25',
          'eventLocation': 'David\'s Apartment',
          'category': 'Holiday',
           'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 7,
              'giftName': 'Bluetooth Speaker',
              'category': 'Tech',
              'pledged': true,
              'imageurl': 'https://example.com/speaker.jpg',
              'price': 120.0,
              'description': 'A smart speaker that connects with your home devices.'
            },
            {
              'giftid': 8,
              'giftName': 'Winter Jacket',
              'category': 'Fashion',
              'pledged': false,
              'imageurl': 'https://example.com/jacket.jpg',
              'price': 150.0,
              'description': 'A stylish and warm winter jacket, perfect for keeping cozy during the cold season.'

            },
          ],
        },
      ],
      'friends': [1, 2, 3, 5],
    },
    {
      'userid': 5,
      'name': 'Eve',
      'phonenumber': '+1222333444',
      'email': 'eve@example.com',
      'address': '56 Maple Rd, Greenfield',
      'notification_preferences': [
        'Push Notifications',
        'SMS Notifications',
        'Email Notifications',
      ],
      'pledgedgifts': [11, 12],
      'events': [
        {
          'eventId': 6,
          'eventName': 'Baby Shower',
          'eventDate': '2025-01-15',
          'eventLocation': 'Eve\'s House',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 9,
              'giftName': 'Baby Stroller',
              'category': 'Toys',
              'pledged': true,
              'imageurl': 'https://example.com/stroller.jpg',
              'price': 300.0,
              'description': 'A comfortable and secure baby stroller designed for easy mobility'
            },
            {
              'giftid': 10,
              'giftName': 'Baby Monitor',
              'category': 'Toys',
              'pledged': false,
              'imageurl': 'https://example.com/monitor.jpg',
              'price': 80.0,
              'description': 'A high-quality baby monitor with video and audio capabilities,'
            },
          ],
        },
      ],
      'friends': [1, 6, 4],
    },
    {
      'userid': 6,
      'name': 'Frank',
      'phonenumber': '+1333444555',
      'email': 'frank@example.com',
      'address': '88 Birch St, Lakeside',
      'notification_preferences': [
        'Push Notifications',
        'Email Notifications',
      ],
      'pledgedgifts': [9],
      'events': [
        {
          'eventId': 7,
          'eventName': 'New Year Party',
          'eventDate': '2024-01-01',
          'eventLocation': 'Frank\'s Mansion',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 11,
              'giftName': 'Portable Charger',
              'category': 'Tech',
              'pledged': true,
              'imageurl': 'https://example.com/charger.jpg',
              'price': 25.0,
              'description': 'A compact and powerful portable charger designed to keep my devices powered on the go.'
            },
            {
              'giftid': 12,
              'giftName': 'Smart Thermostat',
              'category': 'Home',
              'pledged': true,
              'imageurl': 'https://example.com/thermostat.jpg',
              'price': 200.0,
              'description': ''
            },
          ],
        },
      ],
      'friends': [1, 2, 3, 5],
    },
  ];
  final current_user_id = 1; // This will later come from somewhere else, such as a user session

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
    var currentUser = homePageData.firstWhere((user) =>
    user['userid'] == current_user_id);

    // Filter the list of friends based on the current user's friends
    List<Map<String, dynamic>> friendsList = homePageData.where((user) {
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
