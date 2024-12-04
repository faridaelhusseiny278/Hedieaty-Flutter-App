import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:hedieatyfinalproject/friend_event.dart';
import 'friends_gift_item.dart';
import 'friends_gift_details.dart';

class FriendsGiftList extends StatefulWidget {
  final int userid;
  DatabaseService dbService = DatabaseService();
  friendEvent event;
  int friendid;
   FriendsGiftList({required this.event, required this.userid, required this.dbService, required this.friendid});

  @override
  _FriendsGiftListState createState() => _FriendsGiftListState();
}

class _FriendsGiftListState extends State<FriendsGiftList> {
  String selectedFilter = 'name';
  List<Map<String, dynamic>> filteredGifts = [];
  List<Map<String, dynamic>> OriginalGifts = [];
  List<Map<String, dynamic>> SearchedGifts = [];
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Tech"; // Default value
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }
  void _loadGifts() async {
  final gifts = await widget.dbService.getGiftsForEventFriends((widget.event.id)!, widget.friendid);
    setState(() {
      OriginalGifts = gifts;
      filteredGifts = OriginalGifts.map((gift) => Map<String, dynamic>.from(gift)).toList();
      isLoading = false;

    });
  }

  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        selectedFilter = 'name';
        filteredGifts.sort((a, b) => a['giftName'].compareTo(b['giftName']));
      } else if (criteria == 'category') {
        selectedFilter = 'category';
        filteredGifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        selectedFilter = 'status';
        filteredGifts.sort((a, b) {
          int aStatus = (a['pledged'] is bool)
              ? (a['pledged'] ? 1 : 0)
              : (a['pledged'] as int);
          int bStatus = (b['pledged'] is bool)
              ? (b['pledged'] ? 1 : 0)
              : (b['pledged'] as int);

          return bStatus - aStatus;
        });
      }
    });
  }
  Future<Map<int, bool>> _fetchPledgeStatuses() async {
    final Map<int, bool> pledgeStatuses = {};
    for (var gift in filteredGifts) {
      final isPledgedByCurrentUser = await widget.dbService.hasPledgedGift(
        widget.userid,
        gift['giftid'],
      );
      pledgeStatuses[gift['giftid']] = isPledgedByCurrentUser;
    }
    return pledgeStatuses;
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
  Future<void> _onPledgeChanged(int index, bool pledged) async {
    final gift = filteredGifts[index];
    final currentUserId = widget.userid;
    final eventDate = widget.event.date;


    try {
      if (pledged) {
        // Pledging the gift
        // checking if the gift is already pledged or deadline has passed
        if ((gift['pledged'] == false || gift['pledged'] == 0)) {
          if (eventDate == null || eventDate.isBefore(DateTime.now())) {
            // Event deadline has passed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Event deadline has passed. You can't pledge this gift.",
                ),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          // Mark the gift as pledged in the database
          await widget.dbService.updateGiftStatus(gift['giftid'], true, currentUserId, widget.friendid);

          // Update status in the state
          setState(() {
            filteredGifts[index]['pledged'] = true;
            print("succesfuly updated gift status to true");
            OriginalGifts = filteredGifts;
          });
        }
      } else {
        // Unpledging the gift
        if ((gift['pledged'] == false || gift['pledged'] == 0))
        {
          // If the gift is not pledged, do nothing
          return;
        }
        // Check if the current user has pledged this gift
        final hasPledged = await widget.dbService.hasPledgedGift(
          currentUserId,
          gift['giftid'],
        );
        if (hasPledged) {
          if (eventDate == null || eventDate.isBefore(DateTime.now())) {
            // Event deadline has passed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Event deadline has passed. You can't unpledge this gift.",
                ),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          // Unpledge the gift in the database
          await widget.dbService.updateGiftStatus(gift['giftid'], false,currentUserId, widget.friendid);

          // Update status in the state
          setState(() {
            filteredGifts[index]['pledged'] = false;
           print("succesfuly updated gift status to false");
            OriginalGifts = filteredGifts;
          });
        } else {
          // Show a message if the user cannot unpledge the gift
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "You cannot unpledge this gift as it was pledged by someone else.",
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search Box
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
                          controller: giftNameController,
                          onChanged: (value) {
                            setState(() {
                              // When the search input is empty, reset to the original list
                              if (value.isEmpty) {
                                filteredGifts = OriginalGifts.map((gift) => Map<String, dynamic>.from(gift)).toList();

                              } else {
                                filteredGifts = OriginalGifts.where((gift) {
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
                                    final status = (gift['pledged'] == 1 || gift['pledged'] == true)
                                        ? 'pledged'
                                        : 'unpledged';
                                    return status.contains(value.toLowerCase());
                                  }
                                  return false;
                                }).toList();
                              }
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
                // Sort Options
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
                // Gift List with FutureBuilder
                Expanded(
                  child: FutureBuilder(
                    future: _fetchPledgeStatuses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else {
                        final pledgeStatuses = snapshot.data as Map<int, bool>;

                        return ListView.builder(
                          itemCount: filteredGifts.length,
                          itemBuilder: (context, index) {
                            var gift = filteredGifts[index];
                            final isPledged = (gift['pledged'] == 1 || gift['pledged'] == true) ? true : false;
                            print("isPledged is $isPledged");
                            final pledgedByCurrentUser =
                                pledgeStatuses[gift['giftid']] ?? false;
                            print("pledgedByCurrentUser is $pledgedByCurrentUser");

                            // Set item background color
                            final backgroundColor = isPledged
                                ? (pledgedByCurrentUser
                                ? Colors.blue.shade100
                                : Colors.green.shade100)
                                : Colors.white;

                            return Container(
                              color: backgroundColor, // Apply background color
                              child: FriendsGiftItem(
                                name: gift['giftName'],
                                category: gift['category'],
                                status: isPledged,
                                imageurl: gift['imageurl'],
                                description: gift['description'],
                                price: gift['price'],
                                isButtonEnabled:
                                !isPledged || pledgedByCurrentUser,
                                // Disable button for other users
                                onPressed: () async {

                                  // Handle navigation or other actions here
                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => FriendsGiftDetails(
                                  gift: gift,
                                  )
                                  )
                                  );
                                },
                                onPledgeChanged: (isPledged) =>
                                    _onPledgeChanged(index, isPledged),
                              ),
                            );
                          },
                        );
                      }
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


