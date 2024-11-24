import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'friends_gift_list.dart';

class FriendsEventList extends StatefulWidget {
  final Map<String, dynamic> frienddata;

  FriendsEventList({Key? key, required this.frienddata}) : super(key: key);

  @override
  _FriendsEventListState createState() => _FriendsEventListState();
}

class _FriendsEventListState extends State<FriendsEventList> {
  bool selectAll = false;
  final ScrollController _scrollController = ScrollController();

  List<Event> selectedEvents = [];
  late List<Event> events;

  @override
  void initState() {
    super.initState();
    events = (widget.frienddata['events'] as List).map((eventData) {
      return Event(
        name: eventData['eventName'],
        category: eventData['category'],
        status: eventData['Status'],
        date: DateTime.parse(eventData['eventDate']),
        location: eventData['eventLocation'],
        gifts: eventData['gifts']
      );
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "${widget.frienddata['name']}'s Events",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
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
      color: Colors.deepPurple[50],
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
              builder: (context) => FriendsGiftList(gifts: event.gifts,eventname:event.name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),  // More padding for spacious look
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSortOptions() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Sort by Name'),
            onTap: () {
              _sortEvents('Name');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sort by Category'),
            onTap: () {
              _sortEvents('Category');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sort by Status'),
            onTap: () {
              _sortEvents('Status');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class Event {
  final String name;
  final String category;
  final String status;
  final DateTime date;
  final String location;
  final List<Map<String, dynamic>> gifts;

  Event({
    required this.name,
    required this.category,
    required this.status,
    required this.date,
    required this.location,
    required this.gifts
  });
}
