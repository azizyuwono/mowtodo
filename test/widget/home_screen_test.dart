// test/widget/home_screen_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mowtodo/core/database/todo_database.dart' as db;
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/providers/database_provider.dart';
import 'package:mowtodo/screens/home_screen.dart';

// ---------------------------------------------------------------------------
// In-memory fake database for widget tests
// ---------------------------------------------------------------------------

class FakeDatabase implements db.AppDatabase {
  final List<db.TodoData> _todos = [];
  final _ctrl = StreamController<List<db.TodoData>>.broadcast();

  void _emit() => _ctrl.add(List.unmodifiable(_todos));

  @override
  Future<List<db.TodoData>> getAllTodos() async => List.unmodifiable(_todos);

  @override
  Future<List<db.TodoData>> getActiveTodos() async =>
      _todos.where((t) => !t.isCompleted).toList();

  @override
  Future<List<db.TodoData>> getCompletedTodos() async =>
      _todos.where((t) => t.isCompleted).toList();

  @override
  Stream<List<db.TodoData>> watchAllTodos() => _ctrl.stream;

  @override
  Stream<List<db.TodoData>> watchActiveTodos() =>
      _ctrl.stream.map((r) => r.where((t) => !t.isCompleted).toList());

  @override
  Stream<List<db.TodoData>> watchCompletedTodos() =>
      _ctrl.stream.map((r) => r.where((t) => t.isCompleted).toList());

  @override
  Future<void> createTodo(db.TodoData todo) async {
    _todos.add(todo);
    _emit();
  }

  @override
  Future<bool> updateTodo(db.TodoData todo) async {
    final i = _todos.indexWhere((t) => t.id == todo.id);
    if (i == -1) return false;
    _todos[i] = todo;
    _emit();
    return true;
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final before = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    _emit();
    return _todos.length < before;
  }

  @override
  Future<bool> toggleTodo(String id, {required bool completed}) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return false;
    final old = _todos[i];
    _todos[i] = db.TodoData(
      id: old.id, title: old.title, description: old.description,
      isCompleted: completed, priority: old.priority,
      createdAt: old.createdAt, dueDate: old.dueDate,
    );
    _emit();
    return true;
  }

  @override
  Future<int> getTodoCount() async => _todos.length;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget buildHomeScreen(FakeDatabase fakeDb) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(AsyncValue.data(fakeDb)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen Widget', () {
    testWidgets('renders Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(buildHomeScreen(FakeDatabase()));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });


    testWidgets('displays empty state when no todos',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildHomeScreen(FakeDatabase()));
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet.'), findsOneWidget);
    });

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(buildHomeScreen(FakeDatabase()));
      await tester.pumpAndSettle();
      expect(find.text('MowTodo'), findsOneWidget);
    });

    testWidgets('displays todos in list when data exists',
        (WidgetTester tester) async {
      final fakeDb = FakeDatabase();
      await fakeDb.createTodo(db.TodoData(
        id: '1', title: 'Task 1', isCompleted: false,
        priority: Priority.medium, createdAt: DateTime.now(),
      ));
      await fakeDb.createTodo(db.TodoData(
        id: '2', title: 'Task 2', isCompleted: false,
        priority: Priority.medium, createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(buildHomeScreen(fakeDb));
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('does not show empty state when todos exist',
        (WidgetTester tester) async {
      final fakeDb = FakeDatabase();
      await fakeDb.createTodo(db.TodoData(
        id: '1', title: 'Existing Task', isCompleted: false,
        priority: Priority.medium, createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(buildHomeScreen(fakeDb));
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet.'), findsNothing);
    });

    testWidgets('renders ListView when todos are present',
        (WidgetTester tester) async {
      final fakeDb = FakeDatabase();
      await fakeDb.createTodo(db.TodoData(
        id: '1', title: 'A Task', isCompleted: false,
        priority: Priority.medium, createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(buildHomeScreen(fakeDb));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
