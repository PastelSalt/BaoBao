import 'dart:io';
import 'dart:math';

import 'package:baobao/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

/// Where the database encryption key is kept. Backed by the platform keystore
/// in the app and by a map in tests.
abstract interface class KeyStore {
  Future<String?> read(String name);
  Future<void> write(String name, String value);
}

/// Opens the app database, encrypted at rest.
abstract final class DatabaseOpener {
  static const keyName = 'baobao.db.key.v1';

  /// Returns the stored database key, creating one on first run.
  static Future<String> loadOrCreateKey(KeyStore store, {Random? random}) async {
    final existing = await store.read(keyName);
    if (existing != null && existing.isNotEmpty) return existing;
    final rng = random ?? Random.secure();
    final key = [for (var i = 0; i < 32; i++) rng.nextInt(256).toRadixString(16).padLeft(2, '0')]
        .join();
    await store.write(keyName, key);
    return key;
  }

  /// Opens [file] with [key].
  ///
  /// If the file cannot be read with this key (for example it was restored
  /// from a backup onto a device that does not have the key), it is moved
  /// aside and a fresh database is created, because a companion app that
  /// will not start helps nobody. The unreadable file is kept next to it.
  static Future<AppDatabase> open(File file, String key) async {
    if (file.existsSync() && !_canRead(file, key)) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      file.renameSync('${file.path}.unreadable-$stamp');
    }
    return AppDatabase(NativeDatabase.createInBackground(file, setup: (raw) => _unlock(raw, key)));
  }

  static void _unlock(Database raw, String key) {
    // The bundled library must be SQLite3 Multiple Ciphers (see `hooks` in
    // pubspec.yaml). Plain SQLite silently ignores PRAGMA key, which would
    // leave mood data unencrypted, so refuse to continue without a cipher.
    if (raw.select('PRAGMA cipher').isEmpty) {
      throw StateError('The bundled SQLite has no encryption support.');
    }
    // The key is hex we generated ourselves, so it is safe to inline.
    raw.execute("PRAGMA key = '$key'");
  }

  static bool _canRead(File file, String key) {
    Database? raw;
    try {
      raw = sqlite3.open(file.path);
      _unlock(raw, key);
      raw.select('SELECT count(*) FROM sqlite_master');
      return true;
    } on SqliteException {
      return false;
    } finally {
      raw?.close();
    }
  }
}
