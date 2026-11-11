import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/loading_overlay.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  setUpAll(() async {
    await Harness.loadContent();
    await loadAppFonts();
  });

  group('BambooButton', () {
    testWidgets('a tap runs the action and plays the click', (tester) async {
      final harness = await Harness.create();
      var taps = 0;
      await tester.pumpWidget(harness.wrap(BambooButton(label: 'Go', onPressed: () => taps++)));

      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(taps, 1);
      expect(harness.sfx.log, ['play ${AudioDirector.clickAsset}']);
      await harness.dispose(tester);
    });

    testWidgets('when disabled it does nothing and says so to screen readers', (tester) async {
      final harness = await Harness.create();
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness.wrap(const BambooButton(label: 'Go', onPressed: null)));

      await tester.tap(find.text('Go'));
      expect(harness.sfx.log, isEmpty);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Go')),
        matchesSemantics(label: 'Go', isButton: true, hasEnabledState: true),
      );
      handle.dispose();
      await harness.dispose(tester);
    });

    testWidgets('is an accessible button at least 48 high', (tester) async {
      final harness = await Harness.create();
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness.wrap(BambooButton(label: 'Go', onPressed: () {})));

      expect(tester.getSize(find.byType(BambooButton)).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Go')),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
      await harness.dispose(tester);
    });

    testWidgets('long labels wrap instead of overflowing', (tester) async {
      final harness = await Harness.create();
      await tester.pumpWidget(
        harness.wrap(
          SizedBox(
            width: 220,
            child: BambooButton(
              label: 'A really rather long label that cannot fit on one line',
              expand: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await harness.dispose(tester);
    });
  });

  group('CharacterView', () {
    test('maps moods to the poses that exist', () {
      expect(CharacterPose.forMood(Mood.happy), CharacterPose.happy);
      expect(CharacterPose.forMood(Mood.okay), CharacterPose.hello);
      expect(CharacterPose.forMood(Mood.sad), CharacterPose.sad);
      expect(CharacterPose.forMood(Mood.anxious), CharacterPose.sad);
      expect(CharacterPose.forMood(Mood.tired), CharacterPose.tired);
      expect(CharacterPose.parse('nonsense'), CharacterPose.hello);
    });

    testWidgets('shows the pose from the outfit folder with a label', (tester) async {
      final harness = await Harness.create();
      await tester.pumpWidget(
        harness.wrap(
          const CharacterView(
            outfitAsset: 'assets/images/character/blue_bao',
            pose: CharacterPose.tired,
            semanticLabel: 'BaoBao',
          ),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'assets/images/character/blue_bao/tired.webp');
      expect(image.semanticLabel, 'BaoBao');
      await harness.dispose(tester);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('blocks touches only while loading', (tester) async {
      final harness = await Harness.create();
      var taps = 0;
      Widget build(bool loading) => harness.wrap(
        LoadingOverlay(
          loading: loading,
          label: 'Working',
          child: BambooButton(label: 'Go', onPressed: () => taps++),
        ),
      );

      await tester.pumpWidget(build(true));
      expect(find.text('Working'), findsOneWidget);
      await tester.tap(find.text('Go'), warnIfMissed: false);
      expect(taps, 0);

      await tester.pumpWidget(build(false));
      expect(find.text('Working'), findsNothing);
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      await harness.dispose(tester);
    });
  });

  group('appearance', () {
    Widget gallery(Harness harness) => harness.wrap(
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpeechBubble(child: Text('Good morning! I am so glad you are here.')),
            const SizedBox(height: 12),
            for (final tone in BambooButtonTone.values) ...[
              BambooButton(label: 'Button ${tone.name}', tone: tone, onPressed: () {}),
              const SizedBox(height: 8),
            ],
            const BambooButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: 12),
            const BambooFrame(child: Text('3000 ✷')),
            const SizedBox(height: 12),
            BambooDialog(
              title: 'A dialog',
              content: const Text('Dialogs use a larger bamboo frame.'),
              actions: [BambooButton(label: 'OK', onPressed: () {})],
            ),
          ],
        ),
      ),
    );

    for (final scale in [1.0, 2.0]) {
      testWidgets('shared widgets at ${scale}x text', (tester) async {
        tester.view.physicalSize = const Size(420, 1400);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final harness = await Harness.create();
        await tester.pumpWidget(gallery(harness));
        await tester.pump();

        expect(tester.takeException(), isNull, reason: 'nothing may overflow');
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/shared_widgets_${scale.toStringAsFixed(0)}x.png'),
        );
        await harness.dispose(tester);
      });
    }
  });
}
