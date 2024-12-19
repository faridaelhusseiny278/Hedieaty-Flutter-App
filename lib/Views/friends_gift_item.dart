import 'package:flutter/material.dart';

class FriendsGiftItem extends StatefulWidget {
  final String name;
  final String category;
  final String description;
  String imageurl; // Image URL for the avatar
  int price;
  final bool isButtonEnabled;
  final bool status; // Pledge status passed from the parent
  final VoidCallback onPressed;
  // final VoidCallback onLongPress;
  final ValueChanged<bool> onPledgeChanged; // Callback to notify when pledge status changes

  FriendsGiftItem({
    required this.name,
    required this.category,
    this.imageurl = '',
    required this.status,
    required this.onPressed,
    required this.price,
    required this.isButtonEnabled,
    required this.description,
    // required this.onLongPress,
    required this.onPledgeChanged,
  });

  @override
  _FriendsGiftItemState createState() => _FriendsGiftItemState();
}

class _FriendsGiftItemState extends State<FriendsGiftItem> {
  bool _isValidImage = true; // Track if the image URL is valid
  bool _isPressed = false; // Track if the button is pressed

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
                        widget.name,
                        style: TextStyle(
                          fontSize: 15,
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

                // Pledge button with animation
                GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _isPressed = true; // Set pressed state
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _isPressed = false; // Reset pressed state
                    });
                    // Trigger your pledge change
                    widget.onPledgeChanged(!widget.status);
                  },
                  onTapCancel: () {
                    setState(() {
                      _isPressed = false; // Reset if the tap is canceled
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut, // Animation curve
                    transform: Matrix4.identity()..scale(_isPressed ? 1.1 : 1.0), // Scaling effect when pressed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: widget.status ? Colors.green : Colors.white70,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(0, 4), // Shadow effect
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print("Pledge button pressed, status: ${widget.status}");
                        widget.onPledgeChanged(!widget.status);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Transparent to let the color change show
                        foregroundColor: widget.status ? Colors.white : Colors.deepPurple,
                        elevation: 0, // Remove extra elevation
                        shadowColor: Colors.transparent, // Disable shadow for a cleaner effect
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        (widget.status == 1 || widget.status == true) ? 'Pledged' : 'Pledge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
