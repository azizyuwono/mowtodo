import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import 'database_provider.dart';

final todoRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider).valueOrNull;
  if (db == null) throw StateError('Database not initialized');
  return TodoRepository(db);
});

final todoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = ref.watch(todoRepositoryProvider);
  yield* repository.watchAllTodos();
});

final activeTodoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = ref.watch(todoRepositoryProvider);
  yield* repository.watchActiveTodos();
});

final completedTodoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = ref.watch(todoRepositoryProvider);
  yield* repository.watchCompletedTodos();
});

final activeTodoCountProvider = StreamProvider<int>((ref) async* {
  final todos = ref.watch(activeTodoListProvider);
  yield todos.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});

final completedTodoCountProvider = StreamProvider<int>((ref) async* {
  final todos = ref.watch(completedTodoListProvider);
  yield todos.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});

final todoNotifierProvider =
    StateNotifierProvider<TodoNotifier, AsyncValue<List<Todo>>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoNotifier(repository);
});

class TodoNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoRepository _repository;

  TodoNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final todos = await _repository.getAllTodos();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTodo(
    String title, {
    String? description,
    Priority priority = Priority.medium,
  }) async {
    final todo = Todo(title: title, description: description, priority: priority);
    try {
      await _repository.createTodo(todo);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTodo(String id) async {
    try {
      final currentTodos = state.maybeWhen(
        data: (todos) => todos,
        orElse: () => <Todo>[],
      );
      final todo = currentTodos.firstWhere((t) => t.id == id);
      await _repository.toggleTodo(id, completed: !todo.isCompleted);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _repository.deleteTodo(id);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final todos = await _repository.getAllTodos();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
