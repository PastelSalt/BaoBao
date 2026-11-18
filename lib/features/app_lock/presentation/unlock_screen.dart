import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shown instead of the app while it is locked.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Ask straight away, so unlocking is one touch rather than two.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    final ok = await ref
        .read(appLockProvider.notifier)
        .unlock(AppLocalizations.of(context).unlockReason);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/brand/baobao.webp',
                    width: 144,
                    height: 144,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: Space.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.unlockTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Space.s),
                  Text(l10n.unlockBody, textAlign: TextAlign.center),
                  const SizedBox(height: Space.xl),
                  if (_failed) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.unlockFailed,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: p.alert),
                      ),
                    ),
                    const SizedBox(height: Space.l),
                  ],
                  AppButton(
                    label: l10n.unlockAction,
                    icon: Glyph.unlock,
                    onPressed: _busy ? null : _unlock,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
