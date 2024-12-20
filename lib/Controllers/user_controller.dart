import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Controllers/firebasedatabase_helper.dart';
import 'package:hedieatyfinalproject/Models/user_model.dart';

class UserController {
  DatabaseService dbService = DatabaseService();
  UserModel userModel = UserModel();
Future <bool> getUserNotificationPreferences(int userid){
//   check if use has Push Notifications in his preferences
print("in getUserNotificationPreferences in user model for user $userid");
//  print the value returned from the function
  return userModel.getUserNotificationPreferences(userid);
}

Future<bool> areFriends(int currentUserId, int friendId) async {
  try {
    // Reference to the current user's "friends" node
    final friendsRef = FirebaseDatabaseHelper.getReference("Users/${currentUserId}/friends");

    // Fetch the snapshot of the friends list
    final DataSnapshot snapshot = await friendsRef.get();

    if (snapshot.exists) {

      if (snapshot.value is Map) {
        // If the data is a Map, check if the friendId is present
        final friends = (snapshot.value as Map).values.map((e) => int.parse(e.toString())).toList();
        return friends.contains(friendId);
      } else if (snapshot.value is List) {
        // If the data is a List, check if the friendId is present
        // skip nulls
        final friends = (snapshot.value as List).where((element) => element != null).map((e) => int.parse(e.toString())).toList();
        return friends.contains(friendId);
      } else {
        print("Unexpected data format: ${snapshot.value}");
        return false;
      }
    } else {
      print("No friends found for user ${currentUserId.toString()}.");
      return false;
    }
  } catch (e) {
    print("Error checking friendship between ${currentUserId.toString()} and ${friendId.toString()}: $e");
    throw e;
  }
}
  // check if phone number exists in firebase
  Future <bool> checkPhoneNumber(String phonenumber, int? userid) async {
    final dbRef = FirebaseDatabaseHelper.getReference("Users");
    final DataSnapshot snapshot = await dbRef.get();
    if (snapshot.exists) {
      if (snapshot.value is List) {
        final usersList = snapshot.value as List;
        for (var user in usersList) {
          if (user == null) {
            continue;
          }
          if (userid != null) {
            if (user['phonenumber'] == phonenumber &&
                user['userid'] != userid) {
              return true;
            }
          }
          else {
            if (user['phonenumber'] == phonenumber) {
              return true;
            }
          }
        }
        return false;
      }
    } else {
      return false;
    }
    return false;
  }

  // check if email already exists in firebase
  Future <bool> checkEmail(String email, int? userid) async {
    final dbRef = FirebaseDatabaseHelper.getReference("Users");
    final DataSnapshot snapshot = await dbRef.get();
    if (snapshot.exists) {
      if (snapshot.value is List) {
        final usersList = snapshot.value as List;
        for (var user in usersList) {
          if (user == null) {
            continue;
          }
          if (userid != null) {
            if (user['email'] == email && user['userid'] != userid) {
              return true;
            }
            else {
              if (user['email'] == email) {
                return true;
              }
            }
          }
        }
        return false;
      }
    } else {
      return false;
    }
    return false;
  }
  Future<int> addUser(int userId, String name, String email, String phonenumber, String address, List<String> notification_preferences, String imageurl) async {
  return await userModel.addUser(userId, name, email, phonenumber, address, notification_preferences,imageurl);
  }
  Future<Map<String, dynamic>?> getUserByIdforFriends(int userId) async {
    return await userModel.getUserByIdforFriends(userId);
  }
  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    return await userModel.getUserByPhoneNumber(phoneNumber);
  }
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await userModel.getUserById(userId);
  }
  Future<Map<String, dynamic>?> getUserbyGift(int giftId) async {
    return await userModel.getUserbyGift(giftId);
  }
  Future<int> getUserIdByEmailFromFirebase(String email) async {
    return await userModel.getUserIdByEmailFromFirebase(email);
  }
  Future<void> updateUserData(int userId, Map<String, dynamic> userData) async {
    return await userModel.updateUserData(userId, userData);
  }
  Future<void> updateUserDatainFirebase(int userId, Map<String, dynamic> userData) async {
    return await userModel.updateUserDatainFirebase(userId, userData);
  }
}
