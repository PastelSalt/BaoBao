import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The frame for every screen other than home: a back button, a title, an
/// optional trailing widget, and the content below, in a centred column that
/// stays readable on tablets.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.background,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  /// Painted behind everything, edge to edge.
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Sizes.contentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.xs, Space.xs, Space.l, Space.xs),
                child: _header(context, trailing: trailing),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: background == null
          ? content
          : Stack(fit: StackFit.expand, children: [background!, content]),
    );
  }

  Widget _header(BuildContext context, {Widget? trailing}) {
    final titleWidget = Expanded(
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    final back = IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const AppIcon(Glyph.back),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: Sizes.touch, height: Sizes.touch),
    );

    // With very large text the title would be squeezed beside the trailing
    // widgets, so they move to a row of their own.
    if (trailing != null && MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [back, titleWidget]),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      );
    }
    return Row(children: [back, titleWidget, ?trailing]);
  }
}
