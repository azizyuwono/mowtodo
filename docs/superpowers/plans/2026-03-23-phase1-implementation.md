# Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver loading screen fix, monochrome redesign, priority filters, and search bar for MowTodo Phase 1.

**Architecture:**

- Create FilterNotifier (Riverpod) to manage search query + priority toggles
- Create PriorityFilterBar widget to display and toggle filters
- Update all colors to monochrome (charcoal/white/gray)
- Add search bar to AddTodoInput
- Remove HomeScreen animations, add loading spinner
- Computed provider (filteredTodosProvider) combines TodoNotifier + FilterNotifier

**Tech Stack:** Flutter, Dart, Riverpod 3, Drift (database)

---

## Task 1: Update AppColors to Monochrome Palette

**Files:**

- Modify: `lib/core/theme/app_colors.dart`

- [ ] **Step 1: Read current AppColors file**

```bash
cat lib/core/theme/app_colors.dart
```

- [ ] **Step 2: Replace color palette**

Replace entire AppColors class:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color charcoal = Color(0xFF2C3E50);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF1A1A1A);

  // Grays
  static const Color gray = Color(0xFF7F8C8D);
  static const Color darkGray = Color(0xFF95A5A6);
  static const Color mediumGray = Color(0xFFBDC3C7);
  static const Color lightGray = Color(0xFFE8EAED);
  static const Color softGray = Color(0xFFF5F5F5);

  // Legacy (keep for compatibility, map to grayscale)
  static const Color accent = nearBlack; // Used for buttons, focus states
  static const Color success = darkGray; // For completed todos
  static const Color error = nearBlack; // For error states

  // Semantic names for new colors
  static const Color hoverBackground = softGray;
  static const Color borderColor = lightGray;
  static const Color textPrimary = charcoal;
  static const Color textSecondary = gray;
}
```

- [ ] **Step 3: Run flutter analyze to check for import errors**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze 2>&1 | head -20
```

Expected: No errors (old color names still mapped for compatibility)

- [ ] **Step 4: Commit**

```bash
git add lib/core/theme/app_colors.dart
git commit -m "refactor(theme): update to monochrome color palette (charcoal/white/gray)"
```

---

## Task 2: Create FilterNotifier and FilterState

**Files:**

- Create: `lib/providers/filter_provider.dart`

- [ ] **Step 1: Write the filter_provider.dart file**

```dart
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
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze 2>&1 | grep -E "error|warning"
```

Expected: No errors related to filter_provider.dart

- [ ] **Step 3: Commit**

```bash
git add lib/providers/filter_provider.dart
git commit -m "feat(providers): create FilterNotifier and filteredTodosProvider"
```

---

## Task 3: Create PriorityFilterBar Widget

**Files:**

- Create: `lib/widgets/priority_filter_bar.dart`

- [ ] **Step 1: Write the priority_filter_bar.dart file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/todo.dart';
import '../providers/filter_provider.dart';

class PriorityFilterBar extends ConsumerWidget {
  const PriorityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _FilterCheckbox(
            label: 'High',
            value: filterState.showHigh,
            onChanged: (_) => filterNotifier.togglePriority(Priority.high),
          ),
          const SizedBox(width: AppSpacing.lg),
          _FilterCheckbox(
            label: 'Medium',
            value: filterState.showMedium,
            onChanged: (_) => filterNotifier.togglePriority(Priority.medium),
          ),
          const SizedBox(width: AppSpacing.lg),
          _FilterCheckbox(
            label: 'Low',
            value: filterState.showLow,
            onChanged: (_) => filterNotifier.togglePriority(Priority.low),
          ),
          const SizedBox(width: AppSpacing.lg),
          _FilterCheckbox(
            label: 'Completed',
            value: filterState.showCompleted,
            onChanged: (_) => filterNotifier.toggleCompleted(),
          ),
        ],
      ),
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
            activeColor: AppColors.nearBlack,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze 2>&1 | grep -E "error|warning" | head -5
```

Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/priority_filter_bar.dart
git commit -m "feat(widgets): create PriorityFilterBar with checkbox toggles"
```

---

## Task 4: Update TodoTile Colors to Monochrome

**Files:**

