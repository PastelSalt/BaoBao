import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/core/widgets/screen_scaffold.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/application/claw_controller.dart';
import 'package:baobao/features/claw_machine/application/claw_tries_provider.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:baobao/features/claw_machine/presentation/claw_machine_painter.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The music that plays in the claw machine.
const clawMusicAsset = 'assets/audio/music/claw_machine.m4a';

final _clawStatsProvider = StreamProvider<ClawStat>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return const Stream.empty();
  return ref.watch(clawRepositoryProvider).watchStats(id);
});

class ClawMachineScreen extends ConsumerStatefulWidget {
  const ClawMachineScreen({super.key});

  @override
  ConsumerState<ClawMachineScreen> createState() => _ClawMachineScreenState();
}

class _ClawMachineScreenState extends ConsumerState<ClawMachineScreen>
    with SingleTickerProviderStateMixin {
  late final ClawController _controller;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  ClawResult? _celebrated;

  @override
  void initState() {
    super.initState();
    _controller = ClawController(
      profileId: ref.read(activeProfileIdProvider)!,
      repository: ref.read(clawRepositoryProvider),
      audio: ref.read(audioDirectorProvider),
      content: ref.read(contentProvider),
      clock: ref.read(clockProvider),
    )..addListener(_onChange);
    _ticker = createTicker((elapsed) {
      final dt = elapsed - _last;
      _last = elapsed;
      // A long pause (app in background) must not fast-forward the claw.
      _controller.advance(dt > const Duration(milliseconds: 100) ? Duration.zero : dt);
    })..start();
  }

  void _onChange() {
    final result = _controller.shownResult;
    if (result != null && !identical(result, _celebrated)) {
      _celebrated = result;
      if (result.won) HapticFeedback.mediumImpact();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  String _message(AppLocalizations l10n) => switch (_controller.notice) {
    ClawNotice.noTries => l10n.clawNoTries,
    ClawNotice.boughtTry => l10n.clawBoughtTry,
    ClawNotice.dailyLimit => l10n.clawDailyLimit,
    ClawNotice.notEnoughStars => l10n.clawNotEnough(ClawTries.tryPrice),
    null => _controller.line?.text ?? '',
  };

  String _controlLabel(AppLocalizations l10n, bool tapMode) => switch (_controller.game.phase) {
    ClawPhase.idle => tapMode ? l10n.clawTapToStart : l10n.clawHoldToMove,
    ClawPhase.moving => tapMode ? l10n.clawTapToDrop : l10n.clawReleaseToDrop,
    _ => l10n.clawWait,
  };

  void _showStats() {
    final l10n = AppLocalizations.of(context);
    final stats = ref.read(_clawStatsProvider).value;
    if (stats == null) return;
    showBambooDialog<void>(
      context: context,
      title: l10n.clawStatsTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatRow(l10n.clawStatsPlays, Text('${stats.plays}')),
          _StatRow(l10n.clawStatsWins, Text('${stats.wins}')),
          _StatRow(l10n.clawStatsEarnings, StarAmount(stats.earnings)),
          _StatRow(l10n.clawStatsBest, StarAmount(stats.bestWin)),
        ],
      ),
      actions: [AppButton(label: l10n.actionClose, onPressed: () => Navigator.of(context).pop())],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tapMode = ref.watch(settingsProvider.select((s) => s.clawTapMode));
    final tries = ref.watch(clawTriesProvider).value;
    // Kept warm so the stats dialog opens with numbers already loaded.
    ref.watch(_clawStatsProvider);
    final balance = ref.watch(balanceProvider).value;
    final now = ref.watch(clockProvider).now();
    final game = _controller.game;
    final result = _controller.shownResult;
    final busy = game.phase != ClawPhase.idle && game.phase != ClawPhase.moving;

    return ScreenScaffold(
      title: l10n.clawTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _showStats,
            icon: const AppIcon(Glyph.chart),
            tooltip: l10n.clawStatsTitle,
            constraints: const BoxConstraints.tightFor(width: Sizes.touch, height: Sizes.touch),
          ),
          if (balance != null)
            Panel(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.xs + 2),
              child: StarAmount(balance),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, Space.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.2),
              child: Semantics(
                liveRegion: true,
                child: Panel(
                  tone: PanelTone.selected,
                  padding: const EdgeInsets.all(Space.m),
                  // With very large text the line is trimmed (screen readers still
                  // hear all of it) so the machine keeps room to be seen.
                  child: Text(
                    _message(l10n),
                    textAlign: TextAlign.center,
                    maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.s),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.m,
              runSpacing: Space.s,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tries == null ? '' : l10n.clawTries(tries.tries),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (tries?.nextRefillAt != null)
                      Text(
                        l10n.clawNextTry(_countdown(tries!.nextRefillAt!.difference(now))),
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
                AppButton(
                  label: l10n.clawBuyTry(ClawTries.tryPrice),
                  kind: ButtonKind.secondary,
                  onPressed: tries == null || tries.purchasesLeft(now) <= 0
                      ? null
                      : _controller.buyTry,
                ),
              ],
            ),
            const SizedBox(height: Space.s),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Semantics(
                        image: true,
                        label: l10n.clawMachineLabel(game.prizes.where((p) => !p.taken).length),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: ClawMachinePainter(game, repaint: _controller),
                          ),
                        ),
                      ),
                      if (result != null) Center(child: _ResultBanner(result: result)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.m),
            _ControlButton(
              label: _controlLabel(l10n, tapMode),
              enabled: !busy,
              active: game.phase == ClawPhase.moving,
              tapMode: tapMode,
              onPress: _controller.press,
              onRelease: _controller.release,
              onTap: _controller.tap,
            ),
          ],
        ),
      ),
    );
  }

  static String _countdown(Duration d) {
    final seconds = d.isNegative ? 0 : d.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

/// The big button that drives the claw. In hold mode it starts on press and
/// drops on release; in tap mode, and always for screen readers, each
/// activation toggles.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.enabled,
    required this.active,
    required this.tapMode,
    required this.onPress,
    required this.onRelease,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool active;
  final bool tapMode;
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled && tapMode ? onTap : null,
        onTapDown: enabled && !tapMode ? (_) => onPress() : null,
        onTapUp: enabled && !tapMode ? (_) => onRelease() : null,
        onTapCancel: enabled && !tapMode ? onRelease : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: BambooFrame(
              fill: active ? context.palette.gold : context.palette.fillPrimary,
              child: Center(
                heightFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: context.palette.onFillPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result});

  final ClawResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: BambooFrame(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.won) ...[
              if (result.rare) Text(l10n.clawRare, style: theme.textTheme.labelLarge),
              StarAmount(result.payout, prefix: '+', style: theme.textTheme.headlineSmall),
              if (result.multiplier > 1)
                Text(
                  l10n.clawCombo(result.streak, result.multiplier.toString()),
                  style: theme.textTheme.bodyMedium,
                ),
            ] else
              Text(l10n.clawMissed, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          DefaultTextStyle.merge(style: Theme.of(context).textTheme.titleMedium, child: value),
        ],
      ),
    );
  }
}
