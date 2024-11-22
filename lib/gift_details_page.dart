import 'package:flutter/material.dart';

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
  String selectedCategory = "Electronics"; // Default category
  bool isPledged = false; // Default status
  String giftImageUrl = ""; // Store the uploaded image URL (if any)

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the gift details
    giftNameController = TextEditingController(text: widget.giftDetails['name']);
    descriptionController =
        TextEditingController(text: widget.giftDetails['description'] ?? "");
    priceController =
        TextEditingController(text: widget.giftDetails['price']?.toString() ?? "");
    selectedCategory = widget.giftDetails['category'] ?? "Electronics";
    isPledged = widget.giftDetails['pledged'] ?? false; // This line remains unchanged
  }

  @override
  void dispose() {
    giftNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // Method to simulate image upload
  void _uploadImage() {
    // For simplicity, we simulate an image upload and set a placeholder URL
    setState(() {
      giftImageUrl =
      "https://via.placeholder.com/150"; // Replace with actual upload logic
    });
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
                      backgroundImage: giftImageUrl.isNotEmpty
                          ? NetworkImage(giftImageUrl)
                          : null,
                      child: giftImageUrl.isEmpty
                          ? Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey.shade600,
                      )
                          : null,
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _uploadImage,
                          child: Container(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Gift Name
              TextField(
                controller: giftNameController,
                enabled: !isPledged,
                decoration: InputDecoration(
                  labelText: "Gift Name",
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                  // You can add other decoration options here
                ),
              ),

              SizedBox(height: 16),

              // Price Input
              TextField(
                controller: priceController,
                enabled: !isPledged,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Status: ${isPledged ? "Pledged" : "Available"}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: isPledged,
                    onChanged: (value) {
                      // Prevent toggling to Available if currently Pledged
                      if (isPledged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Pledged gifts cannot be modified."),
                          ),
                        );
                      } else {
                        setState(() {
                          isPledged = value;
                        });
                      }
                    },
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
                      'name': giftNameController.text.isNotEmpty ? giftNameController.text : "Unnamed Gift",
                      'category': selectedCategory,
                      'description': descriptionController.text.isNotEmpty ? descriptionController.text : "No Description",
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'pledged': isPledged,
                      'image': giftImageUrl,
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
