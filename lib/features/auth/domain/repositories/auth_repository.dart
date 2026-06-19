import '../entities/app_user.dart';

/// Identity boundary. The data and sync layers only ever read [currentUser];
/// the implementation (Firebase, added once `flutterfire configure` is run) is
/// hidden behind this interface so nothing else touches Firebase directly.
abstract interface class AuthRepository {
  /// Emits on sign-in / sign-out. Null means signed out.
  Stream<AppUser?> authStateChanges();

  /// The currently signed-in user, or null. Source of the owner `uid`.
  AppUser? get currentUser;

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();
}
