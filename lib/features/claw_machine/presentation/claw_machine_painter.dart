import 'dart:math' as math;

import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:flutter/widgets.dart';

/// Draws the claw machine: cabinet, glass, rail, claw, capsules and chute.
///
/// Everything is laid out in fractions of the canvas, so it scales to any size.
class ClawMachinePainter extends CustomPainter {
  ClawMachinePainter(this.game, {super.repaint});

  final ClawGame game;

  static const _capsuleColours = [
    Color(0xFFF28B82), // coral
    Color(0xFF81C995), // mint
    Color(0xFF8AB4F8), // sky
    Color(0xFFC58AF9), // lilac
    Color(0xFFFFB74D), // apricot
    Color(0xFF4DD0E1), // aqua
  ];

  /// A stable colour for a prize, so it does not change between frames.
  static Color colourFor(Prize prize) =>
      prize.rare ? AppColors.gold : _capsuleColours[prize.value % _capsuleColours.length];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Cabinet.
    final cabinet = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.07));
    canvas.drawRRect(cabinet, Paint()..color = AppColors.bambooEdge);
    final inner = cabinet.deflate(w * 0.012);
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.bambooShade, AppColors.bambooLight, AppColors.bambooShade],
        ).createShader(inner.outerRect),
    );

    // Glass.
    final glass = Rect.fromLTRB(w * 0.06, h * 0.05, w * 0.94, h * 0.80);
    final glassR = RRect.fromRectAndRadius(glass, Radius.circular(w * 0.04));
    canvas.drawRRect(
      glassR,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6FF), Color(0xFFD9F0DC)],
        ).createShader(glass),
    );
    canvas.save();
    canvas.clipRRect(glassR);

    // Soft bamboo silhouettes inside, for depth.
    final stalk = Paint()..color = AppColors.green.withValues(alpha: 0.22);
    for (final x in [0.18, 0.33, 0.71, 0.86]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(glass.left + glass.width * x, glass.top, w * 0.035, glass.height),
          Radius.circular(w * 0.02),
        ),
        stalk,
      );
    }

    // Prize bed.
    final floorY = glass.bottom - glass.height * 0.10;
    canvas.drawRect(
      Rect.fromLTRB(glass.left, floorY, glass.right, glass.bottom),
      Paint()..color = AppColors.lightGreen,
    );

    // Chute: a dark opening at the left of the bed.
    final chuteCentre = glass.left + glass.width * ClawGame.chuteX;
    final chuteWidth = glass.width * 0.13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(chuteCentre, floorY + glass.height * 0.05),
          width: chuteWidth,
          height: glass.height * 0.11,
        ),
        Radius.circular(w * 0.02),
      ),
      Paint()..color = AppColors.ink.withValues(alpha: 0.75),
    );

    double xAt(double fraction) => glass.left + glass.width * fraction;
    final railY = glass.top + glass.height * 0.07;
    final restY = railY + glass.height * 0.16;
    final radius = glass.width * Prize.defaultWidth * 0.46;
    final prizeY = floorY - radius * 0.85;
    final clawX = xAt(game.clawX);
    final clawY = restY + (prizeY - radius * 0.9 - restY) * game.depth;

    // Prizes resting on the bed.
    for (final prize in game.prizes) {
      if (prize.taken) continue;
      _capsule(canvas, Offset(xAt(prize.x), prizeY), radius, prize);
    }

    // The prize in the claw, or falling into the chute.
    final held = game.held;
    if (held != null) {
      final fall = game.releaseProgress;
      final centre = Offset(clawX, clawY + radius * 0.9 + fall * (floorY - clawY));
      _capsule(canvas, centre, radius * (1 - 0.35 * fall), held, opacity: 1 - 0.6 * fall);
    }

    // Rail and trolley.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          glass.left + w * 0.02,
          railY - h * 0.008,
          glass.right - w * 0.02,
          railY + h * 0.008,
        ),
        Radius.circular(h * 0.008),
      ),
      Paint()..color = AppColors.tan,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(clawX, railY), width: w * 0.09, height: h * 0.03),
        Radius.circular(h * 0.01),
      ),
      Paint()..color = AppColors.inkSoft,
    );

    // Cable and claw.
    final metal = Paint()
      ..color = AppColors.inkSoft
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.012;
    canvas.drawLine(Offset(clawX, railY), Offset(clawX, clawY - radius * 0.5), metal);

    final gripping =
        held != null || game.phase == ClawPhase.lifting || game.phase == ClawPhase.finished;
    final spread = gripping ? 0.55 : 1.0;
    final hub = Offset(clawX, clawY - radius * 0.45);
    canvas.drawCircle(hub, radius * 0.28, Paint()..color = AppColors.tan);
    canvas.drawCircle(hub, radius * 0.28, metal..strokeWidth = w * 0.008);
    metal.strokeWidth = w * 0.014;
    for (final side in [-1.0, 1.0]) {
      final elbow = hub + Offset(side * radius * 1.05 * spread, radius * 0.55);
      final tip = hub + Offset(side * radius * 0.62 * spread, radius * 1.45);
      canvas.drawPath(
        Path()
          ..moveTo(hub.dx + side * radius * 0.2, hub.dy + radius * 0.1)
          ..quadraticBezierTo(elbow.dx, elbow.dy - radius * 0.3, elbow.dx, elbow.dy)
          ..quadraticBezierTo(elbow.dx, tip.dy - radius * 0.2, tip.dx, tip.dy),
        metal,
      );
    }

    // Glass shine.
    canvas.drawPath(
      Path()
        ..moveTo(glass.left + glass.width * 0.05, glass.top)
        ..lineTo(glass.left + glass.width * 0.22, glass.top)
        ..lineTo(glass.left + glass.width * 0.02, glass.top + glass.height * 0.45)
        ..lineTo(glass.left, glass.top + glass.height * 0.3)
        ..close(),
      Paint()..color = const Color(0x40FFFFFF),
    );
    canvas.restore();
    canvas.drawRRect(
      glassR,
      Paint()
        ..color = AppColors.tan
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );

    // Control panel with the prize door under the chute.
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, h * 0.83, w * 0.94, h * 0.955),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(panel, Paint()..color = AppColors.green);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(chuteCentre + w * 0.03, h * 0.893),
          width: w * 0.2,
          height: h * 0.075,
        ),
        Radius.circular(w * 0.02),
      ),
      Paint()..color = AppColors.ink.withValues(alpha: 0.7),
    );
    // A joystick and two buttons, purely decorative.
    canvas.drawCircle(Offset(w * 0.56, h * 0.893), w * 0.035, Paint()..color = AppColors.tan);
    canvas.drawCircle(Offset(w * 0.56, h * 0.873), w * 0.022, Paint()..color = AppColors.alert);
    canvas.drawCircle(Offset(w * 0.72, h * 0.893), w * 0.03, Paint()..color = AppColors.gold);
    canvas.drawCircle(Offset(w * 0.83, h * 0.893), w * 0.03, Paint()..color = AppColors.white);
  }

  void _capsule(Canvas canvas, Offset c, double r, Prize prize, {double opacity = 1}) {
    final colour = colourFor(prize).withValues(alpha: opacity);
    final bounds = Rect.fromCircle(center: c, radius: r);

    // Shadow, lower half (white), upper half (colour), seam, shine.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 0.95), width: r * 1.5, height: r * 0.3),
      Paint()..color = AppColors.ink.withValues(alpha: 0.12 * opacity),
    );
    canvas.drawArc(
      bounds,
      0,
      math.pi,
      true,
      Paint()..color = AppColors.white.withValues(alpha: opacity),
    );
    canvas.drawArc(bounds, math.pi, math.pi, true, Paint()..color = colour);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.35 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07,
    );
    canvas.drawLine(
      c - Offset(r, 0),
      c + Offset(r, 0),
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.3 * opacity)
        ..strokeWidth = r * 0.07,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.38, -r * 0.5), width: r * 0.45, height: r * 0.26),
      Paint()..color = AppColors.white.withValues(alpha: 0.7 * opacity),
    );
    if (prize.rare) {
      canvas.drawPath(
        StarPainter.starPath(c + Offset(0, r * 0.45), r * 0.36),
        Paint()..color = AppColors.gold.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(ClawMachinePainter oldDelegate) => true;
}
