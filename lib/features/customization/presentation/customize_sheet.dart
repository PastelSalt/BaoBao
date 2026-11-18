import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/features/customization/presentation/item_card.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lets the person switch between the things they own. Changes apply at once
/// to the home screen behind the sheet, so it doubles as a live preview.
Future<void> showCustomizeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Leaves the top of home visible so the change can be seen.
    barrierColor: context.palette.scrim,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scroll) => _CustomizeSheet(scroll),
    ),
  );
}

class _CustomizeSheet extends ConsumerWidget {
  const _CustomizeSheet(this.scroll);

  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final catalog = ref.watch(catalogProvider);
    final owned = ref.watch(ownedItemsProvider).value ?? const <String>{};
    final selections = ref.watch(selectionsProvider).value ?? const {};
    final profileId = ref.watch(activeProfileIdProvider);

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.xl),
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.customizeTitle,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        for (final slot in ItemSlot.values) ...[
          const SizedBox(height: Space.l),
          Semantics(
            header: true,
            child: Text(slotLabel(l10n, slot), style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: Space.s),
          for (final item in catalog.inSlot(slot))
            if (owned.contains(item.id))
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: ItemCard(
                  item: item,
                  owned: true,
                  selected: selections[slot]?.id == item.id,
                  onUse: () {
                    if (profileId != null) {
                      ref.read(economyRepositoryProvider).select(profileId, item).ignore();
                    }
                  },
                ),
              ),
        ],
        const SizedBox(height: Space.m),
        AppButton(
          label: l10n.customizeGetMore,
          icon: Glyph.shop,
          kind: ButtonKind.secondary,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop();
            context.push(Routes.shop).ignore();
          },
        ),
      ],
    );
  }
}
