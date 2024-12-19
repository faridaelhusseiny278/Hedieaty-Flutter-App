

import 'package:hedieatyfinalproject/Models/friend_model.dart';

class FriendController {
  FriendModel friendModel = FriendModel();


  Future<List<int>> getUserFriendsIDs(int userId) async {
    return await friendModel.getUserFriendsIDs(userId);
  }
  Future<void> addFriend(int userId, int friendId) async
  {
    await friendModel.addFriend(userId, friendId);
  }
  Future<void> addFriendinDatabase(int userId, int friendId) async {
    await friendModel.addFriendinDatabase(userId, friendId);
  }

}