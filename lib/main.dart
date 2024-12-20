import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Controllers/event_controller.dart';
import 'package:hedieatyfinalproject/Controllers/user_controller.dart';
import 'package:hedieatyfinalproject/Views/welcome_screen.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'Views/home_page.dart';
import 'Views/event_list_page.dart';
import 'Views/profile_page.dart';
import 'Views/my_pledged_gifts_page.dart';
import 'database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart'; // Check for this import
import 'package:hedieatyfinalproject/Models/Notification.dart';
import 'Controllers/NotificationService.dart';
import 'firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Controllers/firebasedatabase_helper.dart';
void main() async {
  print("Starting app");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseDatabaseHelper.initializeDatabase();

  // FirebaseDatabase.instance.goOffline();
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseService dbService = DatabaseService();
  UserController userController = UserController();
  if (currentUser == null) {
    runApp(MaterialApp(
      home: WelcomeScreen(),
    ));
    return;
  }
  int userid = await userController.getUserIdByEmailFromFirebase((currentUser!.email)!);
  // call get user by id for friends
  Map<String, dynamic>? user= await userController.getUserByIdforFriends(userid);


  await FirebaseApi().initNotifications();

  debugPaintSizeEnabled = false;
  runApp(MyApp(isLoggedIn: currentUser != null
      , userid: userid, dbService: dbService, user: user!));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int userid;
  final DatabaseService dbService;
  final Map<String, dynamic> user;
  const MyApp({required this.isLoggedIn, required this.userid, required this.dbService, required this.user});

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
         MainScreen(userId: userid, user: user): WelcomeScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int userId; // Accept userId as parameter
  bool testing;
  Map<String, dynamic> user;

  MainScreen({required this.userId, this.testing = false, this.user = const {}});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  DatabaseService dbService = DatabaseService();
  String? _headerNotification;
  bool _showHeaderNotification = false;
  List<AppNotification> _notificationQueue = [];
  bool PushNotifications = false;
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    print("initializing main screen");
    _initializeEvents();
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
    _loadStoredNotifications();
    _getUserNotificationPreferences();

  }
  Future <void> _initializeEvents() async {
    print("initializing events");
    EventController eventController = EventController();
    await eventController.initializeEvents();
  }

  Future<void> _getUserNotificationPreferences() async
  {
    UserController userController = UserController();
    bool notif = await userController.getUserNotificationPreferences(widget.userId);
    setState(() {
      print("setting state of push notifications to $notif for user ${widget.userId}");
      PushNotifications = notif;
    });

  }
  // void _syncDatabaseWithFirebase() async {
  //   await dbService.syncDatabasewithFirebase(widget.userId);
  // }
  Future<void> _loadStoredNotifications() async {
    final AppNotificationService _notificationService =
    AppNotificationService(userid: widget.userId);
    List<AppNotification> notifications = await _notificationService.getNotifications();

    setState(() {
      _notificationQueue = notifications;
    });

    // Show notifications sequentially after a delay
    _showNotificationsSequentially();

  }

  Future<void> _showNotificationsSequentially() async {
    final AppNotificationService _notificationService =
    AppNotificationService(userid: widget.userId);

    for (var notification in _notificationQueue) {
      if (notification.isSent== true) {
        continue;
      }
      // Wait for a small duration before showing the next notification
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        // set the notification as sent in the firebase
        notification.isSent = true;
        print("marking notification as sent");
        _notificationService.markNotificationAsSent(notification);
        _headerNotification = notification.message;
        _showHeaderNotification = true;
      });

      // Auto-hide the notification after 3 seconds
      await Future.delayed(Duration(seconds: 3));

      setState(() {
        _showHeaderNotification = false;
      });
    }

    // Clear the queue after processing
    setState(() {
      _notificationQueue.clear();
    });
  }
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
              PushNotifications= await userController.getUserNotificationPreferences(widget.userId);
              if (gift['pledged'] == true && gift['notificationSent'] == false && PushNotifications) {
                print("now sending notification to user ${widget
                    .userId} who has push notif in notification preferences ${PushNotifications}");
                String message =
                    '${gift['giftName']} has been pledged for the event ${event['eventName']}!';
                // check if message is not already in the notifications
                List<
                    AppNotification> notificationsList = await _notificationService
                    .getNotifications();
                // Add to your local notification service
                if (!notificationsList.any((element) =>
                element.message == message)) {
                  await _notificationService.addNotification(AppNotification(
                    message: message,
                    timestamp: DateTime.now(),
                    isSent: false,
                  ));
                }
                else {
                  print("notification already exists");
                }


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
            labels: const ["Events", "Home", "Pledged", "Profile"],
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
              duration: Duration(milliseconds: 300),  // Smoother transition
              curve: Curves.easeOut,  // Smooth out the animation
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.9), // Slightly transparent background
                  borderRadius: BorderRadius.circular(8),  // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 24),  // Slightly smaller icon
                    SizedBox(width: 12),  // Reduced space for a tighter fit
                    Expanded(
                      child: Text(
                        _headerNotification ?? 'You have a new notification!',
                        style: TextStyle(
                          color: Colors.white,  // White text for better contrast
                          fontSize: 14,  // Slightly smaller font size for a cleaner look
                          fontWeight: FontWeight.w500, // Regular weight to look less heavy
                          height: 1.3,
                        ),
                        softWrap: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 18),
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
