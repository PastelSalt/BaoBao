import 'dart:math';

import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/presentation/claw_machine_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> paint(WidgetTester tester, ClawGame game, String name) async {
    tester.view.physicalSize = const Size(410, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ColoredBox(
        color: const Color(0xFFF6F6DB),
        child: Center(
          child: SizedBox(
            width: 369,
            height: 450,
            child: CustomPaint(painter: ClawMachinePainter(game)),
          ),
        ),
      ),
    );
    await expectLater(find.byType(ColoredBox), matchesGoldenFile('goldens/$name.png'));
  }

  List<Prize> prizes() => [
    Prize(x: 0.24, value: 30, rare: false),
    Prize(x: 0.45, value: 200, rare: true),
    Prize(x: 0.66, value: 71, rare: false),
    Prize(x: 0.84, value: 44, rare: false),
  ];

  testWidgets('idle machine', (tester) async {
    await paint(tester, ClawGame(random: Random(1), prizes: prizes()), 'claw_idle');
  });

  testWidgets('carrying a rare prize', (tester) async {
    final game = ClawGame(random: Random(1), prizes: prizes())
      ..startMoving()
      ..clawX = 0.45
      ..drop();
    for (var i = 0; i < 100 && game.phase != ClawPhase.lifting; i++) {
      game.tick(const Duration(milliseconds: 16));
    }
    game.tick(const Duration(milliseconds: 600));
    await paint(tester, game, 'claw_carrying');
  });
}
