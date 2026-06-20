import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaultLockService {
  VaultLockService({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuth,
  })  : _prefs = prefs,
        _secureStorage = secureStorage,
        _localAuth = localAuth;

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  static const _keyOnboardingComplete = 'archivo_onboarding_complete';
  static const _keyBiometricEnabled = 'archivo_biometric_enabled';
  static const _keyPinEnabled = 'archivo_pin_enabled';
  static const _keyPin = 'archivo_vault_pin';

  // ---------- Onboarding ----------

  bool get isOnboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> markOnboardingComplete() =>
      _prefs.setBool(_keyOnboardingComplete, true);

  // ---------- Lock state ----------

  bool get isBiometricEnabled => _prefs.getBool(_keyBiometricEnabled) ?? false;
  bool get isPinEnabled => _prefs.getBool(_keyPinEnabled) ?? false;
  bool get isLockEnabled => isBiometricEnabled || isPinEnabled;

  // ---------- Biometric ----------

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock your Archivo vault',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometric() =>
      _prefs.setBool(_keyBiometricEnabled, true);

  Future<void> disableBiometric() =>
      _prefs.setBool(_keyBiometricEnabled, false);

  // ---------- PIN ----------

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _keyPin, value: pin);
    await _prefs.setBool(_keyPinEnabled, true);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(key: _keyPin);
    return stored == pin;
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _keyPin);
    await _prefs.setBool(_keyPinEnabled, false);
  }

  Future<void> disableAllLocks() async {
    await disableBiometric();
    await clearPin();
  }
}
