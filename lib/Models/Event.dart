import 'package:hedieatyfinalproject/Models/pledges_model.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
class Event {

  DatabaseService dbService = DatabaseService();
  PledgesModel pledgesModel = PledgesModel();

  int? id;
  final String name;
  final String category;
  final DateTime date;
  final String status;
  final String location;
  final String? description;

  Event({
    this.id,
    required this.name,
    required this.status,
    required this.category,
    required this.date,
    required this.location,
    this.description,
  });

  // Factory constructor to create an Event object from a Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['eventId'],
      name: map['eventName'],
      status: map['Status'],
      description: map['description'] ?? '',
      category: map['category'],
      date: DateTime.parse(map['eventDate']),
      location: map['eventLocation'],
    );
  }

  // Method to convert an Event object into a Map (JSON representation)
  Map<String, dynamic> toJson() {
    return {
      'eventId': id,
      'eventName': name,
      'category': category,
      'eventDate': date.toIso8601String(), // Convert DateTime to ISO 8601 format
      'Status': status,
      'eventLocation': location,
      'description': description ?? '', // Use an empty string if null
    };
  }

  //   get events for user (dont return an object)
  Future<List<Map<String, dynamic>>> getEventsForUserFriends(int userId) async {
    try {
      // Reference to the user's events node
      final eventsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Check if the data is a Map (Firebase often uses Map<dynamic, dynamic>)
        if (snapshot.value is Map) {
          // Convert the snapshot value to Map<String, dynamic>
          final events = (snapshot.value as Map).values.map((event) {
            // Ensure dynamic types are cast to Map<String, dynamic>
            return Map<String, dynamic>.from(event as Map);
          }).toList();

          return events;
        } else if (snapshot.value is List) {
          // If the data is a List, convert each item to Map<String, dynamic>
          final events = (snapshot.value as List)
              .map((event) => Map<String, dynamic>.from(event as Map))
              .toList();

          return events;
        } else {
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
  // Get all events for a user
  Future<List<Event>> getAllEventsForUser(int userId) async {
    final myData = await dbService.db;
    var result = await myData.rawQuery(
        'SELECT * FROM Events WHERE userID = $userId');
    return result.map((event) => Event.fromMap(event)).toList();
  }

  Future<List<Map<String, dynamic>>> getEventsForUser(int userId) async {
    final myData = await dbService.db;
    return await myData.rawQuery('SELECT * FROM Events WHERE userID = $userId');
  }

  // Delete events for user
  Future<void> deleteEventsForUser(int userId,
      List<Event> eventsToDelete) async {
    final myData = await dbService.db;
    for (var event in eventsToDelete) {
      await myData.rawDelete("DELETE FROM Events WHERE eventId = ${event.id}");
    }
    // await deleteEventsForUserinFirebase(userId, eventsToDelete);

  }

  Future<void> deleteEventsForUserinFirebase(int userId,
      List<Event> eventsToDelete) async {
    try {
      await pledgesModel.deletePldegedGiftsForUser(userId, eventsToDelete);
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Convert the snapshot value to Map<String, dynamic>
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");
          for (var eventToDelete in eventsToDelete) {
            // Iterate through the map to find the key with the matching eventId
            String? keyToDelete;
            // loop on each element in the eventsmap and check if the event id is equal to the event id to delete
            eventsMap.forEach((key, value) {
              if (value['eventId'] == eventToDelete.id) {
                keyToDelete = key;
              }
            });

            if (keyToDelete != null) {
              // Delete the event with the matching key
              await dbRef.child(keyToDelete!).remove();
              print(
                  "Deleted event with key $keyToDelete for eventId ${eventToDelete
                      .id}");
            } else {
              print("No matching event found for eventId ${eventToDelete.id}");
            }
          }
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          // Handle the case where the value is a list (in case of other data formats)
          final rawEvents = snapshot.value as List;

          // Iterate through the list to find the matching eventId
          for (var eventToDelete in eventsToDelete) {
            String? keyToDelete;
            for (var eventData in rawEvents) {
              print("eventData is $eventData");
              if (eventData is Map) {
                print("yes it is a map");
                print("event data type is ${eventData.runtimeType}");
                if (eventData['eventId'] == eventToDelete.id) {
                  keyToDelete = rawEvents.indexOf(eventData).toString();
                }
              }
              else {
                print("Unexpected event data format: $eventData");
              }
            }

            if (keyToDelete != null) {
              // Delete the event with the matching key
              await dbRef.child(keyToDelete).remove();
              print(
                  "Deleted event with key $keyToDelete for eventId ${eventToDelete
                      .id}");
            } else {
              print("No matching event found for eventId ${eventToDelete.id}");
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error deleting events for user $userId: $e");
      throw e;
    }
  }


  // Update event for user
  Future<void> updateEventForUser(int userId, Event event) async {
    final myData = await dbService.db;

    // Use parameterized query to avoid syntax issues and SQL injection
    await myData.rawUpdate(
        'UPDATE Events SET eventName = ?, category = ?, eventDate = ?, eventLocation = ?, description = ?, Status = ? WHERE userID = ? and eventId = ?',
        [
          event.name,
          event.category,
          event.date.toString(),
          event.location,
          event.description,
          event.status,
          userId,
          event.id,
        ]
    );
    // await updateEventForUserinFirebase(event, userId);

  }

  Future<void> updateEventForUserinFirebase(Event event, int userId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          // Convert the snapshot value to Map<String, dynamic>
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");

          // Iterate through the events map to find the matching eventId
          String? keyToUpdate;
          eventsMap.forEach((key, value) {
            if (value['eventId'] == event.id) {
              keyToUpdate = key;
            }
          });

          if (keyToUpdate != null) {
            // Prepare the updated event data
            final updatedEventData = {
              'eventId': event.id,
              'eventName': event.name,
              'eventLocation': event.location,
              'eventDate': (event.date).toString(),
              'category': event.category,
              'description': event.description,
              // Include other attributes you want to update here
            };

            // Update the event data with the matching key
            await dbRef.child(keyToUpdate!).update(updatedEventData);
            print(
                "Updated event with key $keyToUpdate for eventId ${event.id}");
          } else {
            print("No matching event found for eventId ${event.id}");
          }
        } else if (snapshot.value is List) {
          print("snapshot value in update event is list");
          // Handle the case where the value is a list (in case of other data formats)
          final rawEvents = snapshot.value as List;

          // Iterate through the list to find the matching eventId
          String? keyToUpdate;
          for (var eventData in rawEvents) {
            if (eventData is Map) {
              if (eventData['eventId'] == event.id) {
                keyToUpdate = rawEvents.indexOf(eventData).toString();
              }
            }
          }

          if (keyToUpdate != null) {
            // Prepare the updated event data
            final updatedEventData = {
              'eventId': event.id,
              'eventName': event.name,
              'eventLocation': event.location,
              'eventDate': (event.date).toString(),
              'category': event.category,
              'description': event.description,
              // Include other attributes you want to update here
            };

            // Update the event with the matching key
            await dbRef.child(keyToUpdate).update(updatedEventData);
            print(
                "Updated event with key $keyToUpdate for eventId ${event.id}");
          } else {
            print("No matching event found for eventId ${event.id}");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error updating events for user $userId: $e");
      throw e;
    }
  }

  // Add event for user
  Future<int> addEventForUser(int userId, Event event) async {
    final myData = await dbService.db;

    int Eventid = await myData.rawInsert(
        "INSERT INTO Events (eventName, category, eventDate, eventLocation, description, Status, userID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [
          event.name,
          event.category,
          event.date.toString(),
          event.location,
          event.description,
          event.status,
          userId
        ]);
    // await addEventForUserinFirebase(event, userId, Eventid);
    return Eventid;
  }


  Future<void> addEventForUserinFirebase(Event event, int userId,
      EventId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");

      // get the ids of all the events in this user node and set the new event with the highest id+1
      // but first check if event is list , if so set the id to the length +1
      // but if its a map set the id to the last key +1
      int EventId_for_firebase = 0;

      final DataSnapshot snapshot = await dbRef.get();
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          final List<int> eventIds = eventsMap.keys.map((e) => int.parse(e))
              .toList();
          EventId_for_firebase =
          eventIds.isEmpty ? 1 : eventIds.reduce((value, element) => value >
              element ? value : element) + 1;
        } else if (snapshot.value is List) {
          final List<dynamic> rawEvents = snapshot.value as List;
          EventId_for_firebase = rawEvents.length;
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      }
      else {
        EventId_for_firebase = 0;
      }

      // Add the event to the user's events list
      await dbRef.child("${EventId_for_firebase}").set({
        'eventId': EventId,
        'eventName': event.name,
        'category': event.category,
        'eventDate': event.date.toString(),
        'eventLocation': event.location,
        'description': event.description,
        'Status': event.status,
      });
    } catch (e) {
      print("Error adding event: $e");
      throw e;
    }
  }
  //     get event by gift id
  Future<Map<String, dynamic>> getEventByGiftId(int giftId) async {
    final myData = await dbService.db;
    var result = await myData.rawQuery(
        'SELECT * FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId)');

    return result.first;
  }
Future <void> UpdateEventStatusBasedOnTodaysDate(int userid, int eventid) async {
    print("Updating event status based on today's date for event $eventid");
  UpdateEventStatusBasedOnTodaysDateinDatabase(userid, eventid);
  final dbRef = FirebaseDatabaseHelper.getReference("Users/$userid/events");
  final DataSnapshot snapshot = await dbRef.get();
  if (snapshot.exists) {
    if (snapshot.value is Map) {
      final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
      eventsMap.forEach((key, value) {
        if (value['eventId'] == eventid) {
          DateTime eventDate = DateTime.parse(value['eventDate']);
          print("event date is $eventDate");
          if (DateTime.now().isAfter(eventDate)) {
            print("event is past");
            dbRef.child(key).update({'Status': 'past'});
          }
          else if (DateTime
              .now()
              .day == eventDate.day &&
              DateTime
                  .now()
                  .month == eventDate.month &&
              DateTime
                  .now()
                  .year == eventDate.year) {
            print("event is current");
            dbRef.child(key).update({'Status': 'Current'});
          }
          else {
            print("event is upcoming");
            dbRef.child(key).update({'Status': 'Upcoming'});
          }
        }
      });
    } else if (snapshot.value is List) {
      final rawEvents = snapshot.value as List;
      for (var eventData in rawEvents) {
        if (eventData is Map) {
          if (eventData['eventId'] == eventid) {
            DateTime eventDate = DateTime.parse(eventData['eventDate']);
            print("event date is $eventDate");
            if (DateTime.now().isAfter(eventDate)) {
              print("event is past");
              dbRef.child(rawEvents.indexOf(eventData).toString())
                  .update({'Status': 'past'});
            }
            //   then check if today is the same date of the event date (date only not time)
            //   if so update the status to current
            else if (DateTime
                .now()
                .day == eventDate.day &&
                DateTime
                    .now()
                    .month == eventDate.month &&
                DateTime
                    .now()
                    .year == eventDate.year) {
              print("event is current");
              dbRef.child(rawEvents.indexOf(eventData).toString())
                  .update({'Status': 'current'});
            }
            else {
              print("event is upcoming");
              dbRef.child(rawEvents.indexOf(eventData).toString())
                  .update({'Status': 'upcoming'});
            }
          }
        }
      }
    } else {
      print("Unexpected data format: ${snapshot.value}");
    }
  } else {
    print("No events found for user $userid.");
  }
}
  Future <void> UpdateEventStatusBasedOnTodaysDateinDatabase(int userid, int eventid) async{
  //   update event status based on todays date in database (sqlite)
  final myData = await dbService.db;
  var result = await myData.rawQuery(
      'SELECT * FROM Events WHERE userID = $userid and eventId = $eventid');
  if (result.isNotEmpty) {
    final event = Event.fromMap(result.first);
    if (DateTime.now().isAfter(event.date)) {
      await myData.rawUpdate(
          'UPDATE Events SET Status = ? WHERE userID = ? and eventId = ?',
          ['past', userid, eventid]);
    }
    else if (DateTime.now().day == event.date.day &&
        DateTime.now().month == event.date.month &&
        DateTime.now().year == event.date.year) {
      await myData.rawUpdate(
          'UPDATE Events SET Status = ? WHERE userID = ? and eventId = ?',
          ['Current', userid, eventid]);
    }
    else {
      await myData.rawUpdate(
          'UPDATE Events SET Status = ? WHERE userID = ? and eventId = ?',
          ['Upcoming', userid, eventid]);
    }
  }
  else {
    print("No events found for user $userid.");
  }

  }
  Future <void> initializeEvents() async{
  //   get events from firebase and update their statuses
    final dbRef = FirebaseDatabaseHelper.getReference("Users");
    final DataSnapshot snapshot = await dbRef.get();
    if (snapshot.exists) {
      if (snapshot.value is List) {
        final usersList = snapshot.value as List;
        for (var userEntry in usersList) {
          if (userEntry==null){
            continue;
          }
          final eventsRef = FirebaseDatabaseHelper.getReference("Users/${userEntry['userid']}/events");
          final DataSnapshot eventsSnapshot = await eventsRef.get();

          if (eventsSnapshot.exists) {
            if (eventsSnapshot.value is Map) {
              final eventsMap = Map<String, dynamic>.from(eventsSnapshot.value as Map);

              for (var eventEntry in eventsMap.entries) {
                DateTime eventDate = DateTime.parse(eventEntry.value['eventDate']);
                await UpdateEventStatusBasedOnTodaysDate(userEntry['userid'], eventEntry.value['eventId']);
              }
            } else if (eventsSnapshot.value is List) {
              final rawEvents = eventsSnapshot.value as List;

              for (var eventData in rawEvents) {
                if (eventData is Map) {
                  DateTime eventDate = DateTime.parse(eventData['eventDate']);
                  await UpdateEventStatusBasedOnTodaysDate(userEntry['userid'], eventData['eventId']);
                }
              }
            } else {
              print("Unexpected data format: ${eventsSnapshot.value}");
            }
          } else {
            print("No events found for user ${userEntry}.");
          }
        }
      } else {
        print("Unexpected data format: ${snapshot.value}");
      }
    }
    else {
      print("No users found.");
    }



  }

}
