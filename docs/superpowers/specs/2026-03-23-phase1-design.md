# Phase 1: Loading Fix + Monochrome + Filters + Search

**Date:** 2026-03-23
**Status:** Design Approved
**Scope:** Desktop widget todo app enhancements

---

## Overview

Phase 1 delivers four focused improvements to MowTodo:

1. Fix loading screen flicker when database initializes
2. Redesign UI from soft blue accent to charcoal + white monochrome
3. Add priority filter toggles (High, Medium, Low, Completed)
4. Add search bar for filtering tasks by title/description

These features can ship together as a cohesive release, improving UX (no loading blink), aesthetics (monochrome), and discoverability (search + filters).

---

## 1. Loading Screen Fix

### Problem

Currently, when the app launches, the database initializes asynchronously. HomeScreen shows `FadeTransition` + `SlideTransition` animations, which cause visual flickering ("blink blink") while data loads.

### Solution

- Remove animations from HomeScreen (no fade-in, no slide-up on load)
- While `todoNotifierProvider` is `AsyncValue.loading()`, display a minimal loading state
- Loading state: centered `CircularProgressIndicator` with no splash screen, no branding
- When todos load, spinner is replaced with actual content (no animation)

### Implementation Details

- Modify HomeScreen body to detect `AsyncValue.loading()` and show spinner instead of Column
- Spinner appears immediately, stays until data arrives (usually < 2-3 seconds)
- Widget context: minimal, non-intrusive (no splash screen needed for floating widget)
- No animation between loading and loaded states

### Error Handling

- If data fails to load, show error message instead of spinner
- User can retry (add retry button in error state)

---

## 2. Monochrome Redesign

### Color Palette

| Usage                | Color      | Hex       |
| -------------------- | ---------- | --------- |
| Background           | White      | `#FFFFFF` |
| Text (Primary)       | Charcoal   | `#2C3E50` |
| Text (Secondary)     | Gray       | `#7F8C8D` |
| Borders/Dividers     | Light Gray | `#E8EAED` |
| Buttons/Focus/Active | Near-Black | `#1A1A1A` |
| Hover Background     | Soft Gray  | `#F5F5F5` |
| Completed State      | Light Gray | `#95A5A6` |

### Changes to AppColors

Replace:

```dart
static const Color accent = Color(0xFF5DADE2); // soft blue
```

With:

```dart
static const Color accent = Color(0xFF1A1A1A); // near-black for focus/active states
static const Color hoverBackground = Color(0xFFF5F5F5); // light gray for hover
```

### UI Element Updates

1. **Buttons (Add, dropdowns)**
   - Background: near-black (`#1A1A1A`)
   - Text: white
   - Hover: slightly darker or add subtle border

2. **TodoTile**
   - Hover background: light gray (`#F5F5F5`)
   - Border: light gray (`#E8EAED`)
   - Priority indicator dot: charcoal (`#2C3E50`)
   - Delete button text: gray (`#7F8C8D`)

3. **TodoStats**
   - Numbers: charcoal (`#2C3E50`, bold 32pt)
   - Labels: gray (`#7F8C8D`)
   - No background color

4. **EmptyState**
   - Icon: light gray (`#BDC3C7`)
   - Text: charcoal (`#2C3E50`)

5. **AppBar**
   - Background: white, slight border-bottom in light gray
   - Text: charcoal

6. **Focus States (search, input fields)**
   - Border: near-black (`#1A1A1A`)
   - Subtle background tint: light gray (`#F5F5F5`)

### Design Rationale

**Why monochrome?**

- Cleaner, more professional aesthetic
- Works well on desktop widgets (less "app-y", more tool-like)
- Better visual hierarchy without color competition
- Easier to extend (Phase 2 can use accents strategically for categories/tags)

**Why charcoal + white instead of dark mode?**

- Desktop widget context: users may have light backgrounds
- Charcoal text on white is highly readable
- Keeps the "calm, focused" brand while being minimalist

---

## 3. Priority Filters

### Component: PriorityFilterBar

**Location:** Between TodoStats and AddTodoInput
**State:** Managed by new `FilterNotifier` (Riverpod)

### UI Design

```
[✓ High] [✓ Medium] [✓ Low] [✓ Completed]
```

- 4 checkboxes, each toggleable
- Labels: "High", "Medium", "Low", "Completed"
- All checked by default (show all todos)
- Clicking unchecks/checks that priority
- Multiple selections allowed (e.g., show High + Low only)

### Behavior

- When a priority is unchecked, todos with that priority disappear from the list
- "Completed" toggle: when unchecked, hides all `isCompleted: true` todos
- Works in combination with search (both filters apply)
- Persists across app sessions (save FilterNotifier state to local storage in Phase 2)

### State Management

New `filterProvider` (Riverpod):

```dart
final filterProvider = NotifierProvider<FilterNotifier, FilterState>(...);

class FilterState {
  bool showHigh = true;
  bool showMedium = true;
  bool showLow = true;
  bool showCompleted = true;
  String searchQuery = '';
}
```

