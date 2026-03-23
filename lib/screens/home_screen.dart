import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/filter_provider.dart';
import '../widgets/todo_tile.dart';
import '../widgets/add_todo_input.dart';
import '../widgets/todo_stats.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_filter_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodosAsync = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MowTodo')),
      body: Column(
        children: [
          // Stats
          filteredTodosAsync.when(
            data: (todos) => TodoStats(
              total: todos.length,
              active: todos.where((t) => !t.isCompleted).length,
              completed: todos.where((t) => t.isCompleted).length,
            ),
            loading: () => const SizedBox(height: 80),
            error: (err, st) => const SizedBox(height: 80),
          ),

          // Priority filter bar
          const PriorityFilterBar(),

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
            child: filteredTodosAsync.when(
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
              error: (err, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(todoNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
