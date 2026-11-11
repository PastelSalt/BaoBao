import 'dart:convert';

import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/mood/domain/mood.dart';

/// Reads one text asset. Lets content load from a Flutter asset bundle in the
/// app and straight from disk in tools and tests.
typedef AssetReader = Future<String> Function(String path);

/// All authored content, loaded once at startup.
class AppContent {
  const AppContent({
    required this.languageCode,
    required this.trees,
    required this.scripts,
    required this.catalog,
    required this.helplines,
    required this.tutorial,
  });

  /// Languages that have a full set of content files and voice clips.
  static const supportedLanguages = ['en'];

  /// Ids of every conversation tree that must exist.
  static final treeIds = [
    for (final mood in Mood.values) mood.name,
    ConversationTree.interventionId,
  ];

  static const root = 'assets/content';

  final String languageCode;
  final Map<String, ConversationTree> trees;
  final ScriptLibrary scripts;
  final Catalog catalog;
  final HelplineDirectory helplines;
  final List<TutorialStep> tutorial;

  /// The asset path of a voice clip in this content's language.
  String voiceAsset(String clipId) => voiceAssetFor(languageCode, clipId);

  static String voiceAssetFor(String languageCode, String clipId) =>
      'assets/audio/voice/$languageCode/$clipId.m4a';

  static Future<AppContent> load(AssetReader read, {String languageCode = 'en'}) async {
    final language = supportedLanguages.contains(languageCode) ? languageCode : 'en';
    Future<Map<String, dynamic>> json(String path) async =>
        jsonDecode(await read('$root/$path')) as Map<String, dynamic>;

    final trees = <String, ConversationTree>{};
    for (final id in treeIds) {
      final tree = ConversationTree.fromJson(await json('conversations/$language/$id.json'));
      if (tree.id != id) throw FormatException('Tree file "$id.json" declares id "${tree.id}"');
      trees[id] = tree;
    }
    final tutorial = await json('tutorial/$language.json');

    return AppContent(
      languageCode: language,
      trees: trees,
      scripts: ScriptLibrary.fromJson(await json('scripts/$language.json')),
      catalog: Catalog.fromJson(await json('catalog.json')),
      helplines: HelplineDirectory.fromJson(await json('helplines.json')),
      tutorial: [
        for (final step in tutorial['steps'] as List<dynamic>)
          TutorialStep.fromJson(step as Map<String, dynamic>),
      ],
    );
  }
}
