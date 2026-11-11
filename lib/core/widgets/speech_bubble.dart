import 'package:baobao/app/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// The bubble BaoBao's words appear in, with a tail pointing down to the character.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.child});

  static const _tail = 12.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 14 + _tail), child: child),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tail = SpeechBubble._tail;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - tail - 2),
      const Radius.circular(18),
    );
    final cx = size.width / 2;
    final bottom = size.height - tail - 1;
    final path = Path()
      ..addRRect(body)
      ..moveTo(cx - tail, bottom)
      ..lineTo(cx, size.height - 1)
      ..lineTo(cx + tail, bottom)
      ..close();
    final outline = Path.combine(PathOperation.union, Path()..addRRect(body), path);

    canvas.drawPath(outline, Paint()..color = AppColors.white);
    canvas.drawPath(
      outline,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;
}
