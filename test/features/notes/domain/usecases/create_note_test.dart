import 'package:archivo/features/notes/domain/entities/note.dart';
import 'package:archivo/features/notes/domain/repositories/notes_repository.dart';
import 'package:archivo/features/notes/domain/usecases/create_note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late _MockNotesRepository repo;
  late CreateNote useCase;

  final note = Note(
    id: '1',
    title: 't',
    body: 'b',
    isFavorite: false,
    isArchived: false,
    updatedAt: DateTime(2026),
  );

  setUp(() {
    repo = _MockNotesRepository();
    useCase = CreateNote(repo);
  });

  test(
    'delegates to NotesRepository.createNote and returns its result',
    () async {
      when(
        () => repo.createNote(title: 't', body: 'b'),
      ).thenAnswer((_) async => note);

      final result = await useCase(
        const CreateNoteParams(title: 't', body: 'b'),
      );

      expect(result, note);
      verify(() => repo.createNote(title: 't', body: 'b')).called(1);
      verifyNoMoreInteractions(repo);
    },
  );
}
