import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/mood/domain/mood.dart';

/// What happens after the user picks an option.
sealed class ConversationStep {
  const ConversationStep();
}

/// BaoBao says the next line.
final class ContinueStep extends ConversationStep {
  const ContinueStep(this.session);
  final ConversationSession session;
}

/// The conversation is over. [session] holds the final path.
final class EndStep extends ConversationStep {
  const EndStep(this.session);
  final ConversationSession session;
}

/// The support resources screen should open. The conversation stays where it is.
final class ResourcesStep extends ConversationStep {
  const ResourcesStep(this.session);
  final ConversationSession session;
}

/// An in-progress conversation. Immutable: [choose] returns the next state.
class ConversationSession {
  const ConversationSession._(this.tree, this.current, this.path);

  factory ConversationSession.start(ConversationTree tree) {
    return ConversationSession._(tree, tree.start, [tree.startId]);
  }

  /// Which tree to use for a check-in: the mood's own, or the intervention.
  static String treeIdFor(Mood mood, {required bool intervene}) =>
      intervene ? ConversationTree.interventionId : mood.name;

  final ConversationTree tree;
  final ConversationNode current;

  /// Ids of every node shown so far, in order.
  final List<String> path;

  ConversationStep choose(ConversationOption option) {
    assert(current.options.contains(option), 'Option does not belong to the current node');
    switch (option.next) {
      case ConversationOption.endTarget:
        return EndStep(this);
      case ConversationOption.resourcesTarget:
        return ResourcesStep(this);
    }
    final next = tree.nodes[option.next];
    // Content is validated in CI, so a missing node should never ship. If it
    // does, ending the conversation is kinder than crashing.
    if (next == null) return EndStep(this);
    return ContinueStep(ConversationSession._(tree, next, [...path, next.id]));
  }
}
