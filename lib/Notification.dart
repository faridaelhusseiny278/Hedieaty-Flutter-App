class AppNotification {
  final String message;
  final DateTime timestamp;
   bool isRead;
   bool isSent;

  AppNotification({required this.message, required this.timestamp, this.isRead = false, this.isSent = false});
}
