import 'dart:io';

import 'package:baobao/app/system_chrome.dart';
import 'package:baobao/core/widgets/app_background.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bao_stage.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/entrance.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  setUpAll(() async {
    await Harness.loadContent();
    await loadAppFonts();
  });

  group('icons', () {
    test('every glyph has a drawing', () {
      for (final glyph in Glyph.values) {
        expect(File(glyph.asset).existsSync(), isTrue, reason: glyph.name);
      }
    });

    test('there are no drawings that no glyph uses', () {
      final names = {for (final glyph in Glyph.values) '${glyph.name}.svg'};
      final files = Directory('assets/images/icons').listSync().map((f) => f.uri.pathSegments.last);
      expect(files.toSet().difference(names), isEmpty);
    });
  });

  group('backgrounds', () {
    test('each has a night version beside it', () {
      expect(
        backgroundAssetFor('assets/images/backgrounds/bamboo.svg', dark: false),
        'assets/images/backgrounds/bamboo.svg',
      );
      expect(
        backgroundAssetFor('assets/images/backgrounds/bamboo.svg', dark: true),
        'assets/images/backgrounds/bamboo_night.svg',
      );
      for (final name in ['bamboo', 'bamboo_clouds', 'bamboo_plum']) {
        expect(
          File('assets/images/backgrounds/${name}_night.svg').existsSync(),
          isTrue,
          reason: name,
        );
      }
    });
  });

  group('Entrance', () {
    Widget app(Harness harness) => harness.wrap(const Entrance(child: Text('hello')));

    double opacity(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find.descendant(of: find.byType(Entrance), matching: find.byType(FadeTransition)).first,
        )
        .opacity
        .value;

    testWidgets('is simply there with reduced motion', (tester) async {
      final harness = await Harness.create(reducedMotion: true);
      await tester.pumpWidget(app(harness));
      expect(opacity(tester), 1);
      await harness.dispose(tester);
    });

    testWidgets('fades in over about 400 ms otherwise', (tester) async {
      final harness = await Harness.create(reducedMotion: false);
      await tester.pumpWidget(app(harness));
      expect(opacity(tester), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(tester), inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(opacity(tester), 1);
      await harness.dispose(tester);
    });

    testWidgets('waits for its delay', (tester) async {
      final harness = await Harness.create(reducedMotion: false);
      await tester.pumpWidget(
        harness.wrap(const Entrance(delay: Duration(milliseconds: 300), child: Text('hello'))),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(opacity(tester), 0);
      await tester.pump(const Duration(milliseconds: 600));
      expect(opacity(tester), 1);
      await harness.dispose(tester);
    });
  });

  group('BaoStage', () {
    final longLine = List.filled(
      30,
      'I am here with you and we can take this one gentle step at a time.',
    ).join(' ');

    Future<Harness> pumpStage(WidgetTester tester, String text, {double height = 400}) async {
      final harness = await Harness.create();
      await tester.pumpWidget(
        harness.wrap(
          SizedBox(
            width: 340,
            height: height,
            child: BaoStage(
              text: text,
              outfitAsset: 'assets/images/character/classic',
              characterLabel: 'BaoBao',
            ),
          ),
        ),
      );
      await tester.pump();
      return harness;
    }

    testWidgets('a very long line scrolls inside the bubble instead of pushing BaoBao away', (
      tester,
    ) async {
      final harness = await pumpStage(tester, longLine);
      final bubble = tester.getRect(find.byType(SpeechBubble));
      final stage = tester.getRect(find.byType(BaoStage));
      expect(bubble.height, lessThanOrEqualTo(stage.height * 0.52 + 1));
      expect(tester.getRect(find.byType(CharacterView)).height, greaterThan(stage.height * 0.3));
      await harness.dispose(tester);
    });

    testWidgets('a short line leaves the bubble small', (tester) async {
      final harness = await pumpStage(tester, 'Hi!');
      expect(tester.getRect(find.byType(SpeechBubble)).height, lessThan(110));
      await harness.dispose(tester);
    });

    testWidgets('the character shrinks rather than vanishing on a tiny stage', (tester) async {
      final harness = await pumpStage(tester, longLine, height: 180);
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(SpeechBubble)).height, lessThanOrEqualTo(180 * 0.52 + 1));
      await harness.dispose(tester);
    });

    testWidgets('tapping the character calls back', (tester) async {
      final harness = await Harness.create();
      var taps = 0;
      await tester.pumpWidget(
        harness.wrap(
          SizedBox(
            width: 340,
            height: 400,
            child: BaoStage(
              text: 'Hi',
              outfitAsset: 'assets/images/character/classic',
              characterLabel: 'BaoBao',
              onCharacterTap: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Image).first);
      expect(taps, 1);
      await harness.dispose(tester);
    });
  });

  group('SystemChromePolicy', () {
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessenger? messenger;
      messenger = TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
    });

    List<Object?> lastOrientations() =>
        (calls.lastWhere((c) => c.method == 'SystemChrome.setPreferredOrientations').arguments
            as List<Object?>);

    testWidgets('keeps phones in portrait', (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: SystemChromePolicy(child: SizedBox())));
      expect(lastOrientations(), [
        'DeviceOrientation.portraitUp',
        'DeviceOrientation.portraitDown',
      ]);
    });

    testWidgets('lets tablets rotate', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: SystemChromePolicy(child: SizedBox())));
      expect(lastOrientations(), hasLength(4));
    });

    testWidgets('draws edge to edge', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SystemChromePolicy(child: SizedBox())));
      expect(calls.map((c) => c.method), contains('SystemChrome.setEnabledSystemUIMode'));
    });

    test('knows what a tablet is', () {
      expect(isTablet(const Size(599, 1000)), isFalse);
      expect(isTablet(const Size(600, 960)), isTrue);
      expect(isTablet(const Size(1280, 800)), isTrue);
    });
  });
}
