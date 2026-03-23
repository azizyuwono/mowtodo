import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mowtodo/models/todo.dart';
import 'package:mowtodo/providers/filter_provider.dart';

void main() {
  group('FilterState', () {
    test('matches returns true for todos matching all criteria', () {
      const state = FilterState();
      final todo = Todo(
        title: 'Test Task',
        priority: Priority.high,
      );
      expect(state.matches(todo), true);
    });

    test('matches returns false for unchecked priority', () {
      const state = FilterState(showHigh: false);
      final todo = Todo(
        title: 'Test Task',
        priority: Priority.high,
      );
      expect(state.matches(todo), false);
    });

    test('matches returns false for completed todo when showCompleted false', () {
      const state = FilterState(showCompleted: false);
      final todo = Todo(
        title: 'Test Task',
        priority: Priority.medium,
        isCompleted: true,
      );
      expect(state.matches(todo), false);
    });

    test('matches filters by search query in title', () {
      const state = FilterState(searchQuery: 'buy');
      final todo = Todo(
        title: 'Buy groceries',
        priority: Priority.medium,
      );
      expect(state.matches(todo), true);
    });

    test('matches filters by search query in description', () {
      const state = FilterState(searchQuery: 'office');
      final todo = Todo(
        title: 'Meeting',
        description: 'at the office',
        priority: Priority.medium,
      );
      expect(state.matches(todo), true);
    });

    test('matches is case insensitive', () {
      const state = FilterState(searchQuery: 'BUY');
      final todo = Todo(
        title: 'buy groceries',
        priority: Priority.medium,
      );
      expect(state.matches(todo), true);
    });

    test('copyWith creates new state with updated fields', () {
      const state = FilterState(showHigh: true);
      final newState = state.copyWith(showHigh: false);
      expect(state.showHigh, true);
      expect(newState.showHigh, false);
    });
  });

  group('FilterNotifier', () {
    test('togglePriority toggles high priority filter', () async {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.togglePriority(Priority.high);
      expect(container.read(filterProvider).showHigh, false);

      notifier.togglePriority(Priority.high);
      expect(container.read(filterProvider).showHigh, true);
    });

    test('toggleCompleted toggles completed filter', () async {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.toggleCompleted();
      expect(container.read(filterProvider).showCompleted, false);

      notifier.toggleCompleted();
      expect(container.read(filterProvider).showCompleted, true);
    });

    test('updateSearch updates search query', () async {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.updateSearch('Buy');
      expect(container.read(filterProvider).searchQuery, 'buy');
    });

    test('clearSearch clears search query', () async {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.updateSearch('test');
      notifier.clearSearch();
      expect(container.read(filterProvider).searchQuery, '');
    });

    test('reset resets all filters to default', () async {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.togglePriority(Priority.high);
      notifier.updateSearch('test');
      notifier.reset();

      final state = container.read(filterProvider);
      expect(state.showHigh, true);
      expect(state.searchQuery, '');
    });
  });
}