### Styling

- Checkboxes: use Flutter's default with charcoal color
- Labels: gray text (`#7F8C8D`)
- Padding: consistent with design system (lg spacing)
- Hover: subtle background highlight

---

## 4. Search Bar

### Component: Integrated into AddTodoInput

**Location:** New top row in AddTodoInput, above title field
**State:** Managed by `FilterNotifier.searchQuery`

### UI Design

```
[🔍 Search tasks...]
[Title input field]
[Description toggle]
```

- Icon: magnifying glass
- Placeholder: "Search tasks..."
- Real-time filtering as user types
- Clear button (X) visible when search is active

### Behavior

- Searches both `title` AND `description` fields (case-insensitive)
- Updates results live (no "Search" button needed)
- Works with priority filters (narrows further)
- Escape key clears search
- Focus defaults to search bar after priority filter change (optional UX refinement)

### State Management

Search query lives in `FilterNotifier`:

```dart
void updateSearch(String query) {
  state = state.copyWith(searchQuery: query.toLowerCase());
}
```

### Styling

- Input field: white background, light gray border (`#E8EAED`)
- Focus: light gray background (`#F5F5F5`), near-black border (`#1A1A1A`)
- Icon: gray (`#7F8C8D`)
- Clear button: gray, hover to black

---

## 5. Filtering Logic

### Combined Filter

When both search + priority filters are active:

```
visibleTodos = allTodos
  .where((todo) => selectedPriorities.contains(todo.priority))
  .where((todo) => !searchQuery.isEmpty
    ? (todo.title.toLowerCase().contains(searchQuery)
      || todo.description?.toLowerCase().contains(searchQuery) ?? false)
    : true)
  .toList()
```

### Default State

- All priorities shown
- All completed todos shown
- No search query
- Result: user sees all todos (existing behavior)

---

## 6. Data Flow

```
App Start
  ↓
[Loading Spinner] → Database Initializes
  ↓
HomeScreen (no animations)
  ↓
[TodoStats] [unchanged]
  ↓
[PriorityFilterBar] ← FilterNotifier (priority toggles)
  ↓
[AddTodoInput with Search] ← FilterNotifier (search query)
  ↓
[TodoList] ← TodoNotifier + FilterNotifier combined
  ↓
Display filtered todos
```

### Providers

- `databaseProvider` (FutureProvider) - database initialization
- `todoNotifierProvider` (NotifierProvider) - all todos from DB
- `filterProvider` (NotifierProvider) - search + priority filter state
- **New computed provider:** `filteredTodosProvider` - combines todoNotifier + filterProvider

---

## 7. Files to Create/Modify

### New Files

- `lib/providers/filter_provider.dart` - FilterNotifier + FilterState
- `lib/widgets/priority_filter_bar.dart` - PriorityFilterBar widget

### Modified Files

- `lib/screens/home_screen.dart` - Remove animations, add loading spinner
- `lib/widgets/add_todo_input.dart` - Add search bar to top
- `lib/core/theme/app_colors.dart` - Update color palette
- `lib/widgets/todo_tile.dart` - Update colors to monochrome
- `lib/widgets/todo_stats.dart` - Update colors
- `lib/widgets/empty_state.dart` - Update colors

---

## 8. Testing Strategy

### Unit Tests

- FilterNotifier: toggle filters, search queries, combined filtering
- FilterState copyWith behavior

### Widget Tests

- PriorityFilterBar renders checkboxes, toggles work
- AddTodoInput search bar updates filter
- TodoList shows/hides todos based on filters
- Loading spinner shows while data loads

### Integration Tests

- E2E: Add todo → filter by priority → search → see filtered results
- E2E: Toggle all filters off → see only completed todos

---

## 9. Migration & Rollout

### Database Changes

None. All filtering is in-memory (no schema changes).

### Breaking Changes

None. Existing code works, colors just change.

### Backward Compatibility

Users' todos are unchanged. New filter state is ephemeral (cleared on app restart, can be persisted in Phase 2).

---

## 10. Success Criteria

- ✅ Loading spinner appears with no flicker when app starts
- ✅ All UI colors are charcoal/gray/white (no blue accent)
- ✅ Priority filter toggles work, multiple selections allowed
- ✅ Search bar filters by title + description, real-time
- ✅ Filters work together (search + priority)
- ✅ All 39 existing tests still pass
- ✅ No errors on startup
- ✅ Desktop widget displays smoothly (minimal, focused aesthetic)

---

## 11. Phase 2 Foundation

This design sets up Phase 2 cleanly:

- FilterNotifier can add `dueDateFilter`, `categoryFilter`, etc.
- State persists to local storage (using shared_preferences)
- Drag-to-reorder uses existing todo list, no new state needed
- Undo/history can hook into TodoNotifier's refresh logic
- Categories/tags can be added to Todo model + FilterNotifier
