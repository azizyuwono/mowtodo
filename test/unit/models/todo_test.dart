// test/unit/models/todo_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mowtodo/models/todo.dart';

void main() {
  group('Todo Model', () {
    test('creates todo with generated ID', () {
      final todo = Todo(title: 'Test Task');
      expect(todo.id, isNotEmpty);
      expect(todo.title, 'Test Task');
      expect(todo.isCompleted, false);
    });

    test('creates todo with default medium priority', () {
      final todo = Todo(title: 'Priority Test');
      expect(todo.priority, Priority.medium);
    });

    test('creates todo with explicit ID', () {
      final todo = Todo(id: 'explicit-id', title: 'Test');
      expect(todo.id, 'explicit-id');
    });

    test('copyWith creates modified copy preserving original', () {
      final original = Todo(title: 'Original');
      final modified = original.copyWith(title: 'Modified', isCompleted: true);

      expect(original.title, 'Original');
      expect(original.isCompleted, false);
      expect(modified.title, 'Modified');
      expect(modified.isCompleted, true);
      expect(original.id, modified.id);
    });

    test('copyWith preserves unspecified fields', () {
      final original = Todo(
        title: 'Original',
        description: 'Desc',
        priority: Priority.high,
      );
      final modified = original.copyWith(title: 'Modified');

      expect(modified.description, 'Desc');
      expect(modified.priority, Priority.high);
    });

    test('equality based on ID', () {
      final todo1 = Todo(id: '1', title: 'Task');
      final todo2 = Todo(id: '1', title: 'Different');

      expect(todo1, todo2);
    });

    test('inequality for different IDs', () {
      final todo1 = Todo(id: '1', title: 'Task');
      final todo2 = Todo(id: '2', title: 'Task');

      expect(todo1, isNot(equals(todo2)));
    });

    test('hashCode matches for equal todos', () {
      final todo1 = Todo(id: '42', title: 'Task A');
      final todo2 = Todo(id: '42', title: 'Task B');

      expect(todo1.hashCode, todo2.hashCode);
    });

    test('toString contains key fields', () {
      final todo = Todo(id: 'abc', title: 'My Task');
      final str = todo.toString();
      expect(str, contains('abc'));
      expect(str, contains('My Task'));
    });

    test('two todos with generated IDs are not equal', () {
      final todo1 = Todo(title: 'Same Title');
      final todo2 = Todo(title: 'Same Title');
      expect(todo1, isNot(equals(todo2)));
    });

    test('createdAt defaults to current time', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final todo = Todo(title: 'Time Test');
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(todo.createdAt.isAfter(before), true);
      expect(todo.createdAt.isBefore(after), true);
    });

    test('dueDate is null by default', () {
      final todo = Todo(title: 'No Due Date');
      expect(todo.dueDate, isNull);
    });

    test('description is null by default', () {
      final todo = Todo(title: 'No Desc');
      expect(todo.description, isNull);
    });
  });
}
