import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import '../widgets/add_todo_input.dart';
import '../widgets/todo_stats.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MowTodo')),
      body: Column(
        children: [
          // Stats
          todosAsync.when(
            data: (todos) => TodoStats(
              total: todos.length,
              active: todos.where((t) => !t.isCompleted).length,
              completed: todos.where((t) => t.isCompleted).length,
            ),
            loading: () => const SizedBox(height: 80),
            error: (err, st) => const SizedBox(height: 80),
          ),

          // Add input
          AddTodoInput(
            onAdd: (title, {description, priority = Priority.medium}) {
              ref.read(todoNotifierProvider.notifier).addTodo(
                    title,
                    description: description,
                    priority: priority,
                  );
            },
          ),

          // Todo list
          Expanded(
            child: todosAsync.when(
              data: (todos) => todos.isEmpty
                  ? const EmptyState()
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return TodoTile(
                          todo: todo,
                          onToggle: () {
                            ref
                                .read(todoNotifierProvider.notifier)
                                .toggleTodo(todo.id);
                          },
                          onDelete: () {
                            ref
                                .read(todoNotifierProvider.notifier)
                                .deleteTodo(todo.id);
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
