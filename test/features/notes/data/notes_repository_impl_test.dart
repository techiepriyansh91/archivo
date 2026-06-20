import 'package:archivo/core/database/app_database.dart';
import 'package:archivo/core/sync/sync_status.dart';
import 'package:archivo/features/notes/data/notes_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/test_doubles.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late NotesRepositoryImpl repo;

  NotesRepositoryImpl buildRepo() => NotesRepositoryImpl(
    dao: db.notesDao,
    userId: 'u1',
    uuid: const Uuid(),
    clock: clock,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(1000);
    repo = buildRepo();
  });

  tearDown(() => db.close());

  test('createNote persists it, stamps owner uid + pending status', () async {
    final note = await repo.createNote(title: 'Hello', body: 'World');

    expect(note.title, 'Hello');
    final row = await db.notesDao.findById(note.id);
    expect(row, isNotNull);
    expect(row!.userId, 'u1');
    expect(row.syncStatus, SyncStatus.pending.index);
    expect(row.updatedAt, 1000);
  });

  test("watchNotes emits the user's active notes, newest first", () async {
    clock.ms = 1000;
    final a = await repo.createNote(title: 'A', body: '');
    clock.ms = 2000;
    final b = await repo.createNote(title: 'B', body: '');

    final notes = await repo.watchNotes().first;

    expect(notes.map((n) => n.id), [b.id, a.id]);
  });

  test("watchNotes excludes other users' notes", () async {
    await repo.createNote(title: 'mine', body: '');
    await db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(id: 'x', userId: 'someone-else', updatedAt: 1),
        );

    final notes = await repo.watchNotes().first;

    expect(notes, hasLength(1));
    expect(notes.single.title, 'mine');
  });

  test('deleteNote tombstones and drops it from the active stream', () async {
    final n = await repo.createNote(title: 'bye', body: '');

    await repo.deleteNote(n.id);

    expect(await repo.watchNotes().first, isEmpty);
    final row = await db.notesDao.findById(n.id);
    expect(row!.deletedAt, isNotNull);
  });

  test('setArchived moves a note between active and archive lists', () async {
    final n = await repo.createNote(title: 'archive me', body: '');

    await repo.setArchived(id: n.id, archived: true);

    expect(await repo.watchNotes(archived: false).first, isEmpty);
    final archived = await repo.watchNotes(archived: true).first;
    expect(archived.single.id, n.id);
  });

  test('updateNote changes fields and bumps updatedAt', () async {
    clock.ms = 1000;
    final n = await repo.createNote(title: 'old', body: 'b');
    clock.ms = 5000;

    await repo.updateNote(n.copyWith(title: 'new'));

    final notes = await repo.watchNotes().first;
    expect(notes.single.title, 'new');
    expect(notes.single.updatedAt.millisecondsSinceEpoch, 5000);
  });
}
