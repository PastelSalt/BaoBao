import 'package:baobao/core/links/link_opener.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/features/home/application/home_controller.dart';
import 'package:baobao/features/home/presentation/home_screen.dart';
import 'package:baobao/features/intervention/presentation/resources_screen.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

class RecordingLinks implements LinkOpener {
  RecordingLinks({this.works = true});
  bool works;
  final opened = <String>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri.toString());
    return works;
  }
}

void main() {
  setUpAll(Harness.loadContent);

  Future<Harness> start(
    WidgetTester tester, {
    LinkOpener? links,
    Map<String, Object> prefs = const {},
  }) async {
    final harness = await Harness.create(links: links, prefs: prefs);
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness);
    return harness;
  }

  HomeState home(Harness harness) => harness.container.read(homeControllerProvider);

  testWidgets('a check-in starts that mood\'s conversation, voiced', (tester) async {
    final harness = await start(tester);

    await tapLabel(tester, 'How are you feeling?');
    expect(find.text('There\'s no wrong answer. Pick whatever fits right now.'), findsOneWidget);
    await tapLabel(tester, 'Sad');

    final sadStart = harness.content.trees['sad']!.start;
    expect(home(harness).session!.current.id, 'sad_start');
    expect(find.bySemanticsLabel(sadStart.line), findsOneWidget);
    expect(harness.voice.log.last, 'play assets/audio/voice/en/s_sad_01.m4a');
    for (final option in sadStart.options) {
      expect(find.text(option.text), findsOneWidget);
    }

    final mood = await tester.runAsync(
      () => harness.container.read(moodRepositoryProvider).recentMoods(1),
    );
    expect(mood, [Mood.sad]);
    await harness.dispose(tester);
  });

  testWidgets('choosing replies walks the tree to its end and BaoBao says goodbye', (tester) async {
    final harness = await start(tester);
    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Happy');

    // Always take the first reply; every tree is validated to reach an end.
    for (var i = 0; i < 20 && home(harness).inConversation; i++) {
      await tapLabel(tester, home(harness).options.first.text);
    }

    expect(home(harness).inConversation, isFalse);
    expect(harness.voice.log.last, matches(RegExp(r'voice/en/i_0\d\.m4a$')));
    expect(find.text('How are you feeling?'), findsOneWidget);

    final saved = await tester.runAsync(
      () => harness.container.read(conversationRepositoryProvider).latest(1),
    );
    expect(saved!.treeId, 'happy');
    await harness.dispose(tester);
  });

  testWidgets('a chat can be ended at any point', (tester) async {
    final harness = await start(tester);
    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Tired');
    await tapLabel(tester, 'End chat for now');

    expect(home(harness).inConversation, isFalse);
    expect(find.text('How are you feeling?'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('quick actions give a voiced joke, kind word or self-care idea', (tester) async {
    final harness = await start(tester);
    final scripts = harness.content.scripts;

    await tapLabel(tester, 'Joke');
    expect(scripts.jokes.lines.map((l) => l.text), contains(home(harness).line));
    expect(harness.voice.log.last, matches(RegExp(r'voice/en/g_\d\d\.m4a$')));

    await tapLabel(tester, 'Kind word');
    expect(scripts.affirmations.lines.map((l) => l.text), contains(home(harness).line));

    await tapLabel(tester, 'Self-care');
    expect(scripts.selfCare.lines.map((l) => l.text), contains(home(harness).line));
    await harness.dispose(tester);
  });

  testWidgets('after two anxious check-ins BaoBao intervenes and can open real help', (
    tester,
  ) async {
    final links = RecordingLinks();
    final harness = await start(tester, links: links, prefs: {'help.country': 'US'});

    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Anxious');
    expect(home(harness).isIntervention, isFalse);
    await tapLabel(tester, 'End chat for now');

    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Anxious');
    expect(home(harness).isIntervention, isTrue);
    expect(harness.voice.log.last, 'play assets/audio/voice/en/int_01.m4a');

    await tapLabel(tester, "I'm managing okay");
    await tapLabel(tester, 'Yes, show me resources');
    await tapLabel(tester, 'View Resources');

    expect(find.byType(ResourcesScreen), findsOneWidget);
    expect(find.text('988 Suicide & Crisis Lifeline'), findsOneWidget);
    await tapLabel(tester, 'Call 988');
    expect(links.opened, ['tel:988']);

    // Coming back, the conversation is still where it was.
    await tester.pageBack();
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(home(harness).session!.current.id, 'intervention_resources');
    await harness.dispose(tester);
  });

  testWidgets('a third low check-in the same day does not intervene again', (tester) async {
    final harness = await start(tester);
    for (var i = 0; i < 3; i++) {
      await tapLabel(tester, 'How are you feeling?');
      await tapLabel(tester, 'Anxious');
      if (i < 2) await tapLabel(tester, 'End chat for now');
    }
    expect(home(harness).session!.tree.id, 'anxious');
    await harness.dispose(tester);
  });

  testWidgets('everything still fits at 2x text on a small phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final harness = await Harness.create();
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness, size: const Size(360, 640));
    expect(tester.takeException(), isNull);

    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Sad');
    expect(tester.takeException(), isNull);
    await harness.dispose(tester);
  });
}
