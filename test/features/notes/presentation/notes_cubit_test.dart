import 'package:archivo/core/error/failure.dart';
import 'package:archivo/features/notes/domain/entities/note.dart';
import 'package:archivo/features/notes/domain/usecases/archive_note.dart';
import 'package:archivo/features/notes/domain/usecases/create_note.dart';
import 'package:archivo/features/notes/domain/usecases/delete_note.dart';
import 'package:archivo/features/notes/domain/usecases/update_note.dart';
import 'package:archivo/features/notes/domain/usecases/watch_notes.dart';
import 'package:archivo/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:archivo/features/notes/presentation/cubit/notes_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchNotes extends Mock implements WatchNotes {}

class _MockCreateNote extends Mock implements CreateNote {}

class _MockUpdateNote extends Mock implements UpdateNote {}

class _MockDeleteNote extends Mock implements DeleteNote {}

class _MockArchiveNote extends Mock implements ArchiveNote {}

void main() {
  late _MockWatchNotes watchNotes;
  late _MockCreateNote createNote;
  late _MockUpdateNote updateNote;
  late _MockDeleteNote deleteNote;
  late _MockArchiveNote archiveNote;

  final note = Note(
    id: '1',
    title: 't',
    body: 'b',
    isFavorite: false,
    isArchived: false,
    updatedAt: DateTime(2026),
  );

  setUp(() {
    watchNotes = _MockWatchNotes();
    createNote = _MockCreateNote();
    updateNote = _MockUpdateNote();
    deleteNote = _MockDeleteNote();
    archiveNote = _MockArchiveNote();
  });

  NotesCubit build() => NotesCubit(
    watchNotes: watchNotes,
    createNote: createNote,
    updateNote: updateNote,
    deleteNote: deleteNote,
    archiveNote: archiveNote,
  );

  blocTest<NotesCubit, NotesState>(
    'watch emits [Loading, Loaded] from the repository stream',
    build: () {
      when(
        () => watchNotes.call(archived: any(named: 'archived')),
      ).thenAnswer((_) => Stream.value([note]));
      return build();
    },
    act: (cubit) => cubit.watch(),
    expect: () => [
      const NotesLoading(),
      NotesLoaded([note]),
    ],
  );

  blocTest<NotesCubit, NotesState>(
    'watch emits [Loading, Error] when the stream errors',
    build: () {
      when(
        () => watchNotes.call(archived: any(named: 'archived')),
      ).thenAnswer((_) => Stream.error(const DatabaseFailure('boom')));
      return build();
    },
    act: (cubit) => cubit.watch(),
    expect: () => [const NotesLoading(), const NotesError('boom')],
  );

  blocTest<NotesCubit, NotesState>(
    'create delegates to the CreateNote use case',
    build: () {
      when(
        () => createNote.call(const CreateNoteParams(title: 't', body: 'b')),
      ).thenAnswer((_) async => note);
      return build();
    },
    act: (cubit) => cubit.create(title: 't', body: 'b'),
    verify: (_) {
      verify(
        () => createNote.call(const CreateNoteParams(title: 't', body: 'b')),
      ).called(1);
    },
  );
}
