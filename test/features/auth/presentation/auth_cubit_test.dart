import 'dart:async';

import 'package:archivo/core/error/failure.dart';
import 'package:archivo/features/auth/domain/entities/app_user.dart';
import 'package:archivo/features/auth/domain/repositories/auth_repository.dart';
import 'package:archivo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:archivo/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;
  late StreamController<AppUser?> authStream;

  const user = AppUser(uid: 'u1', email: 'a@b.com');

  setUp(() {
    repo = _MockAuthRepository();
    authStream = StreamController<AppUser?>();
    when(() => repo.authStateChanges()).thenAnswer((_) => authStream.stream);
  });

  tearDown(() => authStream.close());

  blocTest<AuthCubit, AuthState>(
    'becomes resolved + authenticated when the auth stream emits a user',
    build: () => AuthCubit(repo),
    act: (_) => authStream.add(user),
    expect: () => [const AuthState(user: user, resolved: true)],
  );

  blocTest<AuthCubit, AuthState>(
    'signInWithEmail toggles submitting and delegates to the repository',
    build: () {
      when(
        () => repo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);
      return AuthCubit(repo);
    },
    act: (cubit) => cubit.signInWithEmail('a@b.com', 'secret'),
    expect: () => const [
      AuthState(isSubmitting: true),
      AuthState(isSubmitting: false),
    ],
    verify: (_) {
      verify(
        () => repo.signInWithEmail(email: 'a@b.com', password: 'secret'),
      ).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'surfaces an error message when sign-in fails',
    build: () {
      when(
        () => repo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure('Incorrect email or password.'));
      return AuthCubit(repo);
    },
    act: (cubit) => cubit.signInWithEmail('a@b.com', 'wrong'),
    expect: () => const [
      AuthState(isSubmitting: true),
      AuthState(isSubmitting: false, error: 'Incorrect email or password.'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signing out delegates to the repository',
    build: () {
      when(() => repo.signOut()).thenAnswer((_) async {});
      return AuthCubit(repo);
    },
    act: (cubit) => cubit.signOut(),
    verify: (_) => verify(() => repo.signOut()).called(1),
  );
}
