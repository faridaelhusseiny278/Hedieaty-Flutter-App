import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';

class FriendModel{

  final String name;
  final int eventCount;

  FriendModel({this.name = '', this.eventCount= 0});

  DatabaseService dbService = DatabaseService();

  Future<List<int>> getUserFriendsIDs(int userId) async {
    // Reference to the database
    final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId/friends");
    print("i'm hereee");

    try {
      // Fetch the snapshot from the "friends" node
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot is $snapshot");
      print("i'm hereee in datasnapshot");
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // If the data is a Map, handle as a map and extract the friend IDs
          final friends = (snapshot.value as Map).values.map((e) =>
              int.parse(e.toString())).toList();
          return friends;
        } else if (snapshot.value is List) {
          // If the data is a List, handle as a list and extract the friend IDs
          print(
              "friends snapshot value is a list and it is  ${snapshot.value}");
          // filter null from the friend ids before returning them
          final friends = (snapshot.value as List).where((e) => e != null).map((
              e) => int.parse(e.toString())).toList();
          return friends;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      }
      else {
        print("No friends found for this user.");
        return [];
      }
    } catch (e) {
      print("Error fetching friends: $e");
      throw e;
    }
  }
  Future<void> addFriend(int userId, int friendId) async {
    try {
      await addFriendinDatabase(userId, friendId);
      // Reference to the current user's friends node
      final userFriendsRef = FirebaseDatabaseHelper.getReference(
          "Users/$userId/friends");

      // Reference to the friend's friends node
      final friendFriendsRef = FirebaseDatabaseHelper.getReference(
          "Users/$friendId/friends");
      int current_user_friendId_in_firebase = 0;
      int friend_friendId_in_firebase = 0;

      final DataSnapshot snapshot = await userFriendsRef.get();
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final user_friends_Map = Map<String, dynamic>.from(
              snapshot.value as Map);
          final List<int> current_user_friendIds = user_friends_Map.values.map((
              e) => int.parse(e.toString())).toList();
          current_user_friendId_in_firebase =
          current_user_friendIds.isEmpty ? 0 : current_user_friendIds.reduce((
              value, element) => value > element ? value : element) + 1;
        }
        else if
        (snapshot.value is List) {
          final List<dynamic> user_friends_ids = snapshot.value as List;
          current_user_friendId_in_firebase = user_friends_ids.length + 1;
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      }
      await userFriendsRef.child(current_user_friendId_in_firebase.toString())
          .set(friendId);

      final DataSnapshot friendSnapshot = await friendFriendsRef.get();
      if (friendSnapshot.exists) {
        if (friendSnapshot.value is Map) {
          final friendsMap = Map<String, dynamic>.from(
              friendSnapshot.value as Map);
          final List<int> friendIds = friendsMap.values.map((e) =>
              int.parse(e.toString())).toList();
          friend_friendId_in_firebase =
          friendIds.isEmpty ? 0 : friendIds.reduce((value, element) => value >
              element ? value : element) + 1;
        } else if (friendSnapshot.value is List) {
          final List<dynamic> friendIds = friendSnapshot.value as List;
          friend_friendId_in_firebase = friendIds.length + 1;
        } else {
          print("Unexpected data format: ${friendSnapshot.value}");
        }
      }
      await friendFriendsRef.child(friend_friendId_in_firebase.toString()).set(
          userId);

      print("Friendship added: $userId and $friendId are now friends.");
    } catch (e) {
      print("Error adding friend: $e");
      throw e;
    }
  }

  Future<void> addFriendinDatabase(int userId, int friendId) async {
    final myData = await dbService.db;
    // check if the entry exists in the database if so then delete it
    // select from table friends
    var result = await myData.rawQuery(
        "SELECT * FROM Friends WHERE userID = $userId AND friendID = $friendId OR userID = $friendId AND friendID = $userId");
    print("result is $result");
    await myData.rawQuery(
        "DELETE FROM Friends WHERE userID = $userId AND friendID = $friendId OR userID = $friendId AND friendID = $userId");

    await myData.rawInsert(
      'INSERT INTO Friends (userID, friendID) VALUES (?, ?)',
      [userId, friendId],
    );
  }

}