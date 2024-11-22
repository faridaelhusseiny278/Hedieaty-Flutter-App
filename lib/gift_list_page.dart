import 'package:flutter/material.dart';
import 'rounded_button.dart';
import 'gift_item.dart';

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  String eventName = "Birthday";
  String selectedFilter = 'name';
  TextEditingController giftNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Electronics"; // Default value

  List<Map<String, dynamic>> gifts = [
    {'name': 'Teddy Bear', 'category': 'Toys', 'status': 'Available', 'pledged': false},
    {'name': 'Perfume Set', 'category': 'Beauty', 'status': 'Available', 'pledged': false},
    {'name': 'Smartwatch', 'category': 'Electronics', 'status': 'Pledged', 'pledged': true},
    {'name': 'Book', 'category': 'Books', 'status': 'Available', 'pledged': false},
  ];

  // Sort gifts by selected criteria
  void sortGifts(String criteria) {
    setState(() {
      if (criteria == 'name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
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
            // crossAxisAlignment: CrossAxisAlignment.start,
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
      gifts.removeAt(index);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
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
                              gifts = gifts.where((gift) {
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
                      onPressed: () {
                        // Show a bottom sheet for adding gift details
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Allows the bottom sheet to expand with the keyboard
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: 16,
                                left: 16,
                                right: 16,
                                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Gift Name Input
                                    Material(
                                      elevation: 2, // Adds shadow for elevation
                                      shadowColor: Colors.grey.withOpacity(0.3), // Light shadow
                                      borderRadius: BorderRadius.circular(10), // Rounded corners for the material
                                      child: TextField(
                                        controller: giftNameController,
                                        decoration: InputDecoration(
                                          labelText: "Gift Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10), // Match Material's rounded corners
                                          ),
                                          filled: true, // Adds a background to the text field
                                          fillColor: Colors.white, // Background color
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),

// Description Input
                                    Material(
                                      elevation: 2,
                                      shadowColor: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      child: TextField(
                                        maxLines: 3,
                                        controller: descriptionController,
                                        decoration: InputDecoration(
                                          labelText: "Description",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),

// Category Input
                                    Material(
                                      elevation: 2,
                                      shadowColor: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      child: DropdownButtonFormField<String>(
                                        value: selectedCategory, // Use the selected category
                                        items: ["Electronics", "Books", "Toys", "Clothing"]
                                            .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCategory = value!; // Update selected category
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Category",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    Material(
                                      elevation: 2,
                                      shadowColor: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: "Price",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixText: "\$",
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 16),
                                    // Upload Image Button
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Handle image upload
                                      },
                                      icon: Icon(Icons.image),
                                      label: Text("Upload Image"),
                                    ),
                                    SizedBox(height: 16),

                                    SizedBox(height: 16),
                                    // Save Button
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            gifts.add({
                                              'name': giftNameController.text,
                                              'category': selectedCategory,
                                              'status': "Available", // Default status
                                              'pledged': false, // Default value
                                            });
                                          });

                                          // Clear the controllers after adding
                                          giftNameController.clear();
                                          descriptionController.clear();

                                          Navigator.pop(context); // Close the bottom sheet
                                        },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple, // Set button color to purple
                                          foregroundColor: Colors.white, // Set text color to white for contrast
                                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Add some padding for better appearance
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text("Save"),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            );
                          },
                        );
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
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      var gift = gifts[index];
                      return GiftItem(
                        giftName: gift['name'],
                        category: gift['category'],
                        status: gift['status'],
                        pledged: gift['pledged'],
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
                                        gifts.removeAt(index);
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
