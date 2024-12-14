import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/event_list_page.dart';
import 'database.dart';
import 'Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:motion_tab_bar/MotionTabBarController.dart';


class CreateEventPage extends StatefulWidget {
  final int userid;



  CreateEventPage({required this.userid});
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  DatabaseService dbService = DatabaseService();
  List<Map<String, dynamic>> actions = [];
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  String category = 'Birthday'; // Default category
  String status = 'Current'; // Default status

  Future<void> saveActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final currentActionsString = prefs.getString('user_${widget.userid.toString()}_events_actions');
    print("currentActionsString in event list is  : $currentActionsString");
    await prefs.setString('user_${widget.userid.toString()}_events_actions', jsonEncode(actions));
    print("currentActions in event list is after saving  : ${prefs.getString('user_${widget.userid.toString()}_events_actions')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: eventDateController,
              decoration: InputDecoration(
                labelText: 'Event Date',
                hintText: 'YYYY-MM-DD',
              ),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: eventLocationController,
              decoration: InputDecoration(labelText: 'Event Location'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(labelText: 'Category'),
              items: ['Birthday', 'Wedding', 'Anniversary', 'Other']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(labelText: 'Status'),
              items: ['Current', 'Upcoming', 'Past']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Event',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() async {
    Event newEvent = Event(
      name: eventNameController.text,
      date: DateTime.parse(eventDateController.text),
      location: eventLocationController.text,
      category: category,
      status: status,
      description: '',
    );
    int eventid= await dbService.addEventForUser(
      widget.userid,
      newEvent
    );
    newEvent.id=eventid;
    actions.add({
      'action': 'add',
      'event': newEvent.toJson()
    });
    saveActions(actions);
    print("added event $newEvent");
    // widget.motionTabBarController.index = 1;
    Navigator.pop(context); // Go back to HomePage
    // Navigator.pop(context);

  }





}
