import 'package:flutter/material.dart';
import 'package:hedieatyfinalproject/Controllers/event_controller.dart';
import 'package:hedieatyfinalproject/Controllers/gift_controller.dart';
import 'package:hedieatyfinalproject/Controllers/user_controller.dart';
import 'package:hedieatyfinalproject/Models/gift_model.dart';
import 'package:hedieatyfinalproject/Views/welcome_screen.dart';
import 'my_pledged_gifts_page.dart';
import '../database.dart';
import '../Models/user_model.dart';
import '../Models/Event.dart';
import '../Models/friend_event.dart';
class ProfilePage extends StatefulWidget {
  final int userid;
  DatabaseService dbService = DatabaseService();
  ProfilePage({required this.userid, required this.dbService});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> user; // Store the current user's data
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late List<Map<String, dynamic>> events;

  UserController user_controller = UserController();
  EventController event_controller = EventController();
  GiftController gift_controller = GiftController();



  String? nameError;
  String? emailError;
  String? phoneError;
  String? addressError;

  late bool pushNotification;
  late bool emailNotification;
  late bool smsNotification ;
  bool isLoading = true;
  var imageurl;
  List<String> imageOptions = [
    'assets/free/3d-illustration-with-online-avatar_23-2151303043.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303045.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303053.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303055.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303080.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303097.jpg',
    'assets/free/3d-illustration-with-online-avatar_23-2151303093.jpg',
    'assets/free/3d-rendering-hair-style-avatar-design_23-2151869121.jpg',
    'assets/free/3d-rendering-hair-style-avatar-design_23-2151869153.jpg',
    'assets/free/df5f5b1b174a2b4b6026cc6c8f9395c1.jpg',
    'assets/free/young-man-with-glasses-avatar_1308-173760.jpg',
    'assets/istockphoto-1296058958-612x612.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  void _loadUserData() async {
    try {
      final rawUser = await user_controller.getUserById(widget.userid);
      print("raw user is $rawUser");
      final rawEvents = await event_controller.getEventsForUser(widget.userid);


      events = [];

      for (var rawEvent in rawEvents) {
        final modifiableEvent = Map<String, dynamic>.from(rawEvent);

        final gifts = await gift_controller.getGiftsForEvent(modifiableEvent['eventId']);
        modifiableEvent['gifts'] = gifts;
        events.add(modifiableEvent);
      }

      setState(() {
        isLoading = false;
        this.user = Map<String, dynamic>.from(rawUser!);
        this.events = events;
        imageurl = rawUser['imageurl'];

        nameController = TextEditingController(text: user['name']);
        emailController = TextEditingController(text: user['email']);
        phoneController = TextEditingController(text: user['phonenumber']);
        addressController = TextEditingController(text: user['address']);
        emailNotification= user['notification_preferences'].contains('Email Notifications');
        pushNotification = user['notification_preferences'].contains('Push Notifications');
        smsNotification = user['notification_preferences'].contains('SMS Notifications');

      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  void _logout() {
    // Navigate back to the welcome screen (do not pop)
    Navigator.pushReplacement(
        context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  }


  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
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

  Future<void> _validateEmail(String email) async {
    DatabaseService dbService = DatabaseService();
    setState(() {
      emailError = null; // Reset error
    });
    if (email.isEmpty) {
      setState(() {
        emailError = 'Email cannot be empty';
      });
    } else if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(email)) {
      setState(() {
        emailError = 'Enter a valid email address';
      });
    } else if (await user_controller.checkEmail(email, widget.userid)) {
      setState(() {
        emailError = 'Email already exists';
      });
    }
  }

  Future<void> _validatePhoneNumber(String phoneNumber) async {
    DatabaseService dbService = DatabaseService();
    setState(() {
      phoneError = null; // Reset error
    });
    if (phoneNumber.isEmpty) {
      setState(() {
        phoneError = 'Phone number cannot be empty';
      });
    } else if (!RegExp(r"^\+\d{10,15}$").hasMatch(phoneNumber)) {
      setState(() {
        phoneError = 'Enter a valid phone number starting with + and has 10-15 digits';
      });
    } else if (await user_controller.checkPhoneNumber(phoneNumber, widget.userid)) {
      setState(() {
        phoneError = 'Phone number already exists';
      });
    }
  }

  void _validateAddress(String address) {
    setState(() {
      if (address.isEmpty) {
        addressError = 'Address cannot be empty';
      } else if (!RegExp(r"^[a-zA-Z0-9\s,.-]{5,100}$").hasMatch(address)) {
        addressError = 'Enter a valid address (5-100 characters, no special characters)';
      } else {
        addressError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _logout, // Call the logout function
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    AssetImage(imageurl),
                  ),
                  SizedBox(height: 10),
                  Text(
                    this.user['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),
            // Profile Settings
            _buildSectionTitle('Edit Profile'),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // add a drop down menu to select an image
                    Text(
                      "Change Your Avatar",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16), // Adds a small gap between the text and the dropdown
                    DropdownButton<String>(
                      value: imageurl,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          imageurl = newValue!;
                        });
                      },
                      items: imageOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(value),
                          ),
                        );
                      }).toList(),
                    ),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: nameError,
                      ),
                      onChanged: (value) => _validateName(value),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: emailError,
                      ),
                      onChanged: (value) => _validateEmail(value),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        errorText: phoneError,
                      ),
                      onChanged: (value) => _validatePhoneNumber(value),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        errorText: addressError,
                      ),
                      onChanged: (value) => _validateAddress(value),
                    ),
                  ],
                ),
              ),
            ),
            // Notifications Settings
            _buildSectionTitle('Notification Settings'),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSwitchTile('Push Notification', pushNotification,
                            (value) {
                          setState(() {
                            pushNotification = value;
                          });
                        }),
                    _buildSwitchTile('Email Notification', emailNotification,
                            (value) {
                          setState(() {
                            emailNotification = value;
                          });
                        }),
                    _buildSwitchTile('SMS Notification', smsNotification,
                            (value) {
                          setState(() {
                            smsNotification = value;
                          });
                        }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ExpansionTile(
              title: Text(
                'My Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: this.events.map((event) {
                final eventName = event['eventName'] ?? 'Unnamed Event';
                return _buildEventTile(eventName, event['gifts']);
              }).toList(),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Pledged Gifts Page
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PledgedListPage(
                       userid: widget.userid,
                        dbService: widget.dbService,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View My Pledged Gifts',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (nameError != null || emailError != null || phoneError != null || addressError != null) {
            // Show SnackBar with specific error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(nameError ?? emailError ?? phoneError ?? addressError ?? 'Please fix the errors'),
                backgroundColor: Colors.red, // Red for error messages
              ),
            );
          } else if (nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
            // Show SnackBar if any fields are empty
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill in all fields'),
                backgroundColor: Colors.orange, // Orange for missing fields
              ),
            );
          } else {
            // If there are no errors and all fields are filled, save the profile
            _saveProfile();
          }
        },
        child: Icon(Icons.save),
        backgroundColor: (nameError == null &&
            emailError == null &&
            phoneError == null &&
            addressError == null &&
            nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            addressController.text.isNotEmpty)
            ? Colors.green
            : Colors.grey, // Green if everything is valid, grey if disabled
      ),

    );
  }

  void _saveProfile() async {
    user['name'] = nameController.text;
    user['email'] = emailController.text;
    user['phonenumber'] = phoneController.text;
    user['address'] = addressController.text;
    user['imageurl'] = imageurl;
    List<String> preferences = [];
    print('pushNotification: $pushNotification');
    if (pushNotification) preferences.add('Push Notifications');
    if (emailNotification) preferences.add('Email Notifications');
    if (smsNotification) preferences.add('SMS Notifications');
    user['notification_preferences'] = preferences.join(', ');

    try {
      // Save the updated user data to the database
      await user_controller.updateUserData(widget.userid, user);
      setState(() {
        print('Profile updated: $user');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
      activeColor: Colors.green,
      activeTrackColor: Colors.green.withOpacity(0.5),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.withOpacity(0.5),
    );
  }

  Widget _buildEventTile(String eventName, List<Map<String, dynamic>> giftList) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white70,
      child: ExpansionTile(
        title: Text(
          eventName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: giftList.map((gift) {
          final giftName = gift['giftName'] ?? 'Unnamed Gift';
          return _buildGiftTile(giftName);
        }).toList(),
      ),
    );
  }


  Widget _buildGiftTile(String giftName) {
    return ListTile(
      title: Text(giftName),
      leading: Icon(Icons.card_giftcard, color: Colors.green),
      onTap: () {
        print('Selected gift: $giftName');
      },
    );
  }
}
