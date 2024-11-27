import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/friends_gift_details.dart';
import 'friends_gift_item.dart';
import 'gift_details_page.dart';
import 'friends_gift_details.dart';

class FriendsGiftList extends StatefulWidget {
  final List<Map<String, dynamic>> gifts;
  final String eventname;
  FriendsGiftList({required this.gifts, required this.eventname});

  @override
  _FriendsGiftListState createState() => _FriendsGiftListState();
}

class _FriendsGiftListState extends State<FriendsGiftList> {
  String selectedFilter = 'name';
  List<Map<String, dynamic>> filteredGifts = [];
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Electronics"; // Default value

  @override
  void initState() {
    super.initState();
    filteredGifts = List.from(widget.gifts); // Initialize with all gifts
  }

  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        filteredGifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        filteredGifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
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
      filteredGifts[index]['pledged'] = pledged;
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
                                return gift[selectedFilter]!
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase());
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
                      print("gifts are $gift");
                      return FriendsGiftItem(
                        giftName: gift['giftName'],
                        category: gift['category'],
                        pledged: gift['pledged'],
                        imageurl: gift['imageurl'],
                        description: gift['description'],
                        price: gift['price'],
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
