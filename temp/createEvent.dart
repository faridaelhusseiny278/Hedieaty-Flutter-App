import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/event_list_page.dart';

class CreateEventPage extends StatefulWidget {
  final int userid;
  final List<Map<String, dynamic>> Database;
  CreateEventPage({required this.userid, required this.Database});
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  String category = 'Birthday'; // Default category
  String status = 'Active'; // Default status

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
              items: ['Active', 'Completed', 'Pending']
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

  void _createEvent() {
    List<Map<String, dynamic>> giftList = [];
    // Create the new event as a map
    final newEvent = {
      'eventId': _generateEventId(widget.Database, widget.userid),
      'eventName': eventNameController.text,
      'eventDate': eventDateController.text,
      'eventLocation': eventLocationController.text,
      'category': category,
      'Status': status,
      'gifts': giftList
    };

    // Find the user by `userid` in the database
    final user = widget.Database.firstWhere((user) => user['userid'] == widget.userid, orElse: () => {});
    print("user is $user");
    if (user != null) {
      // Add the new event to the user's list of events
      if (user['events'] != null) {
        user['events'].add(newEvent);
      } else {
        user['events'] = [newEvent];
      }
    } else {
      // If user is not found, you might want to handle the error case here
      print('User with ID ${widget.userid} not found in the database.');
    }
    print("added event $newEvent");
    // Navigate to the EventListPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(userid: widget.userid, Database: widget.Database),
      ),
    );
  }

// Helper function to generate a unique event ID
  int _generateEventId(List<Map<String, dynamic>> database, int userid) {
    final user = database.firstWhere(
          (user) => user['userid'] == userid,
      orElse: () => {}, // Default empty user if not found
    );

    print("user is $user");

    if (user != null && user['events'] != null && user['events'].isNotEmpty) {
      // Create a list of eventIds ensuring they are integers
      List<int> eventIds = [];

      for (var event in user['events']) {
        final eventId = event['eventId'];
        if (eventId is int) {
          eventIds.add(eventId); // Add eventId if it's already an int
        } else if (eventId is String) {
          final parsedId = int.tryParse(eventId); // Try to parse the eventId if it's a string
          if (parsedId != null) {
            eventIds.add(parsedId); // Add parsed eventId
          } else {
            print("Failed to parse eventId: $eventId");
          }
        } else {
          print("Unexpected type for eventId: $eventId");
        }
      }

      if (eventIds.isNotEmpty) {
        final maxEventId = eventIds.reduce((a, b) => a > b ? a : b);
        print('Maximum Event ID for user $userid: $maxEventId');
        return maxEventId + 1; // Increment to generate a new ID
      } else {
        print('No valid event IDs found for user $userid.');
      }
    } else {
      print('No events found for user $userid. Returning default ID: 1');
    }
    return 1; // Default to 1 if no events exist for the user
  }



}
