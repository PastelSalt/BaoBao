import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BaoBao'**
  String get appName;

  /// No description provided for @characterLabel.
  ///
  /// In en, this message translates to:
  /// **'BaoBao the panda'**
  String get characterLabel;

  /// Screen-reader label for the in-app currency balance.
  ///
  /// In en, this message translates to:
  /// **'{amount} stars'**
  String balanceLabel(int amount);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Just a moment…'**
  String get loading;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get actionStart;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionSkip;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m BaoBao!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we start'**
  String get onboardingPromiseTitle;

  /// No description provided for @onboardingPromiseCompanion.
  ///
  /// In en, this message translates to:
  /// **'I\'m a friendly companion for everyday feelings. I\'m not a therapist or a doctor, and I can\'t help in an emergency.'**
  String get onboardingPromiseCompanion;

  /// No description provided for @onboardingPromiseEmergency.
  ///
  /// In en, this message translates to:
  /// **'If you ever feel unsafe, please contact your local emergency number or a crisis line right away. You\'ll always find helplines in Settings.'**
  String get onboardingPromiseEmergency;

  /// No description provided for @onboardingPromisePrivacy.
  ///
  /// In en, this message translates to:
  /// **'What you share with me stays on this device, encrypted. Nothing is sent anywhere, and you can delete it whenever you like.'**
  String get onboardingPromisePrivacy;

  /// No description provided for @onboardingConfirmUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand BaoBao is not a substitute for professional care.'**
  String get onboardingConfirmUnderstand;

  /// No description provided for @onboardingConfirmAge.
  ///
  /// In en, this message translates to:
  /// **'I am 13 or older.'**
  String get onboardingConfirmAge;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name or nickname'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameHelp.
  ///
  /// In en, this message translates to:
  /// **'This only appears on this device. You can change it later.'**
  String get onboardingNameHelp;

  /// No description provided for @onboardingLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep our chats private?'**
  String get onboardingLockTitle;

  /// No description provided for @onboardingLockBody.
  ///
  /// In en, this message translates to:
  /// **'I can ask for your fingerprint, face, or device PIN each time you open the app. You can switch this on or off later in Settings.'**
  String get onboardingLockBody;

  /// No description provided for @onboardingLockEnable.
  ///
  /// In en, this message translates to:
  /// **'Yes, lock the app'**
  String get onboardingLockEnable;

  /// No description provided for @onboardingLockReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to switch on the app lock'**
  String get onboardingLockReason;

  /// No description provided for @onboardingLockFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work, so the lock is still off. You can try again or skip for now.'**
  String get onboardingLockFailed;

  /// No description provided for @onboardingFinishing.
  ///
  /// In en, this message translates to:
  /// **'Getting your cozy corner ready…'**
  String get onboardingFinishing;

  /// No description provided for @onboardingFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while setting things up. Please try again.'**
  String get onboardingFailed;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get unlockTitle;

  /// No description provided for @unlockBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to open BaoBao.'**
  String get unlockBody;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock BaoBao'**
  String get unlockReason;

  /// No description provided for @unlockFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Please try again.'**
  String get unlockFailed;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreetingName(String name);

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'BaoBao couldn\'t start'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening the app. Your data has not been deleted.'**
  String get startupErrorBody;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodTired;

  /// No description provided for @moodSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get moodSheetTitle;

  /// No description provided for @moodSheetHint.
  ///
  /// In en, this message translates to:
  /// **'There\'s no wrong answer. Pick whatever fits right now.'**
  String get moodSheetHint;

  /// No description provided for @homeCheckIn.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get homeCheckIn;

  /// No description provided for @homeCheckInHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to tell BaoBao how you feel'**
  String get homeCheckInHint;

  /// No description provided for @homeLeaveChat.
  ///
  /// In en, this message translates to:
  /// **'End chat for now'**
  String get homeLeaveChat;

  /// No description provided for @homeLastMood.
  ///
  /// In en, this message translates to:
  /// **'Last check-in: {mood}'**
  String homeLastMood(String mood);

  /// No description provided for @quickJoke.
  ///
  /// In en, this message translates to:
  /// **'Joke'**
  String get quickJoke;

  /// No description provided for @quickAffirmation.
  ///
  /// In en, this message translates to:
  /// **'Kind word'**
  String get quickAffirmation;

  /// No description provided for @quickSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get quickSelfCare;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navClaw.
  ///
  /// In en, this message translates to:
  /// **'Claw'**
  String get navClaw;

  /// No description provided for @navClawTries.
  ///
  /// In en, this message translates to:
  /// **'Claw ({tries})'**
  String navClawTries(int tries);

  /// No description provided for @navCustomize.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get navCustomize;

  /// No description provided for @nudgeJoke.
  ///
  /// In en, this message translates to:
  /// **'Want a joke?'**
  String get nudgeJoke;

  /// No description provided for @nudgeAffirmation.
  ///
  /// In en, this message translates to:
  /// **'Want a kind word?'**
  String get nudgeAffirmation;

  /// No description provided for @nudgeSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Want a self-care idea?'**
  String get nudgeSelfCare;

  /// No description provided for @nudgeClaw.
  ///
  /// In en, this message translates to:
  /// **'Play the claw machine'**
  String get nudgeClaw;

  /// No description provided for @nudgeShop.
  ///
  /// In en, this message translates to:
  /// **'Visit the shop'**
  String get nudgeShop;

  /// No description provided for @slotMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get slotMusic;

  /// No description provided for @slotOutfit.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get slotOutfit;

  /// No description provided for @slotBackground.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get slotBackground;

  /// No description provided for @itemInUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get itemInUse;

  /// No description provided for @itemOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get itemOwned;

  /// No description provided for @itemUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get itemUse;

  /// No description provided for @itemBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get itemBuy;

  /// No description provided for @itemPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview {name}'**
  String itemPreview(String name);

  /// No description provided for @itemStopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop preview of {name}'**
  String itemStopPreview(String name);

  /// No description provided for @customizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your style'**
  String get customizeTitle;

  /// No description provided for @customizeGetMore.
  ///
  /// In en, this message translates to:
  /// **'Get more in the shop'**
  String get customizeGetMore;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}?'**
  String shopConfirmTitle(String name);

  /// No description provided for @shopBought.
  ///
  /// In en, this message translates to:
  /// **'{name} is yours, and it\'s on now!'**
  String shopBought(String name);

  /// No description provided for @shopNotEnough.
  ///
  /// In en, this message translates to:
  /// **'You need {amount} more stars. The claw machine can help!'**
  String shopNotEnough(int amount);

  /// No description provided for @shopAlreadyOwned.
  ///
  /// In en, this message translates to:
  /// **'You already have {name}.'**
  String shopAlreadyOwned(String name);

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get resourcesTitle;

  /// No description provided for @resourcesIntro.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to carry this alone. These services are free, confidential, and staffed by people who want to help.'**
  String get resourcesIntro;

  /// No description provided for @resourcesEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'In an emergency'**
  String get resourcesEmergencyTitle;

  /// No description provided for @resourcesEmergencyKnown.
  ///
  /// In en, this message translates to:
  /// **'If you or someone else is in immediate danger, call {number} now.'**
  String resourcesEmergencyKnown(String number);

  /// No description provided for @resourcesEmergencyUnknown.
  ///
  /// In en, this message translates to:
  /// **'If you or someone else is in immediate danger, call your local emergency number now.'**
  String get resourcesEmergencyUnknown;

  /// No description provided for @resourcesRegion.
  ///
  /// In en, this message translates to:
  /// **'Showing help for'**
  String get resourcesRegion;

  /// No description provided for @resourcesRegionOther.
  ///
  /// In en, this message translates to:
  /// **'Another country'**
  String get resourcesRegionOther;

  /// No description provided for @resourcesRegionOtherNote.
  ///
  /// In en, this message translates to:
  /// **'We don\'t have local numbers for your region yet. These directories list helplines around the world.'**
  String get resourcesRegionOtherNote;

  /// No description provided for @resourcesCall.
  ///
  /// In en, this message translates to:
  /// **'Call {number}'**
  String resourcesCall(String number);

  /// No description provided for @resourcesText.
  ///
  /// In en, this message translates to:
  /// **'Text {number}'**
  String resourcesText(String number);

  /// No description provided for @resourcesTextWith.
  ///
  /// In en, this message translates to:
  /// **'Text {word} to {number}'**
  String resourcesTextWith(String word, String number);

  /// No description provided for @resourcesOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get resourcesOpenWebsite;

  /// No description provided for @resourcesCannotOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that here'**
  String get resourcesCannotOpenTitle;

  /// No description provided for @resourcesCannotOpenBody.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t start it for you. You can use these details on another phone or computer:'**
  String get resourcesCannotOpenBody;

  /// No description provided for @resourcesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'BaoBao is not a crisis service and is not a substitute for professional care.'**
  String get resourcesDisclaimer;

  /// No description provided for @countryUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUS;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get settingsGetHelp;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsMusicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get settingsMusicVolume;

  /// No description provided for @settingsSfxVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound effects volume'**
  String get settingsSfxVolume;

  /// No description provided for @settingsVoiceVolume.
  ///
  /// In en, this message translates to:
  /// **'BaoBao\'s voice volume'**
  String get settingsVoiceVolume;

  /// No description provided for @settingsVoiceEnabled.
  ///
  /// In en, this message translates to:
  /// **'BaoBao\'s voice'**
  String get settingsVoiceEnabled;

  /// No description provided for @settingsVoiceEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'The words always appear on screen either way.'**
  String get settingsVoiceEnabledHint;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @settingsReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReducedMotion;

  /// No description provided for @settingsReducedMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Text appears at once and BaoBao stays still.'**
  String get settingsReducedMotionHint;

  /// No description provided for @settingsClawTapMode.
  ///
  /// In en, this message translates to:
  /// **'Tap instead of hold in the claw machine'**
  String get settingsClawTapMode;

  /// No description provided for @settingsClawTapModeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap once to start the claw and again to drop it.'**
  String get settingsClawTapModeHint;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsRename.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get settingsRename;

  /// No description provided for @settingsSwitchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to {name}'**
  String settingsSwitchTo(String name);

  /// No description provided for @settingsAddProfile.
  ///
  /// In en, this message translates to:
  /// **'Add another profile'**
  String get settingsAddProfile;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for your fingerprint, face, or device PIN when opening BaoBao.'**
  String get settingsAppLockHint;

  /// No description provided for @settingsAppLockOffReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to switch off the app lock'**
  String get settingsAppLockOffReason;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes {name}\'s check-ins, conversations, stars and items from this device. It can\'t be undone.'**
  String settingsDeleteBody(String name);

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsReplayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay the tour'**
  String get settingsReplayTutorial;

  /// No description provided for @settingsNotMedical.
  ///
  /// In en, this message translates to:
  /// **'What BaoBao is'**
  String get settingsNotMedical;

  /// No description provided for @settingsLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsLicences;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get tutorialSkip;

  /// No description provided for @tutorialDone.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get tutorialDone;

  /// No description provided for @clawTitle.
  ///
  /// In en, this message translates to:
  /// **'Claw machine'**
  String get clawTitle;

  /// No description provided for @clawTries.
  ///
  /// In en, this message translates to:
  /// **'Tries: {count}'**
  String clawTries(int count);

  /// No description provided for @clawNextTry.
  ///
  /// In en, this message translates to:
  /// **'Next try in {time}'**
  String clawNextTry(String time);

  /// No description provided for @clawBuyTry.
  ///
  /// In en, this message translates to:
  /// **'+1 try ({price})'**
  String clawBuyTry(int price);

  /// No description provided for @clawHoldToMove.
  ///
  /// In en, this message translates to:
  /// **'Hold to move'**
  String get clawHoldToMove;

  /// No description provided for @clawReleaseToDrop.
  ///
  /// In en, this message translates to:
  /// **'Let go to drop'**
  String get clawReleaseToDrop;

  /// No description provided for @clawTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get clawTapToStart;

  /// No description provided for @clawTapToDrop.
  ///
  /// In en, this message translates to:
  /// **'Tap to drop'**
  String get clawTapToDrop;

  /// No description provided for @clawWait.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get clawWait;

  /// No description provided for @clawNoTries.
  ///
  /// In en, this message translates to:
  /// **'No tries left right now. One comes back every five minutes, or you can get an extra one.'**
  String get clawNoTries;

  /// No description provided for @clawBoughtTry.
  ///
  /// In en, this message translates to:
  /// **'Yay, an extra try!'**
  String get clawBoughtTry;

  /// No description provided for @clawDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'That\'s all the extra tries for today. Come back tomorrow!'**
  String get clawDailyLimit;

  /// No description provided for @clawNotEnough.
  ///
  /// In en, this message translates to:
  /// **'You need {price} stars for an extra try.'**
  String clawNotEnough(int price);

  /// No description provided for @clawMissed.
  ///
  /// In en, this message translates to:
  /// **'So close!'**
  String get clawMissed;

  /// No description provided for @clawRare.
  ///
  /// In en, this message translates to:
  /// **'★ Rare ★'**
  String get clawRare;

  /// No description provided for @clawCombo.
  ///
  /// In en, this message translates to:
  /// **'{streak} in a row! ×{multiplier}'**
  String clawCombo(int streak, String multiplier);

  /// No description provided for @clawMachineLabel.
  ///
  /// In en, this message translates to:
  /// **'Claw machine with {count} prizes inside'**
  String clawMachineLabel(int count);

  /// No description provided for @clawStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your claw stats'**
  String get clawStatsTitle;

  /// No description provided for @clawStatsPlays.
  ///
  /// In en, this message translates to:
  /// **'Plays'**
  String get clawStatsPlays;

  /// No description provided for @clawStatsWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get clawStatsWins;

  /// No description provided for @clawStatsEarnings.
  ///
  /// In en, this message translates to:
  /// **'Stars won'**
  String get clawStatsEarnings;

  /// No description provided for @clawStatsBest.
  ///
  /// In en, this message translates to:
  /// **'Best win'**
  String get clawStatsBest;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
