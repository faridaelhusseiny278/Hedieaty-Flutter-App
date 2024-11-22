import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> giftDetails;

  GiftDetailsPage({required this.giftDetails});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {

  late TextEditingController giftNameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageURLController = TextEditingController();
  String selectedCategory = "Electronics"; // Default category
  bool isPledged = false; // Default status

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the gift details
    giftNameController = TextEditingController(text: widget.giftDetails['name']);
    descriptionController = TextEditingController(text: widget.giftDetails['description'] ?? "");
    priceController = TextEditingController(text: widget.giftDetails['price']?.toString() ?? "");
    imageURLController = TextEditingController(text: widget.giftDetails['imageurl']?.toString() ?? "");
    selectedCategory = widget.giftDetails['category'] ?? "Electronics";
    isPledged = widget.giftDetails['pledged'] ?? false; // This line remains unchanged
  }

  @override
  void dispose() {
    giftNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageURLController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Details"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Icon
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageURLController.text.isNotEmpty
                          ? NetworkImage(imageURLController.text) // Use the URL provided by the user
                          : null, // If no URL, the icon will stay as the default
                      child: imageURLController.text.isEmpty
                          ? Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey.shade600,
                      )
                          : null, // If URL is provided, the icon disappears
                    ),


                  ],
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: giftNameController,
                enabled: !isPledged,
                decoration: InputDecoration(
                  labelText: "Gift Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple.shade200,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Description
              TextField(
                controller: descriptionController,
                enabled: !isPledged,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple.shade200,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: isPledged
                    ? null // Disable the dropdown when the gift is pledged
                    : (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: ["Electronics", "Books", "Toys", "Clothing"]
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: priceController,
                enabled: !isPledged,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple.shade200,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageURLController,
                enabled: !isPledged,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple.shade200,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),

              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Label with Icon
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isPledged
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPledged ? Colors.green : Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPledged
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isPledged ? Colors.green : Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Status: ${isPledged ? "Pledged" : "Available"}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isPledged ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (isPledged) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Pledged gifts cannot be modified."),
                      ),
                    );
                  } else {
                    // Ensure the returned values are never null
                    Navigator.pop(context, {
                      'name': giftNameController.text.isNotEmpty
                          ? giftNameController.text
                          : "Unnamed Gift",
                      'category': selectedCategory,
                      'description': descriptionController.text.isNotEmpty
                          ? descriptionController.text
                          : "No Description",
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'pledged': isPledged,
                      'imageurl': imageURLController.text, // Send the image URL here
                    });
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
