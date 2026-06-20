import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/vault_lock_service.dart';
import '../../../../injection/injection.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../pages/login_page.dart';
import '../../../onboarding/presentation/pages/splash_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../onboarding/presentation/pages/vault_setup_page.dart';
import '../../../vault_lock/presentation/pages/lock_screen_page.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';

/// Root routing widget. Decides which screen to show based on:
///   1. Auth state (Firebase)
///   2. Onboarding completion (SharedPreferences)
///   3. Vault lock state (biometric/PIN)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.resolved) {
          // Still checking Firebase auth — show splash while resolving.
          return SplashPage(onDone: () {});
        }
        if (!state.isAuthenticated) {
          return const LoginPage();
        }
        // Authenticated → enter the vault flow.
        return const _VaultRouter();
      },
    );
  }
}

/// Handles post-auth routing: onboarding → lock → shell.
class _VaultRouter extends StatefulWidget {
  const _VaultRouter();

  @override
  State<_VaultRouter> createState() => _VaultRouterState();
}

class _VaultRouterState extends State<_VaultRouter> {
  final _lockService = getIt<VaultLockService>();

  _Phase _phase = _Phase.splash;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  void _resolve() {
    if (!_lockService.isOnboardingComplete) {
      setState(() => _phase = _Phase.onboarding);
    } else if (_lockService.isLockEnabled) {
      setState(() => _phase = _Phase.locked);
    } else {
      setState(() => _phase = _Phase.shell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.splash => SplashPage(onDone: _resolve),
      _Phase.onboarding => OnboardingPage(
          onDone: () => setState(() => _phase = _Phase.vaultSetup),
        ),
      _Phase.vaultSetup => VaultSetupPage(
          onDone: () => setState(() => _phase = _Phase.shell),
        ),
      _Phase.locked => LockScreenPage(
          onUnlocked: () => setState(() => _phase = _Phase.shell),
        ),
      _Phase.shell => const MainShellPage(),
    };
  }
}

enum _Phase { splash, onboarding, vaultSetup, locked, shell }
