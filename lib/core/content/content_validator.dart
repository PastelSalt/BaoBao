import 'package:baobao/features/conversation/domain/conversation_models.dart';

/// Structural checks for a [ConversationTree]. Returns human-readable problems;
/// an empty list means the tree is sound.
abstract final class ContentValidator {
  static List<String> validateTree(ConversationTree tree) {
    final problems = <String>[];
    final where = 'Tree "${tree.id}"';

    if (!tree.nodes.containsKey(tree.startId)) {
      return ['$where: start node "${tree.startId}" does not exist'];
    }

    for (final node in tree.nodes.values) {
      if (node.line.trim().isEmpty) problems.add('$where: node "${node.id}" has an empty line');
      if (node.options.isEmpty) problems.add('$where: node "${node.id}" has no options');
      for (final option in node.options) {
        if (option.text.trim().isEmpty) {
          problems.add('$where: node "${node.id}" has an option with no text');
        }
        final known =
            ConversationOption.reservedTargets.contains(option.next) ||
            tree.nodes.containsKey(option.next);
        if (!known) {
          problems.add('$where: node "${node.id}" points to unknown node "${option.next}"');
        }
      }
    }

    // Every node must be reachable from the start.
    final reachable = <String>{};
    final queue = [tree.startId];
    while (queue.isNotEmpty) {
      final id = queue.removeLast();
      if (!reachable.add(id)) continue;
      for (final option in tree.nodes[id]!.options) {
        if (tree.nodes.containsKey(option.next)) queue.add(option.next);
      }
    }
    for (final id in tree.nodes.keys) {
      if (!reachable.contains(id)) problems.add('$where: node "$id" cannot be reached');
    }

    // Every node must be able to reach an end, so nobody gets stuck in a loop.
    final canEnd = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final node in tree.nodes.values) {
        if (canEnd.contains(node.id)) continue;
        final exits = node.options.any(
          (option) =>
              ConversationOption.reservedTargets.contains(option.next) ||
              canEnd.contains(option.next),
        );
        if (exits) {
          canEnd.add(node.id);
          changed = true;
        }
      }
    }
    for (final id in tree.nodes.keys) {
      if (!canEnd.contains(id)) problems.add('$where: node "$id" can never reach an ending');
    }

    return problems;
  }
}
