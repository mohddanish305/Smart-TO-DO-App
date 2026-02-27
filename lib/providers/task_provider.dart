// lib/providers/task_provider.dart
// Full task state: CRUD, filtering, search, analytics, sync

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/cache_service.dart';
import '../core/utils/date_utils.dart';

enum TaskLoadStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  final CacheService _cacheService;

  TaskLoadStatus _status = TaskLoadStatus.initial;
  List<TaskModel> _tasks = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _errorMessage;
  String? _userId;

  // Stream simulation timer instead of Firestore stream subscription
  Timer? _taskTimer;

  TaskProvider({
    required DatabaseService dbService,
    required CacheService cacheService,
  })  : _dbService = dbService,
        _cacheService = cacheService;

  // ── Getters ───────────────────────────────────────────────────

  TaskLoadStatus get status => _status;
  bool get isLoading => _status == TaskLoadStatus.loading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<TaskModel> get allTasks => _tasks;

  /// Filtered + searched tasks for display
  List<TaskModel> get filteredTasks {
    var result = List<TaskModel>.from(_tasks);

    // Category filter
    if (_selectedCategory != 'All') {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  double get todayProgress {
    final todayTasks = _tasks.where((t) => _isCreatedToday(t)).toList();
    if (todayTasks.isEmpty) return 0.0;
    final done = todayTasks.where((t) => t.isCompleted).length;
    return done / todayTasks.length;
  }

  // ── Analytics ─────────────────────────────────────────────────

  int get todayCompleted {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return AppDateUtils.isToday(t.completedAt!);
    }).length;
  }

  int get todayPending {
    return _tasks.where((t) => !t.isCompleted && _isCreatedToday(t)).length;
  }

  /// Weekly completions Mon→Sun for the current ISO week
  List<int> get weeklyData {
    final now = DateTime.now();
    // weekday: 1=Mon, 7=Sun. Find Monday of the current week.
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return _tasks.where((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return AppDateUtils.isSameDay(t.completedAt!, day);
      }).length;
    });
  }

  /// The 7 day dates (Mon–Sun) for the current ISO week for chart labels
  List<DateTime> get weekDays {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  int get monthlyCompleted {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      final d = t.completedAt!;
      return d.year == now.year && d.month == now.month;
    }).length;
  }

  int get monthlyTotal {
    final now = DateTime.now();
    return _tasks.where((t) {
      return t.createdAt.year == now.year && t.createdAt.month == now.month;
    }).length;
  }

  double get monthlyRate =>
      monthlyTotal == 0 ? 0.0 : monthlyCompleted / monthlyTotal;

  int get yearlyCompleted {
    return _tasks.where((t) {
      return t.isCompleted &&
          t.completedAt != null &&
          t.completedAt!.year == DateTime.now().year;
    }).length;
  }

  int get yearlyTotal =>
      _tasks.where((t) => t.createdAt.year == DateTime.now().year).length;

  // ── Initialize user data ──────────────────────────────────────

  Future<void> initForUser(String userId) async {
    _userId = userId;
    _status = TaskLoadStatus.loading;
    notifyListeners();

    // Load from SQLite instantly
    try {
      _tasks = await _dbService.fetchAllTasks(userId);
      _status = TaskLoadStatus.loaded;
      notifyListeners();

      // Simple polling mechanism instead of Firebase's real-time stream 
      // (though SQLite is local so it only changes from our own writes anyway!)
      _taskTimer?.cancel();
      _taskTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        final newTasks = await _dbService.fetchAllTasks(userId);
        if (newTasks.length != _tasks.length || _hasDifferences(_tasks, newTasks)) {
          _tasks = newTasks;
          notifyListeners();
        }
      });
    } catch (e) {
      _status = TaskLoadStatus.error;
      _errorMessage = "Failed to load tasks.";
      notifyListeners();
    }
  }

  bool _hasDifferences(List<TaskModel> oldList, List<TaskModel> newList) {
    if (oldList.isEmpty && newList.isEmpty) return false;
    for (int i = 0; i < newList.length; i++) {
       if (oldList.length <= i) return true;
       if (oldList[i].id != newList[i].id || oldList[i].isCompleted != newList[i].isCompleted || oldList[i].title != newList[i].title) return true;
    }
    return false;
  }

  /// Dispose stream and reset state on logout
  void reset() {
    _taskTimer?.cancel();
    _taskTimer = null;
    _tasks = [];
    _status = TaskLoadStatus.initial;
    _searchQuery = '';
    _selectedCategory = 'All';
    _errorMessage = null;
    _userId = null;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────

  Future<bool> addTask(TaskModel task) async {
    try {
      await _dbService.addTask(task);
      _tasks = await _dbService.fetchAllTasks(task.userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add task.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      await _dbService.updateTask(task);
      _tasks = await _dbService.fetchAllTasks(task.userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    if (_userId == null) return false;
    // Optimistic local removal
    final index = _tasks.indexWhere((t) => t.id == taskId);
    TaskModel? removed;
    if (index != -1) {
      removed = _tasks[index];
      _tasks.removeAt(index);
      notifyListeners();
    }
    try {
      await _dbService.deleteTask(_userId!, taskId);
      return true;
    } catch (e) {
      // Rollback on failure
      if (removed != null && index != -1) {
        _tasks.insert(index, removed);
        notifyListeners();
      }
      _errorMessage = 'Failed to delete task.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(String taskId) async {
    if (_userId == null) return false;
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final task = _tasks[index];
    final newStatus = !task.isCompleted;

    // Optimistic update
    _tasks[index] = task.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
      clearCompletedAt: !newStatus,
    );
    notifyListeners();

    try {
      await _dbService.toggleTaskCompletion(
        _userId!,
        taskId,
        newStatus,
      );
      return true;
    } catch (e) {
      // Rollback
      _tasks[index] = task;
      _errorMessage = 'Failed to update task.';
      notifyListeners();
      return false;
    }
  }

  // ── Filtering / Search ────────────────────────────────────────

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────

  bool _isCreatedToday(TaskModel task) =>
      AppDateUtils.isToday(task.createdAt);
}