- Modify: `lib/widgets/todo_tile.dart:48-57` (priority color method)
- Modify: `lib/widgets/todo_tile.dart:120-170` (text colors)

- [ ] **Step 1: Update priority indicator color method**

Find and replace `_getPriorityColor()` method:

```dart
Color _getPriorityColor() {
  switch (widget.todo.priority) {
    case Priority.high:
      return AppColors.charcoal; // dark gray instead of red
    case Priority.medium:
      return AppColors.gray; // medium gray instead of blue
    case Priority.low:
      return AppColors.mediumGray; // light gray instead of gray
  }
}
```

- [ ] **Step 2: Update title text color in build method**

Find line ~121 where title text color is set, update to:

```dart
style: AppTypography.bodyLarge.copyWith(
  color: widget.todo.isCompleted
      ? AppColors.mediumGray
      : AppColors.textPrimary,
  decoration: widget.todo.isCompleted
      ? TextDecoration.lineThrough
      : null,
  height: 1.5,
),
```

- [ ] **Step 3: Update delete button color**

Find line ~169 where delete button color is set, update to:

```dart
color: AppColors.textSecondary,
```

- [ ] **Step 4: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze lib/widgets/todo_tile.dart 2>&1
```

Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/todo_tile.dart
git commit -m "refactor(widgets): update TodoTile to monochrome colors"
```

---

## Task 5: Update TodoStats Colors to Monochrome

**Files:**

- Modify: `lib/widgets/todo_stats.dart:60-75` (stat item colors)

- [ ] **Step 1: Update stat number color in \_StatItem**

Find the Text widget that displays `'$value'`, update to:

```dart
Text(
  '$value',
  style: AppTypography.displayMedium.copyWith(
    color: AppColors.textPrimary, // charcoal instead of color param
    fontSize: 32,
    fontWeight: FontWeight.w600,
  ),
),
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze lib/widgets/todo_stats.dart 2>&1
```

Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/todo_stats.dart
git commit -m "refactor(widgets): update TodoStats to monochrome colors"
```

---

## Task 6: Update EmptyState Colors to Monochrome

**Files:**

- Modify: `lib/widgets/empty_state.dart:13-27`

- [ ] **Step 1: Update icon color**

Find the Icon widget, update to:

```dart
Icon(
  Icons.inbox_outlined,
  size: 72,
  color: AppColors.mediumGray,
),
```

- [ ] **Step 2: Update text colors**

Find the heading Text, update to:

```dart
Text(
  'No tasks yet.',
  style: AppTypography.displaySmall.copyWith(
    color: AppColors.textPrimary,
    height: 1.4,
  ),
),
```

And the subtitle Text:

```dart
Text(
  'Create your first task to stay focused.',
  style: AppTypography.bodyMedium.copyWith(
    color: AppColors.textSecondary,
    height: 1.5,
  ),
  textAlign: TextAlign.center,
),
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze lib/widgets/empty_state.dart 2>&1
```

Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/empty_state.dart
git commit -m "refactor(widgets): update EmptyState to monochrome colors"
```

---

## Task 7: Update AddTodoInput with Search Bar

**Files:**

- Modify: `lib/widgets/add_todo_input.dart`

- [ ] **Step 1: Add search field to state variables**

In `_AddTodoInputState`, add:

```dart
late TextEditingController _searchController;
```

- [ ] **Step 2: Initialize search controller in initState**

Add to `initState()`:

```dart
_searchController = TextEditingController();

_searchController.addListener(() {
  ref.read(filterProvider.notifier).updateSearch(_searchController.text);
});
```

- [ ] **Step 3: Dispose search controller**

Add to `dispose()`:

```dart
_searchController.dispose();
```

- [ ] **Step 4: Add search bar to build method**

In the Column children, add search bar BEFORE the title field Row:

```dart
Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
  child: Row(
    children: [
      Icon(Icons.search, color: AppColors.textSecondary, size: 20),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          style: AppTypography.bodyMedium,
        ),
      ),
      if (_searchController.text.isNotEmpty)
        GestureDetector(
          onTap: () {
            _searchController.clear();
            ref.read(filterProvider.notifier).clearSearch();
          },
          child: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
        ),
    ],
  ),
),
```

