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
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieatyfinalproject/Notification.dart';
import 'NotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebasedatabase_helper.dart';

void main() async {
  print("Starting app");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseDatabaseHelper.initializeDatabase();
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseService dbService = DatabaseService();
  int userid = await dbService.getUserIdByEmailFromFirebase((currentUser!.email)!);


  await FirebaseApi().initNotifications();

  debugPaintSizeEnabled = false;
  runApp(MyApp(isLoggedIn: currentUser != null
      , userid: userid, dbService: dbService));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int userid;
  final DatabaseService dbService;
  const MyApp({required this.isLoggedIn, required this.userid, required this.dbService});

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
      home: isLoggedIn ?
         MainScreen(userId: userid): WelcomeScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int userId; // Accept userId as parameter
  bool testing;

  MainScreen({required this.userId, this.testing = false});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  DatabaseService dbService = DatabaseService();
  String? _headerNotification;
  bool _showHeaderNotification = false;

  @override
  void initState() {
    super.initState();
    // _syncDatabaseWithFirebase();
    _startFirebaseListener();
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

  // void _syncDatabaseWithFirebase() async {
  //   await dbService.syncDatabasewithFirebase(widget.userId);
  // }

  void _startFirebaseListener() {
    final AppNotificationService _notificationService =
    AppNotificationService(userid: widget.userId);
    final dbRef =
    FirebaseDatabaseHelper.getReference("Users/${widget.userId}/events");

    dbRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data != null) {
        if (data is List) {
          final List eventList = data as List;
          for (var event in eventList) {
            if (event == null) {
              continue;
            }
            if (event['gifts'] == null) {
              continue;
            }
            final List giftList = event['gifts'] as List;
            for (var gift in giftList) {
              if (gift == null) {
                continue;
              }
              if (gift['pledged'] == true && gift['notificationSent'] == false) {
                String message =
                    '${gift['giftName']} has been pledged for the event ${event['eventName']}!';

                // Add to your local notification service
                await _notificationService.addNotification(AppNotification(
                  message: message,
                  timestamp: DateTime.now(),
                ));

                // Update database to avoid duplicate notifications
                dbRef
                    .child(eventList.indexOf(event).toString())
                    .child('gifts')
                    .child(giftList.indexOf(gift).toString())
                    .update({'notificationSent': true});


                // Show the notification as a header

                setState(() {
                  _headerNotification = message;
                  _showHeaderNotification = true;
                });

                // Auto-hide the notification after 3 seconds
                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    _showHeaderNotification = false;
                  });
                });
              }
            }
          }
        }
      }
    });
  }



  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: TabBarView(
            controller: _motionTabBarController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              EventListPage(userid: widget.userId, db: dbService),
              HomePage(userid: widget.userId, dbService: dbService, motionTabBarController: _motionTabBarController, testing: widget.testing),
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
        ),
        // Add header notification here
        if (_showHeaderNotification)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: _showHeaderNotification ? Offset(0, 0) : Offset(0, -1),
              duration: Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple, // Fully opaque color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _headerNotification ?? 'You have a new notification!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Slightly bolder
                          fontFamily: 'Roboto', // Use a clean and modern font
                          height: 1.4,
                        ),
                        softWrap: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          _showHeaderNotification = false;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),



      ],
    );
  }

}
