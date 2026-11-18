import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_background.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bao_stage.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/entrance.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/application/claw_tries_provider.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/customization/presentation/customize_sheet.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/home/application/home_controller.dart';
import 'package:baobao/features/home/presentation/cheer_sheet.dart';
import 'package:baobao/features/home/presentation/dock_tile.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/mood/presentation/mood_sheet.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// BaoBao's home: check in, talk, and reach everything else.
///
/// Three zones that never trade places: a top bar, the stage (BaoBao and what
/// BaoBao says), and the dock of actions at the bottom. The dock scrolls
/// inside itself if it must; the stage never scrolls away.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!ref.read(settingsProvider).tutorialSeen) {
        // First visit: the tour comes before the greeting.
        await context.push(Routes.tutorial);
      }
      if (mounted) _controller.speakGreeting();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode every pose up front so BaoBao never blinks out when the mood changes.
    final outfit =
        ref.read(selectionsProvider).value?[ItemSlot.outfit] ??
        ref.read(catalogProvider).defaultFor(ItemSlot.outfit);
    for (final pose in CharacterPose.values) {
      unawaited(
        precacheImage(
          AssetImage(CharacterView.assetFor(outfit.asset, pose)),
          context,
          onError: (_, _) {},
        ),
      );
    }
  }

  HomeController get _controller => ref.read(homeControllerProvider.notifier);

  /// Runs [action], ignoring further taps until it finishes.
  Future<void> _guarded(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkIn() async {
    final mood = await showMoodSheet(context);
    if (mood == null || !mounted) return;
    await _guarded(() => _controller.checkIn(mood));
  }

  Future<void> _cheerUp() async {
    final action = await showCheerSheet(context);
    if (action != null) _controller.quick(action);
  }

  Future<void> _choose(ConversationOption option) => _guarded(() async {
    final outcome = await _controller.choose(option);
    if (outcome == ChoiceOutcome.openResources && mounted) {
      await context.push(Routes.resources);
    }
  });

  Future<void> _followNudge(FeatureNudge nudge) async {
    final l10n = AppLocalizations.of(context);
    switch (nudge) {
      case FeatureNudge.clawMachine:
        await context.push(Routes.claw);
      case FeatureNudge.shop:
        await context.push(Routes.shop);
      case FeatureNudge.joke || FeatureNudge.affirmation || FeatureNudge.selfCare:
        final action = switch (nudge) {
          FeatureNudge.joke => QuickAction.joke,
          FeatureNudge.affirmation => QuickAction.affirmation,
          _ => QuickAction.selfCare,
        };
        // Shown in a dialog so the conversation underneath is not replaced.
        final line = _controller.peek(action);
        await showBambooDialog<void>(
          context: context,
          title: _nudgeLabel(l10n, nudge),
          content: Text(line.text, textAlign: TextAlign.center),
          actions: [
            AppButton(label: l10n.actionClose, onPressed: () => Navigator.of(context).pop()),
          ],
        );
    }
  }

  static String _nudgeLabel(AppLocalizations l10n, FeatureNudge nudge) => switch (nudge) {
    FeatureNudge.joke => l10n.nudgeJoke,
    FeatureNudge.affirmation => l10n.nudgeAffirmation,
    FeatureNudge.selfCare => l10n.nudgeSelfCare,
    FeatureNudge.clawMachine => l10n.nudgeClaw,
    FeatureNudge.shop => l10n.nudgeShop,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(catalogProvider);
    final selections =
        ref.watch(selectionsProvider).value ??
        {for (final slot in ItemSlot.values) slot: catalog.defaultFor(slot)};
    final home = ref.watch(homeControllerProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: AppBackground(
        asset: selections[ItemSlot.background]!.asset,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Sizes.contentWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, Space.m),
                child: Column(
                  children: [
                    const Entrance(child: _TopBar()),
                    const SizedBox(height: Space.s),
                    Expanded(
                      child: Entrance(
                        delay: const Duration(milliseconds: 90),
                        child: BaoStage(
                          text: home.line,
                          lineId: home.lineId,
                          pose: home.pose,
                          outfitAsset: selections[ItemSlot.outfit]!.asset,
                          characterLabel: l10n.characterLabel,
                          onCharacterTap: home.inConversation || _busy ? null : _checkIn,
                          badgeAsset: switch (home.mood) {
                            Mood.anxious || Mood.okay => moodAsset(home.mood!),
                            _ => null,
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.s),
                    Entrance(
                      delay: const Duration(milliseconds: 180),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * (home.inConversation ? 0.5 : 0.42),
                        ),
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: home.inConversation
                                ? _ConversationDock(
                                    home: home,
                                    enabled: !_busy,
                                    nudgeLabel: home.nudge == null
                                        ? null
                                        : _nudgeLabel(l10n, home.nudge!),
                                    onChoose: _choose,
                                    onNudge: () => _followNudge(home.nudge!),
                                    onLeave: () => _guarded(_controller.leaveConversation),
                                  )
                                : _IdleDock(
                                    enabled: !_busy,
                                    onCheckIn: _checkIn,
                                    onCheerUp: _cheerUp,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(activeProfileProvider).value?.displayName;
    final balance = ref.watch(balanceProvider).value;
    final mood = ref.watch(latestMoodProvider).value;

    final greeting = name == null
        ? const SizedBox.shrink()
        : Semantics(
            header: true,
            child: Text(
              l10n.homeGreetingName(name),
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
    final badges = <Widget>[
      if (mood != null)
        Padding(
          padding: const EdgeInsets.only(left: Space.s),
          child: Semantics(
            label: l10n.homeLastMood(moodLabel(l10n, mood)),
            child: Image.asset(moodAsset(mood), width: 32, height: 32, excludeFromSemantics: true),
          ),
        ),
      if (balance != null)
        Padding(
          padding: const EdgeInsets.only(left: Space.s),
          child: Panel(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.xs + 2),
            child: StarAmount(balance),
          ),
        ),
    ];
    final actions = [
      IconButton(
        onPressed: () => showCustomizeSheet(context),
        icon: const AppIcon(Glyph.sparkle),
        tooltip: l10n.navCustomize,
        constraints: const BoxConstraints.tightFor(width: Sizes.touch, height: Sizes.touch),
      ),
      IconButton(
        onPressed: () => context.push(Routes.settings),
        icon: const AppIcon(Glyph.settings),
        tooltip: l10n.settingsTitle,
        constraints: const BoxConstraints.tightFor(width: Sizes.touch, height: Sizes.touch),
      ),
    ];

    // With very large text the greeting gets a line of its own, so it is never
    // squeezed to nothing between the badges and the buttons.
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          greeting,
          Row(
            children: [
              ...badges.map(
                (b) => b is Padding ? Padding(padding: EdgeInsets.zero, child: b.child) : b,
              ),
              const Spacer(),
              ...actions,
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: greeting),
        ...badges,
        ...actions,
      ],
    );
  }
}

class _IdleDock extends ConsumerWidget {
  const _IdleDock({required this.enabled, required this.onCheckIn, required this.onCheerUp});

  final bool enabled;
  final VoidCallback onCheckIn;
  final VoidCallback onCheerUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tries = ref.watch(clawTriesProvider).value?.tries;

    return LayoutBuilder(
      builder: (context, box) {
        // Three tiles side by side while each has room for its label;
        // otherwise a stack of rows.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final stacked = box.maxWidth / 3 < 96 * scale;
        final tiles = [
          DockTile(
            glyph: Glyph.cheer,
            label: l10n.navCheer,
            horizontal: stacked,
            onTap: enabled ? onCheerUp : () {},
          ),
          DockTile(
            glyph: Glyph.shop,
            label: l10n.navShop,
            horizontal: stacked,
            onTap: () => context.push(Routes.shop),
          ),
          DockTile(
            glyph: Glyph.claw,
            label: l10n.navClaw,
            badge: tries?.toString(),
            semanticLabel: tries == null ? l10n.navClaw : l10n.navClawTries(tries),
            horizontal: stacked,
            onTap: () => context.push(Routes.claw),
          ),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: l10n.homeCheckIn,
              icon: Glyph.heart,
              expand: true,
              onPressed: enabled ? onCheckIn : null,
            ),
            const SizedBox(height: Space.s),
            if (stacked)
              for (final (i, tile) in tiles.indexed) ...[
                if (i > 0) const SizedBox(height: Space.s),
                tile,
              ]
            else
              Row(
                children: [
                  for (final (i, tile) in tiles.indexed) ...[
                    if (i > 0) const SizedBox(width: Space.s),
                    Expanded(child: tile),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ConversationDock extends StatelessWidget {
  const _ConversationDock({
    required this.home,
    required this.enabled,
    required this.nudgeLabel,
    required this.onChoose,
    required this.onNudge,
    required this.onLeave,
  });

  final HomeState home;
  final bool enabled;
  final String? nudgeLabel;
  final ValueChanged<ConversationOption> onChoose;
  final VoidCallback onNudge;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nudgeLabel != null) ...[
          Align(
            child: ActionChip(
              avatar: AppIcon(Glyph.sparkle, size: 18, color: p.ink),
              label: Text(nudgeLabel!),
              backgroundColor: p.panel,
              side: BorderSide(color: p.gold, width: 2),
              onPressed: enabled ? onNudge : null,
            ),
          ),
          const SizedBox(height: Space.s),
        ],
        for (final (i, option) in home.options.indexed) ...[
          AppButton(
            key: ValueKey('${home.lineId}-$i'),
            label: option.text,
            expand: true,
            onPressed: enabled ? () => onChoose(option) : null,
          ),
          const SizedBox(height: Space.s),
        ],
        AppButton(
          label: l10n.homeLeaveChat,
          kind: ButtonKind.quiet,
          onPressed: enabled ? onLeave : null,
        ),
      ],
    );
  }
}
