import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the domain/presentation
/// layers. Data-layer exceptions are caught at the repository boundary and
/// mapped to a [Failure] so use cases never see raw Drift/Firebase types.
abstract class Failure extends Equatable {
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
