import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/economy/domain/purchase_rules.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> item(String id, String slot, int price, {bool isDefault = false}) => {
  'id': id,
  'slot': slot,
  'name': {'en': id.toUpperCase()},
  'price': price,
  'asset': 'assets/$id',
  if (isDefault) 'default': true,
};

void main() {
  final catalog = Catalog.fromJson({
    'startingBalance': 3000,
    'items': [
      item('song', 'music', 0, isDefault: true),
      item('tune', 'music', 500),
      item('plain', 'outfit', 0, isDefault: true),
      item('grove', 'background', 0, isDefault: true),
    ],
  });

  group('Catalog', () {
    test('looks items up by id and slot', () {
      expect(catalog.byId('tune')!.price, 500);
      expect(catalog.byId('nope'), isNull);
      expect(catalog.inSlot(ItemSlot.music).map((i) => i.id), ['song', 'tune']);
      expect(catalog.defaultFor(ItemSlot.music).id, 'song');
    });

    test('falls back to English, then the id, for names', () {
      expect(catalog.byId('tune')!.nameFor('fr'), 'TUNE');
    });

    test('a sound catalogue has no problems', () {
      expect(catalog.validate(), isEmpty);
    });

    test('reports duplicates, paid defaults and slots without one default', () {
      final broken = Catalog.fromJson({
        'startingBalance': 0,
        'items': [
          item('a', 'music', 10, isDefault: true),
          item('a', 'music', 5),
          item('b', 'outfit', 0),
        ],
      });
      final problems = broken.validate();
      expect(problems, contains(contains('duplicate item id "a"')));
      expect(problems, contains(contains('default item "a" must be free')));
      expect(problems, contains(contains('slot "outfit" has 0 default items')));
      expect(problems, contains(contains('slot "background" has 0 default items')));
    });

    test('rejects an unknown slot', () {
      expect(() => CatalogItem.fromJson(item('x', 'hat', 1)), throwsFormatException);
    });
  });

  group('PurchaseRules', () {
    final tune = catalog.byId('tune')!;

    test('allows a purchase that can be afforded', () {
      expect(
        PurchaseRules.evaluate(item: tune, balance: 500, ownedItemIds: {}),
        isA<PurchaseAllowed>(),
      );
    });

    test('refuses when funds are short and says by how much', () {
      final decision = PurchaseRules.evaluate(item: tune, balance: 120, ownedItemIds: {});
      expect(decision, isA<InsufficientFunds>());
      expect((decision as InsufficientFunds).shortBy, 380);
    });

    test('refuses items that are already owned, including defaults', () {
      expect(
        PurchaseRules.evaluate(item: tune, balance: 9999, ownedItemIds: {'tune'}),
        isA<AlreadyOwned>(),
      );
      expect(
        PurchaseRules.evaluate(item: catalog.byId('song')!, balance: 0, ownedItemIds: {}),
        isA<AlreadyOwned>(),
      );
    });
  });
}
