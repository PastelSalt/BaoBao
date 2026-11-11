import 'package:baobao/core/content/content_validator.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/conversation/domain/conversation_session.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:flutter_test/flutter_test.dart';

ConversationTree tree(Map<String, dynamic> nodes, {String start = 'a'}) =>
    ConversationTree.fromJson({'id': 'test', 'start': start, 'nodes': nodes});

Map<String, dynamic> node(String line, List<List<Object>> options, {String? nudge}) => {
  'line': line,
  'nudge': ?nudge,
  'options': [
    for (final o in options) {'text': o[0], 'next': o[1], if (o.length > 2) 'moodEffect': o[2]},
  ],
};

void main() {
  final sample = tree({
    'a': node('Hello', [
      ['Go on', 'b', 1],
      ['Help', '@resources'],
    ], nudge: 'joke'),
    'b': node('Bye', [
      ['Done', '@end'],
    ]),
  });

  group('parsing', () {
    test('reads nodes, options, nudges and mood effects', () {
      expect(sample.start.line, 'Hello');
      expect(sample.start.nudge, FeatureNudge.joke);
      expect(sample.start.options.first.moodEffect, 1);
      expect(sample.start.options.last.moodEffect, 0);
    });

    test('rejects an unknown nudge', () {
      expect(
        () => tree({
          'a': node('Hi', [
            ['x', '@end'],
          ], nudge: 'karaoke'),
        }),
        throwsFormatException,
      );
    });
  });

  group('ConversationSession', () {
    test('starts at the start node', () {
      final session = ConversationSession.start(sample);
      expect(session.current.id, 'a');
      expect(session.path, ['a']);
    });

    test('moves to the next node and records the path', () {
      final step = ConversationSession.start(sample).choose(sample.start.options.first);
      expect(step, isA<ContinueStep>());
      final session = (step as ContinueStep).session;
      expect(session.current.id, 'b');
      expect(session.path, ['a', 'b']);
    });

    test('ends on the end target', () {
      final atB = (ConversationSession.start(
        sample,
      ).choose(sample.start.options.first) as ContinueStep).session;
      final step = atB.choose(atB.current.options.single);
      expect(step, isA<EndStep>());
      expect((step as EndStep).session.path, ['a', 'b']);
    });

    test('opens resources without leaving the node', () {
      final step = ConversationSession.start(sample).choose(sample.start.options.last);
      expect(step, isA<ResourcesStep>());
      expect((step as ResourcesStep).session.current.id, 'a');
    });

    test('ends gracefully if content points at a missing node', () {
      final broken = tree({
        'a': node('Hi', [
          ['x', 'nowhere'],
        ]),
      });
      final step = ConversationSession.start(broken).choose(broken.start.options.single);
      expect(step, isA<EndStep>());
    });

    test('uses the intervention tree only when asked to intervene', () {
      expect(ConversationSession.treeIdFor(Mood.sad, intervene: false), 'sad');
      expect(ConversationSession.treeIdFor(Mood.sad, intervene: true), 'intervention');
    });
  });

  group('ContentValidator', () {
    test('accepts a sound tree', () {
      expect(ContentValidator.validateTree(sample), isEmpty);
    });

    test('reports a missing start node', () {
      expect(
        ContentValidator.validateTree(
          tree({
            'a': node('Hi', [
              ['x', '@end'],
            ]),
          }, start: 'zzz'),
        ),
        [contains('start node "zzz" does not exist')],
      );
    });

    test('reports unknown targets, unreachable nodes and dead ends', () {
      final problems = ContentValidator.validateTree(
        tree({
          'a': node('Hi', [
            ['x', 'missing'],
            ['y', 'loop'],
          ]),
          'loop': node('Round', [
            ['again', 'loop'],
          ]),
          'island': node('Alone', [
            ['x', '@end'],
          ]),
        }),
      );
      expect(problems, contains(contains('points to unknown node "missing"')));
      expect(problems, contains(contains('node "island" cannot be reached')));
      expect(problems, contains(contains('node "loop" can never reach an ending')));
    });

    test('reports empty lines and nodes without options', () {
      final problems = ContentValidator.validateTree(tree({'a': node(' ', [])}));
      expect(problems, contains(contains('empty line')));
      expect(problems, contains(contains('no options')));
    });
  });
}
