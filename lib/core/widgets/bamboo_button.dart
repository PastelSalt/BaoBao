import 'dart:async';

import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BambooButtonTone {
  green(AppColors.green),
  lightGreen(AppColors.lightGreen),
  paleGreen(AppColors.paleGreen),
  tan(AppColors.tan),
  cream(AppColors.offWhite);

  const BambooButtonTone(this.fill);
  final Color fill;
}

/// The standard button: a bamboo frame that dips when pressed and clicks.
class BambooButton extends ConsumerStatefulWidget {
  const BambooButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = BambooButtonTone.green,
    this.icon,
    this.expand = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final BambooButtonTone tone;
  final IconData? icon;

  /// Whether to fill the available width.
  final bool expand;

  @override
  ConsumerState<BambooButton> createState() => _BambooButtonState();
}

class _BambooButtonState extends ConsumerState<BambooButton> {
  bool _pressed = false;
  bool _focusRing = false;

  bool get _enabled => widget.onPressed != null;

  void _activate() {
    unawaited(ref.read(audioDirectorProvider).click());
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context, ref);
    final style = Theme.of(context).textTheme.labelLarge!
        .copyWith(fontSize: 16, color: AppColors.ink);

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: AppColors.ink),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(widget.label, style: style, textAlign: TextAlign.center),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      focusable: _enabled ? true : null,
      focused: _enabled ? _focusRing : null,
      label: widget.label,
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
                constraints: const BoxConstraints(minHeight: 52, minWidth: 64),
                child: DecoratedBox(
                  // Shown only for keyboard and switch navigation.
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: _focusRing ? Border.all(color: AppColors.deepGreen, width: 3) : null,
                  ),
                  child: BambooFrame(
                    fill: widget.tone.fill,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      widthFactor: widget.expand ? null : 1,
                      heightFactor: 1,
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
