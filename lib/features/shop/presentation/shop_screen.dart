import 'dart:async';
import 'dart:math';

import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/screen_scaffold.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/claw_machine/application/claw_tries_provider.dart';
import 'package:baobao/features/customization/presentation/item_card.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/economy/domain/purchase_rules.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The music that plays in the shop, unless a track is being previewed.
const shopMusicAsset = 'assets/audio/music/shop.mp3';

/// Where ✷ are spent on music, outfits and backgrounds.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late final VoicedLine _line;
  String? _previewing;

  @override
  void initState() {
    super.initState();
    final content = ref.read(contentProvider);
    _line = content.scripts.shop.pick(Random());
    final voice = _line.voice;
    if (voice != null) {
      unawaited(ref.read(audioDirectorProvider).speak(content.voiceAsset(voice)));
    }
  }

  void _togglePreview(CatalogItem item) {
    final audio = ref.read(audioDirectorProvider);
    if (_previewing == item.id) {
      setState(() => _previewing = null);
      unawaited(audio.playMusic(shopMusicAsset));
    } else {
      setState(() => _previewing = item.id);
      unawaited(audio.playMusic(item.asset));
    }
  }

  Future<void> _buy(CatalogItem item) async {
    final l10n = AppLocalizations.of(context);
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) return;
    final name = item.nameFor(Localizations.localeOf(context).languageCode);

    final confirmed = await showBambooDialog<bool>(
      context: context,
      title: l10n.shopConfirmTitle(name),
      content: Center(child: StarAmount(item.price, style: Theme.of(context).textTheme.titleLarge)),
      actions: [
        BambooButton(
          label: l10n.actionCancel,
          tone: BambooButtonTone.cream,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BambooButton(label: l10n.itemBuy, onPressed: () => Navigator.of(context).pop(true)),
      ],
    );
    if (confirmed != true || !mounted) return;

    final economy = ref.read(economyRepositoryProvider);
    final decision = await economy.purchase(profileId, item, ref.read(clockProvider).now());
    if (!mounted) return;
    switch (decision) {
      case PurchaseAllowed():
        // Buying something means wanting to use it.
        await economy.select(profileId, item);
        _announce(l10n.shopBought(name));
      case InsufficientFunds(:final shortBy):
        _announce(l10n.shopNotEnough(shortBy));
      case AlreadyOwned():
        _announce(l10n.shopAlreadyOwned(name));
    }
  }

  void _announce(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final catalog = ref.watch(catalogProvider);
    final owned = ref.watch(ownedItemsProvider).value ?? const <String>{};
    final selections = ref.watch(selectionsProvider).value ?? const {};
    final balance = ref.watch(balanceProvider).value;
    final profileId = ref.watch(activeProfileIdProvider);

    return ScreenScaffold(
      title: l10n.shopTitle,
      trailing: balance == null
          ? null
          : BambooFrame(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: StarAmount(balance),
            ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/moods/happy.webp',
                  width: 44,
                  height: 44,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(_line.text)),
              ],
            ),
          ),
          for (final slot in ItemSlot.values) ...[
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(slotLabel(l10n, slot), style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            for (final item in catalog.inSlot(slot))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ItemCard(
                  item: item,
                  owned: owned.contains(item.id),
                  selected: selections[slot]?.id == item.id,
                  onBuy: () => _buy(item),
                  onUse: () {
                    if (profileId != null) {
                      ref.read(economyRepositoryProvider).select(profileId, item);
                    }
                  },
                  onPreview: slot == ItemSlot.music ? () => _togglePreview(item) : null,
                  previewing: _previewing == item.id,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
