import 'dart:convert';
import 'dart:io';

import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

/// A fresh in-memory database for one test.
AppDatabase memoryDatabase() {
  // Every test gets its own in-memory executor, so drift's warning about
  // several instances sharing one does not apply.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// The real shipped catalogue.
Catalog shippedCatalog() => Catalog.fromJson(
  jsonDecode(File('assets/content/catalog.json').readAsStringSync()) as Map<String, dynamic>,
);
