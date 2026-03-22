import '../../models/todo.dart';

/// Plain data class representing a persisted todo row.
class TodoData {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TodoData({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
    this.dueDate,
  });
}

/// Abstract database interface.
abstract class AppDatabase {
  Future<List<TodoData>> getAllTodos();
  Future<List<TodoData>> getActiveTodos();
  Future<List<TodoData>> getCompletedTodos();
  Future<void> createTodo(TodoData todo);
  Future<bool> updateTodo(TodoData todo);
  Future<bool> deleteTodo(String id);
  Future<bool> toggleTodo(String id, {required bool completed});
  Future<int> getTodoCount();
  Stream<List<TodoData>> watchAllTodos();
  Stream<List<TodoData>> watchActiveTodos();
  Stream<List<TodoData>> watchCompletedTodos();
}
