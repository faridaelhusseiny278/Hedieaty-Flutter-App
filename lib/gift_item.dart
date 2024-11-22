import 'package:flutter/material.dart';

class GiftItem extends StatelessWidget {
  final String giftName;
  final String category;
  final String status;
  final bool pledged;
  final VoidCallback onLongPress;

  GiftItem({
    required this.giftName,
    required this.category,
    required this.status,
    required this.pledged,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(2), // Space for gradient border
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Colors.red,
              // Colors.orange,
              // Colors.yellow,
              // Colors.green,
              // Colors.blue,
              Colors.grey,
              Colors.purple,
              // Colors.deepPurple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Rounded gradient border
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pledged ? Colors.green[100] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              giftName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$category - $status'),
          ),
        ),
      ),
    );
  }
}
