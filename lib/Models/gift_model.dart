import 'package:hedieatyfinalproject/Models/user_model.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
import '../Models/Event.dart';
class GiftModel{
  DatabaseService dbService = DatabaseService();
  UserModel userModel = UserModel();
  // Add gift for user
  Future<int> addGiftForUser(Map<String, dynamic> gift, int userId) async {
    final myData = await dbService.db;
    int id = await myData.rawInsert(
        "INSERT INTO Gifts (giftName, category, price, imageurl, description, pledged, eventID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [
          gift['giftName'],
          gift['category'],
          gift['price'],
          gift['imageurl'],
          gift['description'],
          gift['pledged'],
          gift['eventID']
        ]);

    // await addGiftForUserinFirebase(gift, userId,id);
    return id;
  }

  Future<void> addGiftForUserinFirebase(Map<String, dynamic> gift, int userId,
      int giftId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      int giftId_for_firebase = 0;

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);

          // Find the event associated with the provided eventID
          String? eventKey;
          eventsMap.forEach((key, value) {
            if (value is Map && value['eventId'] == gift['eventID']) {
              eventKey = key;
              if (value['gifts'] == null) {
                giftId_for_firebase = 0;
              } else {
                giftId_for_firebase = value['gifts'].length;
              }
            }
          });

          if (eventKey != null) {
            // Add the gift to the 'gifts' list under the specified event
            await dbRef.child("$eventKey/gifts/${giftId_for_firebase}").set({
              'giftid': giftId,
              'giftName': gift['giftName'],
              'category': gift['category'],
              'price': gift['price'],
              'imageurl': gift['imageurl'],
              'description': gift['description'],
              'pledged': gift['pledged'],
              'notificationSent': false
            });
            print(
                "Added gift with ID $giftId to event ${gift['eventID']} for user $userId");
          } else {
            print(
                "No matching event found for eventID ${gift['eventID']} for user $userId");
          }
        }
        else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;

          String? eventIndex;
          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event['eventId'] == gift['eventID']) {
              eventIndex = i.toString();
              if (event['gifts'] == null) {
                giftId_for_firebase = 0;
              } else {
                giftId_for_firebase = event['gifts'].length;
              }
              break;
            }
          }

          if (eventIndex != null) {
            // Add the gift to the 'gifts' list under the specified event
            await dbRef.child("$eventIndex/gifts/${giftId_for_firebase}").set({
              'giftid': giftId,
              'giftName': gift['giftName'],
              'category': gift['category'],
              'price': gift['price'],
              'imageurl': gift['imageurl'],
              'description': gift['description'],
              'pledged': gift['pledged'],
              'notificationSent': false
            });
            print(
                "Added gift with ID $giftId to event ${gift['eventID']} for user $userId");
          } else {
            print(
                "No matching event found for eventID ${gift['eventID']} for user $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print(
          "Error adding gift with ID $giftId to event ${gift['eventID']} for user $userId: $e");
      throw e;
    }
  }

