import 'package:baobao/core/widgets/typewriter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

/// The part of the line that is currently visible.
String shown(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.byType(RichText));
  return ((rich.text as TextSpan).children!.first as TextSpan).children!.first.toPlainText();
}

void main() {
  setUpAll(Harness.loadContent);
  const line = 'Hi 🐼 there';

  testWidgets('reveals the line character by character', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    var finished = 0;
    await tester.pumpWidget(
      harness.wrap(
        TypewriterText(
          line,
          perCharacter: const Duration(milliseconds: 10),
          onFinished: () => finished++,
        ),
      ),
    );

    expect(shown(tester), '');
    await tester.pump(const Duration(milliseconds: 45));
    expect(shown(tester), 'Hi 🐼');
    expect(finished, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(shown(tester), line);
    expect(finished, 1);
    await harness.dispose(tester);
  });

  testWidgets('keeps its final size from the first frame', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    await tester.pumpWidget(harness.wrap(const TypewriterText(line)));
    final before = tester.getSize(find.byType(TypewriterText));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getSize(find.byType(TypewriterText)), before);
    await harness.dispose(tester);
  });

  testWidgets('a tap shows the rest at once', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    await tester.pumpWidget(harness.wrap(const TypewriterText(line)));
    await tester.tap(find.byType(TypewriterText));
    await tester.pump();
    expect(shown(tester), line);
    await harness.dispose(tester);
  });

  testWidgets('screen readers get the whole line immediately', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness.wrap(const TypewriterText(line)));
    expect(find.bySemanticsLabel(line), findsOneWidget);
    handle.dispose();
    await harness.dispose(tester);
  });

  testWidgets('with reduced motion the line simply appears', (tester) async {
    final harness = await Harness.create(reducedMotion: true);
    var finished = 0;
    await tester.pumpWidget(harness.wrap(TypewriterText(line, onFinished: () => finished++)));
    expect(shown(tester), line);
    await tester.pump();
    expect(finished, 1);
    await harness.dispose(tester);
  });

  testWidgets('a new line starts again from the beginning', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    await tester.pumpWidget(harness.wrap(const TypewriterText('First')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(harness.wrap(const TypewriterText('Second line')));
    expect(shown(tester), '');
    await tester.pump(const Duration(seconds: 1));
    expect(shown(tester), 'Second line');
    await harness.dispose(tester);
  });
}
