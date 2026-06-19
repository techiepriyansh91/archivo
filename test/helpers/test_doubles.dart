import 'package:archivo/core/utils/clock.dart';
import 'package:archivo/features/auth/domain/entities/app_user.dart';
import 'package:archivo/features/auth/domain/repositories/auth_repository.dart';

/// Deterministic clock so tests can assert exact `updatedAt` values.
class FixedClock implements Clock {
  FixedClock(this.ms);

  int ms;

  @override
  int nowMs() => ms;
}

/// In-memory auth double with a configurable signed-in user.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? user}) : _user = user;

  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_user);

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async => _user ??= AppUser(uid: 'test-uid', email: email);

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) async => _user ??= AppUser(uid: 'test-uid', email: email);

  @override
  Future<AppUser> signInWithGoogle() async =>
      _user ??= const AppUser(uid: 'test-uid');

  @override
  Future<void> signOut() async => _user = null;
}
