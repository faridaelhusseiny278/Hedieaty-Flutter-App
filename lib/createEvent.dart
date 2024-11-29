import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/event_list_page.dart';
import 'database.dart';
import 'Event.dart';

class CreateEventPage extends StatefulWidget {
  final int userid;

  CreateEventPage({required this.userid});
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  DatabaseService dbService = DatabaseService();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  String category = 'Birthday'; // Default category
  String status = 'Current'; // Default status

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
    print("added event $newEvent");
    // Navigate to the EventListPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(userid: widget.userid, db: dbService),
      ),
    );
  }





}
