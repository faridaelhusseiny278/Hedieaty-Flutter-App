import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:intl/intl.dart';
import '../Models/friend_event.dart';
import 'friends_gift_list.dart';
import '../Models/Event.dart';
import '../Controllers/friend_event_controller.dart';
import '../Controllers/event_controller.dart';

class FriendsEventList extends StatefulWidget {
  final Map<String, dynamic> frienddata;
  final int userid;
  DatabaseService dbService = DatabaseService();

  FriendsEventList({required this.frienddata, required this.userid, required this.dbService});

  @override
  _FriendsEventListState createState() => _FriendsEventListState();
}

class _FriendsEventListState extends State<FriendsEventList> {
  bool selectAll = false;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  List<friendEvent> selectedEvents = [];
  late List<friendEvent> events;


  FriendEventController friendEventController = FriendEventController();
  EventController eventController = EventController();

  @override
  void initState() {
    super.initState();
    _loadEvents();

  }
  void _loadEvents() async {
    try {
      final userId = widget.frienddata['userid'];
      final eventList = await friendEventController.getAllEventsForUserFriends(userId);

      // Using a for loop to process the events (if needed)
      List<friendEvent> eventsLoaded = [];
      for (var event in eventList) {
        eventsLoaded.add(event);
      }

      // Update state
      setState(() {
        events = eventsLoaded;
        isLoading = false;
      });
    } catch (e) {
      // Handle potential errors
      print("Error loading events: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedEvents = value ? List.from(events) : [];
    });
  }

  void _toggleEventSelection(friendEvent event) {
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
    if (isLoading) {
      // Show loading indicator while data is loading
      return Center(child: CircularProgressIndicator());
    }
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

  Widget _buildEventCard(friendEvent event) {
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
        borderRadius: BorderRadius.circular(20.0), // Softer, more rounded corners
      ),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1), // Subtle shadow
      child: InkWell(
        onTap: () {
          _toggleEventSelection(event);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendsGiftList(
                event: event,
                userid: widget.userid,
                dbService: widget.dbService,
                friendid: widget.frienddata['userid'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0), // More padding for spacious look
          child: SingleChildScrollView(  // Wrap content in a SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // friendEvent name with bigger font size and bold style
                Text(
                  event.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700, // Bold weight for name
                    fontSize: 20, // Larger font size
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,  // Prevent overflow
                  maxLines: 1,  // Limit to one line if the text is too long
                ),
                SizedBox(height: 12), // Space between name and other info
                // Category and status with smaller font size and color for subtlety
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.deepPurple, size: 18),
                    SizedBox(width: 8),
                    Flexible(  // Ensure text can flex if too long
                      child: Text(
                        event.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,  // Prevent overflow
                      ),
                    ),
                    SizedBox(width: 20), // Space between category and status
                    Icon(statusIcon, color: statusColor, size: 18), // Dynamic status icon
                    SizedBox(width: 8),
                    Flexible(  // Ensure text can flex if too long
                      child: Text(
                        // set the event status based on todays date
                        event.status,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,  // Prevent overflow
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
                    Flexible(  // Ensure text can flex if too long
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,  // Prevent overflow
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

