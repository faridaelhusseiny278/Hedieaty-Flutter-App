import 'package:hedieatyfinalproject/Models/gift_model.dart';
import 'package:hedieatyfinalproject/Models/user_model.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
class GiftController{
  DatabaseService dbService = DatabaseService();
  UserModel userModel = UserModel();
  GiftModel giftModel = GiftModel();

  Future<void> unpledgeGift(int userId, int giftId) async {
    final myData = await dbService.db;
    await myData.rawQuery(
        'DELETE FROM Pledges WHERE userID = $userId AND giftID = $giftId');
    //   make the gift status false
    await myData.rawQuery(
        'UPDATE Gifts SET pledged = 0 WHERE giftid = $giftId');
  }


  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEventFriends(int eventId,
      int userId) async {
    try {
      // Reference to the user's events node
      final eventsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Convert the snapshot data to a list of maps
          final events = (snapshot.value as Map).values.map((event) {
            return Map<String, dynamic>.from(event as Map);
          }).toList();
          print("events are $events for user $userId, it's a map");
          // print("event id is $eventId");

          // Loop through all events and find the event with the matching eventId
          for (var event in events) {
            if (event == null) {
              continue;
            }
            if (event['eventId'] == eventId) {
              if (event['gifts'] == null) {
                continue;
              }
              // Ensure the 'gifts' key exists and is a list of maps
              if (event['gifts'] is List) {
                return (event['gifts'] as List).map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else if (event['gifts'] is Map) {
                return (event['gifts'] as Map).values.map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else {
                print(
                    "Gifts for event $eventId are not in the expected format.");
                return [];
              }
            }
          }
        } else if (snapshot.value is List) {
          // Handle the case where the snapshot value is a List
          final events = (snapshot.value as List).map((event) {
            return Map<String, dynamic>.from(event as Map);
          }).toList();
          print("events are $events for user $userId, its a list");
          // print("event id is $eventId");

          // Loop through all events and find the event with the matching eventId
          for (var event in events) {
            if (event == null) {
              continue;
            }

            // print("event gifts are ${event['gifts']}");
            if (event['eventId'] == eventId) {
              print("event['gifts'] is ${event['gifts']}");
              if (event['gifts'] == null) {
                continue;
              }
              // Ensure the 'gifts' key exists and is a list of maps
              if (event['gifts'] is List) {
                print("yes it is a list");
                //   filter nulls first
                return (event['gifts'] as List)
                    .where((element) =>
                element != null &&
                    element is Map) // Exclude null and non-Map elements
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
              }
              else if (event['gifts'] is Map) {
                print("yes it is a map");
                //   filter nulls first
                return (event['gifts'] as Map).values
                    .where((element) =>
                element != null &&
                    element is Map) // Exclude null and non-Map elements
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
              }
              else {
                print(
                    "Gifts for event $eventId are not in the expected format.");
                return [];
              }
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }

        // If no event with the given eventId is found
        print("Event with ID $eventId not found for user $userId.");
        return [];
      }
      else {
        print("No events found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching gifts for event $eventId: $e");
      throw e;
    }
  }


  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final myData = await dbService.db;
    return await myData.rawQuery(
        'SELECT * FROM Gifts WHERE eventID = $eventId');
  }
  Future<int> addGiftForUser(Map<String, dynamic> gift, int userId) async {
    return await giftModel.addGiftForUser(gift, userId);
  }
  Future<void> addGiftForUserinFirebase(Map<String, dynamic> gift, int userId,
      int giftId) async {
    return await giftModel.addGiftForUserinFirebase(gift, userId, giftId);
  }
  Future<void> updateGiftForUser(Map<String, dynamic> gift, int giftid,
      int userId) async {
    return await giftModel.updateGiftForUser(gift, giftid, userId);
  }
  Future<void> updateGiftStatusindatabase(int giftId, bool status, int userId,
      int friendId) async {
    return await giftModel.updateGiftStatusindatabase(giftId, status, userId,
        friendId);
  }
  Future<void> updateGiftStatus(int giftId, bool status, int userId,
      int friendId) async {
    return await giftModel.updateGiftStatus(giftId, status, userId, friendId);
  }
  Future<void> deleteGiftsForUser(int giftId,int userId,int eventid) async {
    return await giftModel.deleteGiftsForUser(giftId, userId, eventid);
  }
  Future<void> deleteGiftsForUserinFirebase(int giftId, int userId, int eventId) async {
    return await giftModel.deleteGiftsForUserinFirebase(giftId, userId, eventId);
  }

  Future<void> updateGiftForUserinFirebase(Map<String, dynamic> gift,
      int giftid, int userId) async {
    return await giftModel.updateGiftForUserinFirebase(gift, giftid, userId);
  }
  

}