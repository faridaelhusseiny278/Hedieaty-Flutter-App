import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  final String imageurl;
  final String name;
  final int eventCount;
  final VoidCallback onTap;  // Add onTap parameter

  // Modify the constructor to accept the onTap callback
  FriendCard({ required this.imageurl, required this.name, required this.eventCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 32.0,
          backgroundImage: imageurl.isNotEmpty
              ? AssetImage(imageurl) // Use FileImage for local image files
              : null,
          backgroundColor: Colors.grey.shade200,
          child: imageurl.isEmpty
              ? Icon(Icons.person, color: Colors.grey.shade600)
              : null,
        ),

        title: Text(
          name,
          style: TextStyle(
            color: Color(0xFF3A3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          eventCount > 0 ? "Events: $eventCount" : "No Events",
          style: TextStyle(color: Color(0xFF666680)),
        ),
        trailing: Icon(Icons.chevron_right, color: Color(0xFF666680)),
        onTap: onTap,  // Pass the onTap callback
      ),
    );
  }
}
