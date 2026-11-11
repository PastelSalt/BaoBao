import 'dart:math';

/// A line BaoBao says, with its voice clip id if it has one.
class VoicedLine {
  const VoicedLine({required this.text, this.voice});

  factory VoicedLine.fromJson(Map<String, dynamic> json) =>
      VoicedLine(text: json['text'] as String, voice: json['voice'] as String?);

  final String text;
  final String? voice;
}

enum DayPart {
  morning,
  afternoon,
  evening;

  /// Morning is 05:00–11:59, afternoon 12:00–17:59, evening the rest.
  static DayPart at(DateTime time) => switch (time.hour) {
    >= 5 && < 12 => morning,
    >= 12 && < 18 => afternoon,
    _ => evening,
  };
}

/// The moments in the claw machine that BaoBao comments on.
enum ClawLine { intro, aim, win, miss, again }

/// A pool of interchangeable lines that avoids saying the same one twice in a row.
class LinePool {
  LinePool(this.lines) : assert(lines.isNotEmpty);

  factory LinePool.fromJson(List<dynamic> json) =>
      LinePool([for (final line in json) VoicedLine.fromJson(line as Map<String, dynamic>)]);

  final List<VoicedLine> lines;
  int? _last;

  VoicedLine pick(Random random) {
    if (lines.length == 1) return lines.single;
    var index = random.nextInt(lines.length - (_last == null ? 0 : 1));
    if (_last != null && index >= _last!) index += 1;
    _last = index;
    return lines[index];
  }
}

/// Everything BaoBao says outside the mood conversations.
class ScriptLibrary {
  const ScriptLibrary({
    required this.welcome,
    required this.welcomeBack,
    required this.shop,
    required this.settings,
    required this.selfCare,
    required this.affirmations,
    required this.jokes,
    required this.goodbye,
    required this.greetings,
    required this.clawMachine,
  });

  factory ScriptLibrary.fromJson(Map<String, dynamic> json) {
    LinePool pool(String key) => LinePool.fromJson(json[key] as List<dynamic>);
    Map<T, VoicedLine> keyed<T extends Enum>(String key, List<T> values) {
      final raw = json[key] as Map<String, dynamic>;
      return {
        for (final value in values)
          value: VoicedLine.fromJson(
            (raw[value.name] ??
                    (throw FormatException('Scripts: "$key" is missing "${value.name}"')))
                as Map<String, dynamic>,
          ),
      };
    }

    return ScriptLibrary(
      welcome: pool('welcome'),
      welcomeBack: pool('welcomeBack'),
      shop: pool('shop'),
      settings: pool('settings'),
      selfCare: pool('selfCare'),
      affirmations: pool('affirmations'),
      jokes: pool('jokes'),
      goodbye: pool('goodbye'),
      greetings: keyed('greetings', DayPart.values),
      clawMachine: keyed('clawMachine', ClawLine.values),
    );
  }

  final LinePool welcome;
  final LinePool welcomeBack;
  final LinePool shop;
  final LinePool settings;
  final LinePool selfCare;
  final LinePool affirmations;
  final LinePool jokes;
  final LinePool goodbye;
  final Map<DayPart, VoicedLine> greetings;
  final Map<ClawLine, VoicedLine> clawMachine;

  VoicedLine greetingAt(DateTime time) => greetings[DayPart.at(time)]!;

  /// Every line in the library, for validation.
  Iterable<VoicedLine> get allLines => [
    for (final pool in [
      welcome,
      welcomeBack,
      shop,
      settings,
      selfCare,
      affirmations,
      jokes,
      goodbye,
    ])
      ...pool.lines,
    ...greetings.values,
    ...clawMachine.values,
  ];
}

enum HelplineActionType { call, sms, web }

/// One way to reach a helpline.
class HelplineAction {
  const HelplineAction({required this.type, required this.value, this.body});

