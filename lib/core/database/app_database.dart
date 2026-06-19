import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Notes table. Sync metadata columns (`updatedAt`, `deletedAt`, `syncStatus`,
/// `remoteRev`, `baseJson`) are present from day one — retrofitting them later is
/// the #1 thing that wrecks offline-first projects. See docs/PLAN.md §3.1.
class Notes extends Table {
  /// Client-generated uuid v4 — offline create must not wait on a server.
  TextColumn get id => text()();

  /// Firebase uid of the owner. Set on every row from the first write.
  TextColumn get userId => text()();

  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// 1:N — a note belongs to at most one collection (added in Slice 3).
  TextColumn get collectionId => text().nullable()();

  /// Epoch ms, set on every write. The LWW clock for conflict resolution.
  IntColumn get updatedAt => integer()();

  /// Soft delete = tombstone, so deletes propagate through sync.
  IntColumn get deletedAt => integer().nullable()();

  /// 0 synced · 1 pending · 2 conflict.
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  /// Server revision/etag, used for conflict detection on pull.
  TextColumn get remoteRev => text().nullable()();

  /// Last-synced snapshot (JSON) for the 3-way merge in §4.3. Notes only.
  TextColumn get baseJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  /// Pass an executor (e.g. [NativeDatabase.memory]) for tests; defaults to an
  /// on-disk database in the app documents directory.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'archivo.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
