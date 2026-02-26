import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SoundSense'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @tabMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get tabMeasure;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @startMeasuring.
  ///
  /// In en, this message translates to:
  /// **'Start Measuring'**
  String get startMeasuring;

  /// No description provided for @stopAndSave.
  ///
  /// In en, this message translates to:
  /// **'Stop & Save'**
  String get stopAndSave;

  /// No description provided for @safeExposure.
  ///
  /// In en, this message translates to:
  /// **'Safe exposure: {time} remaining'**
  String safeExposure(String time);

  /// No description provided for @safeForExtended.
  ///
  /// In en, this message translates to:
  /// **'Safe for extended exposure 🟢'**
  String get safeForExtended;

  /// No description provided for @responseFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get responseFast;

  /// No description provided for @responseSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get responseSlow;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minLabel;

  /// No description provided for @avgLabel.
  ///
  /// In en, this message translates to:
  /// **'AVG'**
  String get avgLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get maxLabel;

  /// No description provided for @dbUnit.
  ///
  /// In en, this message translates to:
  /// **'dB'**
  String get dbUnit;

  /// No description provided for @levelSilent.
  ///
  /// In en, this message translates to:
  /// **'Very Quiet'**
  String get levelSilent;

  /// No description provided for @levelQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get levelQuiet;

  /// No description provided for @levelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get levelModerate;

  /// No description provided for @levelLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud'**
  String get levelLoud;

  /// No description provided for @levelDanger.
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get levelDanger;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveSession;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurement saved!'**
  String get sessionSaved;

  /// No description provided for @dontSave.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Save'**
  String get dontSave;

  /// No description provided for @addMemo.
  ///
  /// In en, this message translates to:
  /// **'+ Add memo'**
  String get addMemo;

  /// No description provided for @shareToMap.
  ///
  /// In en, this message translates to:
  /// **'Share to noise map'**
  String get shareToMap;

  /// No description provided for @includeLocation.
  ///
  /// In en, this message translates to:
  /// **'Include location'**
  String get includeLocation;

  /// No description provided for @measurementComplete.
  ///
  /// In en, this message translates to:
  /// **'Measurement Complete 💾'**
  String get measurementComplete;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic button to start\nyour first measurement'**
  String get historyEmptySub;

  /// No description provided for @startMeasuringBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Measuring'**
  String get startMeasuringBtn;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lastSevenDays;

  /// No description provided for @allHistory.
  ///
  /// In en, this message translates to:
  /// **'All History'**
  String get allHistory;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @sessionDetail.
  ///
  /// In en, this message translates to:
  /// **'Session Detail'**
  String get sessionDetail;

  /// No description provided for @levelEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Level Evaluation'**
  String get levelEvaluation;

  /// No description provided for @safeExposureTime.
  ///
  /// In en, this message translates to:
  /// **'Safe Exposure Time'**
  String get safeExposureTime;

  /// No description provided for @noiseDistribution.
  ///
  /// In en, this message translates to:
  /// **'Noise Distribution'**
  String get noiseDistribution;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @noiseCard.
  ///
  /// In en, this message translates to:
  /// **'Noise Card'**
  String get noiseCard;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSession;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this measurement?'**
  String get deleteConfirm;

  /// No description provided for @deleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteConfirmDesc;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Noise Map'**
  String get mapTitle;

  /// No description provided for @mapEmpty.
  ///
  /// In en, this message translates to:
  /// **'No noise data yet'**
  String get mapEmpty;

  /// No description provided for @mapEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Save measurements with location\nto see them on the map'**
  String get mapEmptySub;

  /// No description provided for @goMeasure.
  ///
  /// In en, this message translates to:
  /// **'Go Measure'**
  String get goMeasure;

  /// No description provided for @mapBeta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get mapBeta;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @calibration.
  ///
  /// In en, this message translates to:
  /// **'Microphone Calibration'**
  String get calibration;

  /// No description provided for @calibrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare with a professional sound meter\nand adjust if needed'**
  String get calibrationDesc;

  /// No description provided for @calibrationDefault.
  ///
  /// In en, this message translates to:
  /// **'0.0 dB (Default)'**
  String get calibrationDefault;

  /// No description provided for @resetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetDefault;

  /// No description provided for @noiseAlert.
  ///
  /// In en, this message translates to:
  /// **'Noise Alert'**
  String get noiseAlert;

  /// No description provided for @noiseAlertDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert when noise exceeds 85dB'**
  String get noiseAlertDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @proFeatures.
  ///
  /// In en, this message translates to:
  /// **'PRO Features'**
  String get proFeatures;

  /// No description provided for @monthlyPdf.
  ///
  /// In en, this message translates to:
  /// **'Monthly PDF Report'**
  String get monthlyPdf;

  /// No description provided for @csvExport.
  ///
  /// In en, this message translates to:
  /// **'CSV Export'**
  String get csvExport;

  /// No description provided for @noiseGuide.
  ///
  /// In en, this message translates to:
  /// **'Noise Level Guide'**
  String get noiseGuide;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @resetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset Onboarding'**
  String get resetOnboarding;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Measure the world\naround you'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Real-time noise measurement,\nhistory & noise map'**
  String get onboardingDesc1;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started →'**
  String get getStarted;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Know your noise levels'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'WHO recommends limiting exposure\nto 85dB+ for hearing safety'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start measuring'**
  String get onboardingTitle3;

  /// No description provided for @allowMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Allow Microphone'**
  String get allowMicrophone;

  /// No description provided for @noAudioRecorded.
  ///
  /// In en, this message translates to:
  /// **'✓ No audio is recorded or stored'**
  String get noAudioRecorded;

  /// No description provided for @onlyDbMeasured.
  ///
  /// In en, this message translates to:
  /// **'✓ Only decibel levels are measured'**
  String get onlyDbMeasured;

  /// No description provided for @dataOnDevice.
  ///
  /// In en, this message translates to:
  /// **'✓ Data stays on your device'**
  String get dataOnDevice;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Tag your measurements'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Auto-tag locations & contribute\nto the community noise map'**
  String get onboardingDesc4;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @unlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock with PRO'**
  String get unlockPro;

  /// No description provided for @getLifetimePro.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime PRO'**
  String get getLifetimePro;

  /// No description provided for @proFeature1.
  ///
  /// In en, this message translates to:
  /// **'✨ Unlimited history'**
  String get proFeature1;

  /// No description provided for @proFeature2.
  ///
  /// In en, this message translates to:
  /// **'📊 Timeline chart'**
  String get proFeature2;

  /// No description provided for @proFeature3.
  ///
  /// In en, this message translates to:
  /// **'📄 Monthly PDF report'**
  String get proFeature3;

  /// No description provided for @proFeature4.
  ///
  /// In en, this message translates to:
  /// **'📁 CSV export'**
  String get proFeature4;

  /// No description provided for @proFeature5.
  ///
  /// In en, this message translates to:
  /// **'🚫 Ad-free experience'**
  String get proFeature5;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchase;

  /// No description provided for @purchaseFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get purchaseFailedTitle;

  /// No description provided for @purchaseFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.\nPlease try again later.'**
  String get purchaseFailedMessage;

  /// No description provided for @restoreFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreFailedTitle;

  /// No description provided for @restoreFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.\nPlease try again later.'**
  String get restoreFailedMessage;

  /// No description provided for @proActivated.
  ///
  /// In en, this message translates to:
  /// **'PRO unlocked successfully!'**
  String get proActivated;

  /// No description provided for @restoreNoPurchase.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get restoreNoPurchase;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.\nPlease enable in Settings.'**
  String get locationPermissionDenied;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required\nto measure noise levels.'**
  String get micPermissionDenied;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Map upload failed. Saved locally.'**
  String get uploadFailed;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @noMeasurementsToExport.
  ///
  /// In en, this message translates to:
  /// **'No measurements to export'**
  String get noMeasurementsToExport;

  /// No description provided for @noMeasurementsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No measurements this month'**
  String get noMeasurementsThisMonth;

  /// No description provided for @noiseCardDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'For reference only. ±5-10dB variance possible.'**
  String get noiseCardDisclaimer;

  /// No description provided for @saveToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Save to Photos'**
  String get saveToPhotos;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @measuredWith.
  ///
  /// In en, this message translates to:
  /// **'Measured with SoundSense'**
  String get measuredWith;

  /// No description provided for @micAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access Required'**
  String get micAccessRequired;

  /// No description provided for @micPermDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was permanently denied.\nPlease enable it in your device settings.'**
  String get micPermDeniedPermanent;

  /// No description provided for @micPermNeeded.
  ///
  /// In en, this message translates to:
  /// **'SoundSense needs microphone access\nto measure noise levels.'**
  String get micPermNeeded;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @immediateHearingRisk.
  ///
  /// In en, this message translates to:
  /// **'Immediate hearing risk!'**
  String get immediateHearingRisk;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @memoHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about this session...'**
  String get memoHint;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gangnam Station, Office...'**
  String get locationHint;

  /// No description provided for @shareToMapDesc.
  ///
  /// In en, this message translates to:
  /// **'Help others discover noise levels in your area'**
  String get shareToMapDesc;

  /// No description provided for @addLocationToShare.
  ///
  /// In en, this message translates to:
  /// **'Add location to enable sharing'**
  String get addLocationToShare;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @failedToLoadSessions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sessions'**
  String get failedToLoadSessions;

  /// No description provided for @failedToLoadSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to load session'**
  String get failedToLoadSession;

  /// No description provided for @failedToSaveSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to save session'**
  String get failedToSaveSession;

  /// No description provided for @failedToExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Failed to export CSV'**
  String get failedToExportCsv;

  /// No description provided for @failedToGenerateCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate card'**
  String get failedToGenerateCard;

  /// No description provided for @failedToGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF report'**
  String get failedToGeneratePdf;

  /// No description provided for @invalidSessionId.
  ///
  /// In en, this message translates to:
  /// **'Invalid session ID'**
  String get invalidSessionId;

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get sessionNotFound;

  /// No description provided for @timelineChart.
  ///
  /// In en, this message translates to:
  /// **'Timeline Chart'**
  String get timelineChart;

  /// No description provided for @evalSilent.
  ///
  /// In en, this message translates to:
  /// **'Very peaceful environment'**
  String get evalSilent;

  /// No description provided for @evalQuiet.
  ///
  /// In en, this message translates to:
  /// **'Comfortable noise level'**
  String get evalQuiet;

  /// No description provided for @evalModerate.
  ///
  /// In en, this message translates to:
  /// **'Normal everyday noise'**
  String get evalModerate;

  /// No description provided for @evalLoud.
  ///
  /// In en, this message translates to:
  /// **'Prolonged exposure may cause fatigue'**
  String get evalLoud;

  /// No description provided for @evalDanger.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Risk of hearing damage with prolonged exposure'**
  String get evalDanger;

  /// No description provided for @safeForExtendedExposure.
  ///
  /// In en, this message translates to:
  /// **'Safe for extended exposure'**
  String get safeForExtendedExposure;

  /// No description provided for @safeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String safeHours(String hours);

  /// No description provided for @safeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String safeMinutes(String minutes);

  /// No description provided for @levelDistribution.
  ///
  /// In en, this message translates to:
  /// **'Level Distribution'**
  String get levelDistribution;

  /// No description provided for @locationRecorded.
  ///
  /// In en, this message translates to:
  /// **'Location recorded'**
  String get locationRecorded;

  /// No description provided for @sharedBadge.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedBadge;

  /// No description provided for @availableInPro.
  ///
  /// In en, this message translates to:
  /// **'Available in PRO'**
  String get availableInPro;

  /// No description provided for @noTimelineData.
  ///
  /// In en, this message translates to:
  /// **'No timeline data for this session'**
  String get noTimelineData;

  /// No description provided for @noiseShareText.
  ///
  /// In en, this message translates to:
  /// **'SoundSense noise data'**
  String get noiseShareText;

  /// No description provided for @savedToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos'**
  String get savedToPhotos;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get sharing;

  /// No description provided for @shareNoiseReport.
  ///
  /// In en, this message translates to:
  /// **'SoundSense - Noise Report'**
  String get shareNoiseReport;

  /// No description provided for @shareDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String shareDate(String date);

  /// No description provided for @shareLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String shareLevel(String level);

  /// No description provided for @shareAvg.
  ///
  /// In en, this message translates to:
  /// **'AVG: {value} dB'**
  String shareAvg(String value);

  /// No description provided for @shareMax.
  ///
  /// In en, this message translates to:
  /// **'MAX: {value} dB'**
  String shareMax(String value);

  /// No description provided for @shareMin.
  ///
  /// In en, this message translates to:
  /// **'MIN: {value} dB'**
  String shareMin(String value);

  /// No description provided for @shareLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String shareLocationLabel(String location);

  /// No description provided for @shareMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo: {memo}'**
  String shareMemoLabel(String memo);

  /// No description provided for @dbAvg.
  ///
  /// In en, this message translates to:
  /// **'dB avg'**
  String get dbAvg;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get weeklyAverage;

  /// No description provided for @weekMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekMon;

  /// No description provided for @weekTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekTue;

  /// No description provided for @weekWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekWed;

  /// No description provided for @weekThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekThu;

  /// No description provided for @weekFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekFri;

  /// No description provided for @weekSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekSat;

  /// No description provided for @weekSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekSun;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @soundsensePro.
  ///
  /// In en, this message translates to:
  /// **'SoundSense PRO'**
  String get soundsensePro;

  /// No description provided for @proDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock full history, detailed charts, and more'**
  String get proDesc;

  /// No description provided for @proFromPrice.
  ///
  /// In en, this message translates to:
  /// **'Just \$8.99'**
  String get proFromPrice;

  /// No description provided for @proActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'All premium features are unlocked.'**
  String get proActiveDesc;

  /// No description provided for @proActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get proActiveLabel;

  /// No description provided for @calibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust if readings seem too high or low'**
  String get calibrationSubtitle;

  /// No description provided for @calibrationWarning.
  ///
  /// In en, this message translates to:
  /// **'This is not a certified measurement device. Values are approximate.'**
  String get calibrationWarning;

  /// No description provided for @proPricing.
  ///
  /// In en, this message translates to:
  /// **'\$8.99 one-time purchase'**
  String get proPricing;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time payment · No subscription'**
  String get oneTimePurchase;

  /// No description provided for @proLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get proLifetime;

  /// No description provided for @proAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get proAdFree;

  /// No description provided for @proUnlimitedHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlimited history'**
  String get proUnlimitedHistory;

  /// No description provided for @proTimelineChart.
  ///
  /// In en, this message translates to:
  /// **'Timeline chart'**
  String get proTimelineChart;

  /// No description provided for @proMonthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly PDF report'**
  String get proMonthlyReport;

  /// No description provided for @proCsvExport.
  ///
  /// In en, this message translates to:
  /// **'CSV export'**
  String get proCsvExport;

  /// No description provided for @understandingNoiseLevels.
  ///
  /// In en, this message translates to:
  /// **'Understanding Noise Levels'**
  String get understandingNoiseLevels;

  /// No description provided for @howLoudIsWorld.
  ///
  /// In en, this message translates to:
  /// **'How loud is the world around you?'**
  String get howLoudIsWorld;

  /// No description provided for @guideWhisper.
  ///
  /// In en, this message translates to:
  /// **'Whisper, dawn'**
  String get guideWhisper;

  /// No description provided for @guideQuietOffice.
  ///
  /// In en, this message translates to:
  /// **'Quiet office'**
  String get guideQuietOffice;

  /// No description provided for @guideConversation.
  ///
  /// In en, this message translates to:
  /// **'Normal conversation'**
  String get guideConversation;

  /// No description provided for @guideTvVacuum.
  ///
  /// In en, this message translates to:
  /// **'TV, vacuum cleaner'**
  String get guideTvVacuum;

  /// No description provided for @guideAlarmStreet.
  ///
  /// In en, this message translates to:
  /// **'Alarm, busy street'**
  String get guideAlarmStreet;

  /// No description provided for @guideProlongedRisk.
  ///
  /// In en, this message translates to:
  /// **'Prolonged exposure risk'**
  String get guideProlongedRisk;

  /// No description provided for @guideConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction, subway'**
  String get guideConstruction;

  /// No description provided for @guideAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane takeoff'**
  String get guideAirplane;

  /// No description provided for @whoGuideline.
  ///
  /// In en, this message translates to:
  /// **'WHO Guideline'**
  String get whoGuideline;

  /// No description provided for @whoWarningText.
  ///
  /// In en, this message translates to:
  /// **'Continuous exposure to 85 dB or above for 8 hours can cause permanent hearing damage.'**
  String get whoWarningText;

  /// No description provided for @disclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'Measurements are for reference only.\n\nSmartphone microphones may have ±5–10 dB variance compared to professional sound level meters.\n\nNot suitable for legal, medical, or official use.'**
  String get disclaimerContent;

  /// No description provided for @ppDataCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get ppDataCollectTitle;

  /// No description provided for @ppDataCollect1.
  ///
  /// In en, this message translates to:
  /// **'Noise level measurements (dB values)'**
  String get ppDataCollect1;

  /// No description provided for @ppDataCollect2.
  ///
  /// In en, this message translates to:
  /// **'Location (optional, only when you share to map)'**
  String get ppDataCollect2;

  /// No description provided for @ppDataCollect3.
  ///
  /// In en, this message translates to:
  /// **'Anonymous device ID (Firebase Anonymous Auth)'**
  String get ppDataCollect3;

  /// No description provided for @ppDataNotCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Data We Do NOT Collect'**
  String get ppDataNotCollectTitle;

  /// No description provided for @ppDataNotCollect1.
  ///
  /// In en, this message translates to:
  /// **'Personal information (name, email, phone)'**
  String get ppDataNotCollect1;

  /// No description provided for @ppDataNotCollect2.
  ///
  /// In en, this message translates to:
  /// **'Audio recordings — no sound is ever stored'**
  String get ppDataNotCollect2;

  /// No description provided for @ppDataNotCollect3.
  ///
  /// In en, this message translates to:
  /// **'Browsing history or app usage tracking'**
  String get ppDataNotCollect3;

  /// No description provided for @ppAnonAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Authentication'**
  String get ppAnonAuthTitle;

  /// No description provided for @ppAnonAuthBody.
  ///
  /// In en, this message translates to:
  /// **'SoundSense uses Firebase Anonymous Auth to generate a random device identifier. This ID cannot be traced back to you personally. It is used only to associate your shared map data for deletion requests.'**
  String get ppAnonAuthBody;

  /// No description provided for @ppDataStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get ppDataStorageTitle;

  /// No description provided for @ppDataStorageBody.
  ///
  /// In en, this message translates to:
  /// **'All measurement sessions are stored locally on your device. Only data you explicitly choose to share is uploaded to Firebase Firestore for the community noise map.'**
  String get ppDataStorageBody;

  /// No description provided for @ppDataDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get ppDataDeletionTitle;

  /// No description provided for @ppDataDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete all your data at any time using the button below. This removes all local measurement sessions and any data you shared to the noise map.'**
  String get ppDataDeletionBody;

  /// No description provided for @ppContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get ppContactTitle;

  /// No description provided for @ppContactBody.
  ///
  /// In en, this message translates to:
  /// **'For questions about this privacy policy or data requests, please contact us at:\nsupport@soundsense.app'**
  String get ppContactBody;

  /// No description provided for @deleteAllMyData.
  ///
  /// In en, this message translates to:
  /// **'Delete All My Data'**
  String get deleteAllMyData;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:\n\n• All local measurement sessions\n• All your data shared to the noise map\n\nThis action cannot be undone.'**
  String get deleteAllDataBody;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get deleteEverything;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted.'**
  String get allDataDeleted;

  /// No description provided for @failedToDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data'**
  String get failedToDeleteData;

  /// No description provided for @enableLaterInSettings.
  ///
  /// In en, this message translates to:
  /// **'You can enable this later in Settings'**
  String get enableLaterInSettings;

  /// No description provided for @levelSilentDesc.
  ///
  /// In en, this message translates to:
  /// **'Library, early morning'**
  String get levelSilentDesc;

  /// No description provided for @levelQuietDesc.
  ///
  /// In en, this message translates to:
  /// **'Office, quiet street'**
  String get levelQuietDesc;

  /// No description provided for @levelModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Conversation, cafe'**
  String get levelModerateDesc;

  /// No description provided for @levelLoudDesc.
  ///
  /// In en, this message translates to:
  /// **'Busy street, restaurant'**
  String get levelLoudDesc;

  /// No description provided for @levelDangerDesc.
  ///
  /// In en, this message translates to:
  /// **'Hearing damage risk'**
  String get levelDangerDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
