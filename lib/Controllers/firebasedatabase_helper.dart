import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseHelper {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  static Future<void> initializeDatabase() async {
    // Enable persistence globally
    _database.setPersistenceEnabled(true);
    // _database.setPersistenceCacheSizeBytes(10 * 1024 * 1024); // Optional: Set cache size
  }

  static DatabaseReference getReference(String path) {
    _database.setPersistenceEnabled(true);
    return _database.ref(path);
  }
}