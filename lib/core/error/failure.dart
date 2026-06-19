import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the domain/presentation
/// layers. Data-layer exceptions are caught at the repository boundary and
/// rethrown as a [Failure] so use cases/cubits never see raw Drift/Firebase
/// types. Cubits catch [Failure] and map it to an error state.
abstract class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}
