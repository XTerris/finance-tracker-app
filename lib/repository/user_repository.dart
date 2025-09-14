import '../models/user.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class UserRepository {
  final ApiService apiService;
  final HiveService hiveService;

  UserRepository({required this.apiService, required this.hiveService});

  Future<User?> fetchUser(String id) async {
    // TODO: Implement API call and local DB logic
    return null;
  }

  Future<void> saveUser(User user) async {
    // TODO: Implement local DB save logic
  }
}
