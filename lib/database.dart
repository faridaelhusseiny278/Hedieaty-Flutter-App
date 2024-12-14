import 'package:hedieatyfinalproject/friend_event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


class DatabaseService {
  static DatabaseService? _dbService;
  Database? _database;

  // Singleton pattern to ensure only one instance of DatabaseService
  Future<Database> get db async {
    if (_database == null) {
      _database = await init();
    }
    return _database!;
  }
  Future<int> insertData(String SQL) async {
    Database myData = await db;
    return await myData.rawInsert(SQL);
  }


  Future<Database> init() async {
    print ("i'm in init database noww!!!");
    String path = join(await getDatabasesPath(), 'hedeaty.db');
    if (await databaseExists(path)) {
      print("database already exists");
      return await openDatabase(path);
    }

    // await deleteDatabase(path);
    // print("database deleted");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''CREATE TABLE Users (
          userid INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phonenumber TEXT,
          email TEXT,
          address TEXT,
          notification_preferences TEXT,
          imageurl TEXT
        )''');

        await db.execute('''CREATE TABLE Events (
          eventId INTEGER PRIMARY KEY AUTOINCREMENT,
          eventName TEXT,
          eventDate Date,
          eventLocation TEXT,
          description TEXT,
          Status TEXT,
          category TEXT,
          userID INTEGER,
          FOREIGN KEY(userID) REFERENCES Users(userid)
        )''');

        await db.execute('''CREATE TABLE Gifts (
          giftid INTEGER PRIMARY KEY AUTOINCREMENT,
          giftName TEXT,
          description TEXT,
          category TEXT,
          price REAL,
          imageurl TEXT,
          pledged BOOLEAN,
          eventID INTEGER,
          FOREIGN KEY(eventID) REFERENCES Events(eventId)
        )''');

        await db.execute('''CREATE TABLE Friends (
          userID INTEGER,
          friendID INTEGER,
          PRIMARY KEY (userID, friendID),
          FOREIGN KEY(userID) REFERENCES Users(userid),
          FOREIGN KEY(friendID) REFERENCES Users(userid)
        )''');

        await db.execute('''CREATE TABLE Pledges (
          giftID INTEGER,
          userID INTEGER,
          FOREIGN KEY(giftID) REFERENCES Gifts(giftid),
          FOREIGN KEY(userID) REFERENCES Users(userid)
        )''');

        // Insert users
        String insertUsersSQL = ''' 
    INSERT INTO Users (userid, name, phonenumber, email, address, notification_preferences, imageurl) 
    VALUES
      (0, 'Alice in wondeland', '+1234567890', 'alice@example.com', '123 Wonderland St, Fantasy City', 'Push Notifications, Email Notifications, SMS Notifications',"assets/istockphoto-1296058958-612x612.jpg"),
      (1, 'Bob', '+1987654321', 'bob@example.com', '456 Oak Ave, Citytown', 'Email Notifications, SMS Notifications', "assets/istockphoto-1371904269-612x612.jpg"),
      (2, 'Charlie', '+1122334455', 'charlie@example.com', '789 Pine Rd, Suburbia', 'SMS Notifications, Push Notifications',"assets/istockphoto-1417086080-612x612.jpg"),
      (3, 'David', '+1998765432', 'david@example.com', '12 Elm St, Downtown', 'Email Notifications, SMS Notifications',"assets/young-smiling-man-adam-avatar-600nw-2107967969.png"),
      (4, 'Eve', '+1222333444', 'eve@example.com', '56 Maple Rd, Greenfield', 'SMS Notifications, Push Notifications',"assets/young-smiling-woman-mia-avatar-600nw-2127358541.png"),
      (5, 'Frank', '+1333444555', 'frank@example.com', '88 Birch St, Lakeside', 'Email Notifications, Push Notifications', "assets/istockphoto-1296058958-612x612.jpg"),
      (7, 'Farida', '+128456', 'Farida@example.com', '11 Maple St, Townville', 'SMS Notifications, Push Notifications', "assets/istockphoto-1296058958-612x612.jpg")
     
