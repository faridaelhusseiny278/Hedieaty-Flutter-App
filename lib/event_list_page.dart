import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/gift_list_page.dart';
import 'package:intl/intl.dart';
import 'Event.dart';

class EventListPage extends StatefulWidget {
  final int userid;
  final List<Map<String, dynamic>> Database;
  EventListPage({required this.userid, required this.Database});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<EventListPage> {
  Event? highlightedEvent;
  DateTime selectedDate = DateTime.now();
  DateTime firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool showCalendar = true;
  bool selectAll = false;
  final ScrollController _scrollController = ScrollController();

  List<Event> selectedEvents = [];
  late List<Event> events;

  @override
  void initState() {
    super.initState();

    // Filter user data based on userid
    final userData = widget.Database.firstWhere(
          (user) => user['userid'] == widget.userid,
      orElse: () => {}, // Return null if no user is found
    );

    // Check if userData is found
    if (userData != null) {
      events = (userData['events'] as List).map((eventData) {
        return Event(
          name: eventData['eventName'],
          category: eventData['category'],
          status: eventData['Status'],
          date: DateTime.parse(eventData['eventDate']),
          location: eventData['eventLocation'],
          gifts: eventData['gifts'],
        );
      }).toList();
    } else {
      // If no user data is found, initialize an empty list of events
      events = [];
    }
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

  void _addOrEditEvent({Event? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventForm(
        event: event,
        onSave: (newEvent) {
          setState(() {
            if (event == null) {
              events.add(newEvent);
            } else {
              int index = events.indexOf(event);
              events[index] = newEvent;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteSelectedEvents() {
    setState(() {
      events.removeWhere((event) => selectedEvents.contains(event));
      selectedEvents.clear();
      selectAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<DateTime> dates = [];
    for (int i = 0; i <= lastDayOfMonth.day - firstDayOfMonth.day; i++) {
      dates.add(firstDayOfMonth.add(Duration(days: i)));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
        child: _buildEventsListView(),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: highlightedEvent == event ? Colors.deepPurple[100] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      shadowColor: Colors.grey.withOpacity(0.2),
      elevation: 6,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onTap: () {
          print("event is $event");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftListPage(event: event),
            ),
          );
        },
        onLongPress: () {
          setState(() {
            highlightedEvent = highlightedEvent == event ? null : event; // Toggle highlight
          });
        },
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggleEventSelection(event),
          activeColor: Colors.deepPurple,
        ),
        title: Text(
          event.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.category} • ${event.status}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '${event.location} • ${event.date.toLocal().hour}:${event.date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.deepPurple,
          size: 18,
        ),
      ),
    );
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
              color: highlightedEvent != null ? Colors.deepPurple : Colors.grey,
            ),
            onPressed: highlightedEvent != null
                ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Event'),
                    content: Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            events.remove(highlightedEvent);
                            highlightedEvent = null; // Clear highlight
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
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



class EventForm extends StatelessWidget {
  final Event? event;
  final Function(Event) onSave;

  EventForm({this.event, required this.onSave});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _statusController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (event != null) {
      _nameController.text = event!.name;
      _categoryController.text = event!.category;
      _statusController.text = event!.status;
      _locationController.text = event!.location;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a status';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text(event == null ? 'Add Event' : 'Save Changes'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newEvent = Event(
                    name: _nameController.text,
                    category: _categoryController.text,
                    status: _statusController.text,
                    date: event?.date ?? DateTime.now(),
                    location: _locationController.text,
                    gifts: []
                  );
                  onSave(newEvent);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}