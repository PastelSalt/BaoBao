import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/layout_checks.dart';
import 'scenarios.dart';

/// Every screen, at every size and text scale below, must have no overflow,
/// no word broken in the middle, and nothing cut off. Run with `REVIEW=1` to
/// also save a picture of each into `build/review/`, then
/// `python3 tool/review_sheets.py` to tile them for a person to look at.
const _sizes = {
  'small-phone': Size(360, 640),
  'phone': Size(412, 892),
  'tablet': Size(600, 960),
  // The dark theme, on the sizes where it is most likely to be used.
  'phone-dark': Size(412, 892),
  'small-phone-dark': Size(360, 640),
};
const _scales = [1.0, 2.0];

final _review = Platform.environment['REVIEW'] == '1';

void main() {
  setUpAll(() async {
    await Harness.loadContent();
    await loadAppFonts();
  });

  for (final scenario in scenarios) {
    for (final MapEntry(key: sizeName, value: size) in _sizes.entries) {
      for (final scale in [..._scales, if (sizeName == 'small-phone') 1.3]) {
        final dark = sizeName.endsWith('-dark');
        testWidgets('${scenario.name} / $sizeName / ${scale}x', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final harness = await Harness.create(
            lockAvailable: scenario.lockAvailable,
            prefs: {'help.country': 'US', if (dark) 'appearance.theme': 'dark', ...scenario.prefs},
          );
          if (!beforeOnboarding.contains(scenario.name)) {
            await tester.runAsync(() async {
              await onboard(harness);
              await scenario.prepare?.call(harness);
            });
          }
          await pumpApp(tester, harness, size: size);
          await scenario.start(tester, harness);
          await _decodeImages(tester);

          final problems = [
            if (tester.takeException() case final error?) 'Flutter reported: $error',
            ...layoutProblems(tester),
            ...?scenario.extraChecks?.call(tester),
          ];

          if (_review) {
            await _savePicture(tester, 'build/review/${scenario.name}/$sizeName-${scale}x.png');
          }
          await harness.dispose(tester);
          expect(problems, isEmpty, reason: problems.join('\n'));
        });
      }
    }
  }
}

Future<void> _decodeImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _savePicture(WidgetTester tester, String path) async {
  await tester.runAsync(() async {
    final boundary = appBoundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = (await image.toByteData(format: ImageByteFormat.png))!;
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes.buffer.asUint8List());
  });
}
