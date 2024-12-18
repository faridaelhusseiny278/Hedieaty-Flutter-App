import 'package:flutter/material.dart';
import 'database.dart';
import 'Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


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
  DateTime? _selectedDate;
  String category = 'Birthday'; // Default category
  String status = 'Current'; // Default status
  String? nameError;
  String? locationError;

  Future<void> saveActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final currentActionsString = prefs.getString('user_${widget.userid.toString()}_events_actions');
    print("currentActionsString in event list is  : $currentActionsString");
    await prefs.setString('user_${widget.userid.toString()}_events_actions', jsonEncode(actions));
    print("currentActions in event list is after saving  : ${prefs.getString('user_${widget.userid.toString()}_events_actions')}");
  }

  // validate event name
  void _validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        nameError = 'Name cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z\s]{3,50}$").hasMatch(name)) {
        nameError = 'Enter a valid name (3-50 alphabetic characters)';
      } else {
        nameError = null;
      }
    });
  }
  // validate event location
  void _validateLocation(String location) {
    setState(() {
      if (location.isEmpty) {
        locationError = 'Location cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z0-9\s]{3,50}$").hasMatch(location)) {
        locationError = 'Enter a valid location (3-50 alphanumeric characters)';
      } else {
        locationError = null;
      }
    });
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name', errorText: nameError),
                onChanged: _validateName,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${DateFormat.yMMMd().format(_selectedDate!)}'
                          : 'Event Date',
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis, // Add ellipsis if the text overflows
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          eventDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate); // Sync with controller
                        });
                      }
                    },
                    child: Text('Select Date', style: TextStyle(fontSize: 14)), // Smaller font size
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: Size(100, 36), // Width: 100, Height: 36
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Smaller padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: eventLocationController,
                decoration: InputDecoration(labelText: 'Event Location', errorText: locationError),
                onChanged: _validateLocation,
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
                  onPressed: () {
                    if (nameError != null || locationError != null) {
                      // Show a SnackBar with the error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(nameError ?? locationError ?? 'Please fix the errors'),
                          backgroundColor: Colors.red, // Set the background color to red for errors
                        ),
                      );
                    } else if (eventNameController.text.isEmpty || eventDateController.text.isEmpty || eventLocationController.text.isEmpty) {
                      // Show a SnackBar if any of the fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.orange, // Set the background color to orange for missing fields
                        ),
                      );
                    } else {
                      // If no errors, create the event
                      _createEvent();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (nameError == null && locationError == null &&
                        eventNameController.text.isNotEmpty && eventDateController.text.isNotEmpty && eventLocationController.text.isNotEmpty)
                        ? Colors.deepPurple
                        : Colors.grey, // Greyed out color when disabled
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Event',
                    style: TextStyle(
                      fontSize: 16,
                      color: (nameError == null && locationError == null)
                          ? Colors.white
                          : Colors.black38, // Dimmed text when disabled
                    ),
                  ),
                ),


              ),
            ],
          ),
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
