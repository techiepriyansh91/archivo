import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/failure.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/clock.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../domain/entities/note.dart';
import '../domain/repositories/notes_repository.dart';
import 'mappers/note_mapper.dart';
import 'notes_dao.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({
    required NotesDao dao,
    required AuthRepository auth,
    required Uuid uuid,
    required Clock clock,
  }) : _dao = dao,
       _auth = auth,
       _uuid = uuid,
       _clock = clock;

  final NotesDao _dao;
  final AuthRepository _auth;
  final Uuid _uuid;
  final Clock _clock;

  /// Owner of every write. Sourced from the auth boundary, never invented here.
  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthFailure('Not signed in.');
    return uid;
  }

  /// Marks a row as a local change awaiting push. Slice 2 enqueues a sync op in
  /// the same transaction; for now this just flags it.
  Value<int> get _pending => Value(SyncStatus.pending.index);

  @override
  Stream<List<Note>> watchNotes({bool archived = false}) {
    return _dao
        .watchNotes(userId: _uid, archived: archived)
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Future<Note> createNote({required String title, required String body}) async {
    try {
      final id = _uuid.v4();
      await _dao.insertNote(
        NotesCompanion.insert(
          id: id,
          userId: _uid,
          title: Value(title),
          body: Value(body),
          updatedAt: _clock.nowMs(),
          syncStatus: _pending,
        ),
      );
      final row = await _dao.findById(id);
      return row!.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw DatabaseFailure('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await _dao.updateFields(
        note.id,
        NotesCompanion(
          title: Value(note.title),
          body: Value(note.body),
          isFavorite: Value(note.isFavorite),
          isArchived: Value(note.isArchived),
          updatedAt: Value(_clock.nowMs()),
          syncStatus: _pending,
        ),
      );
    } catch (e) {
      throw DatabaseFailure('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      // Soft delete (tombstone) so the deletion can propagate on sync.
      await _dao.updateFields(
        id,
        NotesCompanion(
          deletedAt: Value(_clock.nowMs()),
          updatedAt: Value(_clock.nowMs()),
          syncStatus: _pending,
        ),
      );
    } catch (e) {
      throw DatabaseFailure('Failed to delete note: $e');
    }
  }

  @override
  Future<void> setArchived({required String id, required bool archived}) async {
    try {
      await _dao.updateFields(
        id,
        NotesCompanion(
          isArchived: Value(archived),
          updatedAt: Value(_clock.nowMs()),
          syncStatus: _pending,
        ),
      );
    } catch (e) {
      throw DatabaseFailure('Failed to archive note: $e');
    }
  }
}
