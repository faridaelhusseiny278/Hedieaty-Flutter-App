import 'package:flutter/material.dart';

class FriendsGiftDetails extends StatefulWidget {
  final Map<String, dynamic> gift;

  FriendsGiftDetails({required this.gift});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<FriendsGiftDetails> {

  late TextEditingController giftNameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageURLController;
  String selectedCategory = "Electronics"; // Default category
  bool isPledged = false; // Default status

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the gift details
    giftNameController = TextEditingController(text: widget.gift['giftName']);
    descriptionController = TextEditingController(text: widget.gift['description'] ?? "");
    priceController = TextEditingController(text: widget.gift['price']?.toString() ?? "");
    imageURLController = TextEditingController(text: widget.gift['imageurl']?.toString() ?? "");
    selectedCategory = widget.gift['category'] ?? "Electronics";
    isPledged = widget.gift['pledged'] ?? false; // This line remains unchanged
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
        title: Text("{$widget.gift.giftName} Details"),
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

              // Gift Name
              TextField(
                controller: giftNameController,
                enabled: false, // Disable editing
                decoration: InputDecoration(
                  labelText: "Gift Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Description
              TextField(
                controller: descriptionController,
                enabled: false, // Disable editing
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
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: null, // Disable the dropdown
                //later on will make items to drop down flexible
                items: ["Tech", "Health","Books", "Toys", "Clothing","Experience","Home","Event","Fashion"]
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

              // Price
              TextField(
                controller: priceController,
                enabled: false, // Disable editing
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
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Image URL
              TextField(
                controller: imageURLController,
                enabled: false, // Disable editing
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Status Label with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
