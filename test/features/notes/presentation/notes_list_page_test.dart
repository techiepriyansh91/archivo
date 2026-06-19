import 'package:archivo/core/database/app_database.dart';
import 'package:archivo/features/auth/domain/entities/app_user.dart';
import 'package:archivo/features/notes/data/notes_repository_impl.dart';
import 'package:archivo/features/notes/domain/usecases/archive_note.dart';
import 'package:archivo/features/notes/domain/usecases/create_note.dart';
import 'package:archivo/features/notes/domain/usecases/delete_note.dart';
import 'package:archivo/features/notes/domain/usecases/update_note.dart';
import 'package:archivo/features/notes/domain/usecases/watch_notes.dart';
import 'package:archivo/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:archivo/features/notes/presentation/pages/notes_list_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/test_doubles.dart';

void main() {
  late AppDatabase db;
  late NotesRepositoryImpl repo;
  late NotesCubit cubit;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NotesRepositoryImpl(
      dao: db.notesDao,
      auth: FakeAuthRepository(user: const AppUser(uid: 'u1')),
      uuid: const Uuid(),
      clock: FixedClock(1000),
    );
    cubit = NotesCubit(
      watchNotes: WatchNotes(repo),
      createNote: CreateNote(repo),
      updateNote: UpdateNote(repo),
      deleteNote: DeleteNote(repo),
      archiveNote: ArchiveNote(repo),
    );
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  Widget harness() => MaterialApp(
    home: BlocProvider.value(value: cubit, child: const NotesListPage()),
  );

  testWidgets('shows empty state, then renders a newly created note', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.textContaining('No notes yet'), findsOneWidget);

    await repo.createNote(title: 'My note', body: 'hello');
    await tester.pumpAndSettle();

    expect(find.text('My note'), findsOneWidget);
    expect(find.textContaining('No notes yet'), findsNothing);
  });

  testWidgets('archiving a note removes it from the active list', (
    tester,
  ) async {
    await repo.createNote(title: 'Archive me', body: '');
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(find.text('Archive me'), findsOneWidget);

    await tester.tap(find.byTooltip('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archive me'), findsNothing);
    expect(find.textContaining('No notes yet'), findsOneWidget);
  });
}
