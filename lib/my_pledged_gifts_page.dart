import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PledgedListPage extends StatefulWidget {
  @override
  _PledgedListPageState createState() => _PledgedListPageState();
}

class _PledgedListPageState extends State<PledgedListPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // Sample list of pledged gifts
  List<Map<String, dynamic>> pledgedGifts = [
    {
      "friendName": "Alice",
      "giftName": "Photo Album",
      "dueDate": DateTime(2024, 11, 20),
      'image': 'assets/istockphoto-1296058958-612x612.jpg'
    },
    {
      "friendName": "Bob",
      "giftName": "Board Game",
      "dueDate": DateTime(2024, 11, 25),
      'image': 'assets/istockphoto-1371904269-612x612.jpg'
    },
    {
      "friendName": "Charlie",
      "giftName": "Coffee Mug",
      "dueDate": DateTime(2024, 11, 15),
      'image': 'assets/istockphoto-1417086080-612x612.jpg'
    },
    {
      "friendName": "Diana",
      "giftName": "Perfume Set",
      "dueDate": DateTime(2024, 12, 5),
      'image': 'assets/young-smiling-man-adam-avatar-600nw-2107967969.png'
    },
    {
      "friendName": "Eve",
      "giftName": "Headphones",
      "dueDate": DateTime(2024, 12, 10),
      'image': 'assets/young-smiling-woman-mia-avatar-600nw-2127358541.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Sort the list by due date, most recent to oldest
    pledgedGifts.sort((a, b) => b['dueDate'].compareTo(a['dueDate']));

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
          final bool isOverdue = gift['dueDate'].isBefore(now);

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
                  backgroundImage: AssetImage(gift['image']),
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
                          'Due Date: ${formatter.format(gift['dueDate'])}',
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
                            // Modify Button (Pencil Icon as a Circle)
                            CircleAvatar(
                              radius: 20.0, // Adjust size as needed
                              backgroundColor: Colors.grey.shade200, // Light grey background
                              child: IconButton(
                                onPressed: () {
                                  // Leave this blank for now
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.grey, // Icon color
                                ),
                                tooltip: 'Modify',
                              ),
                            ),

                            // Delete Button (Trash Icon as ElevatedButton)
                            if (!isOverdue)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    pledgedGifts.removeAt(index);
                                  });
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
