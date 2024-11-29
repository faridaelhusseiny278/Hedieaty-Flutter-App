import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Event.dart'; // Ensure this model is correctly defined

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
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phonenumber TEXT,
          email TEXT,
          address TEXT,
          preferences TEXT
        )''');

        await db.execute('''CREATE TABLE Events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date Date,
          location TEXT,
          description TEXT,
          status TEXT,
          category TEXT,
          userID INTEGER,
          FOREIGN KEY(userID) REFERENCES Users(ID)
        )''');

        await db.execute('''CREATE TABLE Gifts (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          description TEXT,
          category TEXT,
          price REAL,
          imageurl TEXT,
          status BOOLEAN,
          eventID INTEGER,
          FOREIGN KEY(eventID) REFERENCES Events(ID)
        )''');

        await db.execute('''CREATE TABLE Friends (
          userID INTEGER,
          friendID INTEGER,
          PRIMARY KEY (userID, friendID),
          FOREIGN KEY(userID) REFERENCES Users(ID),
          FOREIGN KEY(friendID) REFERENCES Users(ID)
        )''');

        await db.execute('''CREATE TABLE Pledges (
          giftID INTEGER,
          userID INTEGER,
          FOREIGN KEY(giftID) REFERENCES Gifts(ID),
          FOREIGN KEY(userID) REFERENCES Users(ID)
        )''');

        // Insert users
        String insertUsersSQL = ''' 
    INSERT INTO Users (ID, name, phonenumber, email, address, preferences) 
    VALUES
      (1, 'Alice', '+1234567890', 'alice@example.com', '123 Wonderland St, Fantasy City', 'email, sms, popup'),
      (2, 'Bob', '+1987654321', 'bob@example.com', '456 Oak Ave, Citytown', 'email, sms'),
      (3, 'Charlie', '+1122334455', 'charlie@example.com', '789 Pine Rd, Suburbia', 'sms, popup'),
      (4, 'David', '+1998765432', 'david@example.com', '12 Elm St, Downtown', 'email, popup'),
      (5, 'Eve', '+1222333444', 'eve@example.com', '56 Maple Rd, Greenfield', 'sms, popup'),
      (6, 'Frank', '+1333444555', 'frank@example.com', 'frank@example.com', 'email, sms')
  ''';

        await db.execute(insertUsersSQL);


        // Insert events for Alice, Bob, Charlie, David, Eve, and Frank
        String insertEventsSQL = '''
    INSERT INTO Events (ID, name, date, location, category, status, userid, description)
    VALUES
      (1, 'Birthday Bash', '2024-12-10', 'Alice''s House', 'Birthday', 'Upcoming', 1, 'Alice''s 30th Birthday Celebration'),
      (2, 'Wedding Anniversary', '2024-10-05', 'Luxury Hotel', 'Social', 'Past', 1, 'Celebrating Alice and her partner''s wedding anniversary'),
      (9, 'Housewarming Party', '2024-11-15', 'Alice''s New Home', 'Housewarming', 'Upcoming', 1, 'Alice''s Housewarming Party at her new place'),
      (10, 'Christmas Celebration', '2024-12-25', 'Alice''s House', 'Holiday', 'Upcoming', 1, 'Traditional family Christmas celebration'),
      (11, 'New Year Eve Party', '2024-12-31', 'City Center', 'Celebration', 'Upcoming', 1, 'City-wide New Year celebration'),
      (3, 'Graduation Party', '2024-11-29', 'Bob''s College', 'Celebration', 'Current', 2, 'Bob''s graduation ceremony and party'),
      (14, 'Housewarming Party', '2024-07-15', 'Bob''s New Apartment', 'Housewarming', 'Upcoming', 2, 'Housewarming party at Bob''s new apartment'),
      (15, 'Birthday Celebration', '2024-08-10', 'Bob''s Backyard', 'Birthday', 'Upcoming', 2, 'Bob''s birthday celebration at his backyard'),
      (16, 'New Year''s Eve Party', '2024-12-31', 'Bob''s House', 'Celebration', 'Upcoming', 2, 'Celebrating New Year''s Eve at Bob''s house'),
      (17, 'Christmas Dinner', '2024-12-25', 'Bob''s House', 'Holiday', 'Upcoming', 2, 'Bob''s Christmas dinner with family and friends'),
      (4, 'Housewarming', '2024-12-01', 'Charlie''s New House', 'Social', 'Current', 3, 'Charlie''s housewarming event with friends'),
      (5, 'Christmas Party', '2024-12-25', 'David''s Apartment', 'Holiday', 'Upcoming', 4, 'Holiday party at David''s apartment'),
      (6, 'Baby Shower', '2025-01-15', 'Eve''s House', 'Celebration', 'Upcoming', 5, 'Eve''s baby shower party with close friends and family'),
      (7, 'New Year Party', '2024-01-01', 'Frank''s Mansion', 'Celebration', 'Upcoming', 6, 'New Year party at Frank''s mansion')
  ''';


        await db.execute(insertEventsSQL);

        // Insert gifts for Alice, Bob, Charlie, David, Eve, and Frank
        String insertGiftsSQL = '''
    INSERT INTO Gifts (ID, name, category, status, imageurl, price, description, eventID)
    VALUES
      (1, 'Smartwatch', 'Tech', FALSE, 'https://example.com/smartwatch.jpg', 200.0, 'A sleek smartwatch with fitness tracking features.', 1),
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
      (1, 2), (1, 3), (1, 6), (1, 5),
      (2, 3), (2, 6), (2, 5), (2, 4), 
      (3, 4), (3, 6), 
      (4, 5), (4, 6), 
      (5, 6)
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
        -- David's pledges
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

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    Database myData = await db;
    var result = await myData.query(
      'Users',
      where: 'ID = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Add event for user
  Future<int> addEventForUser(int userId, Event event) async {
    Database myData = await db;

    return await myData.rawInsert("INSERT INTO Events (name, category, date, location, description, status, userID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [event.name, event.category, event.date.toString(), event.location, event.description, event.status, userId]);
  }
  // Add gift for user
  Future<int> addGiftForUser(Map<String,dynamic> gift) async {
    Database myData = await db;


    int id= await myData.rawInsert("INSERT INTO Gifts (name, category, price, imageurl, description, status, eventID) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [gift['name'], gift['category'], gift['price'], gift['imageurl'], gift['description'], gift['status'], gift['eventID']]);

    var result = await myData.rawQuery('SELECT * FROM Gifts');
    print("result after insert is $result");
    return id;
  }
  // check if the 2 users are friends
  Future<bool> areFriends(int userId, int friendId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Friends WHERE userID = $userId AND friendID = $friendId');
    return result.isNotEmpty;
  }

  // Update event for user
  Future<void> updateEventForUser(int userId, Event event) async {
    Database myData = await db;

    // Use parameterized query to avoid syntax issues and SQL injection
    await myData.rawUpdate(
        'UPDATE Events SET name = ?, category = ?, date = ?, location = ?, description = ?, status = ? WHERE userID = ? and ID = ?',
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
        'UPDATE Gifts SET name = ?, category = ?, price = ?, imageurl = ?, description = ?, status = ? WHERE ID = ?',
        [
          gift['name'],
          gift['category'],
          gift['price'],
          gift['imageurl'],
          gift['description'],
          gift['status']==true?1:0,
          giftid,
        ]
    );
  //   print the gift with id 1
    var result = await myData.rawQuery('SELECT * FROM Gifts WHERE ID = $giftid');
    print("result after update is $result");
  }
//get user friends by user id
  Future<List<Map<String, dynamic>>> getUserFriendsIDs(int userId) async {
    Database myData = await db;
    return await myData.rawQuery('SELECT * FROM Friends WHERE userID = $userId OR friendID = $userId');
  }

  //get gifts for event by event id
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    Database myData = await db;
    return await myData.rawQuery('SELECT * FROM Gifts WHERE eventID = $eventId');
  }
  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Users WHERE phoneNumber = ?', [phoneNumber]);
    return result.isNotEmpty ? result.first : null;
  }
  Future<void> addFriend(int userId, int friendId) async {
    Database myData = await db;
    await myData.rawInsert(
      'INSERT INTO Friends (userID, friendID) VALUES (?, ?)',
      [userId, friendId],
    );
  }
  // update gift status
  Future<void> updateGiftStatus(int giftId, bool status, int userid) async {
    Database myData = await db;
    print("im in update gift status");

    await myData.rawUpdate('UPDATE Gifts SET status = ? WHERE ID = ?', [status==true? 1:0, giftId]);
    var result = await myData.rawQuery('SELECT * FROM Gifts WHERE ID = $giftId');
    print("result after update is $result");
    if (status) {
      print("status is $status");
      await myData.rawInsert('INSERT INTO Pledges (giftID, userID) VALUES (?, ?)', [giftId, userid]);
    } else {
      print("status is $status");
      await myData.rawDelete('DELETE FROM Pledges WHERE giftID = $giftId AND userID = $userid');
    }
    var pledges = await myData.rawQuery('SELECT * FROM Pledges');
    print("pledges after update is $pledges");
    for (var pledge in pledges) {
      print(pledge);
    }
  }

  // get event count for user
  Future<int> getEventCountForUser(int userId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT COUNT(*) FROM Events WHERE userID = $userId');
    return Sqflite.firstIntValue(result) ?? 0;
  }


  // Delete events for user
  Future<void> deleteEventsForUser(int userId, List<Event> eventsToDelete) async {
    Database myData = await db;
    int totalDeleted = 0;
    for (var event in eventsToDelete) {
       await myData.rawQuery("Select * from Events where ID = ${event.id} AND userID = $userId");
    }
    // return totalDeleted;
  }
  // delete gifts for user
  Future<void> deleteGiftsForUser(int giftId) async {
    Database myData = await db;
    await myData.rawQuery("DELETE FROM Gifts WHERE ID = $giftId");
  }

  // Get all events for a user
  Future<List<Event>> getAllEventsForUser(int userId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Events WHERE userID = $userId');
    return result.map((event) => Event.fromMap(event)).toList();
  }
//   get events for user (dont return an object)
  Future<List<Map<String, dynamic>>> getEventsForUser(int userId) async {
    Database myData = await db;
    return await myData.rawQuery('SELECT * FROM Events WHERE userID = $userId');
  }
//   check if user id has pledged a gift id

    Future<bool> hasPledgedGift(int userId, int giftId) async {
    Database myData = await db;
    var result = await myData.rawQuery('SELECT * FROM Pledges WHERE userID = $userId AND giftID = $giftId');
    // print all pledges
    var pledges = await myData.rawQuery('SELECT * FROM Pledges');
    print("pledges in has pledged gift is");
    for (var pledge in pledges) {
      print(pledge);
    }

    return result.isNotEmpty;
    }
//     create a table to delete a pledge
    Future<void> deletePledge(int userId, int giftId) async {
    Database myData = await db;
    await myData.rawQuery('DELETE FROM Pledges WHERE userID = $userId AND giftID = $giftId');
    }

}
