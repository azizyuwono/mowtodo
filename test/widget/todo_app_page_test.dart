// test/widget/todo_app_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mowtodo/core/database/todo_database.dart';
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/providers/todo_provider.dart';
import 'package:mowtodo/repositories/todo_repository.dart';
import 'package:mowtodo/screens/home_screen.dart';

// ---------------------------------------------------------------------------
// In-memory fake — mirrors the one in home_screen_test.dart
// ---------------------------------------------------------------------------

class FakeAppDatabase implements AppDatabase {
  final List<TodoData> _todos;

  FakeAppDatabase([List<TodoData>? initial]) : _todos = initial ?? [];

  @override
  Future<List<TodoData>> getAllTodos() async => List.unmodifiable(_todos);

  @override
  Future<List<TodoData>> getActiveTodos() async =>
      _todos.where((t) => !t.isCompleted).toList();

  @override
  Future<List<TodoData>> getCompletedTodos() async =>
      _todos.where((t) => t.isCompleted).toList();

  @override
  Future<void> createTodo(TodoData todo) async => _todos.add(todo);

  @override
  Future<bool> updateTodo(TodoData todo) async {
    final i = _todos.indexWhere((t) => t.id == todo.id);
    if (i == -1) return false;
    _todos[i] = todo;
    return true;
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final before = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    return _todos.length < before;
  }

  @override
  Future<bool> toggleTodo(String id, {required bool completed}) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    final old = _todos[i];
    _todos[i] = TodoData(
      id: old.id,
      title: old.title,
      description: old.description,
      isCompleted: completed,
      priority: old.priority,
      createdAt: old.createdAt,
      dueDate: old.dueDate,
    );
    return true;
  }

  @override
  Future<int> getTodoCount() async => _todos.length;

  @override
  Stream<List<TodoData>> watchAllTodos() =>
      Stream.fromFuture(getAllTodos());

  @override
  Stream<List<TodoData>> watchActiveTodos() =>
      Stream.fromFuture(getActiveTodos());

  @override
  Stream<List<TodoData>> watchCompletedTodos() =>
      Stream.fromFuture(getCompletedTodos());
}

Widget buildApp(FakeAppDatabase db) {
  final repo = TodoRepository(db);
  return ProviderScope(
    overrides: [
      todoNotifierProvider.overrideWith((ref) => TodoNotifier(repo)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('HomeScreen (TodoAppPage replacement)', () {
    testWidgets('displays empty state when no todos', (tester) async {
      await tester.pumpWidget(buildApp(FakeAppDatabase()));
      await tester.pumpAndSettle();

      expect(find.textContaining('No tasks yet'), findsOneWidget);
    });

    testWidgets('displays app bar with title MowTodo', (tester) async {
      await tester.pumpWidget(buildApp(FakeAppDatabase()));
      await tester.pumpAndSettle();

      expect(find.text('MowTodo'), findsOneWidget);
    });

    testWidgets('displays seeded todos in list', (tester) async {
      final db = FakeAppDatabase([
        TodoData(id: '1', title: 'Task 1', isCompleted: false, priority: Priority.medium, createdAt: DateTime.now()),
        TodoData(id: '2', title: 'Task 2', isCompleted: false, priority: Priority.medium, createdAt: DateTime.now()),
      ]);
      await tester.pumpWidget(buildApp(db));
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('shows stats widget scaffold', (tester) async {
      await tester.pumpWidget(buildApp(FakeAppDatabase()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('todo list is scrollable when many items', (tester) async {
      final todos = List.generate(
        10,
        (i) => TodoData(id: '$i', title: 'Task $i', isCompleted: false, priority: Priority.medium, createdAt: DateTime.now()),
      );
      await tester.pumpWidget(buildApp(FakeAppDatabase(todos)));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(buildApp(FakeAppDatabase()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('MowTodo'), findsOneWidget);
    });
  });
}
