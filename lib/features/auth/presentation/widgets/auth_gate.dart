import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../core/services/vault_lock_service.dart';
import '../../../../injection/injection.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../pages/login_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../onboarding/presentation/pages/vault_setup_page.dart';
import '../../../vault_lock/presentation/pages/lock_screen_page.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';

/// Root routing widget. Keeps the native splash alive until Firebase resolves,
/// then transitions to: Login → Onboarding → VaultSetup → Shell (or Lock).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      // Remove native splash exactly once — when auth state first resolves.
      listenWhen: (prev, curr) => !prev.resolved && curr.resolved,
      listener: (context, state) => FlutterNativeSplash.remove(),
      builder: (context, state) {
        // Still waiting for Firebase — keep native splash, show nothing behind it.
        if (!state.resolved) return const SizedBox.shrink();

        if (!state.isAuthenticated) return const LoginPage();

        return const _VaultRouter();
      },
    );
  }
}

/// Post-auth routing: onboarding → lock check → shell.
class _VaultRouter extends StatefulWidget {
  const _VaultRouter();

  @override
  State<_VaultRouter> createState() => _VaultRouterState();
}

class _VaultRouterState extends State<_VaultRouter> {
  final _lockService = getIt<VaultLockService>();
  late _Phase _phase;

  @override
  void initState() {
    super.initState();
    _phase = _computePhase();
  }

  _Phase _computePhase() {
    if (!_lockService.isOnboardingComplete) return _Phase.onboarding;
    if (_lockService.isLockEnabled) return _Phase.locked;
    return _Phase.shell;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
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

enum _Phase { onboarding, vaultSetup, locked, shell }
