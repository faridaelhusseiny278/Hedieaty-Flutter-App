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
              // Adding a new event
              events.add(newEvent);

              // Add the new event to the database as well
              final userIndex = widget.Database.indexWhere((user) => user['userid'] == widget.userid);
              if (userIndex != -1) {
                widget.Database[userIndex]['events'].add({
                  'eventName': newEvent.name,
                  'category': newEvent.category,
                  'Status': newEvent.status,
                  'eventDate': newEvent.date.toIso8601String(),
                  'eventLocation': newEvent.location,
                  'gifts': newEvent.gifts,
                });
              }
            } else {
              // Modifying an existing event
              int index = events.indexOf(event);
              events[index] = newEvent;

              // Update the event in the database as well
              final userIndex = widget.Database.indexWhere((user) => user['userid'] == widget.userid);
              if (userIndex != -1) {
                final userEvents = widget.Database[userIndex]['events'] as List;

                // Find the index of the event to modify
                final eventIndex = userEvents.indexWhere((eventData) => eventData['eventName'] == event.name);
                if (eventIndex != -1) {
                  userEvents[eventIndex] = {
                    'eventName': newEvent.name,
                    'category': newEvent.category,
                    'Status': newEvent.status,
                    'eventDate': newEvent.date.toIso8601String(),
                    'eventLocation': newEvent.location,
                    'gifts': newEvent.gifts,
                  };
                }
              }
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }


  void _deleteSelectedEvents() {
    setState(() {
      // Remove selected events from the UI events list
      events.removeWhere((event) => selectedEvents.contains(event));

      // Remove selected events from the user's events in the widget.Database
      final userIndex = widget.Database.indexWhere((user) => user['userid'] == widget.userid);
      if (userIndex != -1) {
        final userData = widget.Database[userIndex];
        final userEvents = userData['events'] as List;

        // Remove the selected events from the user's events list
        userEvents.removeWhere((eventData) =>
            selectedEvents.any((event) => eventData['eventName'] == event.name)
        );

        // Update the database with the new events list
        widget.Database[userIndex]['events'] = userEvents;
      }

      // Clear the selected events and reset selectAll flag
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

    // Determine the icon based on the event status
    IconData statusIcon;
    Color statusColor;

    switch (event.status.toLowerCase()) {
      case 'upcoming':
        statusIcon = Icons.access_time;  // Clock icon for upcoming events
        statusColor = Colors.orange;     // Orange color for upcoming
        break;
      case 'current':
        statusIcon = Icons.check_circle; // Check circle icon for current events
        statusColor = Colors.green;      // Green color for current
        break;
      case 'past':
        statusIcon = Icons.history;     // History icon for past events
        statusColor = Colors.grey;       // Grey color for past
        break;
      default:
        statusIcon = Icons.help_outline; // Default icon if status is unknown
        statusColor = Colors.blueGrey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.deepPurple[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),  // Softer, more rounded corners
      ),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),  // Subtle shadow
      child: InkWell(
        onTap: () {
          _toggleEventSelection(event);
          print("event gifts is ${event.gifts}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftListPage(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),  // More padding for spacious look
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox on the left for selection
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
              // Event name with bigger font size and bold style
              Text(
                event.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700, // Bold weight for name
                  fontSize: 20, // Larger font size
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12), // Space between name and other info
              // Category and status with smaller font size and color for subtlety
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
                  SizedBox(width: 20), // Space between category and status
                  Icon(statusIcon, color: statusColor, size: 18), // Dynamic status icon
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
              SizedBox(height: 12), // Space between category/status and location/date
              // Location and date
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    event.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 20), // Space between location and date
                  Icon(Icons.calendar_today, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().format(event.date), // Formatted date
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12), // Space between info and action buttons
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () => _addOrEditEvent(event: event), // Pass the selected event
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



class EventForm extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;

  EventForm({this.event, required this.onSave});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _statusController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _categoryController.text = widget.event!.category;
      _statusController.text = widget.event!.status;
      _locationController.text = widget.event!.location;
      _selectedDate = widget.event!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            DropdownButtonFormField<String>(
              value: _statusController.text.isNotEmpty
                  ? _statusController.text
                  : null,
              decoration: InputDecoration(labelText: 'Status'),
              items: ['Upcoming', 'Current', 'past']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                _statusController.text = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a status';
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
            Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'
                      : 'No date selected',
                  style: TextStyle(fontSize: 16),
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
                      });
                    }
                  },
                  child: Text('Select Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text(widget.event == null ? 'Add Event' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newEvent = Event(
                    name: _nameController.text,
                    category: _categoryController.text,
                    status: _statusController.text,
                    date: _selectedDate ?? DateTime.now(),
                    location: _locationController.text,
                    gifts: [],
                  );
                  widget.onSave(newEvent);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

