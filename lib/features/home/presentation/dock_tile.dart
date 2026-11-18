import 'dart:async';

import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A square-ish shortcut on the home dock: an icon over a short label, with an
/// optional small badge (such as the number of claw tries left).
class DockTile extends ConsumerWidget {
  const DockTile({
    super.key,
    required this.glyph,
    required this.label,
    required this.onTap,
    this.badge,
    this.semanticLabel,
    this.horizontal = false,
  });

  final Glyph glyph;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final String? semanticLabel;

  /// Icon beside the label, for narrow screens and large text.
  final bool horizontal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final text = Theme.of(context).textTheme.labelLarge!;

    final icon = Stack(
      clipBehavior: Clip.none,
      children: [
        AppIcon(glyph, size: 26, color: p.primary),
        if (badge != null)
          Positioned(
            right: -10,
            top: -8,
            child: DecoratedBox(
              decoration: BoxDecoration(color: p.gold, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: Text(badge!, style: text.copyWith(fontSize: 12, color: p.onFillPrimary)),
              ),
            ),
          ),
      ],
    );

    final content = horizontal
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: Space.s),
                child: icon,
              ),
              const SizedBox(width: Space.s),
              Expanded(child: Text(label, style: text)),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: Space.xs + 2),
              Text(label, style: text, textAlign: TextAlign.center),
            ],
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Corners.medium,
          onTap: () {
            unawaited(ref.read(audioDirectorProvider).click());
            onTap();
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: horizontal ? Sizes.touch + 4 : 76),
            child: Panel(
              padding: EdgeInsets.symmetric(
                horizontal: Space.m,
                vertical: horizontal ? Space.s : Space.m,
              ),
              child: Center(heightFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
