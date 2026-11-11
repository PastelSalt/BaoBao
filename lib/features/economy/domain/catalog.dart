/// The customisable parts of the app. Each holds one selected item.
enum ItemSlot {
  music,
  outfit,
  background;

  static ItemSlot parse(String name) => values.firstWhere(
    (slot) => slot.name == name,
    orElse: () => throw FormatException('Unknown item slot "$name"'),
  );
}

/// Something that can be owned and equipped.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.slot,
    required this.names,
    required this.price,
    required this.asset,
    this.isDefault = false,
    this.licence,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      slot: ItemSlot.parse(json['slot'] as String),
      names: (json['name'] as Map<String, dynamic>).cast<String, String>(),
      price: json['price'] as int,
      asset: json['asset'] as String,
      isDefault: (json['default'] as bool?) ?? false,
      licence: json['licence'] as String?,
    );
  }

  final String id;
  final ItemSlot slot;

  /// Display names keyed by language code.
  final Map<String, String> names;

  /// Cost in ✷. Default items cost nothing.
  final int price;

  /// For music and backgrounds, a file. For outfits, a folder of emotion images.
  final String asset;

  /// Every profile owns the default item of each slot from the start.
  final bool isDefault;

  /// Licence status of bundled third-party media. `unverified` blocks release.
  final String? licence;

  String nameFor(String languageCode) => names[languageCode] ?? names['en'] ?? id;
}

/// Everything the shop can offer.
class Catalog {
  Catalog({required this.startingBalance, required List<CatalogItem> items})
    : items = List.unmodifiable(items),
      _byId = {for (final item in items) item.id: item};

  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      startingBalance: json['startingBalance'] as int,
      items: [
        for (final item in json['items'] as List<dynamic>)
          CatalogItem.fromJson(item as Map<String, dynamic>),
      ],
    );
  }

  /// The ✷ a new profile starts with.
  final int startingBalance;
  final List<CatalogItem> items;
  final Map<String, CatalogItem> _byId;

  CatalogItem? byId(String id) => _byId[id];

  List<CatalogItem> inSlot(ItemSlot slot) => [
    for (final item in items)
      if (item.slot == slot) item,
  ];

  CatalogItem defaultFor(ItemSlot slot) =>
      items.firstWhere((item) => item.slot == slot && item.isDefault);

  /// Structural problems: duplicate ids, or a slot without exactly one default.
  List<String> validate() {
    final problems = <String>[];
    final seen = <String>{};
    for (final item in items) {
      if (!seen.add(item.id)) problems.add('Catalogue: duplicate item id "${item.id}"');
      if (item.price < 0) problems.add('Catalogue: item "${item.id}" has a negative price');
      if (item.isDefault && item.price != 0) {
        problems.add('Catalogue: default item "${item.id}" must be free');
      }
    }
    for (final slot in ItemSlot.values) {
      final defaults = items.where((item) => item.slot == slot && item.isDefault).length;
      if (defaults != 1) {
        problems.add('Catalogue: slot "${slot.name}" has $defaults default items, expected 1');
      }
    }
    return problems;
  }
}
