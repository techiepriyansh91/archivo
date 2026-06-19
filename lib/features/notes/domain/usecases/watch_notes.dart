import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Streams the current user's notes. A streaming use case, so it doesn't use the
/// Future-based [UseCase] base.
class WatchNotes {
  const WatchNotes(this._repository);

  final NotesRepository _repository;

  Stream<List<Note>> call({bool archived = false}) =>
      _repository.watchNotes(archived: archived);
}
