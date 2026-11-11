import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_background.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/core/widgets/typewriter_text.dart';
import 'package:baobao/features/claw_machine/application/claw_tries_provider.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/customization/presentation/customize_sheet.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/home/application/home_controller.dart';
import 'package:baobao/features/mood/presentation/mood_sheet.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// BaoBao's home: check in, talk, and reach everything else.
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
            BambooButton(label: l10n.actionClose, onPressed: () => Navigator.of(context).pop()),
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

    return Scaffold(
      body: AppBackground(
        asset: selections[ItemSlot.background]!.asset,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                // Fills the screen normally; scrolls instead of overflowing
                // when text is very large or the screen very small.
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const _StatusBar(),
                          const SizedBox(height: 12),
                          SpeechBubble(
                            child: TypewriterText(home.line, key: ValueKey(home.lineId)),
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 150),
                              child: Semantics(
                                button: !home.inConversation,
                                hint: home.inConversation ? null : l10n.homeCheckInHint,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: home.inConversation || _busy ? null : _checkIn,
                                  child: CharacterView(
                                    outfitAsset: selections[ItemSlot.outfit]!.asset,
                                    pose: home.pose,
                                    semanticLabel: l10n.characterLabel,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (home.inConversation)
                            _ConversationPanel(
                              home: home,
                              enabled: !_busy,
                              nudgeLabel: home.nudge == null
                                  ? null
                                  : _nudgeLabel(l10n, home.nudge!),
                              onChoose: _choose,
                              onNudge: () => _followNudge(home.nudge!),
                              onLeave: () => _guarded(_controller.leaveConversation),
                            )
                          else
                            _IdlePanel(
                              enabled: !_busy,
                              onCheckIn: _checkIn,
                              onQuick: _controller.quick,
                            ),
                        ],
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

class _StatusBar extends ConsumerWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(activeProfileProvider).value?.displayName;
    final balance = ref.watch(balanceProvider).value;
    final mood = ref.watch(latestMoodProvider).value;

    return Row(
      children: [
        Expanded(
          child: name == null
              ? const SizedBox()
              : Semantics(
                  header: true,
                  child: Text(
                    l10n.homeGreetingName(name),
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
        if (mood != null) ...[
          Semantics(
            label: l10n.homeLastMood(moodLabel(l10n, mood)),
            child: Image.asset(moodAsset(mood), width: 36, height: 36, excludeFromSemantics: true),
          ),
          const SizedBox(width: 8),
        ],
        if (balance != null)
          BambooFrame(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: StarAmount(balance),
          ),
        IconButton(
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(Icons.settings_rounded),
          color: AppColors.ink,
          tooltip: l10n.settingsTitle,
        ),
      ],
    );
  }
}

class _IdlePanel extends ConsumerWidget {
  const _IdlePanel({required this.enabled, required this.onCheckIn, required this.onQuick});

  final bool enabled;
  final VoidCallback onCheckIn;
  final ValueChanged<QuickAction> onQuick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tries = ref.watch(clawTriesProvider).value?.tries;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BambooButton(
          label: l10n.homeCheckIn,
          icon: Icons.favorite_rounded,
          expand: true,
          onPressed: enabled ? onCheckIn : null,
        ),
        const SizedBox(height: 8),
        _ButtonRow(
          children: [
            BambooButton(
              label: l10n.quickJoke,
              tone: BambooButtonTone.paleGreen,
              expand: true,
              onPressed: enabled ? () => onQuick(QuickAction.joke) : null,
            ),
            BambooButton(
              label: l10n.quickAffirmation,
              tone: BambooButtonTone.paleGreen,
              expand: true,
              onPressed: enabled ? () => onQuick(QuickAction.affirmation) : null,
            ),
            BambooButton(
              label: l10n.quickSelfCare,
              tone: BambooButtonTone.paleGreen,
              expand: true,
              onPressed: enabled ? () => onQuick(QuickAction.selfCare) : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ButtonRow(
          children: [
            BambooButton(
              label: l10n.navShop,
              icon: Icons.storefront_rounded,
              tone: BambooButtonTone.tan,
              expand: true,
              onPressed: () => context.push(Routes.shop),
            ),
            BambooButton(
              label: tries == null ? l10n.navClaw : l10n.navClawTries(tries),
              icon: Icons.sports_esports_rounded,
              tone: BambooButtonTone.tan,
              expand: true,
              onPressed: () => context.push(Routes.claw),
            ),
            BambooButton(
              label: l10n.navCustomize,
              icon: Icons.palette_rounded,
              tone: BambooButtonTone.tan,
              expand: true,
              onPressed: () => showCustomizeSheet(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lays buttons out side by side, or stacked when text is large or the screen
/// narrow, so labels are never squeezed.
class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Decided from the screen width rather than a LayoutBuilder, because the
    // scrollable home layout needs to measure this row's natural height.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final width = MediaQuery.sizeOf(context).width.clamp(0.0, 640.0) - 32;
    if (width / children.length < 104 * scale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            child,
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: child),
          ],
        ],
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({
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

  static const _tones = [
    BambooButtonTone.green,
    BambooButtonTone.lightGreen,
    BambooButtonTone.tan,
    BambooButtonTone.paleGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nudgeLabel != null) ...[
          Align(
            child: ActionChip(
              avatar: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.ink),
              label: Text(nudgeLabel!),
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.gold, width: 2),
              onPressed: enabled ? onNudge : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
        for (final (i, option) in home.options.indexed) ...[
          BambooButton(
            key: ValueKey('${home.lineId}-$i'),
            label: option.text,
            tone: _tones[i % _tones.length],
            expand: true,
            onPressed: enabled ? () => onChoose(option) : null,
          ),
          const SizedBox(height: 8),
        ],
        TextButton(onPressed: enabled ? onLeave : null, child: Text(l10n.homeLeaveChat)),
      ],
    );
  }
}
