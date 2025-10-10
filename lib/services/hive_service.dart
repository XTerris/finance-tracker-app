import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/transaction.dart';

class HiveService {
  static const String _kvBoxName = 'key_value_store';
  static const String _userBoxName = 'user';
  static const String _transactionBoxName = 'transactions';

  static const String _currentUserKey = "currentUser";
  static const String _transactionsUpdateKey = "transactionsUpdate";

  static late Box<User> _userBox;
  static late Box<dynamic> _kvBox;
  static late Box<Transaction> _transactionBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Open boxes with types
    _userBox = await _openBoxSafely<User>(_userBoxName);
    _kvBox = await _openBoxSafely<dynamic>(_kvBoxName);
    _transactionBox = await _openBoxSafely<Transaction>(_transactionBoxName);
  }

  static Future<Box<T>> _openBoxSafely<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      if (e is HiveError && e.message.contains('unknown typeId')) {
        // Delete the corrupted box and try again
        await Hive.deleteBoxFromDisk(boxName);
        return await Hive.openBox<T>(boxName);
      } else {
        rethrow;
      }
    }
  }

  Future<User?> getCurrentUser() async {
    final user = _userBox.get(_currentUserKey);
    return user;
  }

  Future<void> saveCurrentUser(User user) async {
    await _userBox.put(_currentUserKey, user);
  }

  Future<void> clearCurrentUser() async {
    // Clear all data in all boxes
    await _userBox.clear();
    await _kvBox.clear();
    await _transactionBox.clear();
  }

  Future<void> setUpdateTransactionsTimestamp(int timestamp) async {
    await _kvBox.put(_transactionsUpdateKey, timestamp);
  }

  Future<int?> getUpdateTransactionsTimestamp() async {
    final timestamp = _kvBox.get(_transactionsUpdateKey) as int?;
    return timestamp;
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    for (var transaction in transactions) {
      final key = transaction.id;
      await _transactionBox.put(key, transaction);
    }
  }

  Future<List<Transaction>> getAllTransactions() async {
    final transactions = _transactionBox.values.toList();
    return transactions;
  }

  Future<void> deleteTransaction(int id) async {
    await _transactionBox.delete(id);
  }

  Future<void> dispose() async {
    await _userBox.close();
    await _kvBox.close();
    await _transactionBox.close();
  }
}
