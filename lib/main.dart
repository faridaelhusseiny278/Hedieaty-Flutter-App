import 'package:flutter/material.dart';
import 'home_page.dart';
import 'event_list_page.dart';

void main() => runApp(MaterialApp(
  home: CalendarPage(),
  theme: ThemeData(
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Color(0xFF3A3A3A),
      secondary: Color(0xFFB3E5FC),
    ),
  ),
));
