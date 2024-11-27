import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'home_page.dart';
import 'event_list_page.dart';
import 'profile_page.dart';
import 'my_pledged_gifts_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static List<Map<String, dynamic>> Database = [
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
              'pledged': false,
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
          'eventDate': '2024-11-29',
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
      'friends': [1, 3, 6, 4,8],
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
      'friends': [1, 2, 4, 6,8],
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
      'friends': [1, 2, 3, 5,8],
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
              'pledged': true,
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
    {
      'userid': 7,
      'name': 'Alice',
      'phonenumber': '+1444555666',
      'email': 'alice@example.com',
      'address': '101 Maple St, Townville',
      'notification_preferences': [
        'SMS Notifications',
        'Push Notifications'
      ],
      'pledgedgifts': [10],
      'events': [
        {
          'eventId': 8,
          'eventName': 'Birthday Bash',
          'eventDate': '2024-03-20',
          'eventLocation': 'Alice\'s House',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 20,
              'giftName': 'Smartphone',
              'category': 'Tech',
              'pledged': true,
              'imageurl': 'https://example.com/smartphone.jpg',
              'price': 800.0,
              'description': 'A new high-end smartphone with the latest features and specs.'
            },
            {
              'giftid': 21,
              'giftName': 'Bluetooth Headphones',
              'category': 'Tech',
              'pledged': false,
              'imageurl': 'https://example.com/headphones.jpg',
              'price': 150.0,
              'description': 'Wireless headphones with noise cancellation and high-quality sound.'
            }
          ]
        }
      ],
      'friends': [2, 3, 4]
    },
    {
      'userid': 8,
      'name': 'Farida',
      'phonenumber': '+128456',
      'email': 'Farida@example.com',
      'address': '11 Maple St, Townville',
      'notification_preferences': [
        'SMS Notifications',
        'Push Notifications'
      ],
      'pledgedgifts': [10],
      'events': [
        {
          'eventId': 29,
          'eventName': 'Birthday Party',
          'eventDate': '2024-03-20',
          'eventLocation': 'Alice\'s House',
          'category': 'Celebration',
          'Status': 'Upcoming',
          'gifts': [
            {
              'giftid': 13,
              'giftName': 'Smartphone',
              'category': 'Tech',
              'pledged': false,
              'imageurl': 'https://example.com/smartphone.jpg',
              'price': 800.0,
              'description': 'A new high-end smartphone with the latest features and specs.'
            },
            {
              'giftid': 14,
              'giftName': 'Bluetooth Headphones',
              'category': 'Tech',
              'pledged': false,
              'imageurl': 'https://example.com/headphones.jpg',
              'price': 150.0,
              'description': 'Wireless headphones with noise cancellation and high-quality sound.'
            }
          ]
        }
      ],
      'friends': [2, 3, 4]
    }

  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF3A3A3A),
          secondary: const Color(0xFFB3E5FC),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;

  @override
  void initState() {
    super.initState();
    // Initialize the MotionTabBarController
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0, // Set initial index to 0 for the first tab
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _motionTabBarController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          EventListPage(userid: 1, Database: MyApp.Database),
          HomePage(userid: 1, Database: MyApp.Database),
          PledgedListPage(userid: 1, Database: MyApp.Database),
          ProfilePage(userid: 1, Database: MyApp.Database),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Home",
        labels: const ["Events", "Home","Pledged Gifts", "Profile"],
        icons: const [
          Icons.calendar_month,
          Icons.home,
          Icons.card_giftcard,
          Icons.person,
        ],
        badges: [
          const MotionBadgeWidget(
            text: '10+',
            color: Colors.red,
          ), // Badge for "Events"
          const MotionBadgeWidget(
            text: '10+',
            color: Colors.red,
          ), // No badge for "Home"
          const MotionBadgeWidget(
            text: '10+',
            color: Colors.red,
          ), // No badge for "Profile"
          const MotionBadgeWidget(
            text: '10+',
            color: Colors.red,
          ), // No badge for "Profile"
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.grey,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.deepPurple,
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: (int index) {
          setState(() {
            _motionTabBarController.index = index;
          });
        },
      ),
    );
  }

}
