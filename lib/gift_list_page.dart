import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Event.dart';
import 'rounded_button.dart';
import 'gift_item.dart';
import 'gift_details_page.dart';
import 'Event.dart';

class GiftListPage extends StatefulWidget {

  final Event event;
  GiftListPage({required this.event});
  // extract gifts from events

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  // String eventName = "Birthday";
  String selectedFilter = 'name';
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Electronics"; // Default value

  // List<Map<String, dynamic>> gifts = [
  //   {'name': 'Teddy Bear', 'category': 'Toys', 'pledged': false,'imageurl':'https://th.bing.com/th/id/OIP.1gzFgCamhP5TDxg44AYKwwAAAA?rs=1&pid=ImgDetMain' },
  //   {'name': 'Perfume Set', 'category': 'Toys', 'pledged': false,'imageurl':''},
  //   {'name': 'Smartwatch', 'category': 'Electronics',  'pledged': true,'imageurl':''},
  //   {'name': 'Book', 'category': 'Books', 'pledged': false,'imageurl':''},
  // ];
  late List<Map<String, dynamic>> gifts;

  @override
  void initState() {
    super.initState();
    // Extract all gifts from the events
    gifts = widget.event.gifts;
  }
  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        this.gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        this.gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        this.gifts.sort((a, b) => b['pledged'] == true ? 1 : 0 - (a['pledged'] == true ? 1 : 0));

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


  // Function to handle delete operation
  void _deleteGift(int index) {
    setState(() {
      this.gifts.removeAt(index);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.event.name} gift list"),
        backgroundColor:Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
              ),
            ),
          ),
          Positioned.fill(
            top: 100,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x77DAD6D6),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.black12,  // Black border color
                  width: 1.5,  // Border thickness
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 120.0),
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
                    border: Border.all(color: Colors.grey.shade300, width: 1), // Add border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // How far the shadow spreads
                        blurRadius: 5, // Blurriness of the shadow
                        offset: Offset(0, 3), // Position of shadow (x, y)
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              gifts = this.gifts.where((gift) {
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
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                // Sort by and "+" button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Sort By Button
                    ElevatedButton.icon(
                      onPressed: _showSortOptions,
                      icon: Icon(Icons.sort),
                      label: Text("Sort By"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White background
                        foregroundColor: Colors.black, // Black text color
                        side: BorderSide(color: Colors.grey), // Grey border
                      ),
                    ),
                    // "+" Icon Button
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to GiftDetailsPage and wait for the updated gift to be returned
                        var updatedGift = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftDetailsPage(
                              giftDetails: {
                                'giftName': '',
                                'category': selectedCategory, // Default category
                                'description': '',
                                'pledged': false, // Default pledge status
                                'imageurl': ''
                              },
                            ),
                          ),
                        );

                        // Check if the updated gift is not null
                        if (updatedGift != null) {
                          // Add the new or updated gift to the list
                          setState(() {
                            widget.event.gifts.add(updatedGift);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), // Circular button
                        backgroundColor: Colors.white, // White background
                        foregroundColor: Colors.black, // Black icon color
                        side: BorderSide(color: Colors.grey), // Grey border
                        padding: EdgeInsets.all(10), // Adds padding for a larger button
                      ),
                      child: Icon(Icons.add),
                    ),

                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.event.gifts.length,
                    itemBuilder: (context, index) {
                      var gift = widget.event.gifts[index];
                      print("gift is $gift");

                      return GiftItem(
                        giftName: gift['giftName'],
                        category: gift['category'],
                        pledged: gift['pledged'],
                        imageurl: gift['imageurl'],
                        onPressed: () async {
                          final updatedGift = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsPage(
                                giftDetails: widget.event.gifts[index], // Pass the selected gift details
                              ),
                            ),
                          );
                          if (updatedGift != null) {
                            setState(() {
                              // Update the gift in the list with the modified data
                              widget.event.gifts[index] = updatedGift;
                            });
                          }
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Delete Gift'),
                                content: Text('Are you sure you want to delete this gift?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.event.gifts.removeAt(index);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
