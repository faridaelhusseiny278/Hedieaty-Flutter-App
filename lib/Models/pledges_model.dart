
import 'package:hedieatyfinalproject/Models/user_model.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
import 'package:hedieatyfinalproject/Models/Event.dart';
import 'package:hedieatyfinalproject/Models/gift_model.dart';


class PledgesModel{
  DatabaseService dbService = DatabaseService();

  GiftModel giftModel = GiftModel();

  Future <int> getWhoHasPledgedGiftfromFirebase(int userId, int giftId) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users");
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot value in getWhoHasPledgedGiftfromFirebase is ${snapshot
          .value}");
      final usersList = snapshot.value as List;
      print("usersMap is $usersList");
      for (var user in usersList) {
        if (user['userid'] == userId) {
          continue;
        }
        if (user['pledgedgifts'] is List) {
          print(
              "user of pledged gifts is a list and it is ${user['pledgedgifts']}");
          // [null, [2,3], [9]]
          for (var pledges in user['pledgedgifts']) {
            print("pledges is $pledges");
            if (pledges == null) {
              continue;
            }
            for (var gift in pledges) {
              if (gift == giftId) {
                print("gift is $gift, while gift id is $giftId");
                print("user id is ${user['userid']}");
                return user['userid'];
              }
            }
          }
        }
        else if (user['pledgedgifts'] is Map) {
          print(
              "user of pledged gifts is a map and it is ${user['pledgedgifts']}");
          // {1: [2,3], 2: [9]}
          final List<int> pledgedGifts_firebase = [];
          user['pledgedgifts'].forEach((key, value) {
            for (var gift in value) {
              pledgedGifts_firebase.add(gift);
            }
          });
          print("pledgedGifts_firebase is $pledgedGifts_firebase");
          for (var gift in pledgedGifts_firebase) {
            if (gift == giftId) {
              return user['userid'];
            }
          }
        }
      }
      return 0;
    }
    catch (e) {
      print("Error fetching pledged gifts for user $userId: $e");
      throw e;
    }
  }
  Future <void> deletePldegedGiftsForUser(int userId,
      List<Event> eventsToDelete) async {
    final myData = await dbService.db;
    int friendId;
    int giftid;
    for (var event in eventsToDelete) {
      var gifts = await myData.rawQuery(
          "SELECT * FROM Gifts WHERE eventID = ${event.id}");
      for (var gift in gifts) {
        giftid = int.parse(gift['giftid'].toString());
        if (gift['pledged'] == 1 || gift['pledged'] == true) {
          //   get the friend id of the user who pledged the gift from firebase
          friendId =
          await getWhoHasPledgedGiftfromFirebase(userId, giftid) as int;
          print("friendId who has the pledged gift is $friendId");
          await giftModel.updateGiftStatus(giftid, false, friendId, userId);
          print("gift with id $giftid is now unpledged");
        }
      }
    }
  }
  //     get user pledged gifts by user id
  Future<List<Map<String, dynamic>>> getUserPledgedGifts(int userId) async {
    final myData = await dbService.db;
    // use join to get the gifts pledged by the user
    return await myData.rawQuery(
        'SELECT * FROM Gifts INNER JOIN Pledges ON Gifts.giftid = Pledges.giftID WHERE Pledges.userID = $userId');
  }
  // query table pledges to get the user id who pledged each gift which is an int
  Future <int> getPledges(int giftid) async {
    int result = await getPledgesFromFirebase(giftid);
    return result;
  }

  Future<int> getPledgesFromFirebase(int giftid) async {
    final dbRef = FirebaseDatabaseHelper.getReference("Users");
    final DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      if (snapshot.value is List) {
        // Look for pledged gifts of each user and if giftid matches the gift ID passed, then return the user ID
        final usersList = snapshot.value as List;

        for (var user in usersList) {
          if (user == null) {
            continue;
          }
          if (user['pledgedgifts'] is List) {
            print("pledgedgifts is list, for user id ${user['userid']}");
            print("user['pledgedgifts'] is ${user['pledgedgifts']}");
            final pledgedGifts = user['pledgedgifts'] as List;
            for (var gifts in pledgedGifts) {
              if (gifts == null) {
                continue;
              } else {
                for (var gift in gifts) {
                  if (gift == giftid) {
                    print("yess gift is $gift and giftid is $giftid");
                    return user['userid'] as int;
                  }
                }
              }
            }
          }
          else if (user['pledgedgifts'] is Map) {
            final pledgedGifts = user['pledgedgifts'] as Map;
            print(
                "pledgedGifts is $pledgedGifts for user id ${user['userid']}");
            print("gift id is $giftid");
            for (var key in pledgedGifts.keys) {
              var values = pledgedGifts[key];
              if (values == null) {
                continue;
              }
              print("values is $values");
              for (var value in values) {
                if (value == null) {
                  continue;
                }
                if (value == giftid) {
                  print("value is $value");
                  print("giftid is $giftid");
                  return user['userid'] as int;
                }
              }
            }
          }
        }
        print("No match found in the users list, now returning -1");
        return -1; // Return -1 if no match is found in the users list
      }
    } else {
      print("Snapshot doesn't exist");
      return -1; // Return -1 if the snapshot doesn't exist
    }
    print("Default return -1");
    return -1; // Default return if no condition matches
  }
  Future<void> deletePledge(int userId, int giftId) async {
    final myData = await dbService.db;
    await myData.rawQuery(
        'DELETE FROM Pledges WHERE userID = $userId AND giftID = $giftId');
  }

}