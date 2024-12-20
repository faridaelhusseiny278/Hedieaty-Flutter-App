import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
import 'package:hedieatyfinalproject/Models/Event.dart';

class EventController{
  DatabaseService dbService = DatabaseService();
  Event event_model = Event (
    id: 0,
    name: '',
    date: DateTime.now(),
    location: '',
    category: '',
    status: '',
  );


  // get event count for user
  Future<int> getEventCountForUserFriends(String userId) async {
    try {
      // Reference to the user's events node
      final eventsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/events");

      // Fetch the snapshot of the events
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Count the number of events
        if (snapshot.value is List) {
          final eventCount = (snapshot.value as List).length;
          print("Event count for user $userId: $eventCount");
          return eventCount;
        } else if (snapshot.value is Map) {
          final eventCount = (snapshot.value as Map).length;
          print("Event count for user $userId: $eventCount");
          return eventCount;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return 0;
        }
      } else {
        print("No events found for user $userId.");
        return 0;
      }
    } catch (e) {
      print("Error fetching events for user $userId: $e");
      throw e;
    }
  }
  // check if event exists in firebase given an event id and user id
  Future<bool> doesEventExistInFirebase(int eventId, int userId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          for (var event in eventsMap.values) {
            if (event['eventId'] == eventId) {
              return true;
            }
          }
          return false;
        }
        else if (snapshot.value is List) {
          final rawEvents = snapshot.value as List;
          for (var event in rawEvents) {
            if (event is Map && event['eventId'] == eventId) {
              return true;
            }
          }
          return false;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return false;
        }
      } else {
        print("No events found for user $userId.");
        return false;
      }
    } catch (e) {
      print("Error checking event existence: $e");
      throw e;
    }
  }
  Future<List<Map<String, dynamic>>> getEventsForUserFriends(int userId) async{
    return await event_model.getEventsForUserFriends(userId);
  }
  Future<List<Event>> getAllEventsForUser(int userId) async{
    return await event_model.getAllEventsForUser(userId);
  }
  Future<List<Map<String, dynamic>>> getEventsForUser(int userId) async {
    return await event_model.getEventsForUser(userId);
  }
  Future<void> deleteEventsForUser(int userId,
      List<Event> eventsToDelete) async {
    return await event_model.deleteEventsForUser(userId, eventsToDelete);
  }
  Future<void> deleteEventsForUserinFirebase(int userId,
      List<Event> eventsToDelete) async {
    return await event_model.deleteEventsForUserinFirebase(userId, eventsToDelete);
  }
  Future<void> updateEventForUser(int userId, Event event) async {
    return await event_model.updateEventForUser(userId, event);
  }
  Future<void> updateEventForUserinFirebase(Event event, int userId) async {
    return await event_model.updateEventForUserinFirebase(event, userId);
  }
  Future<int> addEventForUser(int userId, Event event) async {
    return await event_model.addEventForUser(userId, event);
  }
  Future<void> addEventForUserinFirebase(Event event, int userId,
      EventId) async {
    return await event_model.addEventForUserinFirebase(event, userId, EventId);
  }
  Future<Map<String, dynamic>> getEventByGiftId(int giftId) async {
    return await event_model.getEventByGiftId(giftId);
  }

  Future <void> UpdateEventStatusBasedOnTodaysDate(int userid, int eventid) async {
    return await event_model.UpdateEventStatusBasedOnTodaysDate(userid, eventid);
  }
  Future <void> UpdateEventStatusBasedOnTodaysDateinDatabase(int userid, int eventid) async {
    return await event_model.UpdateEventStatusBasedOnTodaysDateinDatabase(userid, eventid);
  }
  Future <void> initializeEvents() async {
    return await event_model.initializeEvents();
  }
}
