import 'package:baobao/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Walks the app on a real device or emulator and saves a screenshot at each
/// stop, so the screens can be reviewed as the person would see them.
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/journey_test.dart --flavor dev
///
/// Start from a fresh install: the first screen must be onboarding.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 800));
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot(name);
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder.first);
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(milliseconds: 300), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
  }

  testWidgets('first run to claw machine', (tester) async {
    await bootstrap(AppFlavor.dev);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await shot(tester, '01_onboarding_welcome');
    await tap(tester, "Let's begin");
    await shot(tester, '02_onboarding_promise');
    await tap(tester, 'I understand BaoBao is not a substitute for professional care.');
    await tap(tester, 'I am 13 or older.');
    await tap(tester, 'Continue');
    await tester.enterText(find.byType(TextField), 'Mei');
    await shot(tester, '03_onboarding_name');
    await tap(tester, "Let's begin");
    await tester.pumpAndSettle(const Duration(seconds: 1));

    if (find.text('Skip tour').evaluate().isNotEmpty) {
      await shot(tester, '04_tour');
      await tap(tester, 'Skip tour');
    }
    await shot(tester, '05_home');

    await tap(tester, 'How are you feeling?');
    await shot(tester, '06_mood_sheet');
    await tap(tester, 'Sad');
    await shot(tester, '07_conversation');
    await tap(tester, 'End chat for now');

    await tap(tester, 'Shop');
    await shot(tester, '08_shop');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tap(tester, 'Claw');
    await shot(tester, '09_claw_machine');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await shot(tester, '10_settings');
    await tap(tester, 'Get help');
    await shot(tester, '11_help');
  });
}
