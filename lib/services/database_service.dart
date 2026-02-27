// lib/services/database_service.dart
// SQLite local database wrapper replacing Firestore

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../core/errors/app_exception.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_todo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        category TEXT,
        dueDate TEXT,
        isCompleted INTEGER,
        createdAt TEXT,
        completedAt TEXT,
        userId TEXT
      )
    ''');
  }

  // ── Stream Simulation ─────────────────────────
  Stream<List<TaskModel>> tasksStream(String userId) async* {
    while (true) {
      yield await fetchAllTasks(userId);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // ── Operations ───────────────────────────────
  Future<List<TaskModel>> fetchAllTasks(String userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'tasks',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      
      return maps.map((map) {
        // Safe conversion of SQLite map to TaskModel json format
        final jsonMap = Map<String, dynamic>.from(map);
        jsonMap['isCompleted'] = jsonMap['isCompleted'] == 1;
        return TaskModel.fromJson(jsonMap);
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to load local tasks: $e');
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final db = await database;
      final map = task.toJson();
      map['isCompleted'] = map['isCompleted'] == true ? 1 : 0;
      await db.insert('tasks', map, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw FirestoreException('Failed to insert local task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await database;
      final map = task.toJson();
      map['isCompleted'] = map['isCompleted'] == true ? 1 : 0;
      await db.update('tasks', map, where: 'id = ?', whereArgs: [task.id]);
    } catch (e) {
      throw FirestoreException('Failed to update local task: $e');
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      final db = await database;
      await db.delete('tasks', where: 'id = ? AND userId = ?', whereArgs: [taskId, userId]);
    } catch (e) {
      throw FirestoreException('Failed to delete local task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted) async {
    try {
      final db = await database;
      await db.update(
        'tasks',
        {
          'isCompleted': isCompleted ? 1 : 0,
          'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ? AND userId = ?',
        whereArgs: [taskId, userId],
      );
    } catch (e) {
      throw FirestoreException('Failed to complete local task: $e');
    }
  }
}
