import 'dart:io';
import 'dart:math';

import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/content/content_audit.dart';
import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppContent content;
  late Set<String> assets;

  setUpAll(() async {
    content = await AppContent.load((path) => File(path).readAsString());
    assets = {
      for (final entity in Directory('assets').listSync(recursive: true))
        if (entity is File) entity.path.replaceAll(r'\', '/'),
    };
  });

  group('shipped content', () {
    test('has no structural errors', () {
      expect(auditContent(content, assets).errors, isEmpty);
    });

    test('contains all six trees and 79 nodes', () {
      expect(content.trees.keys, AppContent.treeIds);
      expect(
        {for (final t in content.trees.values) t.id: t.nodes.length},
        {'happy': 11, 'okay': 13, 'sad': 16, 'tired': 16, 'anxious': 15, 'intervention': 8},
      );
    });

    test('every conversation line is voiced', () {
      for (final tree in content.trees.values) {
        for (final node in tree.nodes.values) {
          expect(node.voice, isNotNull, reason: node.id);
        }
      }
    });

    test('the intervention tree can open the resources screen', () {
      final targets = content.trees['intervention']!.nodes.values
          .expand((node) => node.options)
          .map((option) => option.next);
      expect(targets, contains('@resources'));
    });

    test('keeps the prototype prices', () {
      expect(content.catalog.startingBalance, 3000);
      expect(
        {for (final i in content.catalog.items) i.id: i.price},
        {
          'bamboo_morning': 0,
          'paper_lanterns': 500,
          'quiet_rain': 750,
          'classic': 0,
          'blue_bao': 1000,
          'bamboo': 0,
          'bamboo_clouds': 800,
          'bamboo_plum': 1000,
        },
      );
    });

    test('every outfit has all four poses', () {
      for (final outfit in content.catalog.inSlot(ItemSlot.outfit)) {
        for (final pose in ['hello', 'happy', 'sad', 'tired']) {
          expect(assets, contains('${outfit.asset}/$pose.webp'));
        }
      }
    });
  });

  group('audit', () {
    test('flags unverified helplines as release blockers', () {
      final blockers = auditContent(content, assets).releaseBlockers;
      expect(blockers, contains(contains('Helpline "us_988" has not been verified')));
    });

    test('all bundled music is original, so nothing is blocked on a licence', () {
      final blockers = auditContent(content, assets).releaseBlockers;
      expect(blockers.where((b) => b.contains('licence')), isEmpty);
      for (final item in content.catalog.inSlot(ItemSlot.music)) {
        expect(item.licence, 'original');
      }
    });

    test('reports missing and unused voice clips', () {
      final missing = {...assets}..remove('assets/audio/voice/en/h_happy_01.m4a');
      expect(
        auditContent(content, missing).errors,
        contains(contains('missing voice clip "h_happy_01"')),
      );

      final extra = {...assets, 'assets/audio/voice/en/stray.m4a'};
      expect(auditContent(content, extra).errors, contains(contains('"stray" is not used')));
    });

    test('reports catalogue items whose asset is missing', () {
      final missing = {...assets}..remove('assets/images/backgrounds/bamboo_plum.svg');
      expect(
        auditContent(content, missing).errors,
        contains(contains('"bamboo_plum" refers to missing asset')),
      );
    });
  });

  group('helplines', () {
    test('a known country gets its own lines followed by the fallback', () {
      final help = content.helplines.helpFor('us');
      expect(help.emergencyNumber, '911');
      expect(help.lines.first.id, 'us_988');
      expect(help.lines.last.id, content.helplines.fallback.last.id);
    });

    test('an unknown country gets only the worldwide fallback', () {
      for (final code in ['ZZ', null]) {
        final help = content.helplines.helpFor(code);
        expect(help.emergencyNumber, isNull);
        expect(help.lines.map((l) => l.id), content.helplines.fallback.map((l) => l.id));
      }
    });

    test('actions become dialable links', () {
      expect(
        const HelplineAction(type: HelplineActionType.call, value: '988').uri.toString(),
        'tel:988',
      );
      expect(
        const HelplineAction(
          type: HelplineActionType.sms,
          value: '741741',
          body: 'HOME',
        ).uri.toString(),
        'sms:741741?body=HOME',
      );
      expect(
        const HelplineAction(
          type: HelplineActionType.web,
          value: 'https://findahelpline.com',
        ).uri.host,
        'findahelpline.com',
      );
    });
  });

  group('scripts', () {
    test('greets by time of day', () {
      String at(int hour) => content.scripts.greetingAt(DateTime(2026, 1, 1, hour)).text;
      expect(at(5), startsWith('Good morning'));
      expect(at(11), startsWith('Good morning'));
      expect(at(12), startsWith('Good afternoon'));
      expect(at(17), startsWith('Good afternoon'));
      expect(at(18), startsWith('Good evening'));
      expect(at(4), startsWith('Good evening'));
    });

    test('a pool never repeats a line twice in a row', () {
      final random = Random(7);
      final pool = content.scripts.jokes;
      var previous = pool.pick(random);
      for (var i = 0; i < 200; i++) {
        final next = pool.pick(random);
        expect(next, isNot(same(previous)));
        previous = next;
      }
    });

    test('a pool eventually uses every line', () {
      final random = Random(3);
      final seen = {for (var i = 0; i < 300; i++) content.scripts.affirmations.pick(random)};
      expect(seen, hasLength(10));
    });
  });
}
