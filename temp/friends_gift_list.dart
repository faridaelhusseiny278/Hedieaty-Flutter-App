import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/friends_gift_details.dart';
import 'friends_gift_item.dart';
import '../lib/gift_details_page.dart';
import 'friends_gift_details.dart';

class FriendsGiftList extends StatefulWidget {
  final List<Map<String, dynamic>> gifts;
  final int userid;
  final List<Map<String, dynamic>> Database;
  final String eventname;
  FriendsGiftList({required this.gifts, required this.eventname,required this.userid, required this.Database});

  @override
  _FriendsGiftListState createState() => _FriendsGiftListState();
}

class _FriendsGiftListState extends State<FriendsGiftList> {
  String selectedFilter = 'name';
  List<Map<String, dynamic>> filteredGifts = [];
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Tech"; // Default value

  @override
  void initState() {
    super.initState();
    filteredGifts = List.from(widget.gifts); // Initialize with all gifts
  }

  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        selectedFilter= 'name';
        filteredGifts.sort((a, b) => a['giftName'].compareTo(b['giftName']));
      } else if (criteria == 'category') {
        selectedFilter= 'category';
        filteredGifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        selectedFilter= 'status';
        filteredGifts.sort((a, b) => (b['pledged'] ? 1 : 0) - (a['pledged'] ? 1 : 0));
      }
    });
  }


  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Name'),
                onTap: () {
                  sortGifts('name');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Category'),
                onTap: () {
                  sortGifts('category');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Status'),
                onTap: () {
                  sortGifts('status');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle pledge change
  void _onPledgeChanged(int index, bool pledged) {
    setState(() {
      final gift = filteredGifts[index];
      final currentUserId = widget.userid;

      if (pledged) {
        // If pledging, set the gift as pledged by the current user
        if (!gift['pledged']) {
          gift['pledged'] = true;

          // Update the user's pledged gifts in the database
          final user = widget.Database.firstWhere((user) => user['userid'] == currentUserId);
          if (!user['pledgedgifts'].contains(gift['giftid'])) {
            user['pledgedgifts'].add(gift['giftid']);
          }
        }
      } else {
        if (!gift['pledged']) {
          // If the gift is not pledged, do nothing
          return;
        }

        // Check if the current user has pledged this gift
        final user = widget.Database.firstWhere((user) => user['userid'] == currentUserId);
        if (user['pledgedgifts'].contains(gift['giftid'])) {
          // If unpledging a gift pledged by the current user
          gift['pledged'] = false;

          // Update the user's pledged gifts in the database
          user['pledgedgifts'].remove(gift['giftid']);
        } else {
          // Show a message indicating the user cannot unpledge this gift
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You cannot unpledge this gift as it was pledged by someone else."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventname),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search box
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              filteredGifts = widget.gifts.where((gift) {
                                if (selectedFilter == 'name') {
                                  return gift['giftName']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                } else if (selectedFilter == 'category') {
                                  return gift['category']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                } else if (selectedFilter == 'status') {
                                  final status = gift['pledged'] ? 'pledged' : 'unpledged';
                                  return status.contains(value.toLowerCase());
                                }
                                return false;
                              }).toList();
                            });
                          },

                          decoration: InputDecoration(
                            hintText: 'Search gifts...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                // Sort
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showSortOptions,
                      icon: Icon(Icons.sort),
                      label: Text("Sort By"),
                    ),

                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredGifts.length,
                    itemBuilder: (context, index) {
                      var gift = filteredGifts[index];

                      // Determine button state and color
                      final isPledged = gift['pledged'] ?? false;
                      final pledgedByCurrentUser = gift['pledgedBy'] == widget.userid;

                      // Set item background color
                      final backgroundColor = isPledged
                          ? (pledgedByCurrentUser ? Colors.blue.shade100 : Colors.green.shade100)
                          : Colors.white;

                      return Container(
                        color: backgroundColor, // Apply background color
                        child: FriendsGiftItem(
                          giftName: gift['giftName'],
                          category: gift['category'],
                          pledged: isPledged,
                          imageurl: gift['imageurl'],
                          description: gift['description'],
                          price: gift['price'],
                          isButtonEnabled: !isPledged || pledgedByCurrentUser, // Disable button for other users
                          onPressed: () async {
                            final updatedGift = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendsGiftDetails(
                                  gift: gift,
                                ),
                              ),
                            );
                            if (updatedGift != null) {
                              setState(() {
                                filteredGifts[index] = updatedGift;
                              });
                            }
                          },
                          onPledgeChanged: (pledged) => _onPledgeChanged(index, pledged),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
