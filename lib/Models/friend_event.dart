import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';


class friendEvent {
  int? id;
  final String name;
  final String category;
  final DateTime date;
  final String status;
  final String location;
  final String? description;
  final List<Map<String, dynamic>> gifts;

  friendEvent({
    this.id,
    required this.name,
    required this.status,
    required this.category,
    required this.date,
    required this.location,
    this.description,
    required this.gifts

  });
  factory friendEvent.fromMap(Map<String, dynamic> map) {
    return friendEvent(
        id: map['eventId'],
        name: map['eventName'],
        status: map['Status'],
        description: map['description']??'',
        category: map['category'],
        date: DateTime.parse(map['eventDate']),
        location: map['eventLocation'],
        gifts: map['gifts']
    );
  }
  Future<List<friendEvent>> getAllEventsForUserFriends(int userId) async {
    try {
      // Reference to the user's events node
      final eventsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Check if the data is a Map (Firebase often uses Map<dynamic, dynamic>)
        if (snapshot.value is Map) {
          print("snapshot value is map");
          // Convert the snapshot value to Map<String, dynamic>
          final events = (snapshot.value as Map).values.map((event) {
            // Ensure dynamic types are cast to Map<String, dynamic>
            print("event is $event");
            return friendEvent.fromMap(Map<String, dynamic>.from(event as Map));
          }).toList();
          print("events are $events");

          return events;
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;
          print("rawEvents are $rawEvents");

          // Iterate through each event and log it
          for (var i = 0; i < rawEvents.length; i++) {
            print("rawEvents[i] is ${rawEvents[i]}");
            if (rawEvents[i] == null) {
              continue;
            }
            if (rawEvents[i]['gifts'] == null) {
              rawEvents[i]['gifts'] = [];
            }
            // ignore nulls
            else if (rawEvents[i]['gifts'] is List) {
              rawEvents[i]['gifts'] = (rawEvents[i]['gifts'] as List)
                  .where((gift) => gift != null) // Exclude null elements
                  .map((gift) {
                // Safely convert each non-null gift to a map
                return Map<String, dynamic>.from(gift as Map);
              }).toList();
            }

            else if (rawEvents[i]['gifts'] is Map) {
              print("gifts is map");
              rawEvents[i]['gifts'] =
              Map<String, dynamic>.from(rawEvents[i]['gifts'] as Map);
            }
          }

          final events = rawEvents
              .where((event) => event != null) // Exclude null events
              .map((event) {
            try {
              // Ensure event is a Map<String, dynamic>
              final eventMap = Map<String, dynamic>.from(event as Map);

              // Normalize 'gifts' to always be a list of maps
              if (eventMap['gifts'] is List) {
                eventMap['gifts'] = (eventMap['gifts'] as List)
                    .where((gift) => gift is Map) // Exclude non-map entries
                    .map((gift) => Map<String, dynamic>.from(gift as Map))
                    .toList();
              } else if (eventMap['gifts'] == null) {
                eventMap['gifts'] = []; // Ensure 'gifts' is not null
              }

              // Pass the normalized event to the fromMap method
              return friendEvent.fromMap(eventMap);
            } catch (e) {
              print("Error processing event: $event, error: $e");
              return null; // Skip problematic events
            }
          }).whereType<friendEvent>() // Remove nulls from the final list
              .toList();

          print("Processed events: $events");
          return events;
        }
        else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      } else {
        print("No events found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching events for user $userId: $e");
      throw e;
    }
  }
}
