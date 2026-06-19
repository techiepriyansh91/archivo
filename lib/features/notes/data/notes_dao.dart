import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'notes_dao.g.dart';

/// Drift access object for the `notes` table. Lives in the feature's data layer
/// (feature-first), while the table + database wiring stay in core/database.
@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  /// Reactive query: the user's notes, excluding tombstones, filtered by archive
  /// state, newest first. Drift rebuilds this stream whenever `notes` changes.
  Stream<List<NoteRow>> watchNotes({
    required String userId,
    required bool archived,
  }) {
    return (select(notes)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.deletedAt.isNull() &
                t.isArchived.equals(archived),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<NoteRow?> findById(String id) =>
      (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertNote(NotesCompanion note) => into(notes).insert(note);

  /// Writes only the columns set in [companion] for the row matching [id].
  Future<void> updateFields(String id, NotesCompanion companion) =>
      (update(notes)..where((t) => t.id.equals(id))).write(companion);
}
