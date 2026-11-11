/// A feature BaoBao can suggest alongside a line of dialogue.
enum FeatureNudge {
  joke,
  affirmation,
  selfCare,
  clawMachine,
  shop;

  static FeatureNudge? tryParse(String? name) {
    for (final nudge in values) {
      if (nudge.name == name) return nudge;
    }
    return null;
  }
}

/// One thing the user can say in reply to a [ConversationNode].
class ConversationOption {
  const ConversationOption({required this.text, required this.next, this.moodEffect = 0});

  factory ConversationOption.fromJson(Map<String, dynamic> json) {
    return ConversationOption(
      text: json['text'] as String,
      next: json['next'] as String,
      moodEffect: (json['moodEffect'] as int?) ?? 0,
    );
  }

  /// Reserved [next] value: the conversation is over.
  static const endTarget = '@end';

  /// Reserved [next] value: open the support resources screen.
  static const resourcesTarget = '@resources';

  static const reservedTargets = {endTarget, resourcesTarget};

  final String text;

  /// A node id in the same tree, or one of [reservedTargets].
  final String next;

  /// Positive values lift the mood (lower the emotional weight).
  final int moodEffect;
}

/// One line BaoBao says, with the replies the user can choose from.
class ConversationNode {
  const ConversationNode({
    required this.id,
    required this.line,
    required this.options,
    this.voice,
    this.nudge,
    this.closing = false,
  });

  factory ConversationNode.fromJson(String id, Map<String, dynamic> json) {
    final nudgeName = json['nudge'] as String?;
    final nudge = FeatureNudge.tryParse(nudgeName);
    if (nudgeName != null && nudge == null) {
      throw FormatException('Node "$id" has unknown nudge "$nudgeName"');
    }
    return ConversationNode(
      id: id,
      line: json['line'] as String,
      voice: json['voice'] as String?,
      nudge: nudge,
      closing: (json['closing'] as bool?) ?? false,
      options: [
        for (final option in json['options'] as List<dynamic>)
          ConversationOption.fromJson(option as Map<String, dynamic>),
      ],
    );
  }

  final String id;
  final String line;

  /// Voice clip id (file name without extension), if the line is voiced.
  final String? voice;
  final FeatureNudge? nudge;

  /// Marks BaoBao's closing line for a branch.
  final bool closing;
  final List<ConversationOption> options;
}

/// A complete branching conversation for one mood, or the intervention.
class ConversationTree {
  const ConversationTree({required this.id, required this.startId, required this.nodes});

  factory ConversationTree.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as Map<String, dynamic>;
    return ConversationTree(
      id: json['id'] as String,
      startId: json['start'] as String,
      nodes: {
        for (final entry in rawNodes.entries)
          entry.key: ConversationNode.fromJson(entry.key, entry.value as Map<String, dynamic>),
      },
    );
  }

  /// The tree id of the intervention conversation.
  static const interventionId = 'intervention';

  final String id;
  final String startId;
  final Map<String, ConversationNode> nodes;

  ConversationNode get start => nodes[startId]!;
}
