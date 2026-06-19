import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Owns authentication state. The signed-in user is driven by the repository's
/// [AuthRepository.authStateChanges] stream (the single source of truth);
/// sign-in/register/google operations only toggle submitting/error.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial()) {
    _sub = _repository.authStateChanges().listen(_onUserChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _sub;

  void _onUserChanged(AppUser? user) {
    emit(
      state.copyWith(
        user: user,
        clearUser: user == null,
        resolved: true,
        clearError: true,
      ),
    );
  }

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _repository.signInWithEmail(email: email, password: password));

  Future<void> register(String email, String password) => _run(
    () => _repository.registerWithEmail(email: email, password: password),
  );

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signOut() => _repository.signOut();

  /// Runs an auth operation, surfacing submitting/error. Success is reflected by
  /// the auth-state stream, not here.
  Future<void> _run(Future<void> Function() action) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await action();
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: e is Failure ? e.message : 'Something went wrong.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
