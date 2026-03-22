import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Priority enum — stored as integer: 0=low, 1=medium, 2=high
// ---------------------------------------------------------------------------

enum TodoPriority {
  low,
  medium,
  high,
}

// ---------------------------------------------------------------------------
// Table definition
// Table is named TodoItems so the generated row class is TodoItem,
// avoiding collision with the domain Todo model.
// ---------------------------------------------------------------------------

class TodoItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get priority =>
      integer().withDefault(const Constant(1))(); // 0=low,1=medium,2=high
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // ------------------------------------------------------------------
  // Queries
  // ------------------------------------------------------------------

  /// All todos ordered by createdAt descending.
  Future<List<TodoItem>> getAllTodos() =>
      (select(todoItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Stream that emits whenever the todo_items table changes.
  Stream<List<TodoItem>> watchAllTodos() =>
      (select(todoItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  /// Stream of only incomplete todos.
  Stream<List<TodoItem>> watchActiveTodos() => (select(todoItems)
        ..where((t) => t.isCompleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  /// Stream of only completed todos.
  Stream<List<TodoItem>> watchCompletedTodos() => (select(todoItems)
        ..where((t) => t.isCompleted.equals(true))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  /// Insert a new todo row.
  Future<int> insertTodo(TodoItemsCompanion entry) =>
      into(todoItems).insert(entry);

  /// Update an existing todo by replacing the full row. Returns true if updated.
  Future<bool> updateTodo(TodoItemsCompanion entry) =>
      update(todoItems).replace(entry);

  /// Delete a todo by id. Returns the number of deleted rows.
  Future<int> deleteTodoById(String id) =>
      (delete(todoItems)..where((t) => t.id.equals(id))).go();

  /// Toggle the isCompleted flag for a single todo.
  Future<void> toggleTodoCompleted(String id, {required bool completed}) async {
    await (update(todoItems)..where((t) => t.id.equals(id)))
        .write(TodoItemsCompanion(isCompleted: Value(completed)));
  }
}

// ---------------------------------------------------------------------------
// Lazy database connection (desktop + mobile)
// ---------------------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mowtodo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
