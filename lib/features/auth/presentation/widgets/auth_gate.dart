import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../notes/presentation/pages/notes_list_page.dart';
import '../../../../injection/injection.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../pages/login_page.dart';

/// Routes between the login screen and the app based on auth state. The notes
/// stack is only built once authenticated, so the NotesRepository always has a
/// signed-in uid to scope writes to.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.resolved) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!state.isAuthenticated) {
          return const LoginPage();
        }
        return BlocProvider<NotesCubit>(
          create: (_) => getIt<NotesCubit>(),
          child: const NotesListPage(),
        );
      },
    );
  }
}
