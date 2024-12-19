import 'package:firebase_database/firebase_database.dart';
import '../Models/Notification.dart';
import 'firebasedatabase_helper.dart';

class AppNotificationService {
  final int userid;
  late final _dbRef;

  AppNotificationService({required this.userid}) {
    _dbRef = FirebaseDatabaseHelper.getReference("Users/$userid/notifications");
  }

  // Add a new notification to Firebase
  Future<void> addNotification(AppNotification notification) async {
    await _dbRef.push().set({
      'message': notification.message,
      'timestamp': notification.timestamp.toIso8601String(),
      'isRead': notification.isRead,
      'isSent': notification.isSent ,
    });
  }

  // Retrieve all notifications
  Future<List<AppNotification>> getNotifications() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final notifications = <AppNotification>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        notifications.add(AppNotification(
          message: value['message'],
          timestamp: DateTime.parse(value['timestamp']),
          isRead: value['isRead'],
          isSent: value['isSent'],
        ));
      });
      return notifications;
    } else {
      return [];
    }
  }
  // implement a function to mark a notification as read
  Future<void> markNotificationAsRead(AppNotification notification) async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['message'] == notification.message) {
          _dbRef.child(key).update({'isRead': true});
        }
      });
    }
  }
  Future<void> markNotificationAsSent(AppNotification notification) async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      print("now in markNotificationAsSent");
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['message'] == notification.message) {
          _dbRef.child(key).update({'isSent': true});
          print("notification sent");
        }
      });
    }
  }
  // Clear all notifications (or only unread ones)
  Future<void> clearNotifications() async {
    await _dbRef.remove();
  }
}

