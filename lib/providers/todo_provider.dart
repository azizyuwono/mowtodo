import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import 'database_provider.dart';

final todoRepositoryProvider = FutureProvider((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TodoRepository(db);
});

final todoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = await ref.watch(todoRepositoryProvider.future);
  yield* repository.watchAllTodos();
});

final activeTodoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = await ref.watch(todoRepositoryProvider.future);
  yield* repository.watchActiveTodos();
});

final completedTodoListProvider = StreamProvider<List<Todo>>((ref) async* {
  final repository = await ref.watch(todoRepositoryProvider.future);
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
    NotifierProvider<TodoNotifier, AsyncValue<List<Todo>>>(() {
  return TodoNotifier();
});

class TodoNotifier extends Notifier<AsyncValue<List<Todo>>> {
  late TodoRepository _repository;

  @override
  AsyncValue<List<Todo>> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    try {
      _repository = await ref.watch(todoRepositoryProvider.future);
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
