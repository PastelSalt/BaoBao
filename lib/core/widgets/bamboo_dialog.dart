import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:flutter/material.dart';

/// Shows a dialog in the bamboo style. [actions] are laid out in a row and
/// wrap when they do not fit.
Future<T?> showBambooDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => BambooDialog(title: title, content: content, actions: actions),
  );
}

class BambooDialog extends StatelessWidget {
  const BambooDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: BambooFrame(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(Space.l, Space.l, Space.l, Space.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Space.m),
              Flexible(child: SingleChildScrollView(child: content)),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: Space.l),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Space.m,
                  runSpacing: Space.s,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
