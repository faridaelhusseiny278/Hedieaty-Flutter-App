import 'package:hedieatyfinalproject/Models/friend_event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Models/Event.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Controllers/firebasedatabase_helper.dart';


class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _database;

  Future<Database> get db async {
    print("now calling get db");
    _database ??= await init();
    return _database!;
  }

  Future<bool> _checkTableExists(Database db, String tableName) async {
    // Query the database to check if the table exists
    var result = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name=?',
        [tableName]);
    return result.isNotEmpty;
  }


  Future<Database> init() async {
    print("i'm in init database noww!!!");
    String path = join(await getDatabasesPath(), 'hedeaty.db');
    //
    // await deleteDatabase(path);
    // print("database deleted");

    // check if the database path exists annd all tables do exist
    var db = await openDatabase(path);
    // Check if the tables exist
    bool usersExist = await _checkTableExists(db, 'Users');
    bool eventsExist = await _checkTableExists(db, 'Events');
    bool giftsExist = await _checkTableExists(db, 'Gifts');
    bool friendsExist = await _checkTableExists(db, 'Friends');
    bool pledgesExist = await _checkTableExists(db, 'Pledges');
    if (usersExist && eventsExist && giftsExist && friendsExist &&
        pledgesExist) {
      print("Database tables already exist");
      return db;
    }
    print("Database tables do not exist, creating tables now...");


    await db.execute('''CREATE TABLE Users (
      userid INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      phonenumber TEXT,
      email TEXT,
      address TEXT,
      notification_preferences TEXT,
      imageurl TEXT
    )''');
    print("Users table created successfully!");

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
    print("Events table created successfully!");

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
    print("Gifts table created successfully!");

    await db.execute('''CREATE TABLE Friends (
      userID INTEGER,
      friendID INTEGER,
      PRIMARY KEY (userID, friendID),
      FOREIGN KEY(userID) REFERENCES Users(userid),
      FOREIGN KEY(friendID) REFERENCES Users(userid)
    )''');
    print("Friends table created successfully!");

    await db.execute('''CREATE TABLE Pledges (
      giftID INTEGER,
      userID INTEGER,
      FOREIGN KEY(giftID) REFERENCES Gifts(giftid),
      FOREIGN KEY(userID) REFERENCES Users(userid)
    )''');
    print("Pledges table created successfully!");

    // Optionally populate sample data
    await FetchDataFromFirebase(db);
    print("Sample data inserted successfully!");
    return db;
  }


  Future <void> FetchDataFromFirebase(Database myData) async
  {
    final dbRef = FirebaseDatabaseHelper.getReference(
        "Users");
    final DataSnapshot snapshot = await dbRef.get();
    if (snapshot.value is List) {
      print("snapshot.value is list in fetch data");

      final List usersList = snapshot.value as List;
      for (var user in usersList) {
        if (user == null) {
          continue;
        }

        print("user to be inserted is $user");
        int user_id = await myData.rawInsert('''
        INSERT INTO Users (userid, name, phonenumber, email, address, notification_preferences, imageurl)
        VALUES (${user['userid']}, '${user['name']}', '${user['phonenumber']}', '${user['email']}', '${user['address']}', '${user['notification_preferences']
            .join(',')}', '${user['imageurl']}')
        ''');
        //   then insert in table events the events of the user
        print("user['events'] is ${user['events']}");
        if (user['events'] == null) {
          continue;
        }
        for (var event in user['events']) {
          if (event == null) {
            continue;
          }
          int event_id = await myData.rawInsert('''
          INSERT INTO Events (eventId, eventName, eventDate, eventLocation, category, Status, userID, description)
          VALUES (${event['eventId']}, '${event['eventName'].replaceAll(
              "'", "''")}', '${event['eventDate']}', '${event['eventLocation']
              .replaceAll("'",
              "''")}', '${event['category']}', '${event['Status']}', ${user['userid']}, '${event['description']
              .replaceAll("'", "''")}')
          ''');
          if (event['gifts'] == null) {
            continue;
          }
          //   then insert in table gifts the gifts of the event
          for (var gift in event['gifts']) {
            if (gift == null) {
              continue;
            }
            int gift_id = await myData.rawInsert('''
            INSERT INTO Gifts (giftid, giftName, description, category, price, imageurl, pledged, eventID)
            VALUES (${gift['giftid']}, '${gift['giftName'].replaceAll(
                "'", "''")}', '${gift['description'].replaceAll("'",
                "''")}', '${gift['category']}', ${gift['price']}, '${gift['imageurl']}', ${gift['pledged']
                ? 1
                : 0}, ${event['eventId']})
            ''');
          }
        }
        //   then insert to table friends the friends of the user
        print("user['friends'] is ${user['friends']}");
        for (var friend in user['friends']) {
          if (friend == null) {
            continue;
          }
          int friend_id = await myData.rawInsert('''
          INSERT INTO Friends (userID, friendID)
          VALUES (${user['userid']}, $friend)
          ''');
        }
        //   then insert to table pledges the pledges of the user
        print("user['pledgedgifts'] is ${user['pledgedgifts']}");
        if (user['pledgedgifts'] is Map) {
          for (var gifts in user['pledgedgifts'].values) {
            if (gifts == null) {
              continue;
            }
            for (var gift in gifts) {
              if (gift == null) {
                continue;
              }
              int pledge_id = await myData.rawInsert('''
            INSERT INTO Pledges (giftID, userID)
            VALUES ($gift, ${user['userid']})
            ''');
            }
          }
        }
        else if (user['pledgedgifts'] is List) {
          for (var gifts in user['pledgedgifts']) {
            if (gifts == null) {
              continue;
            }
            for (var gift in gifts) {
              if (gift == null) {
                continue;
              }
              int pledge_id = await myData.rawInsert('''
            INSERT INTO Pledges (giftID, userID)
            VALUES ($gift, ${user['userid']})
            ''');
            }
          }
        }
      }
    }
  }


  Future <void> syncDatabasewithFirebase(int userid) async {
    //   check if user data is the same
    //   1- get all users from firebase
    //   2- get all users from sqlite
    //   3- compare the 2 lists
    //   4- if the lists are not the same print the differences
    //   5- if the lists are the same print "the data is the same"
    final dbRef = FirebaseDatabaseHelper.getReference(
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
          final List<
              String> normalizedDatabasePreferences = result['notification_preferences']
              .toString()
              .split(',')
              .map((s) => s.trim()) // Trim each item to remove extra spaces
              .toList();


          if (!normalizedDatabasePreferences.contains(normalizedNotification)) {
            print(
                "user doesn't have $normalizedNotification notification preference");
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
                .where((element) =>
            element != null &&
                element is Map) // Exclude null and non-Map elements
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
            .where((friend) =>
        friend['userID'] == userid || friend['friendID'] == userid)
            .map((friend) =>
        friend['userID'] == userid
            ? friend['friendID'] as int
            : friend['userID'] as int)
            .toList();


        if (usersMap['friends'] is Map) {
          final List<int> friendsList = [];
          usersMap['friends'].forEach((key, value) {
            friendsList.add(value);
          });

          for (var friend in friendsList) {
            if (!friendListinDatabase.contains(friend)) {
              print(
                  "user ${usersMap['userid']} is not friends with user $friend");
              print(
                  "where the friends in database are $friendListinDatabase and the friends in firebase are $friendsList");
            }
          }
        }
        else if (usersMap['friends'] is List) {
          for (var friend in usersMap['friends']) {
            if (!friendListinDatabase.contains(friend)) {
              print(
                  "user ${usersMap['userid']} is not friends with user $friend");
              print(
                  "where the friends in database are $friendListinDatabase and the friends in firebase are ${usersMap['friends']}");
            }
          }
        }


        //   now compare the pledgedgifts
        final List<Map<String, dynamic>> localPledges = await myData.rawQuery(
            'SELECT * FROM Pledges WHERE userID = ${usersMap['userid']}');
        final List<int> pledgedGifts = localPledges.map((
            e) => e['giftID'] as int).toList();
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


  Future<List<Map<String, dynamic>>> readData(String SQL) async {
    Database myData = await db;
    return await myData.rawQuery(SQL);
  }


  Future<void> printDatabase() async {
    final db = await openDatabase('hedeaty.db');
    // Replace 'tableName' with the name of the table you want to print
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'");

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


}

