import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Controllers/event_controller.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'gift_list_page.dart';
import 'package:intl/intl.dart';
import '../Models/Event.dart';
import 'eventForm.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class EventStatus {
  final IconData icon;
  final Color color;

  EventStatus(this.icon, this.color);


}

class EventListPage extends StatefulWidget {
  final int userid;
  DatabaseService db = DatabaseService();
  EventListPage({required this.userid, required this.db});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<EventListPage> {
  EventController eventController = EventController();

  List<Map<String, dynamic>> actions = [];
  Event? highlightedEvent;
  DateTime selectedDate = DateTime.now();
  DateTime firstDayOfMonth = DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, 1);
  DateTime lastDayOfMonth = DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month + 1, 0);
  bool showCalendar = true;
  bool selectAll = false;
  final ScrollController _scrollController = ScrollController();
  bool loading = true;

  List<Event> selectedEvents = [];
  List<Event> DeletedEvents = [];
  late List<Event> events=[];

  @override
  void initState() {
    super.initState();

    _initializeEvents();

    _loadActions(widget.userid).then((value) {
      // Directly assign the list returned from _loadActions
      actions = value ?? [];
    });
  }
  Future<void> deleteActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_${widget.userid.toString()}_events_actions');
  }


  Future<List<Map<String, dynamic>>> _loadActions(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    // if (prefs.getString('user_${widget.userid.toString()}_events_actions') != null) {
    //   await prefs.remove('user_${widget.userid.toString()}_events_actions');
    // }
    final jsonString = prefs.getString('user_${userId.toString()}_events_actions');
    setState(() {
      loading = false;
    });
    print("jsonString in event list is : $jsonString");
    return jsonString != null
        ? List<Map<String, dynamic>>.from(jsonDecode(jsonString))
        : [];
  }


  Future<void> _initializeEvents() async {
    // Fetch events asynchronously
    final fetchedEvents = await eventController.getAllEventsForUser(widget.userid);
    // print id of each event
    fetchedEvents.forEach((element) {
    });

    // Update the events variable
    setState(() {
      events = fetchedEvents;
    });
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedEvents = value ? List.from(events) : [];
    });
  }

  void _toggleEventSelection(Event event) {
    setState(() {
      if (selectedEvents.contains(event)) {
        selectedEvents.remove(event);
      } else {
        selectedEvents.add(event);
      }
    });
  }

  void _sortEvents(String criteria) {
    setState(() {
      if (criteria == 'Name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == 'Category') {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == 'Status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  Future<void> saveActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final currentActionsString = prefs.getString('user_${widget.userid.toString()}_events_actions');
    print("currentActionsString in event list is  : $currentActionsString");
    await prefs.setString('user_${widget.userid.toString()}_events_actions', jsonEncode(actions));
    print("currentActions in event list is after saving  : ${prefs.getString('user_${widget.userid.toString()}_events_actions')}");
  }

  void _addOrEditEvent({Event? event}) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final modalHeight = screenHeight - keyboardHeight;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: EventForm(
          event: event,
          onSave: (newEvent) async {
            // Perform asynchronous work outside of setState
            if (event == null) {
              // Adding a new event
              int eventId = await eventController.addEventForUser(widget.userid, newEvent);
              if (eventId > 0) {
                // Set the generated ID from the database
                newEvent.id = eventId;
                actions.add({
                  'action': 'add',
                  'event': newEvent.toJson()
                });
                // call save actions
                saveActions(actions);

                // Update the local list
                setState(() {
                  events.add(newEvent);
                });
              } else {
                print("Error adding event to the database.");
              }
            }
            else {
              // Modifying an existing event
              int index = events.indexOf(event);
              events[index] = newEvent;
              actions.add({
                'action': 'update',
                'oldEvent': event.toJson(),
                'newEvent': newEvent.toJson()
              });
              // call save actions
              saveActions(actions);


              // Update the event in the database
              await eventController.updateEventForUser(widget.userid, newEvent);

                print("Event updated successfully.");

              // Update the local list synchronously after the operation is complete
              setState(() {
                events[index] = newEvent;
              });
            }

            // Close the modal bottom sheet
            Navigator.pop(context);
          },
        ),
      ),
    );
  }



  void _publishToFirebase() async {

   for (var action in actions) {
      if (action['action'] == 'add') {
        // convert event json to event object
        await eventController.addEventForUserinFirebase(Event.fromMap(action['event']),widget.userid, action['event']['eventId']);

      } else if (action['action'] == 'update') {
        await eventController.updateEventForUserinFirebase(Event.fromMap(action['newEvent']), widget.userid);
      } else if (action['action'] == 'delete') {
        print("delete event ${action}");
        for (var event in action['events']) {
          DeletedEvents.add(Event.fromMap(event));
        }
        await eventController.deleteEventsForUserinFirebase(widget.userid, DeletedEvents);
        DeletedEvents.clear();
      }
    }
   actions.clear();
    deleteActions(actions);
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text("Events published in Firebase successfully!")),
   );
  }



  void _deleteSelectedEvents() async {
    // Remove selected events from the database
    await eventController.deleteEventsForUser(widget.userid, selectedEvents);
    actions.add({
      'action': 'delete',
      'events': selectedEvents.map((event) => event.toJson()).toList()
    });
    // call save actions
    saveActions(actions);


    setState(() {
      events.removeWhere((event) => selectedEvents.contains(event));
      // copy the selected events to the deleted events list (deep copy)
      selectedEvents.clear();
      selectAll = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    if (loading){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    DateTime today = DateTime.now();
    List<DateTime> dates = [];
    for (int i = 0; i <= lastDayOfMonth.day - firstDayOfMonth.day; i++) {
      dates.add(firstDayOfMonth.add(Duration(days: i)));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        leading: null,
        elevation: 0,
        title: Text(
          "My Events",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => setState(() => showCalendar = !showCalendar),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => _buildSortOptions(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Publish Button
            ElevatedButton(
              onPressed: _publishToFirebase, // Call your publish function here
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button background color
                foregroundColor: Colors.white, // Button text color
                padding: EdgeInsets.symmetric(vertical: 16.0), // Larger button height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
              ),
              child: Text(
                'Publish Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 16.0), // Spacing between button and list
            // Events List View
            Expanded(child: _buildEventsListView()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }




  Widget _buildEventsListView() {
    return ListView(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Event event) {
    bool isSelected = selectedEvents.contains(event);

    // Determine the icon based on the event status
    final eventStatus = _getEventStatus(event.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.deepPurple[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          _toggleEventSelection(event);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftListPage(eventid: event.id!, userid: widget.userid),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleEventSelection(event),
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
              Text(
                event.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category, color: Colors.deepPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    event.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(eventStatus.icon, color: eventStatus.color, size: 18),
                  SizedBox(width: 8),
                  Text(
                    event.status,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 8),
                  // Use Expanded or Flexible here
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.calendar_today, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  // Use Expanded or Flexible here as well
                  Expanded(
                    child: Text(
                      DateFormat.yMMMd().format(event.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () => _addOrEditEvent(event: event),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepPurple,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper function for determining event status
  EventStatus _getEventStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return EventStatus(Icons.access_time, Colors.orange);
      case 'current':
        return EventStatus(Icons.check_circle, Colors.green);
      case 'past':
        return EventStatus(Icons.history, Colors.grey);
      default:
        return EventStatus(Icons.help_outline, Colors.blueGrey);
    }
  }






  Widget _buildSortOptions() {
    return ListView(
      shrinkWrap: true,
      children: ['Name', 'Category', 'Status'].map((criteria) {
        return ListTile(
          title: Text(criteria),
          onTap: () {
            _sortEvents(criteria);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.deepPurple),
            onPressed: () => _addOrEditEvent(),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: selectedEvents.isNotEmpty ? Colors.deepPurple : Colors
                  .grey,
            ),
            onPressed: selectedEvents.isNotEmpty
                ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Events'),
                    content: Text(
                        'Are you sure you want to delete the selected events?'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteSelectedEvents();
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            }
                : null,
          ),
        ],
      ),
    );
  }
}




