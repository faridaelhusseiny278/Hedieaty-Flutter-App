import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Controllers/event_controller.dart';
import 'package:hedieatyfinalproject/Controllers/gift_controller.dart';
import 'package:hedieatyfinalproject/Controllers/pledges_controller.dart';
import 'package:hedieatyfinalproject/Models/gift_model.dart';
import 'package:hedieatyfinalproject/Models/pledges_model.dart';
// import 'package:hedieatyfinalproject/friends_gift_details.dart';
import 'gift_details_page.dart';
import '../database.dart';
import 'gift_item.dart';
import '../Models/Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GiftListPage extends StatefulWidget {
  final int eventid;
  final int userid;
  GiftListPage({required this.eventid,required this.userid});

  @override
  _GiftListPage createState() => _GiftListPage();
}

class _GiftListPage extends State<GiftListPage> {
  List<Map<String, dynamic>> actions = [];
  DatabaseService dbService = DatabaseService();

  GiftController giftController = GiftController();
  PledgesController pledgeController = PledgesController();
  EventController eventController = EventController();
  String selectedFilter = 'giftName'; // Default filter is gift name
  List<Map<String, dynamic>> filteredGifts = [];
  bool exists = false;
  List<Map<String, dynamic>> allGifts = [];
  List<Map<String, dynamic>> pledges = [];
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Tech"; // Default value
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllGifts();
    _loadActions(widget.userid).then((value) {
      setState(() {
        actions = value;
      });
    });
  }



  Future<void> _loadAllGifts() async {
    try {
      // Fetch all gifts from the database
      List<Map<String, dynamic>> value = await dbService.readData("SELECT * FROM Gifts");

      // Create a modifiable copy of value
      List<Map<String, dynamic>> modifiableValue = List<Map<String, dynamic>>.from(value);

      for (var giftData in modifiableValue) {
        // Only process gifts related to the current event
        if (giftData['eventID'] == widget.eventid) {
          // Fetch gifts for event friends from Firebase
          List<Map<String, dynamic>> giftsFirebase = await giftController.getGiftsForEventFriends(giftData['eventID'], widget.userid);

          // Create a mutable copy of the current gift map
          Map<String, dynamic> modifiableGift = Map<String, dynamic>.from(giftData);

          for (var firebaseGift in giftsFirebase) {
            if (firebaseGift['giftid'] == modifiableGift['giftid']) {
              // Fetch pledged status from Firebase
              print("Gift ID match found, updating pledged status...");
              modifiableGift['pledged'] = firebaseGift['pledged'];
              print("Pledged status updated.");
            }
          }

          // Fetch the friend ID who pledged for the gift
          var friendId = await pledgeController.getPledges(modifiableGift['giftid']);
          if (friendId != -1) {
            // Get the friend's name from the database by the friend ID
            List<Map> usersResponse = await dbService.readData("SELECT * FROM Users");
            for (var user in usersResponse) {
              if (user['userid'] == friendId) {
                modifiableGift['pledgedby'] = user['name'];
                break;
              }
            }
          } else {
            modifiableGift['pledgedby'] = '';
          }

          // Update the UI with the filtered gifts
          setState(() {
            filteredGifts.add(modifiableGift);
            allGifts.add(modifiableGift);
          });
        }
      }
    } catch (e) {
      print("Error loading gifts: $e");
    }

    print("All filtered gifts loaded: $filteredGifts");
  }



  Future<void> deleteActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_${widget.userid.toString()}_gifts_actions');
  }

  Future<List<Map<String, dynamic>>> _loadActions(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    // if (prefs.getString('user_${widget.userid.toString()}_gifts_actions') != null) {
    //   await prefs.remove('user_${widget.userid.toString()}_gifts_actions');
    // }
    final jsonString = prefs.getString('user_${userId.toString()}_gifts_actions');

    setState(() {
      loading = false;
    });
    print("jsonString: $jsonString");

    // Decode to a List<Map<String, dynamic>> instead of a Map
    return jsonString != null
        ? List<Map<String, dynamic>>.from(jsonDecode(jsonString))
        : [];
  }

  Future<void> saveActions(List<Map<String, dynamic>> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final currentActionsString = prefs.getString('user_${widget.userid.toString()}_gifts_actions');
    print("currentActionsString in gift list is  : $currentActionsString");
    await prefs.setString('user_${widget.userid.toString()}_gifts_actions', jsonEncode(actions));
    print("currentActions in gift list is after saving  : ${prefs.getString('user_${widget.userid.toString()}_gifts_actions')}");
  }

  void _publishToFirebase() async {
    for (var action in actions) {
      print("Processing action: $action");

      final eventId = action['gift']['eventID'];
      final gift = action['gift'];
      final giftId = gift['giftid'];

      // Check if the event exists
      bool exists = await _checkEventExistsAndHandleError(eventId);
      if (!exists) return;

      // Handle actions
      switch (action['action']) {
        case 'add':
          await giftController.addGiftForUserinFirebase(gift, widget.userid, giftId);
          break;

        case 'update':
          await giftController.updateGiftForUserinFirebase(gift, giftId, widget.userid);
          break;

        case 'delete':
          print("Deleting gift: $gift");
          await giftController.deleteGiftsForUserinFirebase(giftId, widget.userid, eventId);
          break;

        default:
          print("Unknown action: ${action['action']}");
          break;
      }
    }

    // Clear actions and update shared preferences
    actions.clear();
    deleteActions(actions);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gifts published in Firebase successfully!")),
    );
  }

  /// Helper function to check if the event exists in Firebase and show an error dialog if not.
  Future<bool> _checkEventExistsAndHandleError(int eventId) async {
    bool exists = await eventController.doesEventExistInFirebase(eventId, widget.userid);

    if (!exists) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Event does not exist'),
          content: Text(
            'Please publish the event first before publishing the gifts.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    return exists;
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
                      if (filteredGifts[index]['pledged'] == true || filteredGifts[index]['pledged'] == 1) {
                      //   can't remove the gift because it has been pledged by someone
                      //   show an alert dialog to inform the user
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Gift is pledged'),
                              content: Text(
                                'You can\'t delete a gift that has been pledged. '
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      // remove the gift from the event's gifts in the database
                      Map<String, dynamic> giftToRemove = filteredGifts[index];
                      await giftController.deleteGiftsForUser(giftToRemove['giftid'], widget.userid, widget.eventid);
                      giftToRemove['eventID'] = widget.eventid;
                      actions.add({
                        'action': 'delete',
                        'gift': giftToRemove
                      });
                      saveActions(actions);
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
    if (loading) {
      // Show loading indicator while data is loading
      return Center(child: CircularProgressIndicator());
    }
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
                          int id = await giftController.addGiftForUser(updatedGift, widget.userid);
                          // Add the new or updated gift to the list
                          updatedGift['giftid'] = id;
                          print("updatedGift is $updatedGift");
                          actions.add({
                            'action': 'add',
                            'gift': updatedGift
                          });
                          saveActions(actions);
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
                ElevatedButton(
                  onPressed: _publishToFirebase, // Call your publish function here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Button background color
                    foregroundColor: Colors.white, // Button text color
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Larger button height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'Publish gifts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredGifts.length,
                    itemBuilder: (context, index) {
                      print("filteredGifts: $filteredGifts");
                      var gift = filteredGifts[index];
                      print("gift is $gift");

                      return GiftItem(
                        giftid: gift['giftid'],
                        friendName: gift['pledgedby']?? '',
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
                            await giftController.updateGiftForUser(updatedGift, gift['giftid'], widget.userid);

                            updatedGift['eventID'] = widget.eventid;
                            actions.add({
                              'action': 'update',
                              'gift': updatedGift
                            });
                            saveActions(actions);
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
