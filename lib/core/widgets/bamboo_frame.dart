import 'package:baobao/app/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// The signature BaoBao surface: a bamboo-coloured rim with small knots on
/// each side, around a flat panel of [fill].
class BambooFrame extends StatelessWidget {
  const BambooFrame({
    super.key,
    required this.child,
    this.fill = AppColors.offWhite,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  /// Thickness of the bamboo rim on the top, left and right.
  static const rim = 8.0;

  /// The rim is slightly deeper at the bottom, which reads as a soft shadow.
  static const rimBottom = 10.0;

  final Widget child;
  final Color fill;
  final double radius;

  /// Space between the inner panel's edge and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BambooFramePainter(fill: fill, radius: radius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(rim, rim, rim, rimBottom).add(padding),
        child: child,
      ),
    );
  }
}

class BambooFramePainter extends CustomPainter {
  const BambooFramePainter({required this.fill, required this.radius});

  final Color fill;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, Radius.circular(radius)),
      Paint()..color = AppColors.bambooEdge,
    );

    final cane = Rect.fromLTRB(2, 2, size.width - 2, size.height - 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cane, Radius.circular(radius - 2)),
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.bambooShade, AppColors.bambooLight, AppColors.bambooShade],
        ).createShader(cane),
    );

    final panel = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        BambooFrame.rim,
        BambooFrame.rim,
        size.width - BambooFrame.rim,
        size.height - BambooFrame.rimBottom,
      ),
      Radius.circular((radius - BambooFrame.rim).clamp(4, radius)),
    );
    canvas.drawRRect(panel, Paint()..color = fill);
    canvas.drawRRect(
      panel,
      Paint()
        ..color = AppColors.bambooLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Knots: short darker marks at the middle of each side of the rim.
    final knot = Paint()..color = AppColors.bambooKnot;
    const r = Radius.circular(2);
    final cx = size.width / 2, cy = size.height / 2;
    final long = (size.shortestSide * 0.3).clamp(12.0, 40.0);
    for (final rect in [
      Rect.fromCenter(center: Offset(cx, 4), width: long, height: 4),
      Rect.fromCenter(center: Offset(cx, size.height - 6), width: long, height: 4),
      Rect.fromCenter(center: Offset(4, cy), width: 4, height: long * 0.75),
      Rect.fromCenter(center: Offset(size.width - 4, cy), width: 4, height: long * 0.75),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, r), knot);
    }
  }

  @override
  bool shouldRepaint(BambooFramePainter old) => old.fill != fill || old.radius != radius;
}
