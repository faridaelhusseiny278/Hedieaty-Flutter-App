import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/welcome_screen.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'home_page.dart';
import 'event_list_page.dart';
import 'profile_page.dart';
import 'my_pledged_gifts_page.dart';
import 'database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signup_screen.dart';
import 'package:flutter/rendering.dart'; // Check for this import
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

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
      home: WelcomeScreen(), // Start with LoginSignupScreen
    );
  }
}

class MainScreen extends StatefulWidget {
  final int userId; // Accept userId as parameter

  MainScreen({required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  DatabaseService dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _syncDatabaseWithFirebase();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1,
      length: 4,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _motionTabBarController.index = 1;
      });
    });
  }

  void _syncDatabaseWithFirebase() async {
    await dbService.syncDatabasewithFirebase(widget.userId);
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
          EventListPage(userid: widget.userId, db: dbService),
          HomePage(userid: widget.userId, dbService: dbService,motionTabBarController: _motionTabBarController),
          PledgedListPage(userid: widget.userId, dbService: dbService),
          ProfilePage(userid: widget.userId, dbService: dbService),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Home",
        labels: const ["Events", "Home", "Pledged Gifts", "Profile"],
        icons: const [
          Icons.calendar_month,
          Icons.home,
          Icons.card_giftcard,
          Icons.person,
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

