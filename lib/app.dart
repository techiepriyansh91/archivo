import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'injection/injection.dart';

class ArchivoApp extends StatelessWidget {
  const ArchivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthCubit lives above MaterialApp so the gate (and sign-out from any
    // route) can read it.
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: MaterialApp(
        title: 'archivo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
