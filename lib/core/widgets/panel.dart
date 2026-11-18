import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:flutter/material.dart';

enum PanelTone {
  /// The ordinary surface.
  normal,

  /// Something chosen or in use.
  selected,
}

/// A plain rounded surface with a thin border: the container for cards, list
/// rows, chips, and groups of settings.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.l),
    this.tone = PanelTone.normal,
    this.radius = Corners.m,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final PanelTone tone;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // A Material, not a plain box, so list tiles and ink splashes inside a
    // panel draw correctly on top of its colour.
    return Material(
      color: tone == PanelTone.selected ? p.panelSelected : p.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: p.border, width: Sizes.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
