import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

/// TEMPORARY Slice 1 stand-in so the Notes vertical runs and is testable before
/// Firebase is configured. It hands out a single fixed local user.
///
/// Replaced by `FirebaseAuthRepository` once `flutterfire configure` is run
/// against archivo-dev/staging/prod (next Slice 1 commit). Because everything
/// depends on [AuthRepository], swapping the implementation in `injection.dart`
/// is the only change required.
class LocalStubAuthRepository implements AuthRepository {
  static const _localUser = AppUser(
    uid: 'local-user',
    email: 'local@archivo.app',
    displayName: 'Local User',
  );

  @override
  AppUser? get currentUser => _localUser;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_localUser);

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async => _localUser;

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) async => _localUser;

  @override
  Future<AppUser> signInWithGoogle() async => _localUser;

  @override
  Future<void> signOut() async {}
}