// update gift for user
  Future<void> updateGiftForUser(Map<String, dynamic> gift, int giftid,
      int userId) async {
    final myData = await dbService.db;


    // Use parameterized query to avoid syntax issues and SQL injection
    await myData.rawUpdate(
        'UPDATE Gifts SET giftName = ?, category = ?, price = ?, imageurl = ?, description = ?, pledged = ? WHERE giftid = ?',
        [
          gift['giftName'],
          gift['category'],
          gift['price'],
          gift['imageurl'],
          gift['description'],
          gift['pledged'] == true ? 1 : 0,
          giftid,
        ]
    );
    // await updateGiftForUserinFirebase(gift, giftid,userId);
    //   print the gift with id 1
    var result = await myData.rawQuery(
        'SELECT * FROM Gifts WHERE giftid = $giftid');
  }

  Future<void> updateGiftForUserinFirebase(Map<String, dynamic> gift,
      int giftid, int userId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);

          // Iterate through events to locate the gift to update
          String? eventKeyToUpdate;
          String? giftIndexToUpdate;

          eventsMap.forEach((eventKey, eventValue) {
            if (eventValue is Map && eventValue.containsKey('gifts')) {
              if (eventValue['gifts'] is List) {
                final giftsList = eventValue['gifts'] as List;
                for (var i = 0; i < giftsList.length; i++) {
                  if (giftsList[i] == null || giftsList[i] is! Map) {
                    print("giftsList[i] is null or not a map, ${giftsList[i]}");
                    continue;
                  }
                  if (giftsList[i]['giftid'] == giftid) {
                    eventKeyToUpdate = eventKey;
                    giftIndexToUpdate = i.toString();
                    break;
                  }
                }
              } else if (eventValue['gifts'] is Map) {
                final giftsMap = eventValue['gifts'] as Map;
                giftsMap.forEach((key, value) {
                  if (value == null || value is! Map) {
                    print("value is null or not a map, $value");
                    return;
                  }
                  if (value['giftid'] == giftid) {
                    eventKeyToUpdate = eventKey;
                    giftIndexToUpdate = key;
                    return;
                  }
                });
              }
            }
          });

          if (eventKeyToUpdate != null && giftIndexToUpdate != null) {
            // Update the gift data
            await dbRef
                .child("$eventKeyToUpdate/gifts/$giftIndexToUpdate")
                .update(gift);
            print(
                "Updated gift with id $giftid for userId $userId in event $eventKeyToUpdate");
          } else {
            print("No matching gift found with id $giftid for userId $userId");
          }
        } else if (snapshot.value is List) {
          print("snapshot value in update gifts is list");
          final rawEvents = snapshot.value as List;

          String? eventIndexToUpdate;
          String? giftIndexToUpdate;

          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event.containsKey('gifts')) {
              if (event['gifts'] is List) {
                final giftsList = event['gifts'] as List;
                print("gift List is $giftsList");
                for (var j = 0; j < giftsList.length; j++) {
                  if (giftsList[j] == null || giftsList[j] is! Map) {
                    print("giftsList[j] is null or not a map, ${giftsList[j]}");
                    continue;
                  }
                  if (giftsList[j]['giftid'] == giftid) {
                    print("i is $i");
                    print("i to string is ${i.toString()}");
                    eventIndexToUpdate = i.toString();
                    print("eventIndexToUpdate is $eventIndexToUpdate");
                    giftIndexToUpdate = j.toString();
                    print("giftIndexToUpdate is $giftIndexToUpdate");
                    break;
                  }
                }
              }
              else if (event['gifts'] is Map) {
                print("gifts is map");
                final giftsMap = event['gifts'] as Map;
                print("giftsMap is $giftsMap");
                giftsMap.forEach((key, value) {
                  if (value == null || value is! Map) {
                    print("value is null or not a map, $value");
                    return;
                  }
                  if (value['giftid'] == giftid) {
                    eventIndexToUpdate = i.toString();
                    giftIndexToUpdate = key;
                    return;
                  }
                });
              }
            }
          }

          if (eventIndexToUpdate != null && giftIndexToUpdate != null) {
            print("eventIndexToUpdate is $eventIndexToUpdate");
            print("giftIndexToUpdate is $giftIndexToUpdate");
            await dbRef
                .child("$eventIndexToUpdate/gifts/$giftIndexToUpdate")
                .update(gift);
            print(
                "Updated gift with id $giftid for userId $userId in event $eventIndexToUpdate");
          } else {
            print("No matching gift found with id $giftid for userId $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error updating gift for user $userId: $e");
      throw e;
    }
  }



  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final myData = await dbService.db;
    return await myData.rawQuery(
        'SELECT * FROM Gifts WHERE eventID = $eventId');
  }




  Future<void> updateGiftStatusindatabase(int giftId, bool status, int userId,
      int friendId) async {
    final myData = await dbService.db;

    await myData.rawUpdate('UPDATE Gifts SET pledged = ? WHERE giftid = ?',
        [status == true ? 1 : 0, giftId]);

    if (status) {
      await myData.rawInsert(
          'INSERT INTO Pledges (giftID, userID) VALUES (?, ?)',
          [giftId, userId]);
    } else {
      await myData.rawDelete(
          'DELETE FROM Pledges WHERE giftID = $giftId AND userID = $userId');
    }
  }

  Future<void> updateGiftStatus(int giftId, bool status, int userId,
      int friendId) async {
    // Update the gift status in the local database (assumed to be another function)
    await updateGiftStatusindatabase(giftId, status, userId, friendId);

    // Reference to the friend's events node
    final friendEventsRef = FirebaseDatabaseHelper.getReference(
        "Users/$friendId/events");

    // Fetch the snapshot of the friend's events
    final DataSnapshot eventsSnapshot = await friendEventsRef.get();

    try {
      // Check if the snapshot exists and handle it as a Map or List
      if (eventsSnapshot.exists) {
        // If the snapshot is a List
        if (eventsSnapshot.value is List) {
          print("event snapshot value is list");
          final List<dynamic> eventsList = eventsSnapshot.value as List<
              dynamic>;

          for (int eventIndex = 0; eventIndex <
              eventsList.length; eventIndex++) {
            final eventData = eventsList[eventIndex];

            if (eventData == null) continue;

            // Check if the event contains gifts
            if (eventData is Map && eventData.containsKey("gifts") &&
                eventData["gifts"] is List) {
              final giftsList = eventData["gifts"] as List;

              // Iterate through the list of gifts
              for (int giftIndex = 0; giftIndex <
                  giftsList.length; giftIndex++) {
                final giftData = giftsList[giftIndex];

                // Skip null entries
                if (giftData == null) continue;

                // Debug: Print gift data and the giftId we are looking for
                print("Gift data: $giftData");
                print("Gift ID to match in else if : $giftId");

                // Check if the giftId matches
                if (giftData is Map && giftData["giftid"] == giftId) {
                  print("yes gift data is map");
                  // Update the 'pledged' status in the friend's events node
                  await friendEventsRef
                      .child("$eventIndex/gifts/$giftIndex/pledged")
                      .set(status);
                  if (status == false) {
                    // set the notification to false
                    await friendEventsRef
                        .child("$eventIndex/gifts/$giftIndex/notificationSent")
                        .set(false);

                    //   also remove the notification which has the gift name in its message
                    final notificationsRef = FirebaseDatabaseHelper
                        .getReference("Users/$friendId/notifications");
                    final DataSnapshot notificationsSnapshot = await notificationsRef
                        .get();
                    if (notificationsSnapshot.exists) {
                      if (notificationsSnapshot.value is Map) {
                        final notificationsMap = notificationsSnapshot
                            .value as Map;
                        for (var notificationKey in notificationsMap.keys) {
                          final notificationData = notificationsMap[notificationKey];
                          if (notificationData is Map &&
                              (notificationData['message'].contains(
                                  giftData['giftName']) &&
                                  notificationData['message'].contains(
                                      eventData['eventName']))) {
                            await notificationsRef.child(notificationKey)
                                .remove();
                          }
                        }
                      }
                    }
                  }

                  // Reference to the pledged gifts for the user
                  final pledgedGiftsRef = FirebaseDatabaseHelper.getReference(
                      "Users/$userId/pledgedgifts");

                  // Fetch the pledged gifts for the user
                  final DataSnapshot pledgedGiftsSnapshot = await pledgedGiftsRef
                      .get();
                  if (pledgedGiftsSnapshot.exists) {
                    print("pledgedGiftsSnapshot exists");
                    if (pledgedGiftsSnapshot.value is List) {
                      print(
                          "pledgedGiftsSnapshot value is ${pledgedGiftsSnapshot
                              .value}");
                      final pledgedGiftsListunmodifiable = pledgedGiftsSnapshot
                          .value as List<dynamic>;
                      print(
                          "pledgedGiftsListunmodifiable is $pledgedGiftsListunmodifiable");
                      // shallow copy to another modifiable list
                      List<List<
                          dynamic>> pledgedGiftsList = pledgedGiftsListunmodifiable
                          .map((e) =>
                      e == null
                          ? <dynamic>[0]
                          : List<dynamic>.from(e as List<dynamic>))
                          .toList();
                      print("pledgedGiftsList is $pledgedGiftsList");
                      if (status) {
                        // Ensure the index exists before accessing it
                        print(
                            "now adding the gift id $giftId to the list of friend $friendId");


                        if (friendId >= pledgedGiftsList.length) {
                          await pledgedGiftsRef.child(friendId.toString()).set(
                              [giftId]);
                        }
                        else {
                          if (!pledgedGiftsList[friendId].contains(giftId)) {
                            pledgedGiftsList[friendId].add(giftId);
                            await pledgedGiftsRef.child(friendId.toString())
                                .set(
                                pledgedGiftsList[friendId]);
                          }
                        }
                      }
                      else {
                        if (friendId < pledgedGiftsList.length) {
                          print(
                              "pledgedGiftslist at the index is ${pledgedGiftsList[friendId]}");
                          pledgedGiftsList[friendId].remove(giftId);
                          print(
                              "pledgedGiftslist after removing is ${pledgedGiftsList[friendId]}");
                          await pledgedGiftsRef.child(friendId.toString()).set(
                              pledgedGiftsList[friendId]);
                        } else {
                          print("Friend ID index out of bounds.");
                        }
                      }


                      print("Gift status updated successfully.");
                      return; // Exit once the status is updated
                    }
                    else if (pledgedGiftsSnapshot.value is Map) {
                      final pledgedGiftsMapUnmodifiable = pledgedGiftsSnapshot
                          .value as Map;
                      print(
                          "pledgedGiftsMapUnmodifiable is $pledgedGiftsMapUnmodifiable");
                      Map<String,
                          dynamic> pledgedGiftsMap = pledgedGiftsMapUnmodifiable
                          .map((key, value) =>
                          MapEntry(key, value == null
                              ? <dynamic>[0]
                              : List<dynamic>.from(value as List<dynamic>)));

                      print("pledgedGiftsMap is $pledgedGiftsMap");
                      if (status) {
                        if (pledgedGiftsMap.containsKey(friendId.toString())) {
                          final List<
                              dynamic> friendGifts = pledgedGiftsMap[friendId
                              .toString()];
                          if (!friendGifts.contains(giftId)) {
                            friendGifts.add(giftId);
                            await pledgedGiftsRef.child(friendId.toString())
                                .set(friendGifts);
                          }
                        } else {
                          await pledgedGiftsRef.child(friendId.toString()).set(
                              [giftId]);
                        }
                      } else {
                        if (pledgedGiftsMap.containsKey(friendId.toString())) {
                          final List<
                              dynamic> friendGifts = pledgedGiftsMap[friendId
                              .toString()];
                          friendGifts.remove(giftId);
                          await pledgedGiftsRef.child(friendId.toString()).set(
                              friendGifts);
                        }
                      }

                      print("Gift status updated successfully.");
                      return; // Exit once the status is updated
                    }
                    else {
                      print("Unexpected data format: ${pledgedGiftsSnapshot
                          .value}");
                    }
                  }
                  else {
                    //   create a new pledged gift list
                    print("pledgedGiftsSnapshot does not exist");
                    if (status) {
                      await pledgedGiftsRef.child(friendId.toString()).set(
                          [giftId]);
                    }
                  }
                }
              }
            }
          }
          // If no matching gift was found in the friend's events
          print("Gift with ID $giftId not found in friend's events.");
        }
      } else {
        print("No events found for user $friendId.");
      }
    } catch (e) {
      print("Error updating gift status for gift $giftId: $e");
      throw e;
    }
  }
  Future<void> deleteGiftsForUser(int giftId,int userId,int eventid) async {
    final myData = await dbService.db;
    await myData.rawQuery("DELETE FROM Gifts WHERE giftid = $giftId");
    // await deleteGiftsForUserinFirebase(giftId, userId, eventid);
  }
  Future<void> deleteGiftsForUserinFirebase(int giftId, int userId, int eventId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");

          // Locate the event and gift to delete
          String? eventKeyToDelete;
          String? giftIndexToDelete;

          eventsMap.forEach((eventKey, eventValue) {
            if (eventValue is Map && eventValue['eventId'] == eventId) {
              print("eventValue is $eventValue");
              if (eventValue.containsKey('gifts')) {
                if (eventValue['gifts'] is List) {
                  final giftsList = eventValue['gifts'] as List;
                  for (var i = 0; i < giftsList.length; i++) {
                    if (giftsList[i]['giftid'] == giftId) {
                      eventKeyToDelete = eventKey;
                      giftIndexToDelete = i.toString();
                      break;
                    }
                  }
                }
                else if (eventValue['gifts'] is Map) {
                  final giftsMap = eventValue['gifts'] as Map;
                  giftsMap.forEach((key, value) {
                    if (value['giftid'] == giftId) {
                      eventKeyToDelete = eventKey;
                      giftIndexToDelete = key;
                    }
                  });
                }
              }

            }
          });

          if (eventKeyToDelete != null && giftIndexToDelete != null) {
            // Delete the gift
            await dbRef.child("$eventKeyToDelete/gifts/$giftIndexToDelete").remove();
            print("Deleted gift with id $giftId for userId $userId in event $eventId");
          } else {
            print("No matching gift found with id $giftId for eventId $eventId and userId $userId");
          }
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;

          String? eventIndexToDelete;
          String? giftIndexToDelete;

          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event['eventId'] == eventId) {
              if (event.containsKey('gifts')) {
                if (event['gifts'] is List) {
                  print("gifts is list");
                  final giftsList = event['gifts'] as List;
                  for (var j = 0; j < giftsList.length; j++) {
                    if (giftsList[j]== null){
                      continue;
                    }
                    if (giftsList[j]['giftid'] == giftId) {
                      eventIndexToDelete = i.toString();
                      giftIndexToDelete = j.toString();
                      break;
                    }
                  }
                }
                else if (event['gifts'] is Map) {
                  print("gifts is map");
                  final giftsMap = event['gifts'] as Map;
                  giftsMap.forEach((key, value) {
                    if (value['giftid'] == giftId) {
                      eventIndexToDelete = i.toString();
                      giftIndexToDelete = key;
                    }
                  });
                }
              }
            }
          }

          if (eventIndexToDelete != null && giftIndexToDelete != null) {
            // Delete the gift
            await dbRef.child("$eventIndexToDelete/gifts/$giftIndexToDelete").remove();
            print("Deleted gift with id $giftId for userId $userId in event $eventId");
          } else {
            print("No matching gift found with id $giftId for eventId $eventId and userId $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error deleting gift with id $giftId for userId $userId in event $eventId: $e");
      throw e;
    }
  }


}