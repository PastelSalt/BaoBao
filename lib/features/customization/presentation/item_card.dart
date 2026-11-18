import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/app_background.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/core/widgets/star_amount.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One catalogue item: a preview, its name and state, and what can be done
/// with it. The actions sit below the text at full width, so a long name or
/// large text never squeezes them.
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

    final actions = <Widget>[
      if (onPreview != null)
        AppButton(
          label: previewing ? l10n.itemStop : l10n.itemPreviewShort,
          icon: previewing ? Glyph.stop : Glyph.play,
          kind: ButtonKind.secondary,
          expand: true,
          semanticLabel: previewing ? l10n.itemStopPreview(name) : l10n.itemPreview(name),
          onPressed: onPreview,
        ),
      if (owned && !selected) AppButton(label: l10n.itemUse, expand: true, onPressed: onUse),
      if (!owned && onBuy != null) AppButton(label: l10n.itemBuy, expand: true, onPressed: onBuy),
    ];

    return Panel(
      tone: selected ? PanelTone.selected : PanelTone.normal,
      padding: const EdgeInsets.all(Space.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: Corners.small,
                child: SizedBox.square(dimension: 80, child: _preview(context)),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: Space.xs),
                    if (selected)
                      _Status(glyph: Glyph.check, text: l10n.itemInUse)
                    else if (owned)
                      Text(l10n.itemOwned, style: theme.textTheme.bodyMedium)
                    else
                      StarAmount(item.price, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: Space.m),
            for (final (i, action) in actions.indexed) ...[
              if (i > 0) const SizedBox(height: Space.s),
              action,
            ],
          ],
        ],
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final p = context.palette;
    return switch (item.slot) {
      ItemSlot.outfit => ColoredBox(
        color: p.panelSelected,
        child: Image.asset(
          CharacterView.assetFor(item.asset, CharacterPose.hello),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
      ItemSlot.background => ExcludeSemantics(
        child: SvgPicture.asset(backgroundAssetFor(item.asset, dark: p.isDark), fit: BoxFit.cover),
      ),
      ItemSlot.music => ColoredBox(
        color: p.panelSelected,
        child: Center(child: AppIcon(Glyph.music, size: 36, color: p.primary)),
      ),
    };
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.glyph, required this.text});

  final Glyph glyph;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(glyph, size: 18, color: p.primary),
        const SizedBox(width: Space.xs),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: p.primary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String slotLabel(AppLocalizations l10n, ItemSlot slot) => switch (slot) {
  ItemSlot.music => l10n.slotMusic,
  ItemSlot.outfit => l10n.slotOutfit,
  ItemSlot.background => l10n.slotBackground,
};
