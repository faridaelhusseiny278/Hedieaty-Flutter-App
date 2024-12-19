
import 'package:hedieatyfinalproject/Models/user_model.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
import 'package:hedieatyfinalproject/Models/pledges_model.dart';
import 'package:hedieatyfinalproject/Models/Event.dart';

class PledgesController{
  DatabaseService dbService = DatabaseService();
  UserModel userModel = UserModel();
  PledgesModel pledgesModel = PledgesModel();
  Event EventModel = Event(
      id: 0,
      name: '',
      date: DateTime.now(),
      location: '',
      status: '',
      category: '',
      description: '',

  );

//   check if user id has pledged a gift id
  Future<bool> hasPledgedGift(int userId, int giftId) async {
    try {
      // Reference to the user's pledged gifts node
      final pledgedGiftsRef =
      FirebaseDatabaseHelper.getReference("Users/$userId/pledgedgifts");

      // Fetch the snapshot of the pledged gifts
      final DataSnapshot snapshot = await pledgedGiftsRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        print("snapshot value is map");
        final pledgedGiftsMap = snapshot.value as Map;
        print("pledgedGiftsMap is $pledgedGiftsMap");

        for (var userKey in pledgedGiftsMap.keys) {
          print("userKey is $userKey");
          print("pledgedGiftsMap[userKey] is ${pledgedGiftsMap[userKey]}");
          final userGifts = pledgedGiftsMap[userKey] as List;
          print("userGifts is $userGifts");

          // Check if the giftId exists in the nested structure
          for (var giftKey in userGifts) {
            if (giftKey == giftId) {
              return true; // Gift ID found
            }
          }
        }
        return false; // Gift ID not found
      } else if (snapshot.exists && snapshot.value is List<Object?>) {
        print("snapshot value is list");
        // Handle case where snapshot is a List
        final pledgedGiftsList = snapshot.value as List<Object?>;

        for (var entry in pledgedGiftsList) {
          if (entry is Map) {
            print("yes it is a map");
            // Check each map entry
            for (var userGifts in entry.values) {
              if (userGifts == giftId) {
                return true;
              }
            }
          }
          else if (entry is List) {
            print("yes it is a list");
            for (var userGifts in entry) {
              if (userGifts == giftId) {
                return true;
              }
            }
          }
        }
        return false; // Gift ID not found
      } else {
        print("Unexpected data structure for pledgedgifts: ${snapshot.value}");
        return false; // Structure is invalid or empty
      }
    } catch (e) {
      print("Error checking pledged gift for user $userId: $e");
      throw e;
    }
  }
  Future<List<Map<String, dynamic>>> getPledgedGiftsWithDetailsfromDatabase(
      int userId) async {
    final myData = await dbService.db;
    List<Map<String, dynamic>> pledgedGiftsWithDetails = [];
    var pledgedGifts = await pledgesModel.getUserPledgedGifts(userId);
    print("pledged gifts for user $userId are $pledgedGifts");
    for (var gift in pledgedGifts) {
      var event = await EventModel.getEventByGiftId(gift['giftid']);
      var friend = await userModel.getUserbyGift(gift['giftid']);
      print("friend who has the gift is $friend");
      pledgedGiftsWithDetails.add({
        "giftid": gift['giftid'],
        "giftName": gift['giftName'],
        "category": gift['category'],
        "price": gift['price'],
        "imageurl": gift['imageurl'],
        "description": gift['description'],
        "pledged": gift['pledged'],
        "eventName": event!['eventName'],
        "eventDate": event['eventDate'],
        "friendName": friend!['name'],
        "friendImageUrl": friend['imageurl'],
        "friendId": friend['userid'],
      });
    }
    return pledgedGiftsWithDetails;
  }

  Future<List<Map<String, dynamic>>> getPledgedGiftsWithDetailsfromfirebase(
      int userId) async {
    try {
      // Reference to the user's pledged gifts node
      final pledgedGiftsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/pledgedgifts");

      // Fetch the snapshot of the pledged gifts
      final DataSnapshot pledgedGiftsSnapshot = await pledgedGiftsRef.get();

      // Prepare the result list
      List<Map<String, dynamic>> pledgedGiftsWithDetails = [];

      if (pledgedGiftsSnapshot.exists) {
        if (pledgedGiftsSnapshot.value is Map) {
          print("pledgedgiftsnapshot is a map, ${pledgedGiftsSnapshot.value}");
          final pledgedGiftsMap = pledgedGiftsSnapshot.value as Map;

          // Iterate through friends in the pledged gifts map
          for (var friendId in pledgedGiftsMap.keys) {
            final friendGifts = pledgedGiftsMap[friendId] as List;
            print("friendGifts are $friendGifts");

            // Fetch friend details
            final friendRef = FirebaseDatabaseHelper.getReference(
                "Users/$friendId");
            final DataSnapshot friendSnapshot = await friendRef.get();

            if (friendSnapshot.exists && friendSnapshot.value is Map) {
              print("friendsnapshot is a map, ${friendSnapshot.value}");
              final friendData = friendSnapshot.value as Map;
              final String friendName = friendData["name"] ?? "Unknown";
              final String friendImageUrl = friendData["imageurl"] ?? "";
              final int friendId = friendData["userid"];

              // Fetch friend's events
              final eventsRef = friendRef.child("events");
              final DataSnapshot eventsSnapshot = await eventsRef.get();

              if (eventsSnapshot.exists && eventsSnapshot.value is List) {
                final eventsList = eventsSnapshot.value as List;

                // Iterate through events
                for (var eventIndex = 0; eventIndex <
                    eventsList.length; eventIndex++) {
                  final eventData = eventsList[eventIndex];

                  // Skip null entries
                  if (eventData == null) continue;

                  if (eventData is Map && eventData.containsKey("gifts") &&
                      eventData["gifts"] is List) {
                    final giftsList = eventData["gifts"] as List;

                    // Iterate through gifts in the event
                    for (var giftIndex = 0; giftIndex <
                        giftsList.length; giftIndex++) {
                      final giftData = giftsList[giftIndex];

                      // Skip null entries
                      if (giftData == null) continue;

                      // Check if the gift is pledged by the user
                      final uniqueGiftId = friendGifts.firstWhere(
                              (key) => key == giftData["giftid"],
                          orElse: () => null);

                      if (uniqueGiftId != null) {
                        // Add gift details to the result list
                        pledgedGiftsWithDetails.add({
                          "giftid": giftData["giftid"],
                          "giftName": giftData["giftName"],
                          "category": giftData["category"],
                          "pledged": giftData["pledged"],
                          "friendName": friendName,
                          "friendImageUrl": friendImageUrl,
                          "friendId": friendId,
                          "eventName": eventData["eventName"],
                          "eventDate": eventData["eventDate"],
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        } else if (pledgedGiftsSnapshot.value is List) {
          print("pledgedgiftsnapshot is a list, ${pledgedGiftsSnapshot.value}");
          final pledgedGiftsList = pledgedGiftsSnapshot.value as List;

          for (var giftIds in pledgedGiftsList) {
            print("giftIds is $giftIds");
            if (giftIds == null) continue;
            // Get the index of the current element
            final friendIdIndex = pledgedGiftsList.indexOf(giftIds);

            // Fetch friend details
            final friendRef = FirebaseDatabaseHelper.getReference(
                "Users/$friendIdIndex");
            final DataSnapshot friendSnapshot = await friendRef.get();

            if (friendSnapshot.exists && friendSnapshot.value is Map) {
              print("friendsnapshot is a map, ${friendSnapshot.value}");
              final friendData = friendSnapshot.value as Map;
              final String friendName = friendData["name"] ?? "Unknown";
              final String friendImageUrl = friendData["imageurl"] ?? "";
              final int friendId = friendData["userid"];

              // Fetch friend's events
              final eventsRef = friendRef.child("events");
              final DataSnapshot eventsSnapshot = await eventsRef.get();

              if (eventsSnapshot.exists && eventsSnapshot.value is List) {
                // print("eventsnapshot is a list, ${eventsSnapshot.value}");
                final eventsList = eventsSnapshot.value as List;

                // Iterate through events
                for (var eventIndex = 0; eventIndex <
                    eventsList.length; eventIndex++) {
                  final eventData = eventsList[eventIndex];

                  // Skip null entries
                  if (eventData == null) continue;

                  if (eventData is Map && eventData.containsKey("gifts") &&
                      eventData["gifts"] is List) {
                    // print("eventData is a map, ${eventData["gifts"]}");
                    if (eventData['gifts'] == null) {
                      continue;
                    }
                    final giftsList = eventData["gifts"] as List;
                    // print("giftsList is $giftsList");

                    // Iterate through gifts in the event
                    for (var giftIndex = 0; giftIndex <
                        giftsList.length; giftIndex++) {
                      final giftData = giftsList[giftIndex];
                      // print("giftdata is $giftData");
                      // Skip null entries
                      if (giftData == null) {continue;}
                      print("giftData is $giftData");
                      print("giftids is $giftIds");

                      // Check if the gift is pledged by the user
                      // check if the gift id is in the list which is called giftids
                      final uniqueGiftId = giftIds.firstWhere(
                              (key) => key == giftData["giftid"],
                          orElse: () => null);

                      print("uniqueGiftId is $uniqueGiftId");

                      if (uniqueGiftId != null) {
                        // Add gift details to the result list
                        pledgedGiftsWithDetails.add({
                          "giftid": giftData["giftid"],
                          "giftName": giftData["giftName"],
                          "category": giftData["category"],
                          "pledged": giftData["pledged"],
                          "friendName": friendName,
                          "friendImageUrl": friendImageUrl,
                          "friendId": friendId,
                          "eventName": eventData["eventName"],
                          "eventDate": eventData["eventDate"],
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        }
        return pledgedGiftsWithDetails;
      }
      else {
        print("No pledged gifts found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching pledged gifts with details for user $userId: $e");
      throw e;
    }
  }
  Future <int> getWhoHasPledgedGiftfromFirebase(int userId, int giftId) async {
    return await pledgesModel.getWhoHasPledgedGiftfromFirebase(userId, giftId);
  }
  Future <void> deletePldegedGiftsForUser(int userId,
      List<Event> eventsToDelete) async {
    return await pledgesModel.deletePldegedGiftsForUser(userId, eventsToDelete);
  }
  Future<List<Map<String, dynamic>>> getUserPledgedGifts(int userId) async {
    return await pledgesModel.getUserPledgedGifts(userId);
  }
  Future <int> getPledges(int giftid) async {
    return await pledgesModel.getPledges(giftid);
  }
  Future<int> getPledgesFromFirebase(int giftid) async {
    return await pledgesModel.getPledgesFromFirebase(giftid);
  }
  Future<void> deletePledge(int userId, int giftId) async {
    return await pledgesModel.deletePledge(userId, giftId);
  }


}