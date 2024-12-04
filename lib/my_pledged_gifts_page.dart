import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';
class PledgedListPage extends StatefulWidget {
  final int userid;
  DatabaseService dbService = DatabaseService();
  PledgedListPage({required this.userid, required this.dbService});

  @override
  _PledgedListPageState createState() => _PledgedListPageState();
}

class _PledgedListPageState extends State<PledgedListPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  late List<Map<String, dynamic>> pledgedGifts; // List to store pledged gifts
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  Future<void> _loadPledgedGifts() async {
    final results = await widget.dbService.getPledgedGiftsWithDetails(widget.userid);
    print("results are $results");

    setState(() {
      // copy the results to the pledgedGifts list
      pledgedGifts = List<Map<String, dynamic>>.from(results);
      pledgedGifts.sort((a, b) => b['eventDate'].compareTo(a['eventDate']));
      isLoading = false;
    });
    print("pledgedGifts are $pledgedGifts");
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // Sort the list by due date, most recent to oldest
    pledgedGifts.sort((a, b) => b['eventDate'].compareTo(a['eventDate']));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Pledged Gifts',
          style: TextStyle(
            color: Colors.white, // Set the title text color to white
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          final now = DateTime.now();
          final bool isOverdue = DateTime.parse(gift['eventDate']).isBefore(now);

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle avatar with the image
                CircleAvatar(
                  radius: 32.0,
                  backgroundImage: AssetImage(gift['friendImageUrl']),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 16.0),
                // Gift details card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift['giftName'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'For: ${gift['friendName']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Due Date: ${formatter.format(DateTime.parse(gift['eventDate']))}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Action Buttons (Modify & Delete)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Delete Button (Trash Icon as ElevatedButton)
                            if (!isOverdue)
                              ElevatedButton(
                                onPressed: () {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Unpledge Gift'),
                                        content: Text(
                                          'Deleting this pledged gift will unpledge it. Are you sure you want to proceed?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                // Get the gift to be removed
                                                final giftToRemove = pledgedGifts[index];

                                                // Remove from UI and Database
                                                pledgedGifts.removeAt(index);

                                                // Update the database
                                                widget.dbService.unpledgeGift(widget.userid, giftToRemove['ID']);
                                              });

                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50, // Light red background
                                  foregroundColor: Colors.red, // Icon color
                                  shape: const CircleBorder(), // Makes it a circle
                                  padding: const EdgeInsets.all(12.0), // Adjust size
                                  elevation: 2.0, // Subtle shadow
                                ),
                                child: const Icon(Icons.delete),
                              ),


                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
