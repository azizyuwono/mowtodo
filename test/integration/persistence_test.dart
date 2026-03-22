// test/integration/persistence_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mowtodo/core/database/todo_database.dart' as db;
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/repositories/todo_repository.dart';

// ---------------------------------------------------------------------------
// In-memory AppDatabase implementation — no SQLite / codegen needed
// ---------------------------------------------------------------------------

class InMemoryDatabase implements db.AppDatabase {
  final List<db.TodoData> _store = [];
  final _ctrl = StreamController<List<db.TodoData>>.broadcast();

  void _emit() => _ctrl.add(List.unmodifiable(_store));

  @override
  Future<List<db.TodoData>> getAllTodos() async => List.unmodifiable(_store);

  @override
  Future<List<db.TodoData>> getActiveTodos() async =>
      _store.where((t) => !t.isCompleted).toList();

  @override
  Future<List<db.TodoData>> getCompletedTodos() async =>
      _store.where((t) => t.isCompleted).toList();

  @override
  Stream<List<db.TodoData>> watchAllTodos() => _ctrl.stream;

  @override
  Stream<List<db.TodoData>> watchActiveTodos() =>
      _ctrl.stream.map((rows) => rows.where((t) => !t.isCompleted).toList());

  @override
  Stream<List<db.TodoData>> watchCompletedTodos() =>
      _ctrl.stream.map((rows) => rows.where((t) => t.isCompleted).toList());

  @override
  Future<void> createTodo(db.TodoData todo) async {
    _store.add(todo);
    _emit();
  }

  @override
  Future<bool> updateTodo(db.TodoData todo) async {
    final i = _store.indexWhere((t) => t.id == todo.id);
    if (i == -1) return false;
    _store[i] = todo;
    _emit();
    return true;
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final before = _store.length;
    _store.removeWhere((t) => t.id == id);
    _emit();
    return _store.length < before;
  }

  @override
  Future<bool> toggleTodo(String id, {required bool completed}) async {
    final i = _store.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    final old = _store[i];
    _store[i] = db.TodoData(
      id: old.id,
      title: old.title,
      description: old.description,
      isCompleted: completed,
      priority: old.priority,
      createdAt: old.createdAt,
      dueDate: old.dueDate,
    );
    _emit();
    return true;
  }

  @override
  Future<int> getTodoCount() async => _store.length;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Persistence Integration', () {
    late InMemoryDatabase database;
    late TodoRepository repository;

    setUp(() {
      database = InMemoryDatabase();
      repository = TodoRepository(database);
    });

    test('create and retrieve todo', () async {
      final todo = Todo(title: 'Integration Test');
      await repository.createTodo(todo);

      final todos = await repository.getAllTodos();
      expect(todos, isNotEmpty);
      expect(todos.first.title, 'Integration Test');
    });

    test('created todo preserves all fields', () async {
      final todo = Todo(
        id: 'field-check',
        title: 'Field Check',
        description: 'Some desc',
        priority: Priority.high,
      );
      await repository.createTodo(todo);

      final todos = await repository.getAllTodos();
      final fetched = todos.firstWhere((t) => t.id == 'field-check');
      expect(fetched.description, 'Some desc');
      expect(fetched.priority, Priority.high);
      expect(fetched.isCompleted, false);
    });

    test('toggle todo updates to completed', () async {
      final todo = Todo(id: 'toggle-test', title: 'Toggle Me');
      await repository.createTodo(todo);

      await repository.toggleTodo('toggle-test', completed: true);

      final todos = await repository.getAllTodos();
      final updated = todos.firstWhere((t) => t.id == 'toggle-test');
      expect(updated.isCompleted, true);
    });

    test('toggle completed todo reverts to incomplete', () async {
      final todo = Todo(id: 'toggle-back', title: 'Toggle Back');
      await repository.createTodo(todo);

      await repository.toggleTodo('toggle-back', completed: true);
      await repository.toggleTodo('toggle-back', completed: false);

      final todos = await repository.getAllTodos();
      expect(todos.firstWhere((t) => t.id == 'toggle-back').isCompleted, false);
    });

    test('delete todo removes from database', () async {
      final todo = Todo(id: 'delete-test', title: 'Delete Me');
      await repository.createTodo(todo);

      final countBefore = (await repository.getAllTodos()).length;
      await repository.deleteTodo('delete-test');
      final countAfter = (await repository.getAllTodos()).length;

      expect(countAfter, lessThan(countBefore));
    });

    test('deleted todo no longer appears in getAllTodos', () async {
      await repository.createTodo(Todo(id: 'gone', title: 'Gone'));
      await repository.deleteTodo('gone');

      final todos = await repository.getAllTodos();
      expect(todos.any((t) => t.id == 'gone'), false);
    });

    test('updateTodo modifies existing entry', () async {
      final original = Todo(id: 'update-me', title: 'Old Title');
      await repository.createTodo(original);

      await repository.updateTodo(original.copyWith(
        title: 'New Title',
        isCompleted: true,
      ));

      final todos = await repository.getAllTodos();
      final fetched = todos.firstWhere((t) => t.id == 'update-me');
      expect(fetched.title, 'New Title');
      expect(fetched.isCompleted, true);
    });

    test('watchAllTodos stream emits after insert', () async {
      final todo = Todo(id: 'watch-test', title: 'Watch Me');

      final emitted = <List<Todo>>[];
      final sub = repository.watchAllTodos().listen(emitted.add);

      await repository.createTodo(todo);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emitted.any((list) => list.any((t) => t.id == 'watch-test')), true);
    });

    test('multiple independent todos coexist', () async {
      for (int i = 0; i < 5; i++) {
        await repository.createTodo(Todo(title: 'Task $i'));
      }
      final all = await repository.getAllTodos();
      expect(all.length, 5);
    });

    test('empty database returns empty list', () async {
      final todos = await repository.getAllTodos();
      expect(todos, isEmpty);
    });

    test('two separate todos have different IDs', () async {
      await repository.createTodo(Todo(title: 'Alpha'));
      await repository.createTodo(Todo(title: 'Beta'));

      final todos = await repository.getAllTodos();
      expect(todos[0].id, isNot(equals(todos[1].id)));
    });
  });
}
