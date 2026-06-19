import 'package:equatable/equatable.dart';

/// The signed-in user. Pure domain object — no Firebase types leak past the
/// AuthRepository boundary. `uid` is the owner id stamped on every note.
class AppUser extends Equatable {
  const AppUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}
