import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../service_locator.dart';

class GoalProvider extends ChangeNotifier {
  Map<int, Goal> _goals = {};

  List<Goal> get goals => _goals.values.toList();

  /// Get goal by account ID instead of goal ID
  Goal? getGoalByAccountId(int accountId) {
    try {
      return _goals.values.firstWhere((goal) => goal.accountId == accountId);
    } catch (e) {
      return null;
    }
  }

  /// Get all goals for a specific account
  List<Goal> getGoalsByAccountId(int accountId) {
    return _goals.values.where((goal) => goal.accountId == accountId).toList();
  }

  Future<void> init() async {
    // Initialize with data from cache
    final goals = await serviceLocator.hiveService.getAllGoals();
    _goals = {for (var goal in goals) goal.id: goal};
    notifyListeners();

    // Try to update from server, but don't fail if offline
    try {
      await update();
    } catch (e) {
      debugPrint('Could not update goals from server: $e');
    }
  }

  Future<void> update() async {
    final goals = await serviceLocator.apiService.getAllGoals();
    _goals = {for (var goal in goals) goal.id: goal};
    await serviceLocator.hiveService.clearAllGoals();
    await serviceLocator.hiveService.saveGoals(goals);
    notifyListeners();
  }

  Future<void> addGoal({
    required int accountId,
    required double targetAmount,
    required DateTime deadline,
  }) async {
    final goal = await serviceLocator.apiService.createGoal(
      accountId: accountId,
      targetAmount: targetAmount,
      deadline: deadline,
    );
    _goals[goal.id] = goal;
    await serviceLocator.hiveService.saveGoals([goal]);
    notifyListeners();
  }

  Future<void> updateGoal({
    required int id,
    int? accountId,
    double? targetAmount,
    DateTime? deadline,
    bool? isCompleted,
  }) async {
    final goal = await serviceLocator.apiService.updateGoal(
      id: id,
      accountId: accountId,
      targetAmount: targetAmount,
      deadline: deadline,
      isCompleted: isCompleted,
    );
    _goals[goal.id] = goal;
    await serviceLocator.hiveService.saveGoals([goal]);
    notifyListeners();
  }

  Future<void> markGoalComplete(int id) async {
    final goal = await serviceLocator.apiService.markGoalComplete(id);
    _goals[goal.id] = goal;
    await serviceLocator.hiveService.saveGoals([goal]);
    notifyListeners();
  }

  Future<void> markGoalIncomplete(int id) async {
    final goal = await serviceLocator.apiService.markGoalIncomplete(id);
    _goals[goal.id] = goal;
    await serviceLocator.hiveService.saveGoals([goal]);
    notifyListeners();
  }

  Future<void> removeGoal(int id) async {
    await serviceLocator.apiService.deleteGoal(id);
    _goals.remove(id);
    await serviceLocator.hiveService.deleteGoal(id);
    notifyListeners();
  }
}
