import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart' as drift_db;
import '../core/database/todo_database.dart';
import '../models/todo.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return _DriftDatabaseAdapter(drift_db.AppDatabase());
});

class _DriftDatabaseAdapter implements AppDatabase {
  final drift_db.AppDatabase _db;
  _DriftDatabaseAdapter(this._db);

  static int _p2i(Priority p) => switch (p) {
        Priority.low => 0,
        Priority.medium => 1,
        Priority.high => 2,
      };

  static Priority _i2p(int v) => switch (v) {
        0 => Priority.low,
        2 => Priority.high,
        _ => Priority.medium,
      };

  static TodoData _row(drift_db.TodoItem r) => TodoData(
        id: r.id, title: r.title, description: r.description,
        isCompleted: r.isCompleted, priority: _i2p(r.priority),
        createdAt: r.createdAt, dueDate: r.dueDate,
      );

  static drift_db.TodoItemsCompanion _companion(TodoData d) =>
      drift_db.TodoItemsCompanion(
        id: Value(d.id), title: Value(d.title),
        description: Value(d.description),
        isCompleted: Value(d.isCompleted),
        priority: Value(_p2i(d.priority)),
        createdAt: Value(d.createdAt),
        dueDate: Value(d.dueDate),
      );

  @override
  Future<List<TodoData>> getAllTodos() async =>
      (await _db.getAllTodos()).map(_row).toList();

  @override
  Future<List<TodoData>> getActiveTodos() async =>
      (await _db.getAllTodos()).where((r) => !r.isCompleted).map(_row).toList();

  @override
  Future<List<TodoData>> getCompletedTodos() async =>
      (await _db.getAllTodos()).where((r) => r.isCompleted).map(_row).toList();

  @override
  Stream<List<TodoData>> watchAllTodos() =>
      _db.watchAllTodos().map((rows) => rows.map(_row).toList());

  @override
  Stream<List<TodoData>> watchActiveTodos() =>
      _db.watchActiveTodos().map((rows) => rows.map(_row).toList());

  @override
  Stream<List<TodoData>> watchCompletedTodos() =>
      _db.watchCompletedTodos().map((rows) => rows.map(_row).toList());

  @override
  Future<void> createTodo(TodoData d) async =>
      _db.insertTodo(_companion(d));

  @override
  Future<bool> updateTodo(TodoData d) =>
      _db.updateTodo(drift_db.TodoItemsCompanion(
        id: Value(d.id), title: Value(d.title),
        description: Value(d.description),
        isCompleted: Value(d.isCompleted),
        priority: Value(_p2i(d.priority)),
        createdAt: Value(d.createdAt),
        dueDate: Value(d.dueDate),
      ));

  @override
  Future<bool> deleteTodo(String id) async =>
      (await _db.deleteTodoById(id)) > 0;

  @override
  Future<bool> toggleTodo(String id, {required bool completed}) async {
    await _db.toggleTodoCompleted(id, completed: completed);
    return true;
  }

  @override
  Future<int> getTodoCount() async => (await _db.getAllTodos()).length;
}
