import 'package:flutter/material.dart';
// Import all the pages here
import 'home_page.dart';
import 'event_list_page.dart';
import 'gift_list_page.dart';
import 'gift_details_page.dart';
import 'my_pledged_gifts_page.dart';
import 'profile_page.dart';

void main() => runApp(MaterialApp(
  // Set the initial page
  initialRoute: '/home', // Default page when the app starts
  theme: ThemeData(
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Color(0xFF3A3A3A),
      secondary: Color(0xFFB3E5FC),
    ),
  ),
  routes: {
    // Define routes for each page
    '/home': (context) => HomePage(),
    '/gifts': (context) => GiftListPage(),
    '/events': (context) => EventListPage(),
    '/pledged_gifts': (context) => PledgedListPage(),
    '/profile': (context) => ProfilePage(),
  },
));
