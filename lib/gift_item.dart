import 'package:flutter/material.dart';

class GiftItem extends StatelessWidget {
  final String giftName;
  final String category;
  final bool pledged;
  String imageurl; // Image URL for the avatar
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  GiftItem({
    required this.giftName,
    required this.category,
    required this.pledged,
    this.imageurl = '',
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(2), // Space for gradient border
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey,
              Colors.purple,
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

            leading: imageurl.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(imageurl), // NetworkImage for the circular avatar
              radius: 25, // Size of the avatar
            )
                : null, // No image, no avatar
            title: Text(
              giftName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$category'),
          ),
        ),
      ),
    );
  }
}
