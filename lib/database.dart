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
      (0, 'Alice', '+1234567890', 'alice@example.com', '123 Wonderland St, Fantasy City', 'email, sms, popup',"assets/istockphoto-1296058958-612x612.jpg"),
      (1, 'Bob', '+1987654321', 'bob@example.com', '456 Oak Ave, Citytown', 'email, sms', "assets/istockphoto-1371904269-612x612.jpg"),
      (2, 'Charlie', '+1122334455', 'charlie@example.com', '789 Pine Rd, Suburbia', 'sms, popup',"assets/istockphoto-1417086080-612x612.jpg"),
      (3, 'David', '+1998765432', 'david@example.com', '12 Elm St, Downtown', 'email, popup',"assets/young-smiling-man-adam-avatar-600nw-2107967969.png"),
      (4, 'Eve', '+1222333444', 'eve@example.com', '56 Maple Rd, Greenfield', 'sms, popup',"assets/young-smiling-woman-mia-avatar-600nw-2127358541.png"),
      (5, 'Frank', '+1333444555', 'frank@example.com', 'frank@example.com', 'email, sms', "assets/istockphoto-1296058958-612x612.jpg")
  ''';

        await db.execute(insertUsersSQL);


        // Insert events for Alice, Bob, Charlie, David, Eve, and Frank
        String insertEventsSQL = '''
    INSERT INTO Events (eventId, eventName, eventDate, eventLocation, category, Status, userid, description)
    VALUES
      (1, 'Birthday Bash', '2024-12-10', 'Alice''s House', 'Birthday', 'Upcoming', 0, 'Alice''s 30th Birthday Celebration'),
      (2, 'Wedding Anniversary', '2024-10-05', 'Luxury Hotel', 'Social', 'Past', 0, 'Celebrating Alice and her partner''s wedding anniversary'),
      (9, 'Housewarming Party', '2024-11-15', 'Alice''s New Home', 'Housewarming', 'Upcoming', 0, 'Alice''s Housewarming Party at her new place'),
      (10, 'Christmas Celebration', '2024-12-25', 'Alice''s House', 'Holiday', 'Upcoming', 0, 'Traditional family Christmas celebration'),
      (11, 'New Year Eve Party', '2024-12-31', 'City Center', 'Celebration', 'Upcoming', 0, 'City-wide New Year celebration'),
      (3, 'Graduation Party', '2024-12-08', 'Bob''s College', 'Celebration', 'Current', 1, 'Bob''s graduation ceremony and party'),
      (14, 'Housewarming Party', '2024-07-15', 'Bob''s New Apartment', 'Housewarming', 'Upcoming', 1, 'Housewarming party at Bob''s new apartment'),
      (15, 'Birthday Celebration', '2024-08-10', 'Bob''s Backyard', 'Birthday', 'Upcoming', 1, 'Bob''s birthday celebration at his backyard'),
      (16, 'New Year''s Eve Party', '2024-12-31', 'Bob''s House', 'Celebration', 'Upcoming', 1, 'Celebrating New Year''s Eve at Bob''s house'),
      (17, 'Christmas Dinner', '2024-12-25', 'Bob''s House', 'Holiday', 'Upcoming', 1, 'Bob''s Christmas dinner with family and friends'),
      (4, 'Housewarming', '2024-12-01', 'Charlie''s New House', 'Social', 'Current', 2, 'Charlie''s housewarming event with friends'),
      (5, 'Christmas Party', '2024-12-25', 'David''s Apartment', 'Holiday', 'Upcoming', 3, 'Holiday party at David''s apartment'),
      (6, 'Baby Shower', '2025-01-15', 'Eve''s House', 'Celebration', 'Upcoming', 4, 'Eve''s baby shower party with close friends and family'),
      (7, 'New Year Party', '2024-01-01', 'Frank''s Mansion', 'Celebration', 'Upcoming', 5, 'New Year party at Frank''s mansion')
  ''';


        await db.execute(insertEventsSQL);

        // Insert gifts for Alice, Bob, Charlie, David, Eve, and Frank
        String insertGiftsSQL = '''
    INSERT INTO Gifts (giftid, giftName, category, pledged, imageurl, price, description, eventID)
    VALUES
      (1, 'Smartwatch', 'Tech', TRUE, 'https://example.com/smartwatch.jpg', 200.0, 'A sleek smartwatch with fitness tracking features.', 1),
      (2, 'Fitness Tracker', 'Health', TRUE, 'https://example.com/fitnesstracker.jpg', 50.0, 'A high-quality fitness tracker that helps monitor my workouts, heart rate, and daily activity.', 1),
      (3, 'Romantic Dinner Voucher', 'Experience', FALSE, 'https://example.com/dinner.jpg', 150.0, 'A voucher for a romantic dinner at a 5-star restaurant.', 2),
      (13, 'Wine Glass Set', 'Home', FALSE, 'https://example.com/wineglassset.jpg', 40.0, '', 9),
      (14, 'Christmas Tree Decoration Set', 'Home', FALSE, 'https://example.com/christmasdecorations.jpg', 30.0, 'A complete set of decorations for the perfect Christmas tree.', 10),
      (15, 'Party Supplies', 'Event', FALSE, 'https://example.com/partysupplies.jpg', 50.0, 'A complete set of party supplies including balloons, decorations, and tableware, perfect for hosting a fun and memorable event.', 11),
      (4, 'Laptop', 'Tech', TRUE, 'https://example.com/laptop.jpg', 1000.0, 'A powerful laptop for all my work and play needs.', 3),
      (5, 'Camera', 'Tech', TRUE, 'https://example.com/camera.jpg', 500.0, 'A high-quality digital camera that captures stunning photos and videos.', 3),
      (16, 'Smart Home Speaker', 'Tech', FALSE, 'https://example.com/smartspeaker.jpg', 150.0, 'A cutting-edge smart speaker that integrates seamlessly with my home.', 14),
      (17, 'Home Decor Set', 'Home', FALSE, 'https://example.com/homedecor.jpg', 75.0, 'A stylish and elegant home decor set that includes decorative items such as candles, vases, and throw pillows.', 14),
      (18, 'Teddy Bear', 'Toys', FALSE, 'https://example.com/giftcard.jpg', 50.0, 'A soft and cuddly teddy bear made from plush fabric.', 15),
      (19, 'Party Decorations', 'Event', FALSE, 'https://example.com/partydecorations.jpg', 40.0, 'A complete set of vibrant party decorations, including balloons, banners, and streamers.', 16),
      (20, 'Christmas Tree', 'Home', FALSE, 'https://example.com/christmastree.jpg', 100.0, 'A complete set of decorations for the perfect Christmas tree.', 17),
      (6, 'Wine Glass Set', 'Home', TRUE, 'https://example.com/wineglasses.jpg', 40.0, '', 4),
      (7, 'Bluetooth Speaker', 'Tech', TRUE, 'https://example.com/speaker.jpg', 120.0, 'A smart speaker that connects with your home devices.', 5),
      (8, 'Winter Jacket', 'Fashion', FALSE, 'https://example.com/jacket.jpg', 150.0, 'A stylish and warm winter jacket, perfect for keeping cozy during the cold season.', 5),
      (9, 'Baby Stroller', 'Toys', TRUE, 'https://example.com/stroller.jpg', 300.0, 'A comfortable and secure baby stroller designed for easy mobility.', 6),
      (10, 'Baby Monitor', 'Toys', TRUE, 'https://example.com/monitor.jpg', 80.0, 'A high-quality baby monitor with video and audio capabilities.', 6),
      (11, 'Portable Charger', 'Tech', TRUE, 'https://example.com/charger.jpg', 30.0, 'A portable charger that fits in your pocket for on-the-go power.', 7)
  ''';

        await db.execute(insertGiftsSQL);



        // Insert friendships between users
        String insertFriendsSQL = '''
    INSERT INTO Friends (userID, friendID)
    VALUES
      (0, 1), (0, 2), (0, 5), (0, 4),
      (1, 2), (1, 5), (1, 4), (1, 3), 
      (2, 3), (2, 5), 
      (3, 4), (3, 5), 
      (4, 5)
  ''';
        await db.execute(insertFriendsSQL);



        String insertPledgesSQL = '''
        INSERT INTO Pledges (giftID, userID)
        VALUES
        -- Alice's pledges
          (1, 2), -- Bob pledges to gift Alice a Smartwatch
        (2, 3), -- Charlie pledges to gift Alice a Fitness Tracker
        -- Bob's pledges
        (4, 1), -- Alice pledges to gift Bob a Laptop
        (5, 3), -- Charlie pledges to gift Bob a Camera
        -- Charlie's pledges
        (6, 4) -- David pledges to gift Charlie a Wine Glass Set
       
        
 ''' ;
        await db.execute(insertPledgesSQL);
        print("Sample data inserted successfully!");


        },
    );
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

    return await myData.rawInsert("INSERT INTO Events (eventName, category, eventDate, eventLocation, description, Status, userID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [event.name, event.category, event.date.toString(), event.location, event.description, event.status, userId]);
  }
  // Add gift for user
  Future<int> addGiftForUser(Map<String,dynamic> gift) async {
    Database myData = await db;


    int id= await myData.rawInsert("INSERT INTO Gifts (giftName, category, price, imageurl, description, pledged, eventID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [gift['giftName'], gift['category'], gift['price'], gift['imageurl'], gift['description'], gift['pledged'], gift['eventID']]);

    var result = await myData.rawQuery('SELECT * FROM Gifts');
    return id;
  }
  // check if the 2 users are friends
  Future<bool> areFriends(int currentUserId, int friendId) async {
    try {
      // Reference to the current user's "friends" node
      final DatabaseReference friendsRef = FirebaseDatabase.instance.ref("Users/${currentUserId.toString()}/friends");

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
  }
  // update gift for user
  Future<void> updateGiftForUser( Map<String,dynamic> gift, int giftid) async {
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
  //   print the gift with id 1
    var result = await myData.rawQuery('SELECT * FROM Gifts WHERE ID = $giftid');
  }


  Future<List<int>> getUserFriendsIDs(int userId) async {
    // Reference to the database
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/$userId/friends");
    print("i'm hereee");

    try {
      // Fetch the snapshot from the "friends" node
      final DataSnapshot snapshot = await dbRef.get();

      print("i'm hereee in datasnapshot");
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          // If the data is a Map, handle as a map and extract the friend IDs
          final friends = (snapshot.value as Map).values.map((e) => int.parse(e.toString())).toList();
          return friends;
        } else if (snapshot.value is List) {
          // If the data is a List, handle as a list of friend IDs
          final friends = List<int>.from(snapshot.value as List);
          return friends;
        } else {
          print("Unexpected data format: ${snapshot.value}");
          return [];
        }
      } else {
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
      } else {
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
          print("users are $users");

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
      // Reference to the current user's friends node
      final DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref("Users/$userId/friends");

      // Reference to the friend's friends node
      final DatabaseReference friendFriendsRef = FirebaseDatabase.instance.ref("Users/$friendId/friends");

      // Add the friendId to the user's friends list
      await userFriendsRef.push().set(friendId);

      // Add the userId to the friend's friends list
      await friendFriendsRef.push().set(userId);

      print("Friendship added: $userId and $friendId are now friends.");
    } catch (e) {
      print("Error adding friend: $e");
      throw e;
    }
  }
  // update gift status
  Future<void> updateGiftStatus(int giftId, bool status, int userId, int friendid) async {
    try {
      // Reference to the user's events node
      final DatabaseReference userEventsRef = FirebaseDatabase.instance.ref("Users/$friendid/events");

      // Fetch the snapshot of the user's events
      final DataSnapshot eventsSnapshot = await userEventsRef.get();

      if (eventsSnapshot.exists && eventsSnapshot.value is List) {
        final eventsList = eventsSnapshot.value as List;

        for (var eventIndex = 0; eventIndex < eventsList.length; eventIndex++) {
          final eventData = eventsList[eventIndex];

          // Skip null entries
          if (eventData == null) continue;

          // Check if event contains gifts
          if (eventData is Map && eventData.containsKey("gifts") && eventData["gifts"] is List) {
            final giftsList = eventData["gifts"] as List;

            for (var giftIndex = 0; giftIndex < giftsList.length; giftIndex++) {
              final giftData = giftsList[giftIndex];

              // Skip null entries
              if (giftData == null) continue;
              print("gift data is $giftData");
              print("gift id is $giftId");
              // Check if the giftId matches
              if (giftData is Map && giftData["giftid"] == giftId) {
                // Update the 'pledged' status
                print("Updating gift status for gift $giftId...");
                await userEventsRef
                    .child("$eventIndex/gifts/$giftIndex/pledged")
                    .set(status);

                // Add the gift ID to the pledged gifts list
                final DatabaseReference pledgedGiftsRef = FirebaseDatabase.instance.ref("Users/$userId/pledgedgifts");
                final DataSnapshot pledgedGiftsSnapshot = await pledgedGiftsRef.get();

                if (pledgedGiftsSnapshot.exists && pledgedGiftsSnapshot.value is List) {
                  final pledgedGifts = List<int>.from(pledgedGiftsSnapshot.value as List);

                  // Avoid duplicate entries
                  if (!pledgedGifts.contains(giftId)) {
                    pledgedGifts.add(giftId);
                    await pledgedGiftsRef.set(pledgedGifts);
                  }
                } else {
                  // Initialize pledged gifts list if it doesn't exist
                  await pledgedGiftsRef.set([giftId]);
                }

                print("Gift status updated successfully.");
                return;
              }
            }
          }
        }

        print("Gift with ID $giftId not found.");
      } else {
        print("No events found for user $userId.");
      }
    } catch (e) {
      print("Error updating gift status for gift $giftId: $e");
      throw e;
    }
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


  // Delete events for user
  Future<void> deleteEventsForUser(int userId, List<Event> eventsToDelete) async {
    Database myData = await db;
    for (var event in eventsToDelete) {
      await myData.rawDelete("DELETE FROM Events WHERE eventId = ${event.id}");
    }
    // return totalDeleted;
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
//   check if user id has pledged a gift id

  Future<bool> hasPledgedGift(int userId, int giftId) async {
    try {
      // Reference to the user's pledged gifts node
      final DatabaseReference pledgedGiftsRef =
      FirebaseDatabase.instance.ref("Users/$userId/pledgedgifts");

      // Fetch the snapshot of the pledged gifts
      final DataSnapshot snapshot = await pledgedGiftsRef.get();

      if (snapshot.exists) {
        if (snapshot.value is List) {
          final pledgedGifts = snapshot.value as List;

          // Check if the giftId is in the pledgedGifts list
          return pledgedGifts.contains(giftId);
        } else {
          print("Unexpected data format for pledgedgifts: ${snapshot.value}");
          return false;
        }
      } else {
        print("No pledged gifts found for user $userId.");
        return false;
      }
    } catch (e) {
      print("Error checking pledged gift for user $userId: $e");
      throw e;
    }
  }



  // delete gifts for user
  Future<void> deleteGiftsForUser(int giftId) async {
    Database myData = await db;
    await myData.rawQuery("DELETE FROM Gifts WHERE giftid = $giftId");
    print("done deleting");
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

          // Iterate through each event and log it
          for (var i = 0; i < rawEvents.length; i++) {
          //   cast each gift list to a map
            if (rawEvents[i]['gifts'] is List) {
              rawEvents[i]['gifts'] = (rawEvents[i]['gifts'] as List).map((gift) {
                return Map<String, dynamic>.from(gift as Map);
              }).toList();
            }
            else if (rawEvents[i]['gifts'] is Map) {
              rawEvents[i]['gifts'] = Map<String, dynamic>.from(rawEvents[i]['gifts'] as Map);
            }
          }

          // Convert events while excluding null entries
          final events = rawEvents
              .where((event) => event != null)
              .map((event) {
            try {
              // print("Processing event: $event");
              return friendEvent.fromMap(Map<String, dynamic>.from(event as Map));
            } catch (e) {
              print("Error processing event: $event, error: $e");
              return null; // Skip problematic events
            }
          })
              .whereType<friendEvent>() // Remove nulls from the final list
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
    Future<Map<String, dynamic>?> getEventByGiftId(int giftId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId)');
    return result.isNotEmpty ? result.first : null;
    }


//     get user by gift id
    Future<Map<String, dynamic>?> getUserbyGift(int giftId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Users WHERE userid IN (SELECT userID FROM Events WHERE eventId IN (SELECT eventID FROM Gifts WHERE giftid = $giftId))');
    return result.isNotEmpty ? result.first : null;
    }
  Future<List<Map<String, dynamic>>> getPledgedGiftsWithDetails(int userId) async {
    Database myData = await db;

    return await myData.rawQuery('''
    SELECT Gifts.*, Events.eventName AS eventName, Events.eventDate AS eventDate,
           Users.name AS friendName, Users.imageurl AS friendImageUrl
    FROM Gifts
    INNER JOIN Pledges ON Gifts.giftid = Pledges.giftID
    INNER JOIN Events ON Events.eventId = Gifts.eventID
    INNER JOIN Users ON Users.userid = Events.userID
    WHERE Pledges.userID = ?
  ''', [userId]);
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
  //   print the user data after update
    var result = await myData.rawQuery('SELECT * FROM Users WHERE userid = $userId');
    print("result after update is $result");
  }

}

