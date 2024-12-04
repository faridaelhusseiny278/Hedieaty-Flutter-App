import 'package:flutter/material.dart';
// import 'package:hedieatyfinalproject/friends_gift_details.dart';
import 'gift_details_page.dart';
import 'database.dart';
import 'gift_item.dart';
import 'Event.dart';
class GiftListPage extends StatefulWidget {
  final int eventid;
  GiftListPage({required this.eventid});

  @override
  _GiftListPage createState() => _GiftListPage();
}

class _GiftListPage extends State<GiftListPage> {
  DatabaseService dbService = DatabaseService();
  String selectedFilter = 'giftName'; // Default filter is gift name
  List<Map<String, dynamic>> filteredGifts = [];
  List<Map<String, dynamic>> allGifts = [];
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Tech"; // Default value

  @override
  void initState() {
    super.initState();
    //loop on all gifts and add them to the filteredGifts list if the event id is the same as the event id of the current event
    dbService.readData("SELECT * from Gifts").then((value) {
      value.forEach((element) {
        if (element['eventID'] == widget.eventid) {
          print("element is $element");
          setState(() {
            filteredGifts.add(element);
            print("filtered gifts in init is $filteredGifts");
            allGifts.add(element);
          });
        }
      });
    });
  }
  // get the event name from the database by the event id
  Future<String> getEventName() async {
    List<Map> Response = await dbService.readData("SELECT * from Events");
    for (int i = 0; i < Response.length; i++) {
      if (Response[i]['eventId'] == widget.eventid) {
        return Response[i]['eventName'];
      }
    }
    return "";
  }

  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        filteredGifts.sort((a, b) => a['giftName'].compareTo(b['giftName']));
      } else if (criteria == 'category') {
        filteredGifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        // Ensure status is properly handled
        filteredGifts.sort((a, b) {
          int aStatus = (a['pledged'] is bool) ? (a['pledged'] ? 1 : 0) : (a['pledged'] as int);
          int bStatus = (b['pledged'] is bool) ? (b['pledged'] ? 1 : 0) : (b['pledged'] as int);

          return bStatus - aStatus;
        });
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


// Function to show bottom sheet with delete option
  void _showDeleteBottomSheet(int index) {
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
                'Delete Gift',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to delete this gift?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // remove the gift from the event's gifts in the database
                      Map<String, dynamic> giftToRemove = filteredGifts[index];
                      await dbService.deleteGiftsForUser(giftToRemove['giftid']);
                      setState(() {
                        // Remove the gift from the filtered list
                        filteredGifts.removeAt(index);
                      });
                      Navigator.of(context).pop(); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Use backgroundColor instead of primary
                    ),
                    child: Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close bottom sheet without deleting
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Use backgroundColor instead of primary
                    ),
                    child: Text('Cancel'),
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: FutureBuilder<String>(
        future: getEventName(), // Call your async function here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...'); // Show loading text while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error if any
          } else if (snapshot.hasData) {
            return Text("${snapshot.data} Gifts" ?? ''); // Display event name when data is available
          } else {
            return Text('No data found');
          }
        },
      ),
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
                              filteredGifts = allGifts
                                  .where((element) => element[selectedFilter]
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search gifts...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'giftName',
                            child: Text('Name'),
                          ),
                          PopupMenuItem(
                            value: 'category',
                            child: Text('Category'),
                          ),

                        ],
                        icon: Icon(Icons.filter_list, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Sort button
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
                        var updatedGift = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftDetailsPage(
                              giftDetails: {
                                'giftName': '',
                                'category': selectedCategory, // Default category
                                'description': '',
                                'pledged': false, // Default pledge status
                                'imageurl': '',
                                'price': ''
                              },
                            ),
                          ),
                        );
                        // Check if the updated gift is not null
                        if (updatedGift != null) {
                          updatedGift['eventID'] = widget.eventid;
                          int id = await dbService.addGiftForUser(updatedGift);
                          // Add the new or updated gift to the list
                          updatedGift['giftid'] = id;
                          print("updatedGift is $updatedGift");
                          setState(() {
                            filteredGifts.add(updatedGift);
                            allGifts.add(updatedGift);
                            print("filteredGifts: $filteredGifts");

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
                    itemCount: filteredGifts.length,
                    itemBuilder: (context, index) {
                      var gift = filteredGifts[index];
                      print("gift is $gift");

                      return GiftItem(
                        giftid: gift['giftid'],
                        giftName: gift['giftName'],
                        category: gift['category'],
                          status: (gift['pledged'] == 0 || gift['pledged'] == false) ? false : true,
                          imageurl: gift['imageurl'],
                        price: gift['price'],
                        description: gift['description'],
                        onPressed: () async {
                          final updatedGift = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsPage(
                                giftDetails: gift,
                              ),
                            ),
                          );

                          if (updatedGift != null) {
                            print("Gift ID: ${gift['giftid']}");
                            await dbService.updateGiftForUser(updatedGift, gift['giftid']);
                            setState(() {
                              filteredGifts[index] = updatedGift;
                              allGifts[index] = updatedGift;
                              print("filteredGifts index: ${filteredGifts[index]}");
                            });
                          }
                        },
                       onLongPress: () {
                            _showDeleteBottomSheet(index); // Show bottom sheet on long press
                          }

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