  factory HelplineAction.fromJson(Map<String, dynamic> json) {
    final name = json['type'] as String;
    return HelplineAction(
      type: HelplineActionType.values.firstWhere(
        (type) => type.name == name,
        orElse: () => throw FormatException('Unknown helpline action "$name"'),
      ),
      value: json['value'] as String,
      body: json['body'] as String?,
    );
  }

  final HelplineActionType type;

  /// A phone number for [HelplineActionType.call] and [HelplineActionType.sms], a URL for web.
  final String value;

  /// The message to pre-fill for [HelplineActionType.sms], if any.
  final String? body;

  Uri get uri => switch (type) {
    HelplineActionType.call => Uri(scheme: 'tel', path: value),
    HelplineActionType.sms => Uri(
      scheme: 'sms',
      path: value,
      queryParameters: body == null ? null : {'body': body},
    ),
    HelplineActionType.web => Uri.parse(value),
  };
}

class Helpline {
  const Helpline({
    required this.id,
    required this.names,
    required this.descriptions,
    required this.actions,
    this.verifiedOn,
  });

  factory Helpline.fromJson(Map<String, dynamic> json) {
    return Helpline(
      id: json['id'] as String,
      names: (json['name'] as Map<String, dynamic>).cast<String, String>(),
      descriptions: (json['description'] as Map<String, dynamic>).cast<String, String>(),
      actions: [
        for (final action in json['actions'] as List<dynamic>)
          HelplineAction.fromJson(action as Map<String, dynamic>),
      ],
      verifiedOn: json['verifiedOn'] as String?,
    );
  }

  final String id;
  final Map<String, String> names;
  final Map<String, String> descriptions;
  final List<HelplineAction> actions;

  /// ISO date on which a person last checked this entry against its source.
  /// Null means unverified, which must not ship in a release.
  final String? verifiedOn;

  String nameFor(String languageCode) => names[languageCode] ?? names['en']!;
  String descriptionFor(String languageCode) => descriptions[languageCode] ?? descriptions['en']!;
}

/// The helplines and emergency number for one country.
class CountryHelp {
  const CountryHelp({required this.lines, this.emergencyNumber});

  final String? emergencyNumber;
  final List<Helpline> lines;
}

/// All helplines, by country, with a worldwide fallback.
class HelplineDirectory {
  const HelplineDirectory({required this.fallback, required this.countries});

  factory HelplineDirectory.fromJson(Map<String, dynamic> json) {
    List<Helpline> lines(Map<String, dynamic> section) => [
      for (final line in section['lines'] as List<dynamic>)
        Helpline.fromJson(line as Map<String, dynamic>),
    ];
    final countries = json['countries'] as Map<String, dynamic>;
    return HelplineDirectory(
      fallback: lines(json['fallback'] as Map<String, dynamic>),
      countries: {
        for (final entry in countries.entries)
          entry.key: CountryHelp(
            emergencyNumber: (entry.value as Map<String, dynamic>)['emergencyNumber'] as String?,
            lines: lines(entry.value as Map<String, dynamic>),
          ),
      },
    );
  }

  /// Directories that work in any country.
  final List<Helpline> fallback;

  /// Keyed by ISO 3166-1 alpha-2 country code.
  final Map<String, CountryHelp> countries;

  /// Help for [countryCode]. Unknown or missing countries get the fallback only,
  /// so nobody is ever shown a number that does not work where they are.
  CountryHelp helpFor(String? countryCode) {
    final country = countries[countryCode?.toUpperCase()];
    if (country == null) return CountryHelp(lines: fallback);
    return CountryHelp(
      emergencyNumber: country.emergencyNumber,
      lines: [...country.lines, ...fallback],
    );
  }

  Iterable<Helpline> get allLines => [...fallback, for (final c in countries.values) ...c.lines];
}

class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.title,
    required this.body,
    required this.emotion,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) => TutorialStep(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    emotion: json['emotion'] as String,
  );

  final String id;
  final String title;
  final String body;

  /// Which character pose to show: `hello`, `happy`, `sad` or `tired`.
  final String emotion;
}
