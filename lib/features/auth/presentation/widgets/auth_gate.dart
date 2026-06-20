import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../core/services/vault_lock_service.dart';
import '../../../../injection/injection.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../onboarding/presentation/pages/vault_setup_page.dart';
import '../../../vault_lock/presentation/pages/lock_screen_page.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';

/// Removes the native splash on the first rendered frame, then routes
/// through: onboarding → vault-setup → (lock screen if enabled) → shell.
/// No network call, no account required.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
  }

  @override
  Widget build(BuildContext context) => const _VaultRouter();
}

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
