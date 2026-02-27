// lib/services/firestore_service.dart
// All Firestore task CRUD operations

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the tasks collection reference for a user
  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  /// Real-time stream of all tasks for a user (newest first)
  Stream<List<TaskModel>> tasksStream(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Fetch all tasks once (for initial cache load)
  Future<List<TaskModel>> fetchAllTasks(String userId) async {
    try {
      final snap = await _tasksRef(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to load tasks: ${e.message}');
    }
  }

  /// Add a new task document
  Future<void> addTask(TaskModel task) async {
    try {
      await _tasksRef(task.userId).doc(task.id).set(task.toFirestore()).timeout(const Duration(seconds: 5));
    } catch (e) {
      throw FirestoreException('Failed to save task: $e');
    }
  }

  /// Update an existing task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksRef(task.userId).doc(task.id).update(task.toFirestore()).timeout(const Duration(seconds: 5));
    } catch (e) {
      throw FirestoreException('Failed to update task: $e');
    }
  }

  /// Delete a task document
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksRef(userId).doc(taskId).delete().timeout(const Duration(seconds: 5));
    } catch (e) {
      throw FirestoreException('Failed to delete task: $e');
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(
      String userId,
      String taskId,
      bool isCompleted,
      ) async {
    try {
      await _tasksRef(userId).doc(taskId).update({
        'isCompleted': isCompleted,
        'completedAt':
        isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
      });
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to update task: ${e.message}');
    }
  }
}
