// Validates everything under assets/content against the files on disk.
//
//   dart run tool/validate_content.dart            fails on structural errors
//   dart run tool/validate_content.dart --release  also fails on release blockers
//
// Run from the repository root.
import 'dart:io';

import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/content/content_audit.dart';

Future<void> main(List<String> args) async {
  final release = args.contains('--release');
  final assets = {
    for (final entity in Directory('assets').listSync(recursive: true))
      if (entity is File) entity.path.replaceAll(r'\', '/'),
  };

  var failed = false;
  for (final language in AppContent.supportedLanguages) {
    final content = await AppContent.load(
      (path) => File(path).readAsString(),
      languageCode: language,
    );
    final audit = auditContent(content, assets);
    final nodes = content.trees.values.fold(0, (sum, tree) => sum + tree.nodes.length);
    stdout.writeln('[$language] ${content.trees.length} trees, $nodes nodes checked');
    for (final error in audit.errors) {
      stdout.writeln('  ERROR   $error');
    }
    for (final blocker in audit.releaseBlockers) {
      stdout.writeln('  ${release ? 'ERROR  ' : 'BLOCKER'} $blocker');
    }
    failed |= audit.errors.isNotEmpty || (release && audit.releaseBlockers.isNotEmpty);
  }

  if (failed) {
    stdout.writeln('Content validation failed.');
    exit(1);
  }
  stdout.writeln('Content validation passed.');
}
