import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/services/vault_lock_service.dart';
import '../core/utils/clock.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
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

  // Vault lock
  getIt.registerLazySingleton<VaultLockService>(
    () => VaultLockService(
      prefs: getIt(),
      secureStorage: getIt(),
      localAuth: getIt(),
    ),
  );

  // Auth
  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(getIt<FirebaseAuth>()),
    );

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

  // Auth presentation — singleton drives the auth gate
  getIt.registerLazySingleton(() => AuthCubit(getIt()));
}
