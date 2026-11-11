import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/content/content_validator.dart';
import 'package:baobao/features/economy/domain/catalog.dart';

/// The result of checking shipped content against the files on disk.
class ContentAudit {
  const ContentAudit({required this.errors, required this.releaseBlockers});

  /// Problems that break the app. CI fails on any of these.
  final List<String> errors;

  /// Things that are fine in development but must be resolved before release:
  /// unverified helplines and media without a confirmed licence.
  final List<String> releaseBlockers;
}

/// Cross-checks [content] against the asset files that actually exist.
///
/// [assetPaths] is every file under `assets/`, as paths relative to the
/// repository root with forward slashes.
ContentAudit auditContent(AppContent content, Set<String> assetPaths) {
  final errors = <String>[];
  final blockers = <String>[];

  for (final tree in content.trees.values) {
    errors.addAll(ContentValidator.validateTree(tree));
  }

  // Voice clips: every reference must resolve, and every clip must be used.
  final referenced = <String>{};
  void checkVoice(String? clip, String where) {
    if (clip == null) return;
    referenced.add(clip);
    if (!assetPaths.contains(content.voiceAsset(clip))) {
      errors.add('$where refers to missing voice clip "$clip"');
    }
  }

  for (final tree in content.trees.values) {
    for (final node in tree.nodes.values) {
      checkVoice(node.voice, 'Node "${node.id}"');
    }
  }
  for (final line in content.scripts.allLines) {
    checkVoice(
      line.voice,
      'Script line "${line.text.substring(0, line.text.length.clamp(0, 24))}…"',
    );
  }
  final voicePrefix = 'assets/audio/voice/${content.languageCode}/';
  for (final path in assetPaths.where((p) => p.startsWith(voicePrefix))) {
    final clip = path.substring(voicePrefix.length).replaceAll(RegExp(r'\.m4a$'), '');
    if (!referenced.contains(clip)) errors.add('Voice clip "$clip" is not used by any content');
  }

  // Catalogue.
  errors.addAll(content.catalog.validate());
  for (final item in content.catalog.items) {
    final exists = item.slot == ItemSlot.outfit
        ? assetPaths.any((path) => path.startsWith('${item.asset}/'))
        : assetPaths.contains(item.asset);
    if (!exists) errors.add('Catalogue item "${item.id}" refers to missing asset "${item.asset}"');
    if (item.licence == 'unverified') {
      blockers.add('Catalogue item "${item.id}" has no confirmed licence');
    }
  }

  // Helplines.
  final lineIds = <String>{};
  for (final line in content.helplines.allLines) {
    if (!lineIds.add(line.id)) errors.add('Helpline id "${line.id}" is used more than once');
    if (line.actions.isEmpty) errors.add('Helpline "${line.id}" has no way to reach it');
    if (line.verifiedOn == null) {
      blockers.add('Helpline "${line.id}" has not been verified by a person');
    }
  }
  if (content.helplines.fallback.isEmpty) errors.add('Helplines: the fallback list is empty');

  // Tutorial.
  if (content.tutorial.isEmpty) errors.add('Tutorial has no steps');
  const poses = {'hello', 'happy', 'sad', 'tired'};
  for (final step in content.tutorial) {
    if (!poses.contains(step.emotion)) {
      errors.add('Tutorial step "${step.id}" uses unknown emotion "${step.emotion}"');
    }
  }

  return ContentAudit(errors: errors, releaseBlockers: blockers);
}
