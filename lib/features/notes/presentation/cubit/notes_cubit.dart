import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/archive_note.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/update_note.dart';
import '../../domain/usecases/watch_notes.dart';
import 'notes_state.dart';

/// Drives the notes list. Reads are reactive: [watch] subscribes to the repo
/// stream, so mutations don't touch local state — the DB change flows back
/// through the stream and re-renders the list (optimistic by construction).
class NotesCubit extends Cubit<NotesState> {
  NotesCubit({
    required WatchNotes watchNotes,
    required CreateNote createNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
    required ArchiveNote archiveNote,
  }) : _watchNotes = watchNotes,
       _createNote = createNote,
       _updateNote = updateNote,
       _deleteNote = deleteNote,
       _archiveNote = archiveNote,
       super(const NotesInitial());

  final WatchNotes _watchNotes;
  final CreateNote _createNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;
  final ArchiveNote _archiveNote;

  StreamSubscription<List<Note>>? _sub;
  bool _archived = false;

  /// Subscribe to the notes stream for the active list ([archived] = false) or
  /// the archive ([archived] = true).
  void watch({bool archived = false}) {
    _archived = archived;
    emit(const NotesLoading());
    _sub?.cancel();
    _sub = _watchNotes(archived: archived).listen(
      (notes) => emit(NotesLoaded(notes)),
      onError: (Object e) => emit(NotesError(_message(e))),
    );
  }

  Future<void> create({required String title, required String body}) =>
      _guard(() => _createNote(CreateNoteParams(title: title, body: body)));

  Future<void> update(Note note) => _guard(() => _updateNote(note));

  Future<void> delete(String id) => _guard(() => _deleteNote(id));

  Future<void> setArchived({required String id, required bool archived}) =>
      _guard(() => _archiveNote(ArchiveNoteParams(id: id, archived: archived)));

  /// Runs a mutation; on failure surfaces an error state without tearing down
  /// the active stream subscription.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      emit(NotesError(_message(e)));
      // Re-attach to the stream so the list recovers after showing the error.
      watch(archived: _archived);
    }
  }

  String _message(Object e) =>
      e is Failure ? e.message : 'Something went wrong.';

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
