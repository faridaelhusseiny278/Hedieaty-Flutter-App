import 'package:flutter/material.dart';
// import 'my_pledged_gifts_page.dart';
import '../lib/database.dart';
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

  bool pushNotification = true;
  bool emailNotification = true;
  bool smsNotification = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data from the database
    user = widget.Database.firstWhere((u) => u['userid'] == widget.userid);
    print("user is $user");
    events = user['events'];
    print("events is $events");
    // Initialize controllers with user's data
    nameController = TextEditingController(text: user['name']);
    emailController = TextEditingController(text: user['email']);
    phoneController = TextEditingController(text: user['phonenumber']);
    addressController = TextEditingController(text: user['address'] ?? "");
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
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
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
                    user['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user['role'] ?? 'No role defined',
                    style: TextStyle(color: Colors.grey),
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
            // Expandable "Your Events" List
            ExpansionTile(
              title: Text(
                'Your Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: this.events.map((event) {
                final eventName = event['eventName'] ?? 'Unnamed Event';
                final giftList = List<Map<String, dynamic>>.from(event['gifts'] ?? []);
                return _buildEventTile(eventName, giftList);
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
                      builder: (context) => PledgedListPage(userid: widget.userid,Database: widget.Database),
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

  void _saveProfile() {
    setState(() {
      user['name'] = nameController.text;
      user['email'] = emailController.text;
      user['phonenumber'] = phoneController.text;
      user['address'] = addressController.text;
    });
    print('Profile updated: $user');
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
