import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mowtodo/core/database/todo_database.dart';
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/repositories/todo_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;
  late TodoRepository repository;

  setUp(() {
    mockDb = MockAppDatabase();
    repository = TodoRepository(mockDb);
  });

  group('TodoRepository', () {
    test('getAllTodos returns mapped list of domain todos', () async {
      final data = TodoData(
        id: '1',
        title: 'Test',
        description: null,
        isCompleted: false,
        priority: Priority.medium,
        createdAt: DateTime.now(),
        dueDate: null,
      );

      when(() => mockDb.getAllTodos()).thenAnswer((_) async => [data]);

      final result = await repository.getAllTodos();

      expect(result, isNotEmpty);
      expect(result.first.title, 'Test');
      expect(result.first.priority, Priority.medium);
      verify(() => mockDb.getAllTodos()).called(1);
    });

    test('createTodo calls database createTodo', () async {
      final todo = Todo(title: 'New Task');

      when(() => mockDb.createTodo(any())).thenAnswer((_) async {});

      await repository.createTodo(todo);

      verify(() => mockDb.createTodo(any())).called(1);
    });

    test('toggleTodo calls database toggleTodo with correct completed flag', () async {
      when(() => mockDb.toggleTodo('1', completed: true))
          .thenAnswer((_) async => true);

      final result = await repository.toggleTodo('1', completed: true);

      expect(result, true);
      verify(() => mockDb.toggleTodo('1', completed: true)).called(1);
    });
  });
}
