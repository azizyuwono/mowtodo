import 'todo.dart';

sealed class TodoState {
  const TodoState();
}

final class TodoInitial extends TodoState {
  const TodoInitial();
}

final class TodoLoading extends TodoState {
  const TodoLoading();
}

final class TodoLoaded extends TodoState {
  final List<Todo> todos;
  const TodoLoaded(this.todos);

  int get activeCount => todos.where((t) => !t.isCompleted).length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
}

final class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
}
