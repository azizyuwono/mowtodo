import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import 'todo_provider.dart';

/// State for filtering todos by priority and search query
class FilterState {
  final bool showHigh;
  final bool showMedium;
  final bool showLow;
  final bool showCompleted;
  final String searchQuery;

  const FilterState({
    this.showHigh = true,
    this.showMedium = true,
    this.showLow = true,
    this.showCompleted = true,
    this.searchQuery = '',
  });

  FilterState copyWith({
    bool? showHigh,
    bool? showMedium,
    bool? showLow,
    bool? showCompleted,
    String? searchQuery,
  }) {
    return FilterState(
      showHigh: showHigh ?? this.showHigh,
      showMedium: showMedium ?? this.showMedium,
      showLow: showLow ?? this.showLow,
      showCompleted: showCompleted ?? this.showCompleted,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Returns true if todo should be visible based on filters
  bool matches(Todo todo) {
    // Check priority filter
    final priorityMatches = switch (todo.priority) {
      Priority.high => showHigh,
      Priority.medium => showMedium,
      Priority.low => showLow,
    };

    if (!priorityMatches) return false;

    // Check completed filter
    if (todo.isCompleted && !showCompleted) return false;

    // Check search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final titleMatches = todo.title.toLowerCase().contains(query);
      final descMatches = (todo.description?.toLowerCase().contains(query)) ?? false;
      return titleMatches || descMatches;
    }

    return true;
  }
}

/// Notifier for managing filter state
class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return const FilterState();
  }

  void togglePriority(Priority priority) {
    state = switch (priority) {
      Priority.high => state.copyWith(showHigh: !state.showHigh),
      Priority.medium => state.copyWith(showMedium: !state.showMedium),
      Priority.low => state.copyWith(showLow: !state.showLow),
    };
  }

  void toggleCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void reset() {
    state = const FilterState();
  }
}

/// Provider for filter state
final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

/// Computed provider that combines todos with filters
final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoNotifierProvider);
  final filterState = ref.watch(filterProvider);

  return todosAsync.whenData((todos) {
    return todos.where((todo) => filterState.matches(todo)).toList();
  });
});
