import '../../models/todo.dart';

/// Plain data class representing a persisted todo row.
/// Uses the domain [Priority] enum directly — the concrete Drift
/// implementation is responsible for converting int <-> Priority.
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

/// Abstract database interface used by [TodoRepository].
/// Keeping this separate from the Drift concrete class allows the
/// repository to be tested without a real SQLite engine.
abstract class AppDatabase {
  Future<List<TodoData>> getAllTodos();
  Future<List<TodoData>> getActiveTodos();
  Future<List<TodoData>> getCompletedTodos();
  Future<void> createTodo(TodoData todo);
  Future<bool> updateTodo(TodoData todo);
  Future<bool> deleteTodo(String id);
  Future<bool> toggleTodo(String id);
  Future<int> getTodoCount();
  Stream<List<TodoData>> watchAllTodos();
  Stream<List<TodoData>> watchActiveTodos();
  Stream<List<TodoData>> watchCompletedTodos();
}
