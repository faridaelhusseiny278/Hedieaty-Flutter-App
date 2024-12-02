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
  String selectedCategory = "Tech"; // Default category
  bool isPledged = false; // Default status

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the gift details
    giftNameController = TextEditingController(text: widget.gift['name']);
    descriptionController = TextEditingController(text: widget.gift['description'] ?? "");
    priceController = TextEditingController(text: widget.gift['price']?.toString() ?? "");
    imageURLController = TextEditingController(text: widget.gift['imageurl']?.toString() ?? "");
    selectedCategory = widget.gift['category'] ?? "Tech";
    if (widget.gift['status'] == true || widget.gift['status'] == 1) {
      isPledged = true;
    }
    else{
      isPledged = false;
    }
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
        title: Text("${widget.gift['name']} Details"),
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
                      child: imageURLController.text.isEmpty
                          ? Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey.shade600,
                      )
                          : Image.network(
                        imageURLController.text,
                        width: 120,
                        height: 120,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Return the image once it has loaded
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image, // Icon for failed image load
                            size: 50,
                            color: Colors.grey.shade600,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: 16),

              // Gift Name
              TextField(
                controller: giftNameController,
                enabled: false, // Disable editing
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600), // Prominent text
                decoration: InputDecoration(
                  labelText: "Gift Name",
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Prominent label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Make background white
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Description
              TextField(
                controller: descriptionController,
                enabled: false, // Disable editing
                maxLines: 3,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600), // Prominent text
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Prominent label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Make background white
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: null, // Disable the dropdown
                items: ["Tech", "Health", "Books", "Toys", "Clothing", "Experience", "Home", "Event", "Fashion"]
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Prominent label
                ),
              ),
              SizedBox(height: 16),

              // Price
              TextField(
                controller: priceController,
                enabled: false, // Disable editing
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600), // Prominent text
                decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Prominent label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Make background white
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),

              // Image URL
              TextField(
                controller: imageURLController,
                enabled: false, // Disable editing
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600), // Prominent text
                decoration: InputDecoration(
                  labelText: "Image URL",
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Prominent label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Make background white
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
