import 'dart:math' as math;

import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// An amount of ✷, BaoBao's currency: a drawn star followed by the number.
///
/// The star is painted rather than typed so it looks the same on every
/// device, whatever fonts are installed.
class StarAmount extends StatelessWidget {
  const StarAmount(this.amount, {super.key, this.style, this.prefix = ''});

  final int amount;
  final TextStyle? style;

  /// Text placed before the number, such as "+" for a reward.
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? Theme.of(context).textTheme.titleMedium!;
    final size = (resolved.fontSize ?? 16) * MediaQuery.textScalerOf(context).scale(1) * 1.05;
    return Semantics(
      label: '$prefix${AppLocalizations.of(context).balanceLabel(amount)}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarIcon(size: size),
          const SizedBox(width: 4),
          Text('$prefix$amount', style: resolved),
        ],
      ),
    );
  }
}

/// The eight-pointed ✷ star.
class StarIcon extends StatelessWidget {
  const StarIcon({super.key, this.size = 18, this.color = AppColors.gold});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: StarPainter(color));
}

class StarPainter extends CustomPainter {
  const StarPainter(this.color);

  final Color color;

  static Path starPath(Offset center, double radius, {int points = 8, double inner = 0.48}) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size.center(Offset.zero), size.shortestSide / 2);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.07
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(StarPainter old) => old.color != color;
}
