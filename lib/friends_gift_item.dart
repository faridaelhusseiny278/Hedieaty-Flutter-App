import 'package:flutter/material.dart';

class FriendsGiftItem extends StatefulWidget {
  final String giftName;
  final String category;
  final String imageurl; // Image URL for the avatar
  final bool pledged; // Pledge status passed from the parent
  final VoidCallback onPressed;
  // final VoidCallback onLongPress;
  final ValueChanged<bool> onPledgeChanged; // Callback to notify when pledge status changes

  FriendsGiftItem({
    required this.giftName,
    required this.category,
    this.imageurl = '',
    required this.pledged,
    required this.onPressed,
    // required this.onLongPress,
    required this.onPledgeChanged,
  });

  @override
  _FriendsGiftItemState createState() => _FriendsGiftItemState();
}

class _FriendsGiftItemState extends State<FriendsGiftItem> {
  bool _isValidImage = true; // Track if the image URL is valid

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
      final response = await Uri.tryParse(widget.imageurl);
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
      // onLongPress: widget.onLongPress,
      onTap: widget.onPressed,
      child: Card(
        elevation: 6,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF917798), Color(0xFF865A97)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Conditionally render the avatar
                if (_isValidImage)
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageurl),
                    radius: 40,
                    onBackgroundImageError: (_, __) {
                      setState(() {
                        _isValidImage = false;
                      });
                    },
                  ),

                if (_isValidImage) SizedBox(width: 16), // Spacing when avatar is present

                // Main gift information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.giftName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Pledge button
                ElevatedButton(
                  onPressed: () {
                    widget.onPledgeChanged(!widget.pledged);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.pledged ? Colors.green : Colors.white70, // Use backgroundColor
                    foregroundColor: Colors.white, // Use foregroundColor
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    widget.pledged ? 'Pledged' : 'Pledge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
