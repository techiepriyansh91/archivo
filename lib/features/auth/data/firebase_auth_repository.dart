import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/error/failure.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, {GoogleSignIn? googleSignIn})
    : _google = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _google;
  bool _googleReady = false;

  AppUser? _toUser(fb.User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        );

  @override
  AppUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_toUser);

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runFirebase(() async {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toUser(cred.user)!;
    });
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _runFirebase(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toUser(cred.user)!;
    });
  }

  @override
  Future<AppUser> signInWithGoogle() {
    return _runFirebase(() async {
      // google_sign_in 7.x: initialize once, then authenticate().
      if (!_googleReady) {
        await _google.initialize();
        _googleReady = true;
      }
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure('Google sign-in returned no token.');
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _auth.signInWithCredential(credential);
      return _toUser(cred.user)!;
    });
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } on GoogleSignInException {
      // Not signed in via Google; nothing to do.
    }
  }

  /// Maps Firebase/Google exceptions to a domain [AuthFailure].
  Future<T> _runFirebase<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    } on GoogleSignInException catch (e) {
      throw AuthFailure('Google sign-in failed (${e.code.name}).');
    }
  }

  String _messageFor(fb.FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'That email address is invalid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Password is too weak (min 6 characters).',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => e.message ?? 'Authentication failed.',
    };
  }
}
