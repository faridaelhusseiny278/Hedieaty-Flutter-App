

// create user model class
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';

class UserModel {
  //   create const
  DatabaseService dbService = DatabaseService();


  Future<int> addUser(int userId, String name, String email,
      String phonenumber, String address,
      List<String> notification_preferences) async {
    final myData = await dbService.db;
    int id = await myData.rawInsert(
        "INSERT INTO Users (userid, name, email, phonenumber, address, notification_preferences) VALUES (?, ?, ?, ?, ?, ?)",
        [
          userId,
          name,
          email,
          phonenumber,
          address,
          notification_preferences.join(",")
        ]);
    return id;
  }

  Future<Map<String, dynamic>?> getUserByIdforFriends(int userId) async {
    // Reference to the database for the specific user
    final dbRef = FirebaseDatabaseHelper.getReference("Users/$userId");

    try {
      // Fetch the snapshot for the user's data
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Cast the data to Map<String, dynamic>
          final user = Map<String, dynamic>.from(
              snapshot.value as Map<Object?, Object?>);
          return user;
        } else if (snapshot.value is List) {
          // If the data is a List, return the first element as a Map
          final user = (snapshot.value as List).first as Map<String, dynamic>;
          return user;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return null;
        }
      } else {
        print("No data found for user ID $userId.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserByPhoneNumber(
      String phoneNumber) async {
    try {
      // Reference to the database
      final dbRef = FirebaseDatabaseHelper.getReference("Users");

      // Fetch the snapshot of the users node
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot is $snapshot");

      if (snapshot.exists) {
        print("snapshot exists");
        //
        if (snapshot.value is Map) {
          // If the data is a Map, loop through the values to find the user with the matching phone number
          final users = (snapshot.value as Map).values.map((user) {
            return Map<String, dynamic>.from(user as Map);
          }).toList();
          // print("users are $users");

          for (var user in users) {
            if (user['phonenumber'] == phoneNumber) {
              return user;
            }
          }
        } else if (snapshot.value is List) {
          // If the data is a List, loop through the list to find the user with the matching phone number
          final users = (snapshot.value as List)
              .where((user) => user != null) // Exclude null users
              .map((user) => Map<String, dynamic>.from(user as Map))
              .toList();
          print("users are $users");
          for (var user in users) {
            if (user['phonenumber'] == phoneNumber) {
              return user;
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return null;
        }
      } else {
        print("No users found in the database.");
        return null;
      }
    } catch (e) {
      print("Error fetching user by phone number: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final myData = await dbService.db;
    var result = await myData.query(
      'Users',
      where: 'userid = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }


  //     get user by gift id
  Future<Map<String, dynamic>?> getUserbyGift(int giftId) async {
    final myData = await dbService.db;
    var result = await myData.rawQuery(
        'SELECT * FROM Users WHERE userid IN (SELECT userID FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId))');
    return result.isNotEmpty ? result.first : null;
  }


  // get user id by email
  Future<int> getUserIdByEmailFromFirebase(String email) async {
    try {
      final dbRef = FirebaseDatabaseHelper.getReference("Users");

      // Fetch the snapshot of the users node
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot is $snapshot");

      if (snapshot.exists) {
        //
        if (snapshot.value is Map) {
          final users = (snapshot.value as Map).values.map((user) {
            return Map<String, dynamic>.from(user as Map);
          }).toList();
          // print("users are $users");

          for (var user in users) {
            if (user['email'] == email) {
              return user['userid'];
            }
          }
        } else if (snapshot.value is List) {
          final users = (snapshot.value as List)
              .where((user) => user != null) // Exclude null users
              .map((user) => Map<String, dynamic>.from(user as Map))
              .toList();
          for (var user in users) {
            if (user['email'] == email) {
              return user['userid'];
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return 0;
        }
      } else {
        print("No users found in the database.");
        return 0;
      }
      return 0;
    } catch (e) {
      print("Error fetching user by email: $e");
      throw e;
    }
  }

  // update user data
  Future<void> updateUserData(int userId,
      Map<String, dynamic> userData) async {
    final myData = await dbService.db;
    await myData.rawUpdate('''
    UPDATE Users
    SET name = ?, phonenumber = ?, email = ?, address = ?, notification_preferences = ?, imageurl = ?
    WHERE userid = ?
  ''', [
      userData['name'],
      userData['phonenumber'],
      userData['email'],
      userData['address'],
      userData['notification_preferences'],
      userData['imageurl'],
      userId,
    ]);
    await updateUserDatainFirebase(userId, userData);
    //   print the user data after update
    var result = await myData.rawQuery(
        'SELECT * FROM Users WHERE userid = $userId');
    print("result after update is $result");
  }


  Future<void> updateUserDatainFirebase(int userId,
      Map<String, dynamic> userData) async {
    try {
      // convert user preferences ( a comma separated string) to a list
      if (userData.containsKey("notification_preferences")) {
        userData["notification_preferences"] =
            (userData["notification_preferences"] as String).split(",");
      }
      // Reference to the user's node
      final userRef = FirebaseDatabaseHelper.getReference("Users/$userId");

      // Update the user data
      await userRef.update(userData);
      print("User data updated successfully.");
    } catch (e) {
      print("Error updating user data: $e");
      throw e;
    }
  }

  Future <bool> getUserNotificationPreferences(int userid) async {
    //   query the firebase and return true if the user has Push Notifications in the notification_preferences array
    final dbRef = FirebaseDatabaseHelper.getReference(
        "Users/$userid/notification_preferences");
    // check if the array contains the string "Push Notifications"
    final DataSnapshot snapshot = await dbRef.get();
    print("snapshot value in getUserNotificationPreferences is ${snapshot
        .value}");
    if (snapshot.exists) {
      final notification_preferences = snapshot.value as List;
      for (var preference in notification_preferences) {
        if (preference.contains("Push Notifications")) {
          return true;
        }
      }
      print("User does not have Push Notifications enabled.");
      return false;
    }
    else {
      print("User does not have any notification preferences.");
      return false;
    }
  }
}

