import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/services/vault_lock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  final _lockService = getIt<VaultLockService>();
  bool _showPin = false;
  final _pin = <int>[];
  bool _pinError = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    if (_lockService.isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBiometric());
    }
  }

  Future<void> _triggerBiometric() async {
    final success = await _lockService.authenticateWithBiometric();
    if (success && mounted) widget.onUnlocked();
  }

  void _onDigit(int d) {
    if (_pin.length >= 6 || _checking) return;
    setState(() {
      _pin.add(d);
      _pinError = false;
    });
    if (_pin.length == 6) _verifyPin();
  }

  void _onBackspace() {
    if (_pin.isEmpty || _checking) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _verifyPin() async {
    setState(() => _checking = true);
    final ok = await _lockService.verifyPin(_pin.join());
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _pin.clear();
        _pinError = true;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: SafeArea(
        child: _showPin ? _PinView(
          pin: _pin,
          pinError: _pinError,
          checking: _checking,
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onBiometric: _lockService.isBiometricEnabled
              ? () => setState(() => _showPin = false)
              : null,
        ) : _BiometricView(
          onTrigger: _triggerBiometric,
          onUsePin: () => setState(() => _showPin = true),
        ),
      ),
    );
  }
}

class _BiometricView extends StatelessWidget {
  const _BiometricView({required this.onTrigger, required this.onUsePin});

  final VoidCallback onTrigger;
  final VoidCallback onUsePin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Shield squircle icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            LucideIcons.shieldCheck,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Archivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const Spacer(flex: 3),

        // Fingerprint circle
        GestureDetector(
          onTap: onTrigger,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            child: const Icon(
              LucideIcons.fingerprint,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Touch sensor to unlock',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        TextButton(
          onPressed: onUsePin,
          child: Text(
            'Use PIN instead',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Spacer(flex: 3),

        // Footer
        Text(
          'SECURED BY ARCHIVO NODE 256',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PinView extends StatelessWidget {
  const _PinView({
    required this.pin,
    required this.pinError,
    required this.checking,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
  });

  final List<int> pin;
  final bool pinError;
  final bool checking;
  final void Function(int) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),

        const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 32),
        const SizedBox(height: 12),
        const Text(
          'Enter your PIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? Colors.white
                    : Colors.transparent,
                border: Border.all(
                  color: pinError ? AppColors.gold : Colors.white,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        if (pinError) ...[
          const SizedBox(height: 10),
          const Text(
            'Incorrect PIN',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const Spacer(),

        // Numpad on lock screen (white digits)
        _LockNumpad(onDigit: onDigit, onBackspace: onBackspace),

        if (onBiometric != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onBiometric,
            icon: const Icon(LucideIcons.fingerprint, color: Colors.white70, size: 18),
            label: const Text(
              'Use biometrics',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LockNumpad extends StatelessWidget {
  const _LockNumpad({required this.onDigit, required this.onBackspace});

  final void Function(int) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];

    return Column(
      children: [
        ...rows.map(
          (row) => Row(
            children: row
                .map((d) => _LockKey(digit: d, onTap: onDigit))
                .toList(),
          ),
        ),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            _LockKey(digit: 0, onTap: onDigit),
            Expanded(
              child: GestureDetector(
                onTap: onBackspace,
                child: const SizedBox(
                  height: 64,
                  child: Icon(
                    LucideIcons.delete,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LockKey extends StatelessWidget {
  const _LockKey({required this.digit, required this.onTap});

  final int digit;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(digit),
        child: SizedBox(
          height: 64,
          child: Center(
            child: Text(
              '$digit',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
