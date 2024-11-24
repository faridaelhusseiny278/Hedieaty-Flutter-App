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
          EventListPage(),
          HomePage(),
          PledgedListPage(),
          ProfilePage(),
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
