import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/app_harness.dart';
import '../home/home_conversation_test.dart' show RecordingLinks;

void main() {
  setUpAll(Harness.loadContent);

  Future<Harness> open(WidgetTester tester, {String? country, RecordingLinks? links}) async {
    final harness = await Harness.create(
      links: links ?? RecordingLinks(),
      prefs: {'help.country': ?country},
    );
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness, size: const Size(420, 2400));
    unawaited(harness.container.read(routerProvider).push(Routes.resources));
    await settle(tester);
    return harness;
  }

  testWidgets('a known country shows its emergency number and local lines first', (tester) async {
    final harness = await open(tester, country: 'US');

    expect(find.textContaining('call 911 now'), findsOneWidget);
    for (final name in ['988 Suicide & Crisis Lifeline', 'Crisis Text Line', 'Find A Helpline']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Text HOME to 741741'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('an unknown country never shows another country\'s numbers', (tester) async {
    final harness = await open(tester, country: 'ZZ');

    expect(find.textContaining('your local emergency number'), findsOneWidget);
    expect(find.textContaining('911'), findsNothing);
    expect(find.text('988 Suicide & Crisis Lifeline'), findsNothing);
    expect(find.text('Find A Helpline'), findsOneWidget);
    expect(find.textContaining("don't have local numbers"), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('the region can be changed and is remembered', (tester) async {
    final harness = await open(tester, country: 'ZZ');

    await tapLabel(tester, 'Another country');
    await tapLabel(tester, 'United States');

    expect(harness.container.read(settingsProvider).helpCountry, 'US');
    expect(find.text('988 Suicide & Crisis Lifeline'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('actions hand the right link to the device', (tester) async {
    final links = RecordingLinks();
    final harness = await open(tester, country: 'US', links: links);

    await tapLabel(tester, 'Call 911');
    await tapLabel(tester, 'Text HOME to 741741');
    expect(links.opened, ['tel:911', 'sms:741741?body=HOME']);
    await harness.dispose(tester);
  });

  testWidgets('if the device cannot open a link, the details are shown instead', (tester) async {
    final harness = await open(tester, country: 'US', links: RecordingLinks(works: false));

    await tapLabel(tester, 'Text HOME to 741741');
    expect(find.text("Couldn't open that here"), findsOneWidget);
    expect(find.textContaining('741741\n“HOME”'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('help is one tap away in Settings, with no trigger needed', (tester) async {
    final harness = await Harness.create(prefs: {'help.country': 'US'});
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tapLabel(tester, 'Get help');
    expect(find.text('In an emergency'), findsOneWidget);
    expect(
      GoRouter.of(tester.element(find.text('In an emergency'))).state.matchedLocation,
      Routes.resources,
    );
    await harness.dispose(tester);
  });
}
