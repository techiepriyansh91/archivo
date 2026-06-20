import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../../../core/services/vault_lock_service.dart';

class VaultSetupPage extends StatefulWidget {
  const VaultSetupPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<VaultSetupPage> createState() => _VaultSetupPageState();
}

class _VaultSetupPageState extends State<VaultSetupPage> {
  final _lockService = getIt<VaultLockService>();
  final _pin = <int>[];
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _confirmingPin = false;
  List<int> _firstPin = [];
  bool _pinMismatch = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _lockService.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  void _onDigit(int d) {
    if (_pin.length >= 6 || _saving) return;
    setState(() {
      _pin.add(d);
      _pinMismatch = false;
    });
    if (_pin.length == 6) _onPinComplete();
  }

  void _onBackspace() {
    if (_pin.isEmpty || _saving) return;
    setState(() => _pin.removeLast());
  }

  void _onPinComplete() {
    if (!_confirmingPin) {
      setState(() {
        _firstPin = List.from(_pin);
        _pin.clear();
        _confirmingPin = true;
      });
    } else {
      if (_pin.join() == _firstPin.join()) {
        _saveAndContinue();
      } else {
        setState(() {
          _pin.clear();
          _pinMismatch = true;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);
    await _lockService.setPin(_firstPin.join());
    if (_biometricEnabled && _biometricAvailable) {
      await _lockService.enableBiometric();
    }
    await _lockService.markOnboardingComplete();
    if (mounted) widget.onDone();
  }

  Future<void> _skip() async {
    await _lockService.markOnboardingComplete();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    LucideIcons.shieldCheck,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Archivo',
                    style: tt.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('What is this?'),
                        content: const Text(
                          'Your PIN is the only key to your vault. We never store it on our servers — it only lives on this device.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(
                      LucideIcons.helpCircle,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Protect your vault',
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _confirmingPin
                    ? 'Confirm your PIN'
                    : 'Your data is secured with AES-256 local-only encryption. Your PIN is the only key; we never store it on our servers.',
                style: tt.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: _pinMismatch
                            ? AppColors.error
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              if (_pinMismatch) ...[
                const SizedBox(height: 8),
                Text(
                  'PINs do not match. Try again.',
                  style: tt.labelLarge?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 32),

              // Numpad
              _Numpad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 24),

              // Biometric toggle (only if available)
              if (_biometricAvailable)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.fingerprint,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: const Text('Biometric Unlock'),
                    subtitle: const Text('Enable fingerprint/face unlock'),
                    trailing: Switch(
                      value: _biometricEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) =>
                          setState(() => _biometricEnabled = v),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Continue button (only shown when 6 digits entered + confirm phase done)
              FilledButton(
                onPressed: _saving ? null : (_pin.length == 6 ? _onPinComplete : null),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: AppColors.primary.withValues(
                    alpha: _pin.length == 6 ? 1.0 : 0.4,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(LucideIcons.arrowRight, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // Skip
              TextButton(
                onPressed: _saving ? null : _skip,
                child: Text(
                  'Skip for now',
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onDigit, required this.onBackspace});

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
            children: row.map((d) => _Key(digit: d, onTap: onDigit)).toList(),
          ),
        ),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            _Key(digit: 0, onTap: onDigit),
            Expanded(
              child: GestureDetector(
                onTap: onBackspace,
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.delete,
                    color: AppColors.onSurface,
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

class _Key extends StatelessWidget {
  const _Key({required this.digit, required this.onTap});

  final int digit;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(digit),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Text(
            '$digit',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
