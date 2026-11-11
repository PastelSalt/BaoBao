// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BaoBao';

  @override
  String get characterLabel => 'BaoBao the panda';

  @override
  String balanceLabel(int amount) {
    return '$amount stars';
  }

  @override
  String get loading => 'Just a moment…';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionStart => 'Let\'s begin';

  @override
  String get actionSkip => 'Not now';

  @override
  String get actionRetry => 'Try again';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Hi, I\'m BaoBao!';

  @override
  String get onboardingPromiseTitle => 'Before we start';

  @override
  String get onboardingPromiseCompanion =>
      'I\'m a friendly companion for everyday feelings. I\'m not a therapist or a doctor, and I can\'t help in an emergency.';

  @override
  String get onboardingPromiseEmergency =>
      'If you ever feel unsafe, please contact your local emergency number or a crisis line right away. You\'ll always find helplines in Settings.';

  @override
  String get onboardingPromisePrivacy =>
      'What you share with me stays on this device, encrypted. Nothing is sent anywhere, and you can delete it whenever you like.';

  @override
  String get onboardingConfirmUnderstand =>
      'I understand BaoBao is not a substitute for professional care.';

  @override
  String get onboardingConfirmAge => 'I am 13 or older.';

  @override
  String get onboardingNameTitle => 'What should I call you?';

  @override
  String get onboardingNameHint => 'Your name or nickname';

  @override
  String get onboardingNameHelp => 'This only appears on this device. You can change it later.';

  @override
  String get onboardingLockTitle => 'Keep our chats private?';

  @override
  String get onboardingLockBody =>
      'I can ask for your fingerprint, face, or device PIN each time you open the app. You can switch this on or off later in Settings.';

  @override
  String get onboardingLockEnable => 'Yes, lock the app';

  @override
  String get onboardingLockReason => 'Confirm it\'s you to switch on the app lock';

  @override
  String get onboardingLockFailed =>
      'That didn\'t work, so the lock is still off. You can try again or skip for now.';

  @override
  String get onboardingFinishing => 'Getting your cozy corner ready…';

  @override
  String get onboardingFailed => 'Something went wrong while setting things up. Please try again.';

  @override
  String get unlockTitle => 'Welcome back';

  @override
  String get unlockBody => 'Confirm it\'s you to open BaoBao.';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get unlockReason => 'Unlock BaoBao';

  @override
  String get unlockFailed => 'That didn\'t work. Please try again.';

  @override
  String homeGreetingName(String name) {
    return 'Hi, $name';
  }

  @override
  String get startupErrorTitle => 'BaoBao couldn\'t start';

  @override
  String get startupErrorBody =>
      'Something went wrong while opening the app. Your data has not been deleted.';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionNext => 'Next';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodTired => 'Tired';

  @override
  String get moodSheetTitle => 'How are you feeling?';

  @override
  String get moodSheetHint => 'There\'s no wrong answer. Pick whatever fits right now.';

  @override
  String get homeCheckIn => 'How are you feeling?';

  @override
  String get homeCheckInHint => 'Tap to tell BaoBao how you feel';

  @override
  String get homeLeaveChat => 'End chat for now';

  @override
  String homeLastMood(String mood) {
    return 'Last check-in: $mood';
  }

  @override
  String get quickJoke => 'Joke';

  @override
  String get quickAffirmation => 'Kind word';

  @override
  String get quickSelfCare => 'Self-care';

  @override
  String get navShop => 'Shop';

  @override
  String get navClaw => 'Claw';

  @override
  String navClawTries(int tries) {
    return 'Claw ($tries)';
  }

  @override
  String get navCustomize => 'Style';

  @override
  String get nudgeJoke => 'Want a joke?';

  @override
  String get nudgeAffirmation => 'Want a kind word?';

  @override
  String get nudgeSelfCare => 'Want a self-care idea?';

  @override
  String get nudgeClaw => 'Play the claw machine';

  @override
  String get nudgeShop => 'Visit the shop';

  @override
  String get slotMusic => 'Music';

  @override
  String get slotOutfit => 'Outfits';

  @override
  String get slotBackground => 'Backgrounds';

  @override
  String get itemInUse => 'In use';

  @override
  String get itemOwned => 'Owned';

  @override
  String get itemUse => 'Use';

  @override
  String get itemBuy => 'Buy';

  @override
  String itemPreview(String name) {
    return 'Preview $name';
  }

  @override
  String itemStopPreview(String name) {
    return 'Stop preview of $name';
  }

  @override
  String get customizeTitle => 'Your style';

  @override
  String get customizeGetMore => 'Get more in the shop';

  @override
  String get shopTitle => 'Shop';

  @override
  String shopConfirmTitle(String name) {
    return 'Buy $name?';
  }

  @override
  String shopBought(String name) {
    return '$name is yours, and it\'s on now!';
  }

  @override
  String shopNotEnough(int amount) {
    return 'You need $amount more stars. The claw machine can help!';
  }

  @override
  String shopAlreadyOwned(String name) {
    return 'You already have $name.';
  }

  @override
  String get resourcesTitle => 'Get help';

  @override
  String get resourcesIntro =>
      'You don\'t have to carry this alone. These services are free, confidential, and staffed by people who want to help.';

  @override
  String get resourcesEmergencyTitle => 'In an emergency';

  @override
  String resourcesEmergencyKnown(String number) {
    return 'If you or someone else is in immediate danger, call $number now.';
  }

  @override
  String get resourcesEmergencyUnknown =>
      'If you or someone else is in immediate danger, call your local emergency number now.';

  @override
  String get resourcesRegion => 'Showing help for';

  @override
  String get resourcesRegionOther => 'Another country';

  @override
  String get resourcesRegionOtherNote =>
      'We don\'t have local numbers for your region yet. These directories list helplines around the world.';

  @override
  String resourcesCall(String number) {
    return 'Call $number';
  }

  @override
  String resourcesText(String number) {
    return 'Text $number';
  }

  @override
  String resourcesTextWith(String word, String number) {
    return 'Text $word to $number';
  }

  @override
  String get resourcesOpenWebsite => 'Open website';

  @override
  String get resourcesCannotOpenTitle => 'Couldn\'t open that here';

  @override
  String get resourcesCannotOpenBody =>
      'This device couldn\'t start it for you. You can use these details on another phone or computer:';

  @override
  String get resourcesDisclaimer =>
      'BaoBao is not a crisis service and is not a substitute for professional care.';

  @override
  String get countryUS => 'United States';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGetHelp => 'Get help';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsMusicVolume => 'Music volume';

  @override
  String get settingsSfxVolume => 'Sound effects volume';

  @override
  String get settingsVoiceVolume => 'BaoBao\'s voice volume';

  @override
  String get settingsVoiceEnabled => 'BaoBao\'s voice';

  @override
  String get settingsVoiceEnabledHint => 'The words always appear on screen either way.';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsReducedMotion => 'Reduce motion';

  @override
  String get settingsReducedMotionHint => 'Text appears at once and BaoBao stays still.';

  @override
  String get settingsClawTapMode => 'Tap instead of hold in the claw machine';

  @override
  String get settingsClawTapModeHint => 'Tap once to start the claw and again to drop it.';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsRename => 'Change name';

  @override
  String settingsSwitchTo(String name) {
    return 'Switch to $name';
  }

  @override
  String get settingsAddProfile => 'Add another profile';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockHint =>
      'Ask for your fingerprint, face, or device PIN when opening BaoBao.';

  @override
  String get settingsAppLockOffReason => 'Confirm it\'s you to switch off the app lock';

  @override
  String get settingsDeleteData => 'Delete my data';

  @override
  String get settingsDeleteTitle => 'Delete everything?';

  @override
  String settingsDeleteBody(String name) {
    return 'This permanently removes $name\'s check-ins, conversations, stars and items from this device. It can\'t be undone.';
  }

  @override
  String get settingsDeleteConfirm => 'Delete';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsReplayTutorial => 'Replay the tour';

  @override
  String get settingsNotMedical => 'What BaoBao is';

  @override
  String get settingsLicences => 'Open-source licences';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get tutorialSkip => 'Skip tour';

  @override
  String get tutorialDone => 'Got it!';

  @override
  String get clawTitle => 'Claw machine';

  @override
  String clawTries(int count) {
    return 'Tries: $count';
  }

  @override
  String clawNextTry(String time) {
    return 'Next try in $time';
  }

  @override
  String clawBuyTry(int price) {
    return '+1 try ($price)';
  }

  @override
  String get clawHoldToMove => 'Hold to move';

  @override
  String get clawReleaseToDrop => 'Let go to drop';

  @override
  String get clawTapToStart => 'Tap to start';

  @override
  String get clawTapToDrop => 'Tap to drop';

  @override
  String get clawWait => '…';

  @override
  String get clawNoTries =>
      'No tries left right now. One comes back every five minutes, or you can get an extra one.';

  @override
  String get clawBoughtTry => 'Yay, an extra try!';

  @override
  String get clawDailyLimit => 'That\'s all the extra tries for today. Come back tomorrow!';

  @override
  String clawNotEnough(int price) {
    return 'You need $price stars for an extra try.';
  }

  @override
  String get clawMissed => 'So close!';

  @override
  String get clawRare => '★ Rare ★';

  @override
  String clawCombo(int streak, String multiplier) {
    return '$streak in a row! ×$multiplier';
  }

  @override
  String clawMachineLabel(int count) {
    return 'Claw machine with $count prizes inside';
  }

  @override
  String get clawStatsTitle => 'Your claw stats';

  @override
  String get clawStatsPlays => 'Plays';

  @override
  String get clawStatsWins => 'Wins';

  @override
  String get clawStatsEarnings => 'Stars won';

  @override
  String get clawStatsBest => 'Best win';
}
