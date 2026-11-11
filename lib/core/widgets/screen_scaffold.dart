import 'package:baobao/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The frame for every screen other than home: a back button, a title, an
/// optional trailing widget, and the content below.
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
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.ink,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
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
}