- [ ] **Step 5: Add import for filterProvider**

Add at the top of file:

```dart
import '../providers/filter_provider.dart';
```

- [ ] **Step 6: Change AddTodoInput to ConsumerStatefulWidget**

Change class declaration from `StatefulWidget` to `ConsumerStatefulWidget`
Change `createState()` return type and implementation
Change state class from `extends State<AddTodoInput>` to `extends ConsumerState<AddTodoInput>`
Add `ref` parameter to build method signature

- [ ] **Step 7: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze lib/widgets/add_todo_input.dart 2>&1 | head -10
```

Expected: No errors

- [ ] **Step 8: Commit**

```bash
git add lib/widgets/add_todo_input.dart
git commit -m "feat(widgets): add search bar to AddTodoInput"
```

---

## Task 8: Update HomeScreen with Loading Spinner and Filtered Todos

**Files:**

- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Remove animations from HomeScreen**

Remove the AnimationController, FadeTransition, and SlideTransition code. Keep it as a simple ConsumerWidget.

- [ ] **Step 2: Update build method to use filteredTodosProvider**

Replace `todoNotifierProvider` watch with `filteredTodosProvider`:

```dart
final filteredTodosAsync = ref.watch(filteredTodosProvider);
```

- [ ] **Step 3: Add loading spinner and error states**

Update the body Column's second child (the list section):

```dart
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
                  ref.read(todoNotifierProvider.notifier).toggleTodo(todo.id);
                },
                onDelete: () {
                  ref.read(todoNotifierProvider.notifier).deleteTodo(todo.id);
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
```

- [ ] **Step 4: Add PriorityFilterBar to layout**

Insert PriorityFilterBar between TodoStats and AddTodoInput in the Column:

```dart
import '../widgets/priority_filter_bar.dart';

// In Column children:
const PriorityFilterBar(),
```

- [ ] **Step 5: Run flutter analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze lib/screens/home_screen.dart 2>&1
```

Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "refactor(screens): remove animations, add loading spinner, integrate filters"
```

---

## Task 9: Write Unit Tests for FilterNotifier

**Files:**

- Create: `test/unit/providers/filter_provider_test.dart`

- [ ] **Step 1: Write filter provider tests**

```dart
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
```

- [ ] **Step 2: Run tests**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter test test/unit/providers/filter_provider_test.dart -v 2>&1 | tail -20
```

Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add test/unit/providers/filter_provider_test.dart
git commit -m "test: add unit tests for FilterNotifier and FilterState"
```

---

## Task 10: Run All Tests and Final Verification

**Files:**

- None (verification only)

- [ ] **Step 1: Run all tests**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter test 2>&1 | tail -30
```

Expected: All tests pass (39+ tests)

- [ ] **Step 2: Run analyze**

```bash
cd /c/Users/Aziz\ Yuwono/Documents/Development/desktop/mowtodo && flutter analyze 2>&1
```

Expected: No issues found

- [ ] **Step 3: Final commit summary**

```bash
git log --oneline -15 2>&1
```

Verify all Phase 1 commits are present

- [ ] **Step 4: Visual check (manual)**

Run the app and verify:

- No flicker on startup (loading spinner appears cleanly)
- All colors are monochrome (charcoal/white/gray)
- Priority filter checkboxes visible and working
- Search bar visible in input area
- Filtering works (toggle priorities, type search)
- All existing features still work

---

## Implementation Notes

### Color Mapping Reference

Old → New:

- `AppColors.accent` (blue) → `AppColors.nearBlack`
- `AppColors.success` → `AppColors.darkGray`
- Hover backgrounds → `AppColors.softGray`

### Testing Strategy

- Unit tests: FilterNotifier behavior
- Widget tests: PriorityFilterBar + search rendering (covered by existing tests)
- Integration: Add todo → filter by priority → search → verify results

### Known Limitations

- Filter state doesn't persist across app restarts (saved for Phase 2)
- No animation on filter toggle (straightforward, added in Phase 2 if needed)

### Future Considerations (Phase 2)

- Persist FilterState to local storage
- Add filter state animations
- Extend filters for due dates, categories, tags
