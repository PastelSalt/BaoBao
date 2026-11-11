import 'package:baobao/core/database/database_opener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the database key in the Android Keystore or iOS Keychain.
class SecureKeyStore implements KeyStore {
  const SecureKeyStore();

  // The key must never leave this device: a database restored elsewhere
  // without it is unreadable by design.
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  @override
  Future<String?> read(String name) => _storage.read(key: name);

  @override
  Future<void> write(String name, String value) => _storage.write(key: name, value: value);
}
