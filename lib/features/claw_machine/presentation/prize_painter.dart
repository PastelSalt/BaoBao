import 'dart:math' as math;

import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:flutter/painting.dart';

/// Draws the prizes: small flat toys with soft shading, each fitting inside a
/// circle of the given radius.
abstract final class PrizePainter {
  static void paint(
    Canvas canvas,
    PrizeKind kind,
    Offset c,
    double r, {
    double opacity = 1,
    double tilt = 0,
  }) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    switch (kind) {
      case PrizeKind.apple:
        _apple(canvas, r, opacity);
      case PrizeKind.carrot:
        _carrot(canvas, r, opacity);
      case PrizeKind.grape:
        _grape(canvas, r, opacity);
      case PrizeKind.strawberry:
        _strawberry(canvas, r, opacity);
      case PrizeKind.bamboo:
        _bamboo(canvas, r, opacity);
      case PrizeKind.goldenStar:
        _goldenStar(canvas, r, opacity);
    }
    canvas.restore();
  }

  static Paint _paint(Color color, double opacity) =>
      Paint()..color = color.withValues(alpha: color.a * opacity);

  static void _shine(Canvas canvas, Offset at, double r, double opacity) {
    canvas.drawOval(
      Rect.fromCenter(center: at, width: r * 0.34, height: r * 0.2),
      _paint(const Color(0xB3FFFFFF), opacity),
    );
  }

  static void _leaf(
    Canvas canvas,
    Offset from,
    double length,
    double angle,
    Color color,
    double opacity,
  ) {
    canvas.save();
    canvas.translate(from.dx, from.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..quadraticBezierTo(length * 0.5, -length * 0.42, length, 0)
        ..quadraticBezierTo(length * 0.5, length * 0.22, 0, 0),
      _paint(color, opacity),
    );
    canvas.restore();
  }

  static void _apple(Canvas canvas, double r, double o) {
    final body = Path()
      ..moveTo(0, -r * 0.55)
      ..cubicTo(r * 0.35, -r * 0.95, r * 1.05, -r * 0.5, r * 0.95, r * 0.15)
      ..cubicTo(r * 0.85, r * 0.8, r * 0.35, r * 1.0, 0, r * 0.88)
      ..cubicTo(-r * 0.35, r * 1.0, -r * 0.85, r * 0.8, -r * 0.95, r * 0.15)
      ..cubicTo(-r * 1.05, -r * 0.5, -r * 0.35, -r * 0.95, 0, -r * 0.55)
      ..close();
    canvas.drawPath(body, _paint(const Color(0xFFE5484D), o));
    canvas.drawPath(
      Path()
        ..moveTo(r * 0.75, r * 0.5)
        ..cubicTo(r * 0.5, r * 0.95, r * 0.1, r * 1.0, 0, r * 0.88)
        ..cubicTo(r * 0.4, r * 0.85, r * 0.7, r * 0.6, r * 0.75, r * 0.5)
        ..close(),
      _paint(const Color(0x33000000), o),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -r * 0.62), width: r * 0.14, height: r * 0.4),
        Radius.circular(r * 0.07),
      ),
      _paint(const Color(0xFF6B4A2B), o),
    );
    _leaf(canvas, Offset(r * 0.04, -r * 0.7), r * 0.6, -0.5, const Color(0xFF5DAE4B), o);
    _shine(canvas, Offset(-r * 0.45, -r * 0.2), r, o);
  }

  static void _carrot(Canvas canvas, double r, double o) {
    for (final angle in [-0.55, 0.0, 0.55]) {
      _leaf(
        canvas,
        Offset(0, -r * 0.55),
        r * 0.75,
        -math.pi / 2 + angle,
        const Color(0xFF58B04A),
        o,
      );
    }
    final body = Path()
      ..moveTo(-r * 0.5, -r * 0.55)
      ..quadraticBezierTo(0, -r * 0.8, r * 0.5, -r * 0.55)
      ..quadraticBezierTo(r * 0.55, r * 0.2, 0, r * 1.02)
      ..quadraticBezierTo(-r * 0.55, r * 0.2, -r * 0.5, -r * 0.55)
      ..close();
    canvas.drawPath(body, _paint(const Color(0xFFF28C28), o));
    final ridge = _paint(const Color(0x40B25A00), o)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    for (final (y, half) in [(-0.2, 0.3), (0.12, 0.22), (0.42, 0.14)]) {
      canvas.drawLine(Offset(-r * half, r * y), Offset(r * half * 0.2, r * y + r * 0.04), ridge);
    }
    _shine(canvas, Offset(-r * 0.2, -r * 0.3), r, o);
  }

  static void _grape(Canvas canvas, double r, double o) {
    final colour = _paint(const Color(0xFF8E5BD6), o);
    final dark = _paint(const Color(0xFF6C3FB4), o);
    final berry = r * 0.3;
    final spots = <Offset>[
      Offset(-r * 0.5, -r * 0.25),
      Offset(0, -r * 0.3),
      Offset(r * 0.5, -r * 0.25),
      Offset(-r * 0.25, r * 0.12),
      Offset(r * 0.25, r * 0.12),
      Offset(0, r * 0.5),
      Offset(-r * 0.02, r * 0.88),
    ];
    for (final spot in spots) {
      canvas.drawCircle(spot + Offset(r * 0.02, r * 0.03), berry, dark);
    }
    for (final spot in spots) {
      canvas.drawCircle(spot, berry, colour);
      _shine(canvas, spot + Offset(-berry * 0.35, -berry * 0.4), r * 0.55, o);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -r * 0.7), width: r * 0.12, height: r * 0.34),
        Radius.circular(r * 0.06),
      ),
      _paint(const Color(0xFF6B4A2B), o),
    );
    _leaf(canvas, Offset(r * 0.04, -r * 0.72), r * 0.6, -0.35, const Color(0xFF5DAE4B), o);
  }

  static void _strawberry(Canvas canvas, double r, double o) {
    final body = Path()
      ..moveTo(0, -r * 0.7)
      ..cubicTo(r * 0.9, -r * 0.75, r * 1.05, -r * 0.05, r * 0.6, r * 0.55)
      ..quadraticBezierTo(r * 0.25, r * 1.02, 0, r * 1.02)
      ..quadraticBezierTo(-r * 0.25, r * 1.02, -r * 0.6, r * 0.55)
      ..cubicTo(-r * 1.05, -r * 0.05, -r * 0.9, -r * 0.75, 0, -r * 0.7)
      ..close();
    canvas.drawPath(body, _paint(const Color(0xFFE63B5A), o));
    final seed = _paint(const Color(0xFFFFE08A), o);
    for (final (x, y) in [
      (-0.4, -0.2),
      (0.0, -0.3),
      (0.4, -0.2),
      (-0.22, 0.15),
      (0.22, 0.15),
      (0.0, 0.5),
      (-0.5, 0.25),
      (0.5, 0.25),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(r * x, r * y), width: r * 0.1, height: r * 0.16),
        seed,
      );
    }
    for (final angle in [-0.9, -0.45, 0.0, 0.45, 0.9]) {
      _leaf(
        canvas,
        Offset(0, -r * 0.66),
        r * 0.5,
        -math.pi / 2 + angle,
        const Color(0xFF58B04A),
        o,
      );
    }
    _shine(canvas, Offset(-r * 0.5, -r * 0.35), r, o);
  }

  static void _bamboo(Canvas canvas, double r, double o) {
    final stalk = _paint(const Color(0xFF86C75F), o);
    final node = _paint(const Color(0xFF4E8F3E), o);
    final width = r * 0.62;
    for (final (top, height) in [
      (-r * 0.98, r * 0.62),
      (-r * 0.28, r * 0.62),
      (r * 0.42, r * 0.58),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-width / 2, top, width, height),
          Radius.circular(r * 0.14),
        ),
        stalk,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-width / 2 + r * 0.08, top + r * 0.06, width * 0.18, height - r * 0.12),
          Radius.circular(r * 0.05),
        ),
        _paint(const Color(0x66FFFFFF), o),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-width / 2 - r * 0.04, top + height - r * 0.04, width + r * 0.08, r * 0.1),
          Radius.circular(r * 0.04),
        ),
        node,
      );
    }
    _leaf(canvas, Offset(width / 2, -r * 0.3), r * 0.7, -0.5, const Color(0xFF5DAE4B), o);
    _leaf(canvas, Offset(-width / 2, r * 0.4), r * 0.6, math.pi + 0.5, const Color(0xFF5DAE4B), o);
  }

  static void _goldenStar(Canvas canvas, double r, double o) {
    canvas.drawCircle(Offset.zero, r * 1.25, _paint(const Color(0x40FFD54F), o));
    final star = StarPainter.starPath(Offset.zero, r * 1.02, inner: 0.52);
    canvas.drawPath(star, _paint(const Color(0xFFFFD54F), o));
    canvas.drawPath(
      star,
      _paint(const Color(0xFFD99A00), o)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      StarPainter.starPath(Offset.zero, r * 0.5, inner: 0.5),
      _paint(const Color(0x66FFFFFF), o),
    );
    _shine(canvas, Offset(-r * 0.3, -r * 0.35), r, o);
  }
}
