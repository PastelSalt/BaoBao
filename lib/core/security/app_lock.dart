import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Asks the device to confirm who is holding it (fingerprint, face, or PIN).
abstract interface class DeviceAuthenticator {
  /// Whether this device has any screen lock that can be used.
  Future<bool> isAvailable();

  /// Shows the system prompt with [reason]. Returns true on success.
  Future<bool> authenticate(String reason);
}

class LocalAuthAuthenticator implements DeviceAuthenticator {
  LocalAuthAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      // Cancelled, locked out, or no credentials enrolled: all mean "not unlocked".
      return false;
    }
  }
}

/// An authenticator for devices or tests with no lock support.
class NoDeviceAuthenticator implements DeviceAuthenticator {
  const NoDeviceAuthenticator();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>(
  (ref) => const NoDeviceAuthenticator(),
);

/// Whether the app is currently locked behind the device's screen lock.
final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);

class AppLockController extends Notifier<bool> {
  /// Leaving the app for less than this does not re-lock it.
  static const gracePeriod = Duration(seconds: 60);

  DateTime? _backgroundedAt;

  /// Starts unlocked. Startup calls [lock] when the app lock is switched on.
  @override
  bool build() => false;

  void lock() => state = true;

  Future<bool> unlock(String reason) async {
    final ok = await ref.read(deviceAuthenticatorProvider).authenticate(reason);
    if (ok) state = false;
    return ok;
  }

  void onBackgrounded(DateTime now) => _backgroundedAt ??= now;

  /// Re-locks if [enabled] and the app was away for longer than [gracePeriod].
  void onForegrounded(DateTime now, {required bool enabled}) {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (enabled && since != null && now.difference(since) >= gracePeriod) lock();
  }
}
