import 'package:baobao/features/economy/domain/catalog.dart';

/// Whether a purchase may go ahead, and if not, why.
sealed class PurchaseDecision {
  const PurchaseDecision();
}

final class PurchaseAllowed extends PurchaseDecision {
  const PurchaseAllowed();
}

final class AlreadyOwned extends PurchaseDecision {
  const AlreadyOwned();
}

final class InsufficientFunds extends PurchaseDecision {
  const InsufficientFunds(this.shortBy);

  /// How many more ✷ are needed.
  final int shortBy;
}

abstract final class PurchaseRules {
  static PurchaseDecision evaluate({
    required CatalogItem item,
    required int balance,
    required Set<String> ownedItemIds,
  }) {
    if (item.isDefault || ownedItemIds.contains(item.id)) return const AlreadyOwned();
    if (balance < item.price) return InsufficientFunds(item.price - balance);
    return const PurchaseAllowed();
  }
}
