import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/brand/baobao.webp',
                  width: 160,
                  height: 160,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(l10n.unlockTitle, style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(height: 8),
                Text(l10n.unlockBody, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (_failed) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.unlockFailed,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                BambooButton(
                  label: l10n.unlockAction,
                  icon: Icons.lock_open_rounded,
                  onPressed: _busy ? null : _unlock,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
