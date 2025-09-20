import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';


class HiveService {
  static const String _userBox = 'user';

  static const String _currentUserKey = "currentUser";

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Open boxes
    await Hive.openBox<User>(_userBox);
  }

  Future<User?> getCurrentUser() async {
    final box = Hive.box<User>(_userBox);
    final user = box.get(_currentUserKey);
    return user;
  }

  Future<void> saveCurrentUser(User user) async {
    final box = Hive.box<User>(_userBox);
    await box.put(_currentUserKey, user);
  }

  Future<void> clearCurrentUser() async {
    final box = Hive.box<User>(_userBox);
    await box.delete(_currentUserKey);
  }

  Future<void> dispose() async {
    await Hive.close();
  }
}
