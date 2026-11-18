import 'package:baobao/app/theme/app_palette.dart';
import 'package:flutter/widgets.dart';

/// BaoBao's signature surface: a bamboo-coloured rim with small knots, around
/// a flat panel. Used sparingly, for the main action on a screen and for
/// dialogs. Everything else uses `Panel`.
class BambooFrame extends StatelessWidget {
  const BambooFrame({
    super.key,
    required this.child,
    this.fill,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  /// Thickness of the rim on the top, left and right.
  static const rim = 5.0;

  /// A little deeper at the bottom, which reads as a soft shadow.
  static const rimBottom = 7.0;

  final Widget child;

  /// The panel colour. Defaults to the palette's panel colour.
  final Color? fill;
  final double radius;

  /// Space between the inner panel's edge and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return CustomPaint(
      painter: BambooFramePainter(
        fill: fill ?? p.panel,
        radius: radius,
        rim: p.rim,
        light: p.rimLight,
        shade: p.rimShade,
        knot: p.knot,
        line: p.border,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(rim, rim, rim, rimBottom).add(padding),
        child: child,
      ),
    );
  }
}

class BambooFramePainter extends CustomPainter {
  const BambooFramePainter({
    required this.fill,
    required this.radius,
    required this.rim,
    required this.light,
    required this.shade,
    required this.knot,
    required this.line,
  });

  final Color fill;
  final double radius;
  final Color rim;
  final Color light;
  final Color shade;
  final Color knot;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(outer, Paint()..color = rim);

    final cane = Rect.fromLTRB(1.5, 1.5, size.width - 1.5, size.height - 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cane, Radius.circular(radius - 1.5)),
      Paint()..shader = LinearGradient(colors: [shade, light, shade]).createShader(cane),
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
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Knots: short darker marks at the middle of each side of the rim.
    final paint = Paint()..color = knot;
    const r = Radius.circular(1.5);
    final cx = size.width / 2, cy = size.height / 2;
    final long = (size.shortestSide * 0.28).clamp(10.0, 32.0);
    for (final rect in [
      Rect.fromCenter(center: Offset(cx, 2.8), width: long, height: 3),
      Rect.fromCenter(center: Offset(cx, size.height - 4), width: long, height: 3),
      Rect.fromCenter(center: Offset(2.8, cy), width: 3, height: long * 0.7),
      Rect.fromCenter(center: Offset(size.width - 2.8, cy), width: 3, height: long * 0.7),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, r), paint);
    }
  }

  @override
  bool shouldRepaint(BambooFramePainter old) =>
      old.fill != fill ||
      old.radius != radius ||
      old.rim != rim ||
      old.light != light ||
      old.shade != shade ||
      old.knot != knot ||
      old.line != line;
}
