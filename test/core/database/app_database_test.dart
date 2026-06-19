import 'package:archivo/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('inserts and reads back a note with sync defaults', () async {
    await db
        .into(db.notes)
        .insert(NotesCompanion.insert(id: 'n1', userId: 'u1', updatedAt: 1000));

    final notes = await db.select(db.notes).get();

    expect(notes, hasLength(1));
    final note = notes.single;
    expect(note.id, 'n1');
    expect(note.userId, 'u1');
    expect(note.title, '');
    expect(note.isFavorite, isFalse);
    expect(note.syncStatus, 0); // synced
    expect(note.deletedAt, isNull);
    expect(note.baseJson, isNull);
  });
}
