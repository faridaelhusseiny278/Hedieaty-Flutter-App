import 'package:flutter/material.dart';

class GiftItem extends StatefulWidget {
  final int giftid;
  final String giftName;
  final String category;
  final bool status;
  final String description;
  String imageurl; // Image URL for the avatar
  double price;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  GiftItem({
   required this.giftid,
    required this.giftName,
    required this.category,
    required this.status,
    this.imageurl = '',
    required this.price,
    required this.description,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  State<GiftItem> createState() => _GiftItemState();
}

class _GiftItemState extends State<GiftItem> {
  bool _isValidImage = true;

  @override
  void initState() {
    super.initState();
    _checkImageValidity();
  }

  Future<void> _checkImageValidity() async {
    if (widget.imageurl.isEmpty) {
      setState(() {
        _isValidImage = false;
      });
      return;
    }
    try {
      final response = Uri.tryParse(widget.imageurl);
      if (response == null) throw Exception("Invalid URL");
      setState(() {
        _isValidImage = true;
      });
    } catch (e) {
      setState(() {
        _isValidImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onPressed,
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
            color: widget.status ? Colors.green[100] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Conditionally render the avatar based on _isValidImage
              if (_isValidImage)
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageurl),
                  radius: 40,
                  onBackgroundImageError: (_, __) {
                    setState(() {
                      _isValidImage = false;
                    });
                  },
                )
              else
              // CircleAvatar(
              //   backgroundColor: Colors.grey, // Fallback color for invalid URL
              //   radius: 40,
              // ),
                SizedBox(width: 16), // Spacing for the avatar
              // Main gift information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.giftName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.category,
                      style: TextStyle(fontSize: 14),
                    ),
                    if (widget.status)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pledged',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
