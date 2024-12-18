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
  late TextEditingController imageURLController = TextEditingController();
  String selectedCategory = "Tech"; // Default category
  bool isPledged = false; // Default status
  String? nameError;
  String? imageUrlError;
  String? priceError;

  @override
  void initState() {
    super.initState();
    giftNameController = TextEditingController(text: widget.giftDetails['giftName']);
    descriptionController = TextEditingController(text: widget.giftDetails['description'] ?? "");
    priceController = TextEditingController(text: widget.giftDetails['price']?.toString() ?? "");
    imageURLController = TextEditingController(text: widget.giftDetails['imageurl']?.toString() ?? "");
    selectedCategory = widget.giftDetails['category'] ?? "Tech";
    isPledged = (widget.giftDetails['pledged'] == 0 || widget.giftDetails['pledged'] == false) ? false: true;
  }

  void _validateName(String name) {
    setState(() {
      if (name.isEmpty) {
        nameError = 'Name cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z\s]{3,50}$").hasMatch(name)) {
        nameError = 'Enter a valid name (3-50 alphabetic characters)';
      } else {
        nameError = null;
      }
    });
  }
  void _validateImageURL(String url) {
    setState(() {
       if (!RegExp(r"^(http|https):\/\/[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$").hasMatch(url)) {
        imageUrlError = 'Enter a valid URL';
      } else {
         imageUrlError = null;
      }
    });
  }
  void _validatePrice(String price) {
    setState(() {
      if (price.isEmpty) {
        priceError = 'Price cannot be empty';
      } else if (!RegExp(r"^[0-9]*$").hasMatch(price)) {
        priceError = 'Enter a valid price';
      } else {
        priceError = null;
      }
    });
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
        title: Text("${widget.giftDetails['giftName']} Details"),
        backgroundColor: Colors.deepPurple,
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
                  errorText: nameError,
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
                onChanged: (name) => _validateName(name),
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
                items: ["Tech", "Health", "Books", "Toys", "Clothing", "Experience", "Home", "Event", "Fashion","other"]
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
                  errorText: priceError,
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
                onChanged: (price) => _validatePrice(price),
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageURLController,
                enabled: !isPledged,
                onChanged: (url) => _validateImageURL(url),
                decoration: InputDecoration(
                  labelText: "Image URL",
                  errorText: imageUrlError,
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
                  }
                  else if (nameError !=null  ||  giftNameController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(nameError ?? 'Please fill in all fields'),
                        backgroundColor: Colors.red, // Set the background color to red for errors
                      ),
                    );
                  }
                  else {
                    Navigator.pop(context, {
                      'giftid': widget.giftDetails['giftid'],
                      'giftName': giftNameController.text.isNotEmpty
                          ? giftNameController.text
                          : "Unnamed Gift",
                      'category': selectedCategory,
                      'description': descriptionController.text.isNotEmpty
                          ? descriptionController.text
                          : "No Description",
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'pledged': isPledged,
                      'imageurl': imageURLController.text.isNotEmpty? imageURLController.text: "" // Send the image URL here
                    });
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: (nameError == null && priceController.text.isNotEmpty && descriptionController.text.isNotEmpty)
                          ? Colors.deepPurple
                          : Colors.grey, // Greyed out color when disabled
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
