import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/features/claw_machine/application/claw_tries_provider.dart';
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
    backgroundColor: AppColors.offWhite,
    showDragHandle: true,
    isScrollControlled: true,
    // Leave the top of home visible so the change can be seen.
    barrierColor: Colors.black26,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(slotLabel(l10n, slot), style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          for (final item in catalog.inSlot(slot))
            if (owned.contains(item.id))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ItemCard(
                  item: item,
                  owned: true,
                  selected: selections[slot]?.id == item.id,
                  onUse: () {
                    if (profileId != null) {
                      ref.read(economyRepositoryProvider).select(profileId, item);
                    }
                  },
                ),
              ),
        ],
        const SizedBox(height: 12),
        BambooButton(
          label: l10n.customizeGetMore,
          icon: Icons.storefront_rounded,
          tone: BambooButtonTone.tan,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop();
            context.push(Routes.shop);
          },
        ),
      ],
    );
  }
}
