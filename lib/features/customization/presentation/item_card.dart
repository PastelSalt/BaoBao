import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One catalogue item: a preview, its name, and what can be done with it.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.owned,
    required this.selected,
    required this.onUse,
    this.onBuy,
    this.onPreview,
    this.previewing = false,
  });

  final CatalogItem item;
  final bool owned;
  final bool selected;

  /// Equips the item. Only offered when it is owned and not already in use.
  final VoidCallback onUse;

  /// Buys the item. Null hides the price and buy button (wardrobe view).
  final VoidCallback? onBuy;

  /// For music: starts or stops a preview.
  final VoidCallback? onPreview;
  final bool previewing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = item.nameFor(Localizations.localeOf(context).languageCode);

    return BambooFrame(
      fill: selected ? AppColors.paleGreen : AppColors.offWhite,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(dimension: 72, child: _preview()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                if (selected)
                  Text(l10n.itemInUse, style: theme.textTheme.bodyMedium)
                else if (owned)
                  Text(l10n.itemOwned, style: theme.textTheme.bodyMedium)
                else
                  StarAmount(item.price, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          if (onPreview != null)
            IconButton(
              onPressed: onPreview,
              icon: Icon(previewing ? Icons.stop_circle_rounded : Icons.play_circle_rounded),
              iconSize: 32,
              color: AppColors.deepGreen,
              tooltip: previewing ? l10n.itemStopPreview(name) : l10n.itemPreview(name),
            ),
          if (owned && !selected)
            BambooButton(label: l10n.itemUse, tone: BambooButtonTone.lightGreen, onPressed: onUse)
          else if (!owned && onBuy != null)
            BambooButton(label: l10n.itemBuy, onPressed: onBuy),
        ],
      ),
    );
  }

  Widget _preview() => switch (item.slot) {
    ItemSlot.outfit => ColoredBox(
      color: AppColors.cream,
      child: Image.asset(
        CharacterView.assetFor(item.asset, CharacterPose.hello),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
    ItemSlot.background => ColoredBox(
      color: AppColors.offWhite,
      child: ExcludeSemantics(child: SvgPicture.asset(item.asset, fit: BoxFit.cover)),
    ),
    ItemSlot.music => const ColoredBox(
      color: AppColors.lightGreen,
      child: Icon(Icons.music_note_rounded, size: 36, color: AppColors.ink),
    ),
  };
}

String slotLabel(AppLocalizations l10n, ItemSlot slot) => switch (slot) {
  ItemSlot.music => l10n.slotMusic,
  ItemSlot.outfit => l10n.slotOutfit,
  ItemSlot.background => l10n.slotBackground,
};
