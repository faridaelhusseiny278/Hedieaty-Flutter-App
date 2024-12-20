
import 'package:hedieatyfinalproject/Models/friend_event.dart';

class FriendEventController{

  friendEvent friendEventModel = friendEvent(
    id: 0,
    name: '',
    date: DateTime.now(),
    location: '',
    status: '',
    category: '',
    description: '',
    gifts: [],
  );
  Future<List<friendEvent>> getAllEventsForUserFriends(int userId) async {
    return await friendEventModel.getAllEventsForUserFriends(userId);
  }


}