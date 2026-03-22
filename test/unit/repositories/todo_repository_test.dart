import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mowtodo/core/database/todo_database.dart';
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/repositories/todo_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;
  late TodoRepository repository;

  setUpAll(() {
    registerFallbackValue(TodoData(
      id: 'fallback',
      title: 'fallback',
      isCompleted: false,
      priority: Priority.medium,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ));
  });

  setUp(() {
    mockDb = MockAppDatabase();
    repository = TodoRepository(mockDb);
  });

  group('TodoRepository', () {
    test('getAllTodos returns list of todos', () async {
      final todo = TodoData(
        id: '1',
        title: 'Test',
        description: null,
        isCompleted: false,
        priority: Priority.medium,
        createdAt: DateTime.now(),
        dueDate: null,
      );

      when(() => mockDb.getAllTodos()).thenAnswer((_) async => [todo]);

      final result = await repository.getAllTodos();

      expect(result, isNotEmpty);
      expect(result.first.title, 'Test');
      verify(() => mockDb.getAllTodos()).called(1);
    });

    test('createTodo calls database insert', () async {
      final todo = Todo(title: 'New Task');

      when(() => mockDb.createTodo(any())).thenAnswer((_) async {});

      await repository.createTodo(todo);

      verify(() => mockDb.createTodo(any())).called(1);
    });

    test('toggleTodo calls database update', () async {
      when(() => mockDb.toggleTodo('1')).thenAnswer((_) async => true);

      final result = await repository.toggleTodo('1');

      expect(result, true);
      verify(() => mockDb.toggleTodo('1')).called(1);
    });
  });
}
