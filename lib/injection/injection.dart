import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/utils/clock.dart';
import '../features/auth/data/local_stub_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/notes/data/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';
import '../features/notes/domain/usecases/archive_note.dart';
import '../features/notes/domain/usecases/create_note.dart';
import '../features/notes/domain/usecases/delete_note.dart';
import '../features/notes/domain/usecases/update_note.dart';
import '../features/notes/domain/usecases/watch_notes.dart';
import '../features/notes/presentation/cubit/notes_cubit.dart';

/// Service locator. Slice 1 registers dependencies manually; migrate to
/// `injectable` codegen once the graph grows (see docs/PLAN.md §1).
final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<Clock>(() => const SystemClock())
    ..registerLazySingleton<Uuid>(() => const Uuid());

  // Auth — local stub for now; swapped for FirebaseAuthRepository once
  // `flutterfire configure` is run. This is the only line that changes.
  getIt.registerLazySingleton<AuthRepository>(LocalStubAuthRepository.new);

  // Notes data
  getIt
    ..registerLazySingleton(() => getIt<AppDatabase>().notesDao)
    ..registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(
        dao: getIt(),
        auth: getIt(),
        uuid: getIt(),
        clock: getIt(),
      ),
    );

  // Notes use cases
  getIt
    ..registerFactory(() => WatchNotes(getIt()))
    ..registerFactory(() => CreateNote(getIt()))
    ..registerFactory(() => UpdateNote(getIt()))
    ..registerFactory(() => DeleteNote(getIt()))
    ..registerFactory(() => ArchiveNote(getIt()));

  // Notes presentation
  getIt.registerFactory(
    () => NotesCubit(
      watchNotes: getIt(),
      createNote: getIt(),
      updateNote: getIt(),
      deleteNote: getIt(),
      archiveNote: getIt(),
    ),
  );
}