  ''';

        await db.execute(insertUsersSQL);


        // Insert events for Alice, Bob, Charlie, David, Eve, and Frank
        String insertEventsSQL = '''
    INSERT INTO Events (eventId, eventName, eventDate, eventLocation, category, Status, userid, description)
    VALUES
      (1, 'Birthday Bash', '2024-12-10', 'Alice''s House', 'Birthday', 'Upcoming', 0, 'Alice''s 30th Birthday Celebration'),
      (2, 'Wedding Anniversary', '2024-10-05', 'Luxury Hotel', 'Social', 'past', 0, 'Celebrating Alice and her partner''s wedding anniversary'),
      (9, 'Housewarming Party', '2024-11-15', 'Alice''s New Home', 'Housewarming', 'Upcoming', 0, 'Alice''s Housewarming Party at her new place'),
      (10, 'Christmas Celebration', '2024-12-25', 'Alice''s House', 'Holiday', 'Upcoming', 0, 'Traditional family Christmas celebration'),
      (11, 'New Year Eve Party', '2024-12-31', 'City Center', 'Celebration', 'Upcoming', 0, 'City-wide New Year celebration'),
      (3, 'Graduation Party', '2024-11-29', 'Bob''s College', 'Celebration', 'Current', 1, 'Bob''s graduation ceremony and party'),
      (14, 'Housewarming Party', '2024-07-15', 'Bob''s New Apartment', 'Housewarming', 'Upcoming', 1, 'Housewarming party at Bob''s new apartment'),
      (15, 'Birthday Celebration', '2024-08-10', 'Bob''s Backyard', 'Birthday', 'Upcoming', 1, 'Bob''s birthday celebration at his backyard'),
      (16, 'New Year''s Eve Party', '2024-12-31', 'Bob''s House', 'Celebration', 'Upcoming', 1, 'Celebrating New Year''s Eve at Bob''s house'),
      (17, 'Christmas Dinner', '2024-12-25', 'Bob''s House', 'Holiday', 'Upcoming', 1, 'Bob''s Christmas dinner with family and friends'),
      (4, 'Housewarming', '2024-12-01', 'Charlie''s New House', 'Social', 'Current', 2, 'Charlie''s housewarming event with friends'),
      (5, 'Christmas Party', '2024-12-25', 'David''s Apartment', 'Holiday', 'Upcoming', 3, 'Holiday party at David''s apartment'),
      (6, 'Baby Shower', '2025-01-15', 'Eve''s House', 'Celebration', 'Upcoming', 4, 'Eve''s baby shower party with close friends and family'),
      (7, 'New Year Party', '2024-01-01', 'Frank''s Mansion', 'Celebration', 'Upcoming', 5, 'New Year party at Frank''s mansion'),
      (8, 'Birthday', '2025-2-1', 'Farida''s House', 'Birthday', 'Upcoming', 7, 'My 21 Birthday')
  ''';


        await db.execute(insertEventsSQL);

        // Insert gifts for Alice, Bob, Charlie, David, Eve, and Frank
        String insertGiftsSQL = '''
    INSERT INTO Gifts (giftid, giftName, category, pledged, imageurl, price, description, eventID)
    VALUES
      (1, 'Smartwatch', 'Tech', TRUE, 'https://example.com/smartwatch.jpg', 200.0, 'A sleek smartwatch with fitness tracking features.', 1),
      (2, 'Fitness Tracker', 'Health', TRUE, 'https://example.com/fitnesstracker.jpg', 50.0, 'A high-quality fitness tracker that helps monitor my workouts, heart rate, and daily activity.', 1),
      (3, 'Romantic Dinner Voucher', 'Experience', FALSE, 'https://example.com/dinner.jpg', 100.0, 'A voucher for a romantic dinner at a 5-star restaurant.', 2),
      (13, 'Wine Glass Set', 'Home', FALSE, 'https://example.com/wineglassset.jpg', 40.0, 'None', 9),
      (14, 'Christmas Tree Decoration Set', 'Home', FALSE, 'https://example.com/christmasdecorations.jpg', 30.0, 'A complete set of decorations for the perfect Christmas tree.', 10),
      (15, 'Party Supplies', 'Event', FALSE, 'https://example.com/partysupplies.jpg', 50.0, 'A complete set of party supplies including balloons, decorations, and tableware, perfect for hosting a fun and memorable event.', 11),
      (4, 'Laptop', 'Tech', FALSE, 'https://example.com/laptop.jpg', 1000.0, 'A powerful laptop for all my work and play needs.', 3),
      (5, 'Camera', 'Tech', FALSE, 'https://example.com/camera.jpg', 500.0, 'A high-quality digital camera that captures stunning photos and videos.', 3),
      (16, 'Smart Home Speaker', 'Tech', FALSE, 'https://example.com/smartspeaker.jpg', 150.0, 'A cutting-edge smart speaker that integrates seamlessly with my home.', 14),
      (17, 'Home Decor Set', 'Home', FALSE, 'https://example.com/homedecor.jpg', 75.0, 'A stylish and elegant home decor set that includes decorative items such as candles, vases, and throw pillows.', 14),
      (18, 'Teddy Bear', 'Toys', FALSE, 'https://example.com/giftcard.jpg', 50.0, 'A soft and cuddly teddy bear made from plush fabric.', 15),
      (19, 'Party Decorations', 'Event', FALSE, 'https://example.com/partydecorations.jpg', 40.0, 'A complete set of vibrant party decorations, including balloons, banners, and streamers.', 16),
      (20, 'Christmas Tree', 'Home', FALSE, 'https://example.com/christmastree.jpg', 100.0, 'A complete set of decorations for the perfect Christmas tree.', 17),
      (6, 'Wine Glass Set', 'Home', TRUE, 'https://example.com/wineglasses.jpg', 40.0, 'None', 4),
      (7, 'Bluetooth Speaker', 'Tech', TRUE, 'https://example.com/speaker.jpg', 120.0, 'A smart speaker that connects with your home devices.', 5),
      (8, 'Winter Jacket', 'Fashion', TRUE, 'https://example.com/jacket.jpg', 150.0, 'A stylish and warm winter jacket, perfect for keeping cozy during the cold season.', 5),
      (9, 'Baby Stroller', 'Toys', FALSE, 'https://example.com/stroller.jpg', 300.0, 'A comfortable and secure baby stroller designed for easy mobility.', 6),
      (10, 'Baby Monitor', 'Toys', TRUE, 'https://example.com/monitor.jpg', 80.0, 'A high-quality baby monitor with video and audio capabilities.', 6),
      (11, 'Portable Charger', 'Tech', TRUE, 'https://example.com/charger.jpg', 25.0, 'A compact and powerful portable charger designed to keep my devices powered on the go.', 7),
      (12, 'Smart Thermostat', 'Home', TRUE, 'https://example.com/thermostat.jpg', 200.0, 'None', 7)
  ''';

        await db.execute(insertGiftsSQL);



        // Insert friendships between users
        String insertFriendsSQL = '''
    INSERT INTO Friends (userID, friendID)
    VALUES
      (0, 1), (0, 2), (0, 5), (0, 4), 
      (0,3), (0,7), 
      (1, 2), (1, 5), (1, 3), 
      (1,7),(1,4),
      (2, 3), (2, 5), (2,7),
      (3, 4), (3, 7), 
      (4, 5)
  ''';
        await db.execute(insertFriendsSQL);



        String insertPledgesSQL = '''
        INSERT INTO Pledges (giftID, userID)
        VALUES
        -- Alice's pledges
          (1, 1), -- Bob pledges to gift Alice a Smartwatch
          (2,1),
        (6, 0), -- Alice pledges to gift Bob a Laptop
        (8,0 ), -- Alice pledges to gift Bob a Winter Jacket
        (7, 2), -- Charlie pledges to gift Bob a Camera
        (11,4), -- Eve pledges to gift Bob a Smart Home Speaker
        (12,4), -- Eve pledges to gift Bob a Home Decor Set
        (9,5), -- Frank pledges to gift Bob a Baby Stroller
        -- Charlie's pledges
        (6, 3),
        (10,7) 
       
        
 ''' ;
        await db.execute(insertPledgesSQL);
        print("Sample data inserted successfully!");


        },
    );
  }
  // query table pledges to get the user id who pledged each gift which is an int
  Future <int> getPledges(int giftid) async {
    // delete from table table pledges where user id = 3 and gift id = 6
    Database myData = await db;
    int pledgedUser = await getPledgesFromFirebase(giftid);
    print("pledgedUser from firebase is $pledgedUser");
    List<Map<String, dynamic>> result = await myData.rawQuery('SELECT userID FROM Pledges WHERE giftID = $giftid');
    if (result.isNotEmpty) {
      return result.first['userID'] as int;
    }
    else {
      return -1;
    }
  }
  Future<int> getPledgesFromFirebase(int giftid) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users");
    final DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      if (snapshot.value is List) {
        // Look for pledged gifts of each user and if giftid matches the gift ID passed, then return the user ID
        final usersList = snapshot.value as List;

        for (var user in usersList)
        {
          if (user == null) {
            continue;
          }
          if (user['pledgedgifts'] is List) {
            print("pledgedgifts is list, for user id ${user['userid']}");
            print("user['pledgedgifts'] is ${user['pledgedgifts']}");
            final pledgedGifts = user['pledgedgifts'] as List;
            for (var gifts in pledgedGifts) {
              if (gifts == null) {
                continue;
              } else {
                for (var gift in gifts) {
                  if (gift == giftid) {
                    print("yess gift is $gift and giftid is $giftid");
                    return user['userid'] as int;
                  }
                }
              }
            }
          }
          else if (user['pledgedgifts'] is Map)
          {
            final pledgedGifts = user['pledgedgifts'] as Map;
            print("pledgedGifts is $pledgedGifts for user id ${user['userid']}");
            print("gift id is $giftid");
            for (var key in pledgedGifts.keys)
            {
              var values = pledgedGifts[key];
              if (values == null) {
                continue;
              }
              print("values is $values");
              for (var value in values) {
                if (value==null){
                  continue;
                }
                if (value == giftid) {
                  print("value is $value");
                  print("giftid is $giftid");
                  return user['userid'] as int;
                }
              }
            }
          }
        }
        print("No match found in the users list, now returning -1");
        return -1; // Return -1 if no match is found in the users list
      }
    } else {
      print("Snapshot doesn't exist");
      return -1; // Return -1 if the snapshot doesn't exist
    }
    print("Default return -1");
    return -1; // Default return if no condition matches
  }


  Future <void> syncDatabasewithFirebase(int userid) async {
    //   check if user data is the same
    //   1- get all users from firebase
    //   2- get all users from sqlite
    //   3- compare the 2 lists
    //   4- if the lists are not the same print the differences
    //   5- if the lists are the same print "the data is the same"
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
        "Users/$userid");
    final DataSnapshot snapshot = await dbRef.get();
    Database myData = await db;
    if (snapshot.exists) {
      if (snapshot.value is Map) {
        final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
        // print("usersMap is $usersMap");
        final List<Map<String, dynamic>> localUser = await myData.rawQuery(
            'SELECT * FROM Users WHERE userid = ${usersMap['userid']}');
        final Map<String, dynamic> result = localUser.first;
        if (result['phonenumber'] != usersMap['phonenumber']) {
          print("phonenumber is different for user ${usersMap['userid']}");
        }
        if (result['email'] != usersMap['email']) {
          print("email is different for user ${usersMap['userid']}");
        }
        if (result['name'] != usersMap['name']) {
          print("name is different for user ${usersMap['userid']}");
        }
        if (result['imageurl'] != usersMap['imageurl']) {
          print("imageurl is different for user ${usersMap['userid']}");
        }
        if (result['address'] != usersMap['address']) {
          print("address is different for user ${usersMap['userid']}");
        }
        for (var notification in usersMap['notification_preferences']) {
          final normalizedNotification = notification.toString();
          final List<String> normalizedDatabasePreferences = result['notification_preferences']
              .toString()
              .split(',')
              .map((s) => s.trim()) // Trim each item to remove extra spaces
              .toList();


          if (!normalizedDatabasePreferences.contains(normalizedNotification)) {
            print("user doesn't have $normalizedNotification notification preference");
            print("Database Notifications: ${normalizedDatabasePreferences}");
          }
        }

        //     now get the events for that user from the database
        final List<Map<String, dynamic>> localEvents = await myData.rawQuery(
            'SELECT * FROM Events WHERE userID = ${usersMap['userid']}');
        // print("usersMap['events'] is ${usersMap['events']}");
        if (usersMap['events'] is List) {
          final List<Map<String, dynamic>> events =
          (usersMap['events'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          for (var event in events) {
            final Map<String, dynamic> result = localEvents.firstWhere((
                element) => element['eventId'] == event['eventId']);
            if (result['eventName'] != event['eventName']) {
              print(
                  "eventName is different for event ${event['eventId']} for user ${usersMap['userid']}");
            }
            if (result['eventDate'] != event['eventDate']) {
              print(
                  "eventDate is different for event ${event['eventId']} for user ${usersMap['userid']}");
            }
            if (result['eventLocation'] != event['eventLocation']) {
              print(
                  "eventLocation is different for event ${event['eventId']} for user ${usersMap['userid']}");
            }
            String normalizedDatabaseDescription = result['description']
                .replaceAll("''", "'");
            String normalizedFirebaseDescription = event['description']
                .replaceAll("''", "'");

            if (normalizedDatabaseDescription !=
                normalizedFirebaseDescription) {
              print(
                  "description is different for event ${event['eventId']} for user ${usersMap['userid']}");
              print(
                  "where the value of description in database is $normalizedDatabaseDescription and the value of description in firebase is $normalizedFirebaseDescription");
            }
            if (result['Status'] != event['Status']) {
              print(
                  "Status is different for event ${event['eventId']} for user ${usersMap['userid']}");
            }
            if (result['category'] != event['category']) {
              print(
                  "category is different for event ${event['eventId']} for user ${usersMap['userid']}");
            }
            //     now get the gifts for that event from the database
            final List<Map<String, dynamic>> localGifts = await myData.rawQuery(
                'SELECT * FROM Gifts WHERE eventID = ${event['eventId']}');
            print("event['gifts'] is ${event['gifts']}");
            int pledged = 0;
            // remove nulls
            final List<Map<String, dynamic>> gifts = (event['gifts'] as List)
                .where((element) => element != null && element is Map) // Exclude null and non-Map elements
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();


            print("gifts are $gifts");
            for (var gift in gifts) {
              final Map<String, dynamic> result = localGifts.firstWhere((
                  element) => element['giftid'] == gift['giftid']);
              if (gift['pledged'] == true) {
                pledged = 1;
              }
              else {
                pledged = 0;
              }
              if (result['giftName'] != gift['giftName']) {
                print(
                    "giftName is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
              }
              if (result['category'] != gift['category']) {
                print(
                    "category is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
              }
              if (result['price'] != gift['price']) {
                print(
                    "price is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
              }
              if (result['imageurl'] != gift['imageurl']) {
                print(
                    "imageurl is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
              }

              String normalizedDatabaseDescription = result['description']
                  .replaceAll("''", "'");
              String normalizedFirebaseDescription = gift['description']
                  .replaceAll("''", "'");
              if (normalizedDatabaseDescription !=
                  normalizedFirebaseDescription) {
                print(
                    "description is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
                print(
                    "where the value of description in database is $normalizedDatabaseDescription and the value of description in firebase is $normalizedFirebaseDescription");
              }
              if (result['pledged'] != pledged) {
                print(
                    "pledged is different for gift ${gift['giftid']} for event ${event['eventId']} for user ${usersMap['userid']}");
                print(
                    "where the value of pledged in database is ${result['pledged']} and the value of pledged in firebase is ${pledged}");
              }
            }
          }
        }


        //   now compare the friends
        final List<Map<String, dynamic>> localFriends = await myData.rawQuery(
            'SELECT * FROM Friends WHERE userID = ${usersMap['userid']} or friendID = ${usersMap['userid']}');
        // print("usersMap['friends'] is ${usersMap['friends']}");
        List<int> friendListinDatabase = localFriends
            .where((friend) => friend['userID'] == userid || friend['friendID'] == userid)
            .map((friend) => friend['userID'] == userid ? friend['friendID'] as int : friend['userID'] as int)
            .toList();


        if (usersMap['friends'] is Map){
          final List<int> friendsList = [];
          usersMap['friends'].forEach((key, value) {
            friendsList.add(value);
          });

          for (var friend in friendsList) {
            if (!friendListinDatabase.contains(friend)) {
              print("user ${usersMap['userid']} is not friends with user $friend");
              print("where the friends in database are $friendListinDatabase and the friends in firebase are $friendsList");
            }
          }
        }
        else if (usersMap['friends'] is List){
          for (var friend in usersMap['friends']) {
            if (!friendListinDatabase.contains(friend)) {
              print("user ${usersMap['userid']} is not friends with user $friend");
              print("where the friends in database are $friendListinDatabase and the friends in firebase are ${usersMap['friends']}");
            }
          }
        }



      //   now compare the pledgedgifts
          final List<Map<String, dynamic>> localPledges = await myData.rawQuery('SELECT * FROM Pledges WHERE userID = ${usersMap['userid']}');
          final List<int> pledgedGifts = localPledges.map((e) => e['giftID'] as int).toList();
          print("pledged gifts in database are $pledgedGifts");
          print("pledged gifts in firebase are ${usersMap['pledgedgifts']}");
          if (usersMap['pledgedgifts'] is List) {
            for (var pledges in usersMap['pledgedgifts']) {
              if (pledges == null) {
                continue;
              }
              for (var gift in pledges) {
                if (!pledgedGifts.contains(gift)) {
                  print(
                      "user ${usersMap['userid']} didn't pledge for gift ${gift}");
                }
              }
            }
          }
          else if (usersMap['pledgedgifts'] is Map) {
            final List<int> pledgedGifts_firebase = [];
            usersMap['pledgedgifts'].forEach((key, value) {
              for (var gift in value) {
                pledgedGifts_firebase.add(gift);
              }
            });
            for (var gift in pledgedGifts_firebase) {
              if (!pledgedGifts.contains(gift)) {
                print(
                    "user ${usersMap['userid']} didn't pledge for gift ${gift}");
              }
            }
          }

      }
      else if (snapshot.value is List) {
        print("users list value is list");
      }
    }
  }



  // close the braces
  // add user
  Future<int> addUser(int userId, String name, String email, String phonenumber, String address, List<String> notification_preferences) async {
    Database myData = await db;
    int id= await myData.rawInsert("INSERT INTO Users (userid, name, email, phonenumber, address, notification_preferences) VALUES (?, ?, ?, ?, ?, ?)",
        [userId, name, email, phonenumber, address, notification_preferences.join(",")]);
    return id;
  }

  Future<List<Map<String, dynamic>>> readData(String SQL) async {
    Database myData = await db;
    return await myData.rawQuery(SQL);
  }


  Future<int> deleteData(String SQL) async {
    Database myData = await db;
    return await myData.rawDelete(SQL);
  }

  Future<int> updateData(String SQL) async {
    Database myData = await db;
    return await myData.rawUpdate(SQL);
  }

  Future<Map<String, dynamic>?> getUserByIdforFriends(int userId) async {
    // Reference to the database for the specific user
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId");

    try {
      // Fetch the snapshot for the user's data
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Cast the data to Map<String, dynamic>
          final user = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
          return user;
        } else if (snapshot.value is List) {
          // If the data is a List, return the first element as a Map
          final user = (snapshot.value as List).first as Map<String, dynamic>;
          return user;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return null;
        }
      } else {
        print("No data found for user ID $userId.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      throw e;
    }
  }


  // Add event for user
  Future<int> addEventForUser(int userId, Event event) async {
    Database myData = await db;

    int Eventid= await myData.rawInsert("INSERT INTO Events (eventName, category, eventDate, eventLocation, description, Status, userID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [event.name, event.category, event.date.toString(), event.location, event.description, event.status, userId]);
    // await addEventForUserinFirebase(event, userId, Eventid);
    return Eventid;
  }


  Future<void> addEventForUserinFirebase(Event event, int userId, EventId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");

      // get the ids of all the events in this user node and set the new event with the highest id+1
      // but first check if event is list , if so set the id to the length +1
      // but if its a map set the id to the last key +1
      int EventId_for_firebase = 0;

      final DataSnapshot snapshot = await dbRef.get();
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          final List<int> eventIds = eventsMap.keys.map((e) => int.parse(e)).toList();
          EventId_for_firebase = eventIds.isEmpty ? 1 : eventIds.reduce((value, element) => value > element ? value : element) + 1;
        } else if (snapshot.value is List) {
          final List<dynamic> rawEvents = snapshot.value as List;
          EventId_for_firebase = rawEvents.length ;
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      }
      else {
        EventId_for_firebase = 0;
      }

      // Add the event to the user's events list
      await dbRef.child("${EventId_for_firebase}").set({
        'eventId': EventId,
        'eventName': event.name,
        'category': event.category,
        'eventDate': event.date.toString(),
        'eventLocation': event.location,
        'description': event.description,
        'Status': event.status,
      });
    } catch (e) {
      print("Error adding event: $e");
      throw e;
    }
  }
  // check if event exists in firebase given an event id and user id
  Future<bool> doesEventExistInFirebase(int eventId,int userId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          for (var event in eventsMap.values) {
            if (event['eventId'] == eventId) {
              return true;
            }
          }
          return false;
        }
          else if (snapshot.value is List) {
          final rawEvents = snapshot.value as List;
          for (var event in rawEvents) {
            if (event is Map && event['eventId'] == eventId) {
              return true;
            }
          }
          return false;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return false;
        }
      } else {
        print("No events found for user $userId.");
        return false;
      }
    } catch (e) {
      print("Error checking event existence: $e");
      throw e;
    }
  }

  // Add gift for user
  Future<int> addGiftForUser(Map<String,dynamic> gift , int userId) async {
    Database myData = await db;
    int id= await myData.rawInsert("INSERT INTO Gifts (giftName, category, price, imageurl, description, pledged, eventID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [gift['giftName'], gift['category'], gift['price'], gift['imageurl'], gift['description'], gift['pledged'], gift['eventID']]);

    // await addGiftForUserinFirebase(gift, userId,id);
    return id;
  }
  Future<void> addGiftForUserinFirebase(Map<String, dynamic> gift, int userId, int giftId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      int giftId_for_firebase = 0;

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);

          // Find the event associated with the provided eventID
          String? eventKey;
          eventsMap.forEach((key, value) {
            if (value is Map && value['eventId'] == gift['eventID']) {
              eventKey = key;
              if (value['gifts'] == null) {
                giftId_for_firebase = 0;
              } else {
                giftId_for_firebase = value['gifts'].length;
              }
            }
          });

          if (eventKey != null) {
            // Add the gift to the 'gifts' list under the specified event
            await dbRef.child("$eventKey/gifts/${giftId_for_firebase}").set({
              'giftid': giftId,
              'giftName': gift['giftName'],
              'category': gift['category'],
              'price': gift['price'],
              'imageurl': gift['imageurl'],
              'description': gift['description'],
              'pledged': gift['pledged'],
            });
            print("Added gift with ID $giftId to event ${gift['eventID']} for user $userId");
          } else {
            print("No matching event found for eventID ${gift['eventID']} for user $userId");
          }
        }
        else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;

          String? eventIndex;
          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event['eventId'] == gift['eventID']) {
              eventIndex = i.toString();
              if (event['gifts'] == null) {
                giftId_for_firebase = 0;
              } else {
                giftId_for_firebase = event['gifts'].length;
              }
              break;
            }
          }

          if (eventIndex != null) {
            // Add the gift to the 'gifts' list under the specified event
            await dbRef.child("$eventIndex/gifts/${giftId_for_firebase}").set({
              'giftid': giftId,
              'giftName': gift['giftName'],
              'category': gift['category'],
              'price': gift['price'],
              'imageurl': gift['imageurl'],
              'description': gift['description'],
              'pledged': gift['pledged'],
            });
            print("Added gift with ID $giftId to event ${gift['eventID']} for user $userId");
          } else {
            print("No matching event found for eventID ${gift['eventID']} for user $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error adding gift with ID $giftId to event ${gift['eventID']} for user $userId: $e");
      throw e;
    }
  }


  // check if the 2 users are friends
  Future<bool> areFriends(int currentUserId, int friendId) async {
    try {
      // Reference to the current user's "friends" node
      final DatabaseReference friendsRef = FirebaseDatabase.instance.ref("Users/${currentUserId}/friends");

      // Fetch the snapshot of the friends list
      final DataSnapshot snapshot = await friendsRef.get();

      if (snapshot.exists) {

        if (snapshot.value is Map) {
          // If the data is a Map, check if the friendId is present
          final friends = (snapshot.value as Map).values.map((e) => int.parse(e.toString())).toList();
          return friends.contains(friendId);
        } else if (snapshot.value is List) {
          // If the data is a List, check if the friendId is present
          final friends = List<int>.from(snapshot.value as List);
          return friends.contains(friendId);
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return false;
        }
      } else {
        print("No friends found for user ${currentUserId.toString()}.");
        return false;
      }
    } catch (e) {
      print("Error checking friendship between ${currentUserId.toString()} and ${friendId.toString()}: $e");
      throw e;
    }
  }

  // Update event for user
  Future<void> updateEventForUser(int userId, Event event) async {
    Database myData = await db;

    // Use parameterized query to avoid syntax issues and SQL injection
    await myData.rawUpdate(
        'UPDATE Events SET eventName = ?, category = ?, eventDate = ?, eventLocation = ?, description = ?, Status = ? WHERE userID = ? and eventId = ?',
        [
          event.name,
          event.category,
          event.date.toString(),
          event.location,
          event.description,
          event.status,
          userId,
          event.id,
        ]
    );
    // await updateEventForUserinFirebase(event, userId);

  }

  Future<void> updateEventForUserinFirebase(Event event, int userId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          // Convert the snapshot value to Map<String, dynamic>
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");

          // Iterate through the events map to find the matching eventId
          String? keyToUpdate;
          eventsMap.forEach((key, value) {
            if (value['eventId'] == event.id) {
              keyToUpdate = key;
            }
          });

          if (keyToUpdate != null) {
            // Prepare the updated event data
            final updatedEventData = {
              'eventId': event.id,
              'eventName': event.name,
              'eventLocation': event.location,
              'eventDate': (event.date).toString(),
              'category': event.category,
              'description': event.description,
              // Include other attributes you want to update here
            };

            // Update the event data with the matching key
            await dbRef.child(keyToUpdate!).update(updatedEventData);
            print("Updated event with key $keyToUpdate for eventId ${event.id}");
          } else {
            print("No matching event found for eventId ${event.id}");
          }
        } else if (snapshot.value is List) {
          print("snapshot value in update event is list");
          // Handle the case where the value is a list (in case of other data formats)
          final rawEvents = snapshot.value as List;

          // Iterate through the list to find the matching eventId
          String? keyToUpdate;
          for (var eventData in rawEvents) {
            if (eventData is Map) {
              if (eventData['eventId'] == event.id) {
                keyToUpdate = rawEvents.indexOf(eventData).toString();
              }
            }
          }

          if (keyToUpdate != null) {
            // Prepare the updated event data
            final updatedEventData = {
              'eventId': event.id,
              'eventName': event.name,
              'eventLocation': event.location,
              'eventDate': (event.date).toString(),
              'category': event.category,
              'description': event.description,
              // Include other attributes you want to update here
            };

            // Update the event with the matching key
            await dbRef.child(keyToUpdate).update(updatedEventData);
            print("Updated event with key $keyToUpdate for eventId ${event.id}");
          } else {
            print("No matching event found for eventId ${event.id}");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error updating events for user $userId: $e");
      throw e;
    }
  }





  // update gift for user
  Future<void> updateGiftForUser( Map<String,dynamic> gift, int giftid, int userId) async {
    Database myData = await db;


    // Use parameterized query to avoid syntax issues and SQL injection
    await myData.rawUpdate(
        'UPDATE Gifts SET giftName = ?, category = ?, price = ?, imageurl = ?, description = ?, pledged = ? WHERE giftid = ?',
        [
          gift['giftName'],
          gift['category'],
          gift['price'],
          gift['imageurl'],
          gift['description'],
          gift['pledged']==true?1:0,
          giftid,
        ]
    );
    // await updateGiftForUserinFirebase(gift, giftid,userId);
  //   print the gift with id 1
    var result = await myData.rawQuery('SELECT * FROM Gifts WHERE giftid = $giftid');
  }
  Future<void> updateGiftForUserinFirebase(Map<String, dynamic> gift, int giftid, int userId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);

          // Iterate through events to locate the gift to update
          String? eventKeyToUpdate;
          String? giftIndexToUpdate;

          eventsMap.forEach((eventKey, eventValue) {
            if (eventValue is Map && eventValue.containsKey('gifts')) {
              if (eventValue['gifts'] is List) {
                final giftsList = eventValue['gifts'] as List;
                for (var i = 0; i < giftsList.length; i++) {
                  if (giftsList[i] == null || giftsList[i] is! Map) {
                    print("giftsList[i] is null or not a map, ${giftsList[i]}");
                    continue;
                  }
                  if (giftsList[i]['giftid'] == giftid) {
                    eventKeyToUpdate = eventKey;
                    giftIndexToUpdate = i.toString();
                    break;
                  }
                }
              } else if (eventValue['gifts'] is Map) {
                final giftsMap = eventValue['gifts'] as Map;
                giftsMap.forEach((key, value) {
                  if (value == null || value is! Map) {
                    print("value is null or not a map, $value");
                    return;
                  }
                  if (value['giftid'] == giftid) {
                    eventKeyToUpdate = eventKey;
                    giftIndexToUpdate = key;
                    return;
                  }
                });
              }
            }
          });

          if (eventKeyToUpdate != null && giftIndexToUpdate != null) {
            // Update the gift data
            await dbRef
                .child("$eventKeyToUpdate/gifts/$giftIndexToUpdate")
                .update(gift);
            print("Updated gift with id $giftid for userId $userId in event $eventKeyToUpdate");
          } else {
            print("No matching gift found with id $giftid for userId $userId");
          }
        } else if (snapshot.value is List) {
          print("snapshot value in update gifts is list");
          final rawEvents = snapshot.value as List;

          String? eventIndexToUpdate;
          String? giftIndexToUpdate;

          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event.containsKey('gifts')) {
              if(event['gifts'] is List){
                final giftsList = event['gifts'] as List;
                print("gift List is $giftsList");
                for (var j = 0; j < giftsList.length; j++) {
                  if (giftsList[j] == null || giftsList[j] is! Map) {
                    print ("giftsList[j] is null or not a map, ${giftsList[j]}");
                    continue;
                  }
                  if (giftsList[j]['giftid'] == giftid) {
                    print("i is $i");
                    print("i to string is ${i.toString()}");
                   eventIndexToUpdate= i.toString();
                   print("eventIndexToUpdate is $eventIndexToUpdate");
                    giftIndexToUpdate = j.toString();
                    print("giftIndexToUpdate is $giftIndexToUpdate");
                    break;
                  }
                }
              }
              else if(event['gifts'] is Map){
                print("gifts is map");
                final giftsMap = event['gifts'] as Map;
                print("giftsMap is $giftsMap");
                giftsMap.forEach((key, value) {
                  if (value == null || value is! Map) {
                    print ("value is null or not a map, $value");
                    return;
                  }
                  if (value['giftid'] == giftid) {
                    eventIndexToUpdate = i.toString();
                    giftIndexToUpdate = key;
                    return;
                  }
                });
            }


          }
        }

          if (eventIndexToUpdate != null && giftIndexToUpdate != null) {
            print("eventIndexToUpdate is $eventIndexToUpdate");
            print("giftIndexToUpdate is $giftIndexToUpdate");
            await dbRef
                .child("$eventIndexToUpdate/gifts/$giftIndexToUpdate")
                .update(gift);
            print("Updated gift with id $giftid for userId $userId in event $eventIndexToUpdate");
          } else {
            print("No matching gift found with id $giftid for userId $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error updating gift for user $userId: $e");
      throw e;
    }
  }



  Future<List<int>> getUserFriendsIDs(int userId) async {
    // Reference to the database
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/friends");
    print("i'm hereee");

    try {
      // Fetch the snapshot from the "friends" node
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot is $snapshot");
      print("i'm hereee in datasnapshot");
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // If the data is a Map, handle as a map and extract the friend IDs
          final friends = (snapshot.value as Map).values.map((e) => int.parse(e.toString())).toList();
          return friends;
        } else if (snapshot.value is List) {
          // If the data is a List, handle as a list and extract the friend IDs
          print("friends snapshot value is a list and it is  ${snapshot.value}");
          // filter null from the friend ids before returning them
          final friends = (snapshot.value as List).where((e) => e != null).map((e) => int.parse(e.toString())).toList();
          return friends;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      }
      else {
        print("No friends found for this user.");
        return [];
      }
    } catch (e) {
      print("Error fetching friends: $e");
      throw e;
    }
  }


  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEventFriends(int eventId, int userId) async {
    try {
      // Reference to the user's events node
      final DatabaseReference eventsRef = FirebaseDatabase.instance.ref("Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Convert the snapshot data to a list of maps
          final events = (snapshot.value as Map).values.map((event) {
            return Map<String, dynamic>.from(event as Map);
          }).toList();
          // print("events are $events for user $userId");
          // print("event id is $eventId");

          // Loop through all events and find the event with the matching eventId
          for (var event in events) {
            if (event['eventId'] == eventId) {
              // Ensure the 'gifts' key exists and is a list of maps
              if (event['gifts'] is List) {
                return (event['gifts'] as List).map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else if (event['gifts'] is Map) {
                return (event['gifts'] as Map).values.map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else {
                print("Gifts for event $eventId are not in the expected format.");
                return [];
              }
            }
          }
        } else if (snapshot.value is List) {
          // Handle the case where the snapshot value is a List
          final events = (snapshot.value as List).map((event) {
            return Map<String, dynamic>.from(event as Map);
          }).toList();
          // print("events are $events for user $userId");
          // print("event id is $eventId");

          // Loop through all events and find the event with the matching eventId
          for (var event in events) {
            // print("event gifts are ${event['gifts']}");
            if (event['eventId'] == eventId) {
              // Ensure the 'gifts' key exists and is a list of maps
              if (event['gifts'] is List) {
                // print ("yes it is a list");
                return (event['gifts'] as List).map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else if (event['gifts'] is Map) {
                // print ("yes it is a map");
                return (event['gifts'] as Map).values.map((gift) {
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }
              else {
                print("Gifts for event $eventId are not in the expected format.");
                return [];
              }
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }

        // If no event with the given eventId is found
        print("Event with ID $eventId not found for user $userId.");
        return [];
      }
      else {
        print("No events found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching gifts for event $eventId: $e");
      throw e;
    }
  }


  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      // Reference to the database
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users");

      // Fetch the snapshot of the users node
      final DataSnapshot snapshot = await dbRef.get();
      print("snapshot is $snapshot");

      if (snapshot.exists) {
        print("snapshot exists");
        //
        if (snapshot.value is Map) {
          // If the data is a Map, loop through the values to find the user with the matching phone number
          final users = (snapshot.value as Map).values.map((user) {
            return Map<String, dynamic>.from(user as Map);
          }).toList();
          // print("users are $users");

          for (var user in users) {
            if (user['phonenumber'] == phoneNumber) {
              return user;
            }
          }
        } else if (snapshot.value is List) {
          // If the data is a List, loop through the list to find the user with the matching phone number
          final users = (snapshot.value as List)
              .where((user) => user != null) // Exclude null users
              .map((user) => Map<String, dynamic>.from(user as Map))
              .toList();
          print("users are $users");
          for (var user in users) {
            if (user['phonenumber'] == phoneNumber) {
              return user;
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return null;
        }
      } else {
        print("No users found in the database.");
        return null;
      }
    } catch (e) {
      print("Error fetching user by phone number: $e");
      throw e;
    }



  }


  Future<void> addFriend(int userId, int friendId) async {
    try {
      await addFriendinDatabase(userId, friendId);
      // Reference to the current user's friends node
      final DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref("Users/$userId/friends");

      // Reference to the friend's friends node
      final DatabaseReference friendFriendsRef = FirebaseDatabase.instance.ref("Users/$friendId/friends");
      int current_user_friendId_in_firebase = 0;
      int friend_friendId_in_firebase = 0;

      final DataSnapshot snapshot = await userFriendsRef.get();
      if (snapshot.exists) {
        if (snapshot.value is Map)
        {
          final user_friends_Map = Map<String, dynamic>.from(snapshot.value as Map);
          final List<int> current_user_friendIds = user_friends_Map.values.map((e) => int.parse(e.toString())).toList();
          current_user_friendId_in_firebase = current_user_friendIds.isEmpty ? 0 : current_user_friendIds.reduce((value, element) => value > element ? value : element) + 1;
        }
        else if
        (snapshot.value is List) {
          final List<dynamic> user_friends_ids = snapshot.value as List;
          current_user_friendId_in_firebase = user_friends_ids.length+1;
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      }
      await userFriendsRef.child(current_user_friendId_in_firebase.toString()).set(friendId);

      final DataSnapshot friendSnapshot = await friendFriendsRef.get();
      if (friendSnapshot.exists) {
        if (friendSnapshot.value is Map) {
          final friendsMap = Map<String, dynamic>.from(friendSnapshot.value as Map);
          final List<int> friendIds = friendsMap.values.map((e) => int.parse(e.toString())).toList();
          friend_friendId_in_firebase = friendIds.isEmpty ? 0 : friendIds.reduce((value, element) => value > element ? value : element) + 1;
        } else if (friendSnapshot.value is List) {
          final List<dynamic> friendIds = friendSnapshot.value as List;
          friend_friendId_in_firebase = friendIds.length+1 ;
        } else {
          print("Unexpected data format: ${friendSnapshot.value}");
        }
      }
      await friendFriendsRef.child(friend_friendId_in_firebase.toString()).set(userId);

      print("Friendship added: $userId and $friendId are now friends.");
    } catch (e) {
      print("Error adding friend: $e");
      throw e;
    }
  }
  Future<void> addFriendinDatabase(int userId, int friendId) async{
    Database myData = await db;
    // check if the entry exists in the database if so then delete it
    // select from table friends
    var result = await myData.rawQuery("SELECT * FROM Friends WHERE userID = $userId AND friendID = $friendId OR userID = $friendId AND friendID = $userId");
    print("result is $result");
    await myData.rawQuery("DELETE FROM Friends WHERE userID = $userId AND friendID = $friendId OR userID = $friendId AND friendID = $userId");

    await myData.rawInsert(
      'INSERT INTO Friends (userID, friendID) VALUES (?, ?)',
      [userId, friendId],
    );
  }






  // get event count for user
  Future<int> getEventCountForUserFriends(String userId) async {
    try {
      // Reference to the user's events node
      final DatabaseReference eventsRef = FirebaseDatabase.instance.ref("Users/$userId/events");

      // Fetch the snapshot of the events
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Count the number of events
        if (snapshot.value is List) {
          final eventCount = (snapshot.value as List).length;
          print("Event count for user $userId: $eventCount");
          return eventCount;
        } else if (snapshot.value is Map) {
          final eventCount = (snapshot.value as Map).length;
          print("Event count for user $userId: $eventCount");
          return eventCount;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return 0;
        }

      } else {
        print("No events found for user $userId.");
        return 0;
      }
    } catch (e) {
      print("Error fetching events for user $userId: $e");
      throw e;
    }
  }
Future <void> deletePldegedGiftsForUser(int userId, List<Event> eventsToDelete) async {
    Database myData = await db;
    int friendId;
    int giftid;
    for (var event in eventsToDelete) {
      var gifts = await myData.rawQuery("SELECT * FROM Gifts WHERE eventID = ${event.id}");
      for (var gift in gifts) {
        giftid = int.parse(gift['giftid'].toString());
        if (gift['pledged'] == 1 || gift['pledged'] == true) {
        //   get the friend id of the user who pledged the gift from firebase
          friendId= await getWhoHasPledgedGiftfromFirebase(userId,giftid) as int;
          print("friendId who has the pledged gift is $friendId");
          await updateGiftStatus(giftid, false,friendId, userId);
          print("gift with id $giftid is now unpledged");

        }
      }
    }
  }
  Future <int> getWhoHasPledgedGiftfromFirebase(int userId, int giftId) async {
    try{

     final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users");
     final DataSnapshot snapshot = await dbRef.get();
     print("snapshot value in getWhoHasPledgedGiftfromFirebase is ${snapshot.value}");
     final usersList = snapshot.value as List;
     print("usersMap is $usersList");
     for (var user in usersList) {
       if (user['userid'] == userId) {
         continue;
       }
       if (user['pledgedgifts'] is List) {
         print("user of pledged gifts is a list and it is ${user['pledgedgifts']}");
         // [null, [2,3], [9]]
         for (var pledges in user['pledgedgifts']) {
           print("pledges is $pledges");
           if (pledges == null) {
             continue;
           }
           for (var gift in pledges) {
             if (gift == giftId) {
               print("gift is $gift, while gift id is $giftId");
               print("user id is ${user['userid']}");
               return user['userid'];
           }
         }
       }


      }
       else if (user['pledgedgifts'] is Map) {
         print("user of pledged gifts is a map and it is ${user['pledgedgifts']}");
         // {1: [2,3], 2: [9]}
         final List<int> pledgedGifts_firebase = [];
         user['pledgedgifts'].forEach((key, value) {
           for (var gift in value) {
             pledgedGifts_firebase.add(gift);
           }
         });
         print("pledgedGifts_firebase is $pledgedGifts_firebase");
         for (var gift in pledgedGifts_firebase) {
            if (gift == giftId) {
              return user['userid'];
         }
       }

     }
  }
     return 0;

  }
    catch (e) {
      print("Error fetching pledged gifts for user $userId: $e");
      throw e;
    }
  }


  // Delete events for user
  Future<void> deleteEventsForUser(int userId, List<Event> eventsToDelete) async {
    Database myData = await db;
    for (var event in eventsToDelete) {
      await myData.rawDelete("DELETE FROM Events WHERE eventId = ${event.id}");
    }
    // await deleteEventsForUserinFirebase(userId, eventsToDelete);

  }
  Future<void> deleteEventsForUserinFirebase(int userId, List<Event> eventsToDelete) async {
    try {
      await deletePldegedGiftsForUser(userId, eventsToDelete);
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // Convert the snapshot value to Map<String, dynamic>
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");
          for (var eventToDelete in eventsToDelete) {
            // Iterate through the map to find the key with the matching eventId
            String? keyToDelete;
            // loop on each element in the eventsmap and check if the event id is equal to the event id to delete
            eventsMap.forEach((key, value) {
              if (value['eventId'] == eventToDelete.id) {
                keyToDelete = key;
              }
            });

            if (keyToDelete != null) {
              // Delete the event with the matching key
              await dbRef.child(keyToDelete!).remove();
              print("Deleted event with key $keyToDelete for eventId ${eventToDelete.id}");
            } else {
              print("No matching event found for eventId ${eventToDelete.id}");
            }
          }
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          // Handle the case where the value is a list (in case of other data formats)
          final rawEvents = snapshot.value as List;

          // Iterate through the list to find the matching eventId
          for (var eventToDelete in eventsToDelete) {
            String? keyToDelete;
            for (var eventData in rawEvents) {
              print("eventData is $eventData");
              if (eventData is Map) {
                print("yes it is a map");
                print("event data type is ${eventData.runtimeType}");
                if (eventData['eventId'] == eventToDelete.id) {
                  keyToDelete = rawEvents.indexOf(eventData).toString();
                }
              }
              else {
                print("Unexpected event data format: $eventData");
              }
            }

            if (keyToDelete != null) {
              // Delete the event with the matching key
              await dbRef.child(keyToDelete).remove();
              print("Deleted event with key $keyToDelete for eventId ${eventToDelete.id}");
            } else {
              print("No matching event found for eventId ${eventToDelete.id}");
            }
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error deleting events for user $userId: $e");
      throw e;
    }
  }




  Future<Map<String, dynamic>?> getUserById(int userId) async {
    Database myData = await db;
    var result = await myData.query(
      'Users',
      where: 'userid = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }


  Future<List<Map<String, dynamic>>> getEventsForUser(int userId) async {
    Database myData = await db;
    return await myData.rawQuery('SELECT * FROM Events WHERE userID = $userId');
  }

  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    Database myData = await db;
    return await myData.rawQuery('SELECT * FROM Gifts WHERE eventID = $eventId');
  }



  // delete gifts for user
  Future<void> deleteGiftsForUser(int giftId,int userId,int eventid) async {
    Database myData = await db;
    await myData.rawQuery("DELETE FROM Gifts WHERE giftid = $giftId");
    // await deleteGiftsForUserinFirebase(giftId, userId, eventid);
  }
  Future<void> deleteGiftsForUserinFirebase(int giftId, int userId, int eventId) async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/events");
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map) {
          print("snapshot value is map");
          final eventsMap = Map<String, dynamic>.from(snapshot.value as Map);
          print("eventsMap is $eventsMap");

          // Locate the event and gift to delete
          String? eventKeyToDelete;
          String? giftIndexToDelete;

          eventsMap.forEach((eventKey, eventValue) {
            if (eventValue is Map && eventValue['eventId'] == eventId) {
              print("eventValue is $eventValue");
              if (eventValue.containsKey('gifts')) {
                if (eventValue['gifts'] is List) {
                  final giftsList = eventValue['gifts'] as List;
                  for (var i = 0; i < giftsList.length; i++) {
                    if (giftsList[i]['giftid'] == giftId) {
                      eventKeyToDelete = eventKey;
                      giftIndexToDelete = i.toString();
                      break;
                    }
                  }
                }
                else if (eventValue['gifts'] is Map) {
                  final giftsMap = eventValue['gifts'] as Map;
                  giftsMap.forEach((key, value) {
                    if (value['giftid'] == giftId) {
                      eventKeyToDelete = eventKey;
                      giftIndexToDelete = key;
                    }
                  });
              }
            }

          }
            });

          if (eventKeyToDelete != null && giftIndexToDelete != null) {
            // Delete the gift
            await dbRef.child("$eventKeyToDelete/gifts/$giftIndexToDelete").remove();
            print("Deleted gift with id $giftId for userId $userId in event $eventId");
          } else {
            print("No matching gift found with id $giftId for eventId $eventId and userId $userId");
          }
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;

          String? eventIndexToDelete;
          String? giftIndexToDelete;

          for (var i = 0; i < rawEvents.length; i++) {
            final event = rawEvents[i];
            if (event is Map && event['eventId'] == eventId) {
              if (event.containsKey('gifts')) {
                if (event['gifts'] is List) {
                  print("gifts is list");
                  final giftsList = event['gifts'] as List;
                  for (var j = 0; j < giftsList.length; j++) {
                    if (giftsList[j]== null){
                      continue;
                    }
                    if (giftsList[j]['giftid'] == giftId) {
                      eventIndexToDelete = i.toString();
                      giftIndexToDelete = j.toString();
                      break;
                    }
                  }
                }
                else if (event['gifts'] is Map) {
                  print("gifts is map");
                  final giftsMap = event['gifts'] as Map;
                  giftsMap.forEach((key, value) {
                    if (value['giftid'] == giftId) {
                      eventIndexToDelete = i.toString();
                      giftIndexToDelete = key;
                    }
                  });
                }
              }
            }
          }

          if (eventIndexToDelete != null && giftIndexToDelete != null) {
            // Delete the gift
            await dbRef.child("$eventIndexToDelete/gifts/$giftIndexToDelete").remove();
            print("Deleted gift with id $giftId for userId $userId in event $eventId");
          } else {
            print("No matching gift found with id $giftId for eventId $eventId and userId $userId");
          }
        } else {
          print("Unexpected data format: ${snapshot.value}");
        }
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error deleting gift with id $giftId for userId $userId in event $eventId: $e");
      throw e;
    }
  }

  // Get all events for a user
  Future<List<Event>> getAllEventsForUser(int userId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Events WHERE userID = $userId');
    return result.map((event) => Event.fromMap(event)).toList();
  }
  Future<List<friendEvent>> getAllEventsForUserFriends(int userId) async{
    try{
      // Reference to the user's events node
      final DatabaseReference eventsRef = FirebaseDatabase.instance.ref("Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Check if the data is a Map (Firebase often uses Map<dynamic, dynamic>)
        if (snapshot.value is Map) {
          print("snapshot value is map");
          // Convert the snapshot value to Map<String, dynamic>
          final events = (snapshot.value as Map).values.map((event) {
            // Ensure dynamic types are cast to Map<String, dynamic>
            print("event is $event");
            return friendEvent.fromMap(Map<String, dynamic>.from(event as Map));
          }).toList();
          print("events are $events");

          return events;
        } else if (snapshot.value is List) {
          print("snapshot value is list");
          final rawEvents = snapshot.value as List;
          print("rawEvents are $rawEvents");

          // Iterate through each event and log it
          for (var i = 0; i < rawEvents.length; i++) {
            print("rawEvents[i] is ${rawEvents[i]}");
            if (rawEvents[i] == null) {
              continue;
            }
            if (rawEvents[i]['gifts'] == null) {
              rawEvents[i]['gifts'] = [];
            }
              // ignore nulls
              else if (rawEvents[i]['gifts'] is List) {
                rawEvents[i]['gifts'] = (rawEvents[i]['gifts'] as List)
                    .where((gift) => gift != null) // Exclude null elements
                    .map((gift) {
                  // Safely convert each non-null gift to a map
                  return Map<String, dynamic>.from(gift as Map);
                }).toList();
              }

            else if (rawEvents[i]['gifts'] is Map) {
              print("gifts is map");
              rawEvents[i]['gifts'] = Map<String, dynamic>.from(rawEvents[i]['gifts'] as Map);
            }
          }

          final events = rawEvents
              .where((event) => event != null) // Exclude null events
              .map((event) {
            try {
              // Ensure event is a Map<String, dynamic>
              final eventMap = Map<String, dynamic>.from(event as Map);

              // Normalize 'gifts' to always be a list of maps
              if (eventMap['gifts'] is List) {
                eventMap['gifts'] = (eventMap['gifts'] as List)
                    .where((gift) => gift is Map) // Exclude non-map entries
                    .map((gift) => Map<String, dynamic>.from(gift as Map))
                    .toList();
              } else if (eventMap['gifts'] == null) {
                eventMap['gifts'] = []; // Ensure 'gifts' is not null
              }

              // Pass the normalized event to the fromMap method
              return friendEvent.fromMap(eventMap);
            } catch (e) {
              print("Error processing event: $event, error: $e");
              return null; // Skip problematic events
            }
          }).whereType<friendEvent>() // Remove nulls from the final list
              .toList();

          print("Processed events: $events");
          return events;

        }
        else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      } else {
        print("No events found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching events for user $userId: $e");
      throw e;
    }
  }


//   get events for user (dont return an object)
  Future<List<Map<String, dynamic>>> getEventsForUserFriends(int userId) async {
    try {
      // Reference to the user's events node
      final DatabaseReference eventsRef = FirebaseDatabase.instance.ref("Users/$userId/events");

      // Fetch the snapshot of the events node
      final DataSnapshot snapshot = await eventsRef.get();

      if (snapshot.exists) {
        // Check if the data is a Map (Firebase often uses Map<dynamic, dynamic>)
        if (snapshot.value is Map) {
          // Convert the snapshot value to Map<String, dynamic>
          final events = (snapshot.value as Map).values.map((event) {
            // Ensure dynamic types are cast to Map<String, dynamic>
            return Map<String, dynamic>.from(event as Map);
          }).toList();

          return events;
        } else if (snapshot.value is List) {
          // If the data is a List, convert each item to Map<String, dynamic>
          final events = (snapshot.value as List)
              .map((event) => Map<String, dynamic>.from(event as Map))
              .toList();

          return events;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      } else {
        print("No events found for user $userId.");
        return [];
      }
    } catch (e) {
      print("Error fetching events for user $userId: $e");
      throw e;
    }
  }



//     create a table to delete a pledge
    Future<void> deletePledge(int userId, int giftId) async {
    Database myData = await db;
    await myData.rawQuery('DELETE FROM Pledges WHERE userID = $userId AND giftID = $giftId');
    }
//     get user pledged gifts by user id
    Future<List<Map<String, dynamic>>> getUserPledgedGifts(int userId) async {
    Database myData = await db;
    // use join to get the gifts pledged by the user
    return await myData.rawQuery('SELECT * FROM Gifts INNER JOIN Pledges ON Gifts.giftid = Pledges.giftID WHERE Pledges.userID = $userId');
    }
//     get event by gift id
    Future<Map<String, dynamic>> getEventByGiftId(int giftId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId)');

    return result.first ;
    }


//     get user by gift id
    Future<Map<String, dynamic>?> getUserbyGift(int giftId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Users WHERE userid IN (SELECT userID FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId))');
    return result.isNotEmpty ? result.first : null;
    }
  Future<void> printDatabase() async {
    final db = await openDatabase('hedeaty.db');
    // Replace 'tableName' with the name of the table you want to print
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    for (var table in tables) {
      final tableName = table['name'];
      if (tableName == 'sqlite_sequence') continue; // Skip system table
      print('Data from table: $tableName');
      final results = await db.rawQuery('SELECT * FROM $tableName');
      for (var row in results) {
        print(row);
      }
    }
  }


  Future<List<Map<String, dynamic>>> getPledgedGiftsWithDetailsfromDatabase(int userId) async {
    Database myData = await db;
    List<Map<String, dynamic>> pledgedGiftsWithDetails = [];
    var pledgedGifts = await getUserPledgedGifts(userId);
    print("pledged gifts for user $userId are $pledgedGifts");
    for (var gift in pledgedGifts) {
      var event = await getEventByGiftId(gift['giftid']);
      var friend = await getUserbyGift(gift['giftid']);
      print("friend who has the gift is $friend");
      pledgedGiftsWithDetails.add({
        "giftid": gift['giftid'],
        "giftName": gift['giftName'],
        "category": gift['category'],
        "price": gift['price'],
        "imageurl": gift['imageurl'],
        "description": gift['description'],
        "pledged": gift['pledged'],
        "eventName": event!['eventName'],
        "eventDate": event['eventDate'],
        "friendName": friend!['name'],
        "friendImageUrl": friend['imageurl'],
        "friendId": friend['userid'],
      });
    }
    return pledgedGiftsWithDetails;
  }

  Future<List<Map<String, dynamic>>> getPledgedGiftsWithDetailsfromfirebase(int userId) async {
    try {
      // Reference to the user's pledged gifts node
      final DatabaseReference pledgedGiftsRef =
      FirebaseDatabase.instance.ref("Users/$userId/pledgedgifts");

      // Fetch the snapshot of the pledged gifts
      final DataSnapshot pledgedGiftsSnapshot = await pledgedGiftsRef.get();

      // Prepare the result list
      List<Map<String, dynamic>> pledgedGiftsWithDetails = [];

      if (pledgedGiftsSnapshot.exists && pledgedGiftsSnapshot.value is Map) {
        final pledgedGiftsMap = pledgedGiftsSnapshot.value as Map;

        // Iterate through friends in the pledged gifts map
        for (var friendId in pledgedGiftsMap.keys) {
          final friendGifts = pledgedGiftsMap[friendId] as Map;

          // Fetch friend details
          final DatabaseReference friendRef = FirebaseDatabase.instance.ref("Users/$friendId");
          final DataSnapshot friendSnapshot = await friendRef.get();

          if (friendSnapshot.exists && friendSnapshot.value is Map) {
            final friendData = friendSnapshot.value as Map;
            final String friendName = friendData["name"] ?? "Unknown";
            final String friendImageUrl = friendData["imageurl"] ?? "";
            final int friendId = friendData["userid"];

            // Fetch friend's events
            final DatabaseReference eventsRef = friendRef.child("events");
            final DataSnapshot eventsSnapshot = await eventsRef.get();

            if (eventsSnapshot.exists && eventsSnapshot.value is List) {
              final eventsList = eventsSnapshot.value as List;

              // Iterate through events
              for (var eventIndex = 0; eventIndex < eventsList.length; eventIndex++) {
                final eventData = eventsList[eventIndex];

                // Skip null entries
                if (eventData == null) continue;

                if (eventData is Map && eventData.containsKey("gifts") && eventData["gifts"] is List) {
                  final giftsList = eventData["gifts"] as List;

                  // Iterate through gifts in the event
                  for (var giftIndex = 0; giftIndex < giftsList.length; giftIndex++) {
                    final giftData = giftsList[giftIndex];

                    // Skip null entries
                    if (giftData == null) continue;

                    // Check if the gift is pledged by the user
                    final uniqueGiftId = friendGifts.keys.firstWhere(
                            (key) => friendGifts[key] == giftData["giftid"],
                        orElse: () => null);

                    if (uniqueGiftId != null) {
                      // Add gift details to the result list
                      pledgedGiftsWithDetails.add({
                        "giftid": giftData["giftid"],
                        "giftName": giftData["giftName"],
                        "category": giftData["category"],
                        "pledged": giftData["pledged"],
                        "friendName": friendName,
                        "friendImageUrl": friendImageUrl,
                         "friendId": friendId,
                        "eventName": eventData["eventName"],
                        "eventDate": eventData["eventDate"],
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }

      return pledgedGiftsWithDetails;
    } catch (e) {
      print("Error fetching pledged gifts with details for user $userId: $e");
      throw e;
    }
  }


  //   check if user id has pledged a gift id
  Future<bool> hasPledgedGift(int userId, int giftId) async {
    try {
      // Reference to the user's pledged gifts node
      final DatabaseReference pledgedGiftsRef =
      FirebaseDatabase.instance.ref("Users/$userId/pledgedgifts");

      // Fetch the snapshot of the pledged gifts
      final DataSnapshot snapshot = await pledgedGiftsRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        print("snapshot value is map");
        final pledgedGiftsMap = snapshot.value as Map;
        print("pledgedGiftsMap is $pledgedGiftsMap");

        for (var userKey in pledgedGiftsMap.keys) {
          print("userKey is $userKey");
          print("pledgedGiftsMap[userKey] is ${pledgedGiftsMap[userKey]}");
          final userGifts = pledgedGiftsMap[userKey] as List;
          print("userGifts is $userGifts");

          // Check if the giftId exists in the nested structure
          for (var giftKey in userGifts) {
            if (giftKey == giftId) {
              return true; // Gift ID found
            }
          }
        }
        return false; // Gift ID not found
      } else if (snapshot.exists && snapshot.value is List<Object?>) {
        print("snapshot value is list");
        // Handle case where snapshot is a List
        final pledgedGiftsList = snapshot.value as List<Object?>;

        for (var entry in pledgedGiftsList) {
          if (entry is Map) {
            print("yes it is a map");
            // Check each map entry
            for (var userGifts in entry.values) {
              if (userGifts==giftId) {
                return true;
              }
            }
          }
          else if (entry is List) {
            print("yes it is a list");
            for (var userGifts in entry) {
             if (userGifts==giftId) {
               return true;
             }
            }
          }
        }
        return false; // Gift ID not found
      } else {
        print("Unexpected data structure for pledgedgifts: ${snapshot.value}");
        return false; // Structure is invalid or empty
      }
    } catch (e) {
      print("Error checking pledged gift for user $userId: $e");
      throw e;
    }
  }


  Future<void> updateGiftStatusindatabase(int giftId, bool status, int userId, int friendId) async {
    Database myData = await db;

    await myData.rawUpdate('UPDATE Gifts SET pledged = ? WHERE giftid = ?', [status==true? 1:0, giftId]);

    if (status) {
      await myData.rawInsert('INSERT INTO Pledges (giftID, userID) VALUES (?, ?)', [giftId, userId]);
    } else {
      await myData.rawDelete('DELETE FROM Pledges WHERE giftID = $giftId AND userID = $userId');
    }



  }
  Future<void> updateGiftStatus(int giftId, bool status, int userId, int friendId) async {
    // Update the gift status in the local database (assumed to be another function)
    await updateGiftStatusindatabase(giftId, status, userId, friendId);

    // Reference to the friend's events node
    final DatabaseReference friendEventsRef = FirebaseDatabase.instance.ref("Users/$friendId/events");

    // Fetch the snapshot of the friend's events
    final DataSnapshot eventsSnapshot = await friendEventsRef.get();

    try {
      // Check if the snapshot exists and handle it as a Map or List
      if (eventsSnapshot.exists) {
        // If the snapshot is a List
        if (eventsSnapshot.value is List) {
          print("event snapshot value is list");
          final List<dynamic> eventsList = eventsSnapshot.value as List<dynamic>;

          for (int eventIndex = 0; eventIndex < eventsList.length; eventIndex++) {
            final eventData = eventsList[eventIndex];

            if (eventData == null) continue;

            // Check if the event contains gifts
            if (eventData is Map && eventData.containsKey("gifts") && eventData["gifts"] is List) {
              final giftsList = eventData["gifts"] as List;

              // Iterate through the list of gifts
              for (int giftIndex = 0; giftIndex < giftsList.length; giftIndex++) {
                final giftData = giftsList[giftIndex];

                // Skip null entries
                if (giftData == null) continue;

                // Debug: Print gift data and the giftId we are looking for
                print("Gift data: $giftData");
                print("Gift ID to match in else if : $giftId");

                // Check if the giftId matches
                if (giftData is Map && giftData["giftid"] == giftId) {
                  print("yes gift data is map");
                  // Update the 'pledged' status in the friend's events node
                  await friendEventsRef
                      .child("$eventIndex/gifts/$giftIndex/pledged")
                      .set(status);

                  // Reference to the pledged gifts for the user
                  final DatabaseReference pledgedGiftsRef = FirebaseDatabase.instance.ref("Users/$userId/pledgedgifts");

                  // Fetch the pledged gifts for the user
                  final DataSnapshot pledgedGiftsSnapshot = await pledgedGiftsRef.get();
                  if (pledgedGiftsSnapshot.exists) {
                    print ("pledgedGiftsSnapshot exists");
                    if (pledgedGiftsSnapshot.value is List)
                    {
                    print("pledgedGiftsSnapshot value is ${pledgedGiftsSnapshot.value}");
                    final pledgedGiftsListunmodifiable = pledgedGiftsSnapshot.value as List<dynamic>;
                    print("pledgedGiftsListunmodifiable is $pledgedGiftsListunmodifiable");
                    // shallow copy to another modifiable list
                    List<List<dynamic>> pledgedGiftsList = pledgedGiftsListunmodifiable
                        .map((e) => e == null
                        ? <dynamic>[0]
                        : List<dynamic>.from(e as List<dynamic>))
                        .toList();
                    print("pledgedGiftsList is $pledgedGiftsList");
                    if (status) {
                      // Ensure the index exists before accessing it
                       print("now adding the gift id $giftId to the list of friend $friendId");


                       if (friendId >= pledgedGiftsList.length) {
                         await pledgedGiftsRef.child(friendId.toString()).set(
                             [giftId]);
                       }
                       else {
                         if (!pledgedGiftsList[friendId].contains(giftId)) {
                           pledgedGiftsList[friendId].add(giftId);
                           await pledgedGiftsRef.child(friendId.toString()).set(
                               pledgedGiftsList[friendId]);
                         }
                       }

                    }
                    else {
                      if (friendId < pledgedGiftsList.length) {
                        print ("pledgedGiftslist at the index is ${pledgedGiftsList[friendId]}");
                        pledgedGiftsList[friendId].remove(giftId);
                        print("pledgedGiftslist after removing is ${pledgedGiftsList[friendId]}");
                        await pledgedGiftsRef.child(friendId.toString()).set(pledgedGiftsList[friendId]);
                      } else {
                        print("Friend ID index out of bounds.");
                      }
                    }

                    print("Gift status updated successfully.");
                    return; // Exit once the status is updated
                  }
                    else if (pledgedGiftsSnapshot.value is Map){
                      final pledgedGiftsMapUnmodifiable = pledgedGiftsSnapshot.value as Map;
                      print("pledgedGiftsMapUnmodifiable is $pledgedGiftsMapUnmodifiable");
                      Map<String, dynamic> pledgedGiftsMap = pledgedGiftsMapUnmodifiable
                          .map((key, value) => MapEntry(key, value == null
                          ? <dynamic>[0]
                          : List<dynamic>.from(value as List<dynamic>)));

                      print("pledgedGiftsMap is $pledgedGiftsMap");
                      if (status) {
                        if (pledgedGiftsMap.containsKey(friendId.toString())) {
                          final List<dynamic> friendGifts = pledgedGiftsMap[friendId.toString()];
                          if (!friendGifts.contains(giftId)) {
                            friendGifts.add(giftId);
                            await pledgedGiftsRef.child(friendId.toString()).set(friendGifts);
                          }
                        } else {
                          await pledgedGiftsRef.child(friendId.toString()).set([giftId]);
                        }
                      } else {
                        if (pledgedGiftsMap.containsKey(friendId.toString())) {
                          final List<dynamic> friendGifts = pledgedGiftsMap[friendId.toString()];
                          friendGifts.remove(giftId);
                          await pledgedGiftsRef.child(friendId.toString()).set(friendGifts);
                        }
                      }

                      print("Gift status updated successfully.");
                      return; // Exit once the status is updated
                    }
                    else{
                      print("Unexpected data format: ${pledgedGiftsSnapshot.value}");
                    }
                  }
                  else{
                  //   create a new pledged gift list
                    print("pledgedGiftsSnapshot does not exist");
                    if (status) {
                      await pledgedGiftsRef.child(friendId.toString()).set([giftId]);
                    }
                  }
                }
              }
            }
          }
          // If no matching gift was found in the friend's events
          print("Gift with ID $giftId not found in friend's events.");
        }
      } else {
        print("No events found for user $friendId.");
      }
    } catch (e) {
      print("Error updating gift status for gift $giftId: $e");
      throw e;
    }
  }


//   unpledge gift using gift id and user id
  Future<void> unpledgeGift(int userId, int giftId) async {
    Database myData = await db;
    await myData.rawQuery('DELETE FROM Pledges WHERE userID = $userId AND giftID = $giftId');
  //   make the gift status false
    await myData.rawQuery('UPDATE Gifts SET pledged = 0 WHERE giftid = $giftId');
  }


// update user data
  Future<void> updateUserData(int userId, Map<String, dynamic> userData) async {
    Database myData = await db;
    await myData.rawUpdate('''
    UPDATE Users
    SET name = ?, phonenumber = ?, email = ?, address = ?, notification_preferences = ?, imageurl = ?
    WHERE userid = ?
  ''', [
      userData['name'],
      userData['phonenumber'],
      userData['email'],
      userData['address'],
      userData['notification_preferences'],
      userData['imageurl'],
      userId,
    ]);
    await updateUserDatainFirebase(userId, userData);
  //   print the user data after update
    var result = await myData.rawQuery('SELECT * FROM Users WHERE userid = $userId');
    print("result after update is $result");
  }

}
Future<void> updateUserDatainFirebase(int userId, Map<String, dynamic> userData) async {
try{
  // convert user preferences ( a comma separated string) to a list
  if (userData.containsKey("notification_preferences")) {
    userData["notification_preferences"] = (userData["notification_preferences"] as String).split(",");
  }
  // Reference to the user's node
  final DatabaseReference userRef = FirebaseDatabase.instance.ref("Users/$userId");

  // Update the user data
  await userRef.update(userData);
  print("User data updated successfully.");
} catch (e) {
  print("Error updating user data: $e");
  throw e;
}

}
