import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/services/local_user_service.dart';
import '../core/services/vault_lock_service.dart';
import '../core/utils/clock.dart';
import '../features/notes/data/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';
import '../features/notes/domain/usecases/archive_note.dart';
import '../features/notes/domain/usecases/create_note.dart';
import '../features/notes/domain/usecases/delete_note.dart';
import '../features/notes/domain/usecases/update_note.dart';
import '../features/notes/domain/usecases/watch_notes.dart';
import '../features/notes/presentation/cubit/notes_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({required SharedPreferences prefs}) async {
  // Core infrastructure
  getIt
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<LocalAuthentication>(() => LocalAuthentication())
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<Clock>(() => const SystemClock())
    ..registerLazySingleton<Uuid>(() => const Uuid());

  // Identity — stable device UUID generated on first launch, no account needed.
  // Google Drive sync (future) will link this ID to the user's Google account
  // without migrating any stored rows.
  getIt.registerLazySingleton<LocalUserService>(
    () => LocalUserService(prefs: getIt(), uuid: getIt()),
  );

  // Vault lock
  getIt.registerLazySingleton<VaultLockService>(
    () => VaultLockService(
      prefs: getIt(),
      secureStorage: getIt(),
      localAuth: getIt(),
    ),
  );

  // Notes data
  getIt
    ..registerLazySingleton(() => getIt<AppDatabase>().notesDao)
    ..registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(
        dao: getIt(),
        userId: getIt<LocalUserService>().userId,
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
