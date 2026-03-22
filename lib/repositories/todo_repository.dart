import '../core/database/todo_database.dart';
import '../models/todo.dart';

class TodoRepository {
  final AppDatabase _database;

  TodoRepository(this._database);

  Future<List<Todo>> getAllTodos() async {
    final items = await _database.getAllTodos();
    return items.map(_toDomain).toList();
  }

  Future<List<Todo>> getActiveTodos() async {
    final items = await _database.getActiveTodos();
    return items.map(_toDomain).toList();
  }

  Future<List<Todo>> getCompletedTodos() async {
    final items = await _database.getCompletedTodos();
    return items.map(_toDomain).toList();
  }

  Future<int> getTodoCount() => _database.getTodoCount();

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
    final data = TodoData(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
      priority: todo.priority,
      createdAt: todo.createdAt,
      dueDate: todo.dueDate,
    );
    await _database.createTodo(data);
  }

  Future<bool> updateTodo(Todo todo) async {
    final data = TodoData(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
      priority: todo.priority,
      createdAt: todo.createdAt,
      dueDate: todo.dueDate,
    );
    return _database.updateTodo(data);
  }

  Future<int> deleteTodo(String id) async {
    final deleted = await _database.deleteTodo(id);
    return deleted ? 1 : 0;
  }

  Future<void> toggleTodo(String id, {required bool completed}) async {
    await _database.toggleTodo(id, completed: completed);
  }

  // Mapper

  Todo _toDomain(TodoData data) {
    return Todo(
      id: data.id,
      title: data.title,
      description: data.description,
      isCompleted: data.isCompleted,
      priority: data.priority,
      createdAt: data.createdAt,
      dueDate: data.dueDate,
    );
  }
}
