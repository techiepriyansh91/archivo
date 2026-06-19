import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.resolved = false,
    this.isSubmitting = false,
    this.error,
  });

  const AuthState.initial() : this();

  /// Signed-in user, or null when signed out.
  final AppUser? user;

  /// True once the first auth-state event has arrived (avoids flashing the login
  /// screen before Firebase reports the persisted session).
  final bool resolved;

  /// An auth operation (sign in / register / google) is in flight.
  final bool isSubmitting;

  /// Last operation error, shown on the login form.
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? resolved,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      resolved: resolved ?? this.resolved,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [user, resolved, isSubmitting, error];
}
