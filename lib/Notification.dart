class AppNotification {
  final String message;
  final DateTime timestamp;
   bool isRead;

  AppNotification({required this.message, required this.timestamp, this.isRead = false});
}
