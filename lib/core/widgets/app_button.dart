import 'dart:async';

import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ButtonKind {
  /// The main action on a screen: bamboo frame, green fill. One per screen.
  primary,

  /// Any other action: a plain bordered panel.
  secondary,

  /// A low-key action such as "Cancel" or "End chat": text only.
  quiet,
}

/// The app's button. Clicks, dips when pressed, shows a focus ring for
/// keyboard and switch users, and tells screen readers what it is.
class AppButton extends ConsumerStatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.primary,
    this.icon,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final Glyph? icon;

  /// Whether to fill the available width.
  final bool expand;

  /// What a screen reader says, when it should differ from [label].
  final String? semanticLabel;

  @override
  ConsumerState<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends ConsumerState<AppButton> {
  bool _pressed = false;
  bool _focusRing = false;

  bool get _enabled => widget.onPressed != null;

  void _activate() {
    unawaited(ref.read(audioDirectorProvider).click());
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final still = reduceMotion(context, ref);

    final (fill, textColor) = switch (widget.kind) {
      ButtonKind.primary => (p.fillPrimary, p.onFillPrimary),
      ButtonKind.secondary => (p.panel, p.ink),
      ButtonKind.quiet => (null, p.primary),
    };
    final label = Text(
      widget.label,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: textColor),
      textAlign: TextAlign.center,
    );
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          AppIcon(widget.icon!, size: 20, color: textColor),
          const SizedBox(width: Space.s),
        ],
        Flexible(child: label),
      ],
    );

    final Widget body = switch (widget.kind) {
      ButtonKind.primary => BambooFrame(
        fill: fill,
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.xs),
        child: Center(widthFactor: widget.expand ? null : 1, heightFactor: 1, child: content),
      ),
      ButtonKind.secondary => DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: Corners.medium,
          border: Border.all(color: p.border, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
          child: Center(widthFactor: widget.expand ? null : 1, heightFactor: 1, child: content),
        ),
      ),
      ButtonKind.quiet => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
        child: Center(widthFactor: widget.expand ? null : 1, heightFactor: 1, child: content),
      ),
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      focusable: _enabled ? true : null,
      focused: _enabled ? _focusRing : null,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: _enabled ? _activate : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (show) => setState(() => _focusRing = show),
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: _enabled ? _activate : null,
          child: AnimatedScale(
            scale: _pressed && !still ? 0.96 : 1,
            duration: const Duration(milliseconds: 90),
            child: Opacity(
              opacity: _enabled ? 1 : 0.5,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: widget.kind == ButtonKind.primary ? 52 : Sizes.touch,
                  minWidth: 64,
                ),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: widget.kind == ButtonKind.primary
                        ? BorderRadius.circular(20)
                        : Corners.medium,
                    border: _focusRing ? Border.all(color: p.primary, width: 3) : null,
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
