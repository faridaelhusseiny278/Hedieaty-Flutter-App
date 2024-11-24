import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool pushNotification = true;
  bool emailNotification = true;
  bool smsNotification = false;
  bool weeklyNewsletter = true;

  // Sample data for events and associated gifts
  final Map<String, List<String>> events = {
    'Birthday Party': ['Gift 1', 'Gift 2', 'Gift 3'],
    'Wedding': ['Gift A', 'Gift B'],
    'Graduation': ['Gift X', 'Gift Y', 'Gift Z'],
  };

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
                    'Alison Danis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'UX/UI Designer',
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
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                    ),
                    TextField(
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
                borderRadius: BorderRadius.circular(12)
              ),
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
              children: events.entries.map((entry) {
                final eventName = entry.key;
                final giftList = entry.value;
                return _buildEventTile(eventName, giftList);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(String eventName, List<String> giftList) {
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
        children: giftList.map((gift) => _buildGiftTile(gift)).toList(),
      ),
    );
  }

  Widget _buildGiftTile(String giftName) {
    return ListTile(
      title: Text(giftName),
      leading: Icon(Icons.card_giftcard, color: Colors.green),
      onTap: () {
        // Perform action on gift click
        print('Selected gift: $giftName');
      },
    );
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
      activeColor: Colors.green, // Thumb color when the switch is on
      activeTrackColor: Colors.green.withOpacity(0.5), // Track color when the switch is on
      inactiveThumbColor: Colors.grey, // Thumb color when the switch is off
      inactiveTrackColor: Colors.grey.withOpacity(0.5), // Track color when the switch is off
    );
  }
}
