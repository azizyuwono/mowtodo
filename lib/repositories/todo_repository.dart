import 'package:drift/drift.dart';

import '../core/database/app_database.dart';
import '../models/todo.dart';

class TodoRepository {
  final AppDatabase _database;

  TodoRepository(this._database);

  Future<List<Todo>> getAllTodos() async {
    final items = await _database.getAllTodos();
    return items.map(_toDomain).toList();
  }

  Stream<List<Todo>> watchActiveTodos() {
    return _database.watchActiveTodos().map(
          (items) => items.map(_toDomain).toList(),
        );
  }

  Stream<List<Todo>> watchCompletedTodos() {
    return _database.watchCompletedTodos().map(
          (items) => items.map(_toDomain).toList(),
        );
  }

  Stream<List<Todo>> watchAllTodos() {
    return _database.watchAllTodos().map(
          (items) => items.map(_toDomain).toList(),
        );
  }

  Future<void> createTodo(Todo todo) async {
    final companion = TodoItemsCompanion(
      id: Value(todo.id),
      title: Value(todo.title),
      description: Value(todo.description),
      isCompleted: Value(todo.isCompleted),
      priority: Value(_priorityToInt(todo.priority)),
      createdAt: Value(todo.createdAt),
      dueDate: Value(todo.dueDate),
    );
    await _database.insertTodo(companion);
  }

  Future<bool> updateTodo(Todo todo) async {
    final companion = TodoItemsCompanion(
      id: Value(todo.id),
      title: Value(todo.title),
      description: Value(todo.description),
      isCompleted: Value(todo.isCompleted),
      priority: Value(_priorityToInt(todo.priority)),
      createdAt: Value(todo.createdAt),
      dueDate: Value(todo.dueDate),
    );
    return _database.updateTodo(companion);
  }

  Future<int> deleteTodo(String id) async {
    return _database.deleteTodoById(id);
  }

  Future<void> toggleTodo(String id, {required bool completed}) async {
    return _database.toggleTodoCompleted(id, completed: completed);
  }

  // Mappers

  Todo _toDomain(TodoItem item) {
    return Todo(
      id: item.id,
      title: item.title,
      description: item.description,
      isCompleted: item.isCompleted,
      priority: _intToPriority(item.priority),
      createdAt: item.createdAt,
      dueDate: item.dueDate,
    );
  }

  int _priorityToInt(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.high:
        return 2;
    }
  }

  Priority _intToPriority(int value) {
    switch (value) {
      case 0:
        return Priority.low;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }
}
