import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'injection/injection.dart';

class ArchivoApp extends StatelessWidget {
  const ArchivoApp({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    // AuthCubit lives above MaterialApp so the gate (and sign-out from any
    // route) can read it.
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: MaterialApp(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3730A3),
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3730A3),
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      ),
    );
  }
}
