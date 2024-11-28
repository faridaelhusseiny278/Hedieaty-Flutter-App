import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
// import 'home_page.dart';
import 'event_list_page.dart';
// import 'profile_page.dart';
// import 'my_pledged_gifts_page.dart';
import 'database.dart';

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
  DatabaseService dbService = DatabaseService();
  List data = [];

  @override
  void initState() {

    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0, // Set initial index to 0 for the first tab
      length: 4,
      vsync: this,
    );



  }
  Future readmyData(tableName) async{
    List<Map> Response = await dbService.readData("SELECT * from $tableName");
    data.addAll(Response);
    print(data);
    if (this.mounted){
      setState(() {
      });
    }

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
          EventListPage(userid: 1, db: dbService),
          // HomePage(userid: 1, dbService: dbService),
          // PledgedListPage(userid: 1, dbService: dbService),
          // ProfilePage(userid: 1, dbService: dbService),
          EventListPage(userid: 1, db: dbService),
          EventListPage(userid: 1, db: dbService),
          EventListPage(userid: 1, db: dbService),

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
