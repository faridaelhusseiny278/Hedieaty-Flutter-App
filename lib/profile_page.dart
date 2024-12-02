import 'package:flutter/material.dart';
import 'my_pledged_gifts_page.dart';
import 'database.dart';
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

  late bool pushNotification;
  late bool emailNotification;
  late bool smsNotification ;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  void _loadUserData() async {
    try {
      final rawUser = await widget.dbService.getUserById(widget.userid);
      final rawEvents = await widget.dbService.getEventsForUser(widget.userid);

      events = [];

      for (var rawEvent in rawEvents) {
        final modifiableEvent = Map<String, dynamic>.from(rawEvent);

        final gifts = await widget.dbService.getGiftsForEvent(modifiableEvent['ID']);
        modifiableEvent['gifts'] = gifts;
        events.add(modifiableEvent);
      }

      setState(() {
        isLoading = false;
        this.user = Map<String, dynamic>.from(rawUser!);
        this.events = events;
        nameController = TextEditingController(text: user['name']);
        emailController = TextEditingController(text: user['email']);
        phoneController = TextEditingController(text: user['phonenumber']);
        addressController = TextEditingController(text: user['address']);
        emailNotification= user['preferences'].contains('email');
        pushNotification = user['preferences'].contains('popup');
        smsNotification = user['preferences'].contains('sms');

      });
    } catch (e) {
      print('Error loading user data: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [Icon(Icons.camera_alt_outlined)],
        title: Text('Profile'),
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
                    AssetImage('assets/istockphoto-1296058958-612x612.jpg'),
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
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: 'Address'),
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
                final eventName = event['name'] ?? 'Unnamed Event';
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
        onPressed: _saveProfile,
        child: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _saveProfile() async {
    user['name'] = nameController.text;
    user['email'] = emailController.text;
    user['phonenumber'] = phoneController.text;
    user['address'] = addressController.text;
    List<String> preferences = [];
    print('pushNotification: $pushNotification');
    if (pushNotification) preferences.add('popup');
    if (emailNotification) preferences.add('email');
    if (smsNotification) preferences.add('sms');
    user['preferences'] = preferences.join(', ');

    try {
      // Save the updated user data to the database
      await widget.dbService.updateUserData(widget.userid, user);
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
          final giftName = gift['name'] ?? 'Unnamed Gift';
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
