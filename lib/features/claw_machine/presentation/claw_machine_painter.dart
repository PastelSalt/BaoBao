import 'dart:math' as math;

import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/presentation/prize_painter.dart';
import 'package:flutter/material.dart';

/// Draws the claw machine: a bamboo-green cabinet with a lit marquee, a glass
/// window, the claw on its rail, the prizes, the chute, and working controls.
///
/// Everything is laid out in fractions of the canvas, so it scales to any
/// size. The machine looks the same in light and dark themes, like a real one.
class ClawMachinePainter extends CustomPainter {
  ClawMachinePainter(this.game, {super.repaint});

  final ClawGame game;

  // Remembered between frames so the cable can swing as the claw moves.
  double _lastX = 0.5;
  double _sway = 0;

  static const _cabinetTop = Color(0xFF9ED27C);
  static const _cabinetBottom = Color(0xFF6BAA55);
  static const _cabinetEdge = Color(0xFF4A8441);
  static const _metal = Color(0xFF55604C);
  static const _metalLight = Color(0xFF8A9680);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    _cabinet(canvas, w, h);
    _marquee(canvas, w, h);

    final glass = Rect.fromLTRB(w * 0.07, h * 0.115, w * 0.93, h * 0.79);
    final glassR = RRect.fromRectAndRadius(glass, Radius.circular(w * 0.04));
    canvas.save();
    canvas.clipRRect(glassR);
    _interior(canvas, glass);
    _playfield(canvas, glass, w, h);
    canvas.restore();
    _glassFrame(canvas, glass, glassR, w);
    _panel(canvas, glass, w, h);
  }

  // ---- cabinet ---------------------------------------------------------

  void _cabinet(Canvas canvas, double w, double h) {
    final body = RRect.fromRectAndRadius(Offset.zero & Size(w, h), Radius.circular(w * 0.09));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cabinetTop, _cabinetBottom],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body.deflate(w * 0.006),
      Paint()
        ..color = _cabinetEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
    // Soft vertical sheen, like bamboo.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.018, h * 0.04, w * 0.018, h * 0.9),
        Radius.circular(w * 0.01),
      ),
      Paint()..color = const Color(0x40FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.964, h * 0.04, w * 0.018, h * 0.9),
        Radius.circular(w * 0.01),
      ),
      Paint()..color = const Color(0x22000000),
    );
  }

  void _marquee(Canvas canvas, double w, double h) {
    final sign = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.14, h * 0.022, w * 0.86, h * 0.092),
      Radius.circular(h * 0.03),
    );
    canvas.drawRRect(sign, Paint()..color = const Color(0xFFFFF6DD));
    canvas.drawRRect(
      sign,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.014,
    );
    // Lights along the sign blink in turn.
    final phase = (DateTime.now().millisecondsSinceEpoch ~/ 450) % 2;
    for (var i = 0; i < 9; i++) {
      final x = sign.left + sign.width * (i + 0.5) / 9;
      for (final y in [sign.top - w * 0.004, sign.bottom + w * 0.004]) {
        canvas.drawCircle(
          Offset(x, y),
          w * 0.01,
          Paint()..color = (i + phase).isEven ? AppColors.gold : const Color(0xFFE9C46A),
        );
      }
    }
    final text = TextPainter(
      text: TextSpan(
        text: 'BaoBao',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w700,
          fontSize: h * 0.05,
          color: const Color(0xFF3F6B2B),
          letterSpacing: w * 0.004,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(sign.center.dx - text.width / 2, sign.center.dy - text.height / 2));
    for (final side in [-1.0, 1.0]) {
      canvas.drawPath(
        StarPainter.starPath(
          Offset(sign.center.dx + side * (text.width / 2 + w * 0.07), sign.center.dy),
          h * 0.022,
        ),
        Paint()..color = AppColors.gold,
      );
    }
  }

  // ---- inside the glass ------------------------------------------------

  void _interior(Canvas canvas, Rect glass) {
    canvas.drawRect(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF7F1), Color(0xFFD3EBD3)],
        ).createShader(glass),
    );
    final stalk = Paint()..color = const Color(0xFF9ED27C).withValues(alpha: 0.28);
    for (final x in [0.16, 0.31, 0.7, 0.85]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(glass.left + glass.width * x, glass.top, glass.width * 0.04, glass.height),
          Radius.circular(glass.width * 0.02),
        ),
        stalk,
      );
    }
    // A string of little lights along the top.
    for (var i = 0; i < 12; i++) {
      final t = (i + 0.5) / 12;
      canvas.drawCircle(
        Offset(
          glass.left + glass.width * t,
          glass.top + glass.height * (0.018 + 0.014 * math.sin(t * math.pi * 3)),
        ),
        glass.width * 0.007,
        Paint()..color = (i.isEven ? const Color(0xFFFFE08A) : const Color(0xFFFFB4C2)),
      );
    }
  }

  void _playfield(Canvas canvas, Rect glass, double w, double h) {
    final floorTop = glass.bottom - glass.height * 0.115;
    double xAt(double f) => glass.left + glass.width * f;

    // Prize bed.
    final bed = Rect.fromLTRB(glass.left, floorTop, glass.right, glass.bottom);
    canvas.drawRect(
      bed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD9BC8C), Color(0xFFC1A06F)],
        ).createShader(bed),
    );
    for (var i = 1; i < 7; i++) {
      canvas.drawLine(
        Offset(bed.left, bed.top + bed.height * i / 7),
        Offset(bed.right, bed.top + bed.height * i / 7),
        Paint()
          ..color = const Color(0x22000000)
          ..strokeWidth = 1,
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(bed.left, bed.top, bed.right, bed.top + h * 0.006),
      Paint()..color = const Color(0x55FFFFFF),
    );

    // Chute at the left of the bed.
    final chuteCentre = xAt(ClawGame.chuteX);
    final chute = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        glass.left,
        floorTop + bed.height * 0.1,
        chuteCentre + glass.width * 0.085,
        glass.bottom,
      ),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(chute, Paint()..color = const Color(0xFF3B3F36));
    canvas.drawRRect(
      chute.deflate(w * 0.006),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2D26), Color(0xFF4A5042)],
        ).createShader(chute.outerRect),
    );
    final arrow = Paint()..color = AppColors.gold.withValues(alpha: 0.9);
    final ax = chute.center.dx, ay = chute.center.dy;
    canvas.drawPath(
      Path()
        ..moveTo(ax - w * 0.022, ay - h * 0.006)
        ..lineTo(ax + w * 0.022, ay - h * 0.006)
        ..lineTo(ax, ay + h * 0.022)
        ..close(),
      arrow,
    );

    final railY = glass.top + glass.height * 0.075;
    final restY = railY + glass.height * 0.15;
    final r = glass.width * Prize.defaultWidth * 0.46;
    final prizeY = floorTop + r * 0.1;
    final clawX = xAt(game.clawX);
    final depth = game.visualDepth;
    final clawY = restY + (prizeY - r * 1.35 - restY) * depth;

    // Shadows first, so everything sits on them.
    for (final prize in game.prizes) {
      if (prize.taken) continue;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(xAt(prize.x), prizeY + r * 0.95),
          width: r * 1.7,
          height: r * 0.34,
        ),
        Paint()..color = const Color(0x22000000),
      );
    }
    // The claw's shadow grows and darkens as it comes down.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(clawX, floorTop + bed.height * 0.4),
        width: r * (1.0 + depth * 1.4),
        height: r * (0.25 + depth * 0.2),
      ),
      Paint()..color = Color.fromARGB((20 + 60 * depth).round(), 0, 0, 0),
    );

    for (final prize in game.prizes) {
      if (prize.taken) continue;
      PrizePainter.paint(canvas, prize.kind, Offset(xAt(prize.x), prizeY), r);
    }

    // Rail and trolley.
    final rail = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        glass.left + w * 0.02,
        railY - h * 0.009,
        glass.right - w * 0.02,
        railY + h * 0.009,
      ),
      Radius.circular(h * 0.009),
    );
    canvas.drawRRect(rail, Paint()..color = _metalLight);
    canvas.drawRRect(rail.deflate(h * 0.003), Paint()..color = const Color(0xFFB7C2AD));
    final trolley = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(clawX, railY), width: w * 0.1, height: h * 0.034),
      Radius.circular(h * 0.012),
    );
    canvas.drawRRect(trolley, Paint()..color = _metal);
    canvas.drawRRect(trolley.deflate(h * 0.004), Paint()..color = const Color(0xFF6E7B64));

    // Swing: the cable lags a little behind the trolley.
    final velocity = game.clawX - _lastX;
    _lastX = game.clawX;
    _sway = (_sway * 0.86 + velocity * -9 * 0.14).clamp(-0.3, 0.3);
    final swing = game.phase == ClawPhase.moving || game.phase == ClawPhase.returning
        ? _sway
        : _sway * 0.5;

    canvas.save();
    canvas.translate(clawX, railY);
    canvas.rotate(swing);
    canvas.translate(-clawX, -railY);

    final cable = Paint()
      ..color = _metal
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round;
    final hub = Offset(clawX, clawY - r * 0.45);
    canvas.drawLine(Offset(clawX, railY), hub, cable);

    final held = game.held;
    final lifting =
        game.phase == ClawPhase.lifting ||
        game.phase == ClawPhase.returning ||
        game.phase == ClawPhase.releasing;
    final grip = held != null ? 0.5 : (game.phase == ClawPhase.lifting ? 0.78 : 1.0);
    // Closing happens over the start of the lift, not instantly.
    final closing = lifting ? ((1 - game.depth) / 0.15).clamp(0.0, 1.0) : 0.0;
    final spread = 1.0 + (grip - 1.0) * (game.phase == ClawPhase.lifting ? closing : 1.0);

    if (held != null) {
      final fall = game.releaseProgress;
      final centre = Offset(clawX, clawY + r * 0.95 + fall * (floorTop - clawY));
      PrizePainter.paint(
        canvas,
        held.kind,
        centre,
        r * (1 - 0.3 * fall),
        opacity: 1 - 0.7 * fall,
        tilt: fall * 0.6,
      );
    }
    _claw(canvas, hub, r, spread);
    canvas.restore();

    _burst(canvas, Offset(chuteCentre + glass.width * 0.02, floorTop), glass, w);
  }

  /// A hub with three jointed fingers. [spread] is 1 when open and smaller as it closes.
  void _claw(Canvas canvas, Offset hub, double r, double spread) {
    final finger = Paint()
      ..color = _metal
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = r * 0.2;
    final highlight = Paint()
      ..color = _metalLight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.06;

    for (final side in [-1.0, 1.0, 0.0]) {
      final out = side * r * 1.05 * spread;
      final elbow = hub + Offset(out, r * 0.6);
      final tip = hub + Offset(side * r * 0.55 * spread, r * 1.5);
      final path = Path()
        ..moveTo(hub.dx + side * r * 0.16, hub.dy + r * 0.12)
        ..quadraticBezierTo(elbow.dx, hub.dy + r * 0.12, elbow.dx, elbow.dy)
        ..quadraticBezierTo(elbow.dx, tip.dy - r * 0.15, tip.dx, tip.dy);
      canvas.drawPath(path, finger);
      canvas.drawPath(path, highlight);
      canvas.drawCircle(tip, r * 0.12, Paint()..color = _metalLight);
    }
    canvas.drawCircle(hub, r * 0.3, Paint()..color = _metal);
    canvas.drawCircle(
      hub,
      r * 0.3,
      Paint()
        ..color = const Color(0xFFB7C2AD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );
    canvas.drawCircle(hub, r * 0.1, Paint()..color = AppColors.gold);
  }

  /// A burst of stars from the chute when a prize is won.
  void _burst(Canvas canvas, Offset origin, Rect glass, double w) {
    final won = game.result?.won ?? false;
    if (!won || game.phase != ClawPhase.finished) return;
    final t = Curves.easeOut.transform(game.celebration);
    if (t >= 1) return;
    for (var i = 0; i < 16; i++) {
      final seed = (i * 7919 % 97) / 97;
      final angle = -math.pi * (0.12 + 0.76 * (i / 15)) + (seed - 0.5) * 0.4;
      final distance = glass.height * (0.22 + 0.32 * seed) * t;
      final at =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * distance +
          Offset(0, glass.height * 0.1 * t * t);
      final colour = [
        AppColors.gold,
        const Color(0xFFFFB4C2),
        Colors.white,
        const Color(0xFFA7D489),
      ][i % 4];
      canvas.drawPath(
        StarPainter.starPath(at, w * (0.014 + 0.012 * seed) * (1 - 0.4 * t), points: 4, inner: 0.4),
        Paint()..color = colour.withValues(alpha: (1 - t) * 0.95),
      );
    }
  }

  void _glassFrame(Canvas canvas, Rect glass, RRect glassR, double w) {
    // Reflection streaks.
    canvas.save();
    canvas.clipRRect(glassR);
    canvas.drawPath(
      Path()
        ..moveTo(glass.left + glass.width * 0.08, glass.top)
        ..lineTo(glass.left + glass.width * 0.2, glass.top)
        ..lineTo(glass.left, glass.top + glass.height * 0.4)
        ..lineTo(glass.left, glass.top + glass.height * 0.26)
        ..close(),
      Paint()..color = const Color(0x40FFFFFF),
    );
    canvas.drawPath(
      Path()
        ..moveTo(glass.left + glass.width * 0.26, glass.top)
        ..lineTo(glass.left + glass.width * 0.3, glass.top)
        ..lineTo(glass.left + glass.width * 0.06, glass.top + glass.height * 0.46)
        ..lineTo(glass.left + glass.width * 0.03, glass.top + glass.height * 0.4)
        ..close(),
      Paint()..color = const Color(0x26FFFFFF),
    );
    canvas.restore();
    canvas.drawRRect(
      glassR,
      Paint()
        ..color = const Color(0xFFCAAD7E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016,
    );
  }

  // ---- control panel ---------------------------------------------------

  void _panel(Canvas canvas, Rect glass, double w, double h) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.07, h * 0.815, w * 0.93, h * 0.96),
      Radius.circular(w * 0.035),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xFF4F8A45));
    canvas.drawRRect(panel.deflate(w * 0.008), Paint()..color = const Color(0xFF5E9B4C));

    // Prize door, under the chute.
    final door = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.1, h * 0.835, w * 0.33, h * 0.94),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(door, Paint()..color = const Color(0xFF2E3A2A));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.115, h * 0.85, w * 0.315, h * 0.925),
        Radius.circular(w * 0.015),
      ),
      Paint()..color = const Color(0xFF1F281C),
    );

    final moving = game.phase == ClawPhase.moving;

    // Joystick: its ball leans the way the claw is going.
    final base = Offset(w * 0.52, h * 0.9);
    canvas.drawCircle(base, w * 0.045, Paint()..color = const Color(0xFF3F6B2B));
    final lean = moving ? 0.8 * (game.clawX > 0.5 ? 1 : -1) : 0.0;
    final ball = base + Offset(lean * w * 0.015, -h * 0.03);
    canvas.drawLine(
      base,
      ball,
      Paint()
        ..color = _metal
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(ball, w * 0.032, Paint()..color = const Color(0xFFE5484D));
    canvas.drawCircle(
      ball + Offset(-w * 0.01, -w * 0.01),
      w * 0.009,
      Paint()..color = const Color(0x99FFFFFF),
    );

    // The big button: pressed in and lit while the claw is moving.
    final button = Offset(w * 0.72, h * 0.9);
    canvas.drawCircle(button, w * 0.052, Paint()..color = const Color(0xFF3F6B2B));
    canvas.drawCircle(
      button + Offset(0, moving ? h * 0.002 : -h * 0.004),
      w * 0.043,
      Paint()..color = moving ? AppColors.gold : const Color(0xFFF2B84B),
    );
    canvas.drawCircle(
      button + Offset(-w * 0.012, -w * 0.014 + (moving ? h * 0.006 : 0)),
      w * 0.01,
      Paint()..color = const Color(0x99FFFFFF),
    );

    // A coin slot, purely for looks.
    final slot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.86, h * 0.9), width: w * 0.035, height: h * 0.05),
      Radius.circular(w * 0.01),
    );
    canvas.drawRRect(slot, Paint()..color = const Color(0xFF2E3A2A));
    canvas.drawLine(
      Offset(w * 0.86, h * 0.885),
      Offset(w * 0.86, h * 0.915),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(ClawMachinePainter oldDelegate) => true;
}
