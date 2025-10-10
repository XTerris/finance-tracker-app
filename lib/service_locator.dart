import 'services/api_service.dart';
import 'services/hive_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  late ApiService _apiService;
  late HiveService _hiveService;

  static Future<void> init() async {
    await ApiService.init();
    await HiveService.init();
    _instance._apiService = ApiService();
    _instance._hiveService = HiveService();
  }

  ApiService get apiService => _apiService;
  HiveService get hiveService => _hiveService;

  Future<void> dispose() async {
    _apiService.dispose();
    await _hiveService.dispose();
  }
}

final serviceLocator = ServiceLocator();
