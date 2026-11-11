import 'dart:io';
import 'dart:math';

import 'package:baobao/core/database/database_opener.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

class MemoryKeyStore implements KeyStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String name) async => values[name];

  @override
  Future<void> write(String name, String value) async => values[name] = value;
}

void main() {
  late Directory dir;
  late File file;
  final now = DateTime.utc(2026, 11, 11);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('baobao_db_test');
    file = File('${dir.path}/baobao.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  group('key', () {
    test('is created once, as 256 bits of hex, and then reused', () async {
      final store = MemoryKeyStore();
      final key = await DatabaseOpener.loadOrCreateKey(store, random: Random(1));
      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(await DatabaseOpener.loadOrCreateKey(store, random: Random(2)), key);
    });
  });

  group('open', () {
    Future<void> createProfile(String key, String name) async {
      final db = await DatabaseOpener.open(file, key);
      await ProfileRepository(db, shippedCatalog()).create(name, now);
      await db.close();
    }

    test('the file on disk is encrypted', () async {
      await createProfile('a' * 64, 'Recognisable Name');

      final bytes = file.readAsBytesSync();
      final text = String.fromCharCodes(bytes);
      expect(text, isNot(startsWith('SQLite format 3')));
      expect(text, isNot(contains('Recognisable Name')));
    });

    test('data survives closing and reopening with the same key', () async {
      await createProfile('a' * 64, 'Mei');

      final db = await DatabaseOpener.open(file, 'a' * 64);
      addTearDown(db.close);
      final all = await ProfileRepository(db, shippedCatalog()).all();
      expect(all.single.displayName, 'Mei');
    });

    test('a file that cannot be read with the key is set aside, not deleted', () async {
      await createProfile('a' * 64, 'Mei');

      final db = await DatabaseOpener.open(file, 'b' * 64);
      addTearDown(db.close);
      expect(await ProfileRepository(db, shippedCatalog()).all(), isEmpty);

      final kept = dir.listSync().where((f) => f.path.contains('.unreadable-'));
      expect(kept, hasLength(1));
    });
  });
}
