import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Finds layout faults on the screen currently shown: text broken in the
/// middle of a word, and text drawn outside the screen.
///
/// Overflow errors (yellow-and-black stripes) are reported separately by
/// `tester.takeException()`.
List<String> layoutProblems(WidgetTester tester) {
  final problems = <String>[];
  final screen = Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);

  void visit(RenderObject node) {
    if (node is RenderParagraph && node.attached && node.hasSize) {
      problems.addAll(_midWordBreaks(node));
    }
    node.visitChildren(visit);
  }

  for (final view in tester.binding.renderViews) {
    view.visitChildren(visit);
  }

  // Text may scroll off the bottom of a list, but never sideways.
  void visitSides(RenderObject node) {
    if (node is RenderParagraph && node.attached && node.hasSize) {
      final box = node.localToGlobal(Offset.zero) & node.size;
      final text = node.text.toPlainText().trim();
      if (text.isNotEmpty &&
          box.overlaps(screen) &&
          (box.left < -1 || box.right > screen.right + 1)) {
        problems.add('text runs off the side of the screen: "${_short(text)}"');
      }
    }
    node.visitChildren(visitSides);
  }

  for (final view in tester.binding.renderViews) {
    view.visitChildren(visitSides);
  }
  return problems;
}

/// Reports [finder] if any part of it lies outside the screen.
List<String> notFullyVisible(WidgetTester tester, Finder finder, String what) {
  if (finder.evaluate().isEmpty) return ['$what is missing'];
  final box = tester.getRect(finder.first);
  final screen = Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);
  if (box.top < -0.5 ||
      box.left < -0.5 ||
      box.bottom > screen.bottom + 0.5 ||
      box.right > screen.right + 0.5) {
    return ['$what is cut off by the screen edge (it is at $box, the screen is $screen)'];
  }
  return const [];
}

/// Reports a pair of widgets that overlap.
List<String> overlapping(WidgetTester tester, Finder a, Finder b, String what) {
  if (a.evaluate().isEmpty || b.evaluate().isEmpty) return const [];
  final ra = tester.getRect(a.first), rb = tester.getRect(b.first);
  final overlap = ra.intersect(rb);
  if (overlap.width > 1 && overlap.height > 1) return ['$what overlap ($ra and $rb)'];
  return const [];
}

List<String> _midWordBreaks(RenderParagraph paragraph) {
  final text = paragraph.text.toPlainText(includePlaceholders: false);
  if (text.length < 2 || text.length > 600) return const [];

  // Where each character is drawn. A character that sits lower than the one
  // before it has started a new line.
  double? topOf(int index) {
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: index, extentOffset: index + 1),
    );
    return boxes.isEmpty ? null : boxes.first.top;
  }

  final found = <String>[];
  double? previousTop;
  for (var i = 0; i < text.length; i++) {
    if (!_wordChar.hasMatch(text[i])) {
      previousTop = null;
      continue;
    }
    final top = topOf(i);
    if (top == null) continue;
    if (previousTop != null && top > previousTop + 2) {
      found.add(
        '"${_short(text)}" is broken in the middle of a word: '
        '"${text.substring((i - 6).clamp(0, i), i)}|${text.substring(i, (i + 6).clamp(i, text.length))}"',
      );
    }
    previousTop = top;
  }
  return found;
}

String _short(String s) => s.length <= 40 ? s : '${s.substring(0, 37)}…';
