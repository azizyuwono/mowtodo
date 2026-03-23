# MowTodo 🎯

A **minimal, focused task management widget** for Flutter Desktop. Stay calm, stay focused, get things done.

> _Calm design. Quick interactions. Zero distractions._

---

## Features

✨ **Minimal & Calm** — Monochrome design that reduces cognitive load
🔍 **Smart Search** — Filter tasks by title or description, case-insensitive
🎚️ **Priority Filters** — Organize by High, Medium, Low, or show only completed tasks
⚡ **Quick Input** — Add title, description, and priority in one smooth flow
📊 **Task Stats** — See active/completed counts at a glance
🎨 **Desktop-First** — Built for Flutter Desktop, floating window friendly

---

## Tech Stack

- **Framework**: Flutter 3.24+ (Desktop)
- **State Management**: Riverpod 3 (computed providers, NotifierProvider)
- **Database**: Drift (SQLite with type-safe queries)
- **Testing**: Unit & widget tests with 100% core coverage
- **Design**: Focus-first principles, monochrome palette

---

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- A supported platform (Windows, macOS, Linux)

### Installation

```bash
# Clone the repo
git clone https://github.com/azizyuwono/mowtodo.git
cd mowtodo

# Get dependencies
flutter pub get

# Run on desktop
flutter run -d windows  # or -d macos, -d linux
```

### Run Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run with coverage
flutter test test/unit/ --coverage
```

---

## Architecture

```
lib/
├── core/
│   ├── database/       # Drift database layer
│   └── theme/          # Colors, spacing, typography
├── models/             # Domain models (Todo)
├── providers/          # Riverpod state management
│   ├── todo_provider.dart         # CRUD operations
│   ├── filter_provider.dart       # Search & filtering
│   └── database_provider.dart     # Database initialization
├── repositories/       # Data layer abstraction
├── screens/            # Main screen
└── widgets/            # Reusable UI components
    ├── add_todo_input.dart        # Search + input
    ├── priority_filter_bar.dart   # Filter checkboxes
    ├── todo_tile.dart             # Task item
    ├── todo_stats.dart            # Stats display
    └── empty_state.dart           # Empty state UI
```

---

## Design Philosophy

**5 Core Principles:**

1. **Focus First** — Every element must justify its existence
2. **Whitespace is Content** — Space reduces cognitive load
3. **One Action at a Time** — Quick, atomic interactions
4. **Calm Colors** — Monochrome palette avoids harsh contrast
5. **Always Accessible** — Readable text, obvious interactions

---

## Phase 1 Complete ✅

- ✅ Loading screen (minimal spinner)
- ✅ Monochrome redesign
- ✅ Priority filters
- ✅ Search functionality
- ✅ Modern outlined icons
- ✅ Optimized padding & spacing

## Phase 2 Planned

- Due dates
- Drag-to-reorder
- Categories/tags
- Keyboard shortcuts
- Undo/history

---

## Contributing

This is an active project. Feel free to open issues or PRs!

---

## License

MIT

---

Built with ❤️ for focused work.
