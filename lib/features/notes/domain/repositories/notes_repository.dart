import '../entities/note.dart';

/// Notes data boundary. Implemented in the data layer over Drift. Implementations
/// throw a [Failure] (from core/error) on error; callers (cubits) catch it.
abstract interface class NotesRepository {
  /// Reactive stream of the signed-in user's notes, newest first.
  /// [archived] selects the active list (false) or the archive (true).
  /// Soft-deleted notes are always excluded.
  Stream<List<Note>> watchNotes({bool archived = false});

  /// Creates a note for the current user and returns it.
  Future<Note> createNote({required String title, required String body});

  /// Persists edits to an existing note (bumps updatedAt, marks pending).
  Future<void> updateNote(Note note);

  /// Soft-deletes (tombstones) a note so the delete can propagate on sync.
  Future<void> deleteNote(String id);

  /// Moves a note in/out of the archive.
  Future<void> setArchived({required String id, required bool archived});
}
