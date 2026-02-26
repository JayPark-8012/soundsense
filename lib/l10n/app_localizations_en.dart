// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SoundSense';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get pro => 'PRO';

  @override
  String get tabMeasure => 'Measure';

  @override
  String get tabHistory => 'History';

  @override
  String get tabMap => 'Map';

  @override
  String get tabSettings => 'Settings';

  @override
  String get startMeasuring => 'Start Measuring';

  @override
  String get stopAndSave => 'Stop & Save';

  @override
  String safeExposure(String time) {
    return 'Safe exposure: $time remaining';
  }

  @override
  String get safeForExtended => 'Safe for extended exposure 🟢';

  @override
  String get responseFast => 'Fast';

  @override
  String get responseSlow => 'Slow';

  @override
  String get minLabel => 'MIN';

  @override
  String get avgLabel => 'AVG';

  @override
  String get maxLabel => 'MAX';

  @override
  String get dbUnit => 'dB';

  @override
  String get levelSilent => 'Very Quiet';

  @override
  String get levelQuiet => 'Quiet';

  @override
  String get levelModerate => 'Moderate';

  @override
  String get levelLoud => 'Loud';

  @override
  String get levelDanger => 'Dangerous';

  @override
  String get saveSession => 'Save Measurement';

  @override
  String get sessionSaved => 'Measurement saved!';

  @override
  String get dontSave => 'Don\'t Save';

  @override
  String get addMemo => '+ Add memo';

  @override
  String get shareToMap => 'Share to noise map';

  @override
  String get includeLocation => 'Include location';

  @override
  String get measurementComplete => 'Measurement Complete 💾';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No measurements yet';

  @override
  String get historyEmptySub =>
      'Tap the mic button to start\nyour first measurement';

  @override
  String get startMeasuringBtn => 'Start Measuring';

  @override
  String get lastSevenDays => 'Last 7 Days';

  @override
  String get allHistory => 'All History';

  @override
  String get duration => 'Duration';

  @override
  String get location => 'Location';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get sessionDetail => 'Session Detail';

  @override
  String get levelEvaluation => 'Level Evaluation';

  @override
  String get safeExposureTime => 'Safe Exposure Time';

  @override
  String get noiseDistribution => 'Noise Distribution';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get noiseCard => 'Noise Card';

  @override
  String get shareResult => 'Share Result';

  @override
  String get deleteSession => 'Delete';

  @override
  String get deleteConfirm => 'Delete this measurement?';

  @override
  String get deleteConfirmDesc => 'This action cannot be undone.';

  @override
  String get mapTitle => 'Noise Map';

  @override
  String get mapEmpty => 'No noise data yet';

  @override
  String get mapEmptySub =>
      'Save measurements with location\nto see them on the map';

  @override
  String get goMeasure => 'Go Measure';

  @override
  String get mapBeta => 'Beta';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get calibration => 'Microphone Calibration';

  @override
  String get calibrationDesc =>
      'Compare with a professional sound meter\nand adjust if needed';

  @override
  String get calibrationDefault => '0.0 dB (Default)';

  @override
  String get resetDefault => 'Reset to Default';

  @override
  String get noiseAlert => 'Noise Alert';

  @override
  String get noiseAlertDesc => 'Alert when noise exceeds 85dB';

  @override
  String get language => 'Language';

  @override
  String get proFeatures => 'PRO Features';

  @override
  String get monthlyPdf => 'Monthly PDF Report';

  @override
  String get csvExport => 'CSV Export';

  @override
  String get noiseGuide => 'Noise Level Guide';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get version => 'Version';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get onboardingTitle1 => 'Measure the world\naround you';

  @override
  String get onboardingDesc1 =>
      'Real-time noise measurement,\nhistory & noise map';

  @override
  String get getStarted => 'Get Started →';

  @override
  String get onboardingTitle2 => 'Know your noise levels';

  @override
  String get onboardingDesc2 =>
      'WHO recommends limiting exposure\nto 85dB+ for hearing safety';

  @override
  String get onboardingTitle3 => 'Let\'s start measuring';

  @override
  String get allowMicrophone => 'Allow Microphone';

  @override
  String get noAudioRecorded => '✓ No audio is recorded or stored';

  @override
  String get onlyDbMeasured => '✓ Only decibel levels are measured';

  @override
  String get dataOnDevice => '✓ Data stays on your device';

  @override
  String get onboardingTitle4 => 'Tag your measurements';

  @override
  String get onboardingDesc4 =>
      'Auto-tag locations & contribute\nto the community noise map';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get unlockPro => 'Unlock with PRO';

  @override
  String get getLifetimePro => 'Get Lifetime PRO';

  @override
  String get proFeature1 => '✨ Unlimited history';

  @override
  String get proFeature2 => '📊 Timeline chart';

  @override
  String get proFeature3 => '📄 Monthly PDF report';

  @override
  String get proFeature4 => '📁 CSV export';

  @override
  String get proFeature5 => '🚫 Ad-free experience';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get purchaseFailedTitle => 'Purchase Failed';

  @override
  String get purchaseFailedMessage =>
      'Something went wrong.\nPlease try again later.';

  @override
  String get restoreFailedTitle => 'Restore Failed';

  @override
  String get restoreFailedMessage =>
      'Something went wrong.\nPlease try again later.';

  @override
  String get proActivated => 'PRO unlocked successfully!';

  @override
  String get restoreNoPurchase => 'No previous purchase found.';

  @override
  String get ok => 'OK';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get locationPermissionDenied =>
      'Location permission denied.\nPlease enable in Settings.';

  @override
  String get micPermissionDenied =>
      'Microphone permission required\nto measure noise levels.';

  @override
  String get uploadFailed => 'Map upload failed. Saved locally.';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get noMeasurementsToExport => 'No measurements to export';

  @override
  String get noMeasurementsThisMonth => 'No measurements this month';

  @override
  String get noiseCardDisclaimer =>
      'For reference only. ±5-10dB variance possible.';

  @override
  String get saveToPhotos => 'Save to Photos';

  @override
  String get share => 'Share';

  @override
  String get measuredWith => 'Measured with SoundSense';

  @override
  String get micAccessRequired => 'Microphone Access Required';

  @override
  String get micPermDeniedPermanent =>
      'Microphone access was permanently denied.\nPlease enable it in your device settings.';

  @override
  String get micPermNeeded =>
      'SoundSense needs microphone access\nto measure noise levels.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get immediateHearingRisk => 'Immediate hearing risk!';

  @override
  String get memo => 'Memo';

  @override
  String get memoHint => 'Add a note about this session...';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get locationHint => 'e.g. Gangnam Station, Office...';

  @override
  String get shareToMapDesc => 'Help others discover noise levels in your area';

  @override
  String get addLocationToShare => 'Add location to enable sharing';

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get failedToLoadSessions => 'Failed to load sessions';

  @override
  String get failedToLoadSession => 'Failed to load session';

  @override
  String get failedToSaveSession => 'Failed to save session';

  @override
  String get failedToExportCsv => 'Failed to export CSV';

  @override
  String get failedToGenerateCard => 'Failed to generate card';

  @override
  String get failedToGeneratePdf => 'Failed to generate PDF report';

  @override
  String get invalidSessionId => 'Invalid session ID';

  @override
  String get sessionNotFound => 'Session not found';

  @override
  String get timelineChart => 'Timeline Chart';

  @override
  String get evalSilent => 'Very peaceful environment';

  @override
  String get evalQuiet => 'Comfortable noise level';

  @override
  String get evalModerate => 'Normal everyday noise';

  @override
  String get evalLoud => 'Prolonged exposure may cause fatigue';

  @override
  String get evalDanger => '⚠️ Risk of hearing damage with prolonged exposure';

  @override
  String get safeForExtendedExposure => 'Safe for extended exposure';

  @override
  String safeHours(String hours) {
    return '$hours hours';
  }

  @override
  String safeMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get levelDistribution => 'Level Distribution';

  @override
  String get locationRecorded => 'Location recorded';

  @override
  String get sharedBadge => 'Shared';

  @override
  String get availableInPro => 'Available in PRO';

  @override
  String get noTimelineData => 'No timeline data for this session';

  @override
  String get noiseShareText => 'SoundSense noise data';

  @override
  String get savedToPhotos => 'Saved to Photos';

  @override
  String get saving => 'Saving...';

  @override
  String get sharing => 'Sharing...';

  @override
  String get shareNoiseReport => 'SoundSense - Noise Report';

  @override
  String shareDate(String date) {
    return 'Date: $date';
  }

  @override
  String shareLevel(String level) {
    return 'Level: $level';
  }

  @override
  String shareAvg(String value) {
    return 'AVG: $value dB';
  }

  @override
  String shareMax(String value) {
    return 'MAX: $value dB';
  }

  @override
  String shareMin(String value) {
    return 'MIN: $value dB';
  }

  @override
  String shareLocationLabel(String location) {
    return 'Location: $location';
  }

  @override
  String shareMemoLabel(String memo) {
    return 'Memo: $memo';
  }

  @override
  String get dbAvg => 'dB avg';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get weekMon => 'Mon';

  @override
  String get weekTue => 'Tue';

  @override
  String get weekWed => 'Wed';

  @override
  String get weekThu => 'Thu';

  @override
  String get weekFri => 'Fri';

  @override
  String get weekSat => 'Sat';

  @override
  String get weekSun => 'Sun';

  @override
  String get viewDetails => 'View Details';

  @override
  String get information => 'Information';

  @override
  String get soundsensePro => 'SoundSense PRO';

  @override
  String get proDesc => 'Unlock full history, detailed charts, and more';

  @override
  String get proFromPrice => 'Just \$8.99';

  @override
  String get proActiveDesc => 'All premium features are unlocked.';

  @override
  String get proActiveLabel => 'Active';

  @override
  String get calibrationSubtitle => 'Adjust if readings seem too high or low';

  @override
  String get calibrationWarning =>
      'This is not a certified measurement device. Values are approximate.';

  @override
  String get proPricing => '\$8.99 one-time purchase';

  @override
  String get oneTimePurchase => 'One-time payment · No subscription';

  @override
  String get proLifetime => 'Lifetime';

  @override
  String get proAdFree => 'Ad-free experience';

  @override
  String get proUnlimitedHistory => 'Unlimited history';

  @override
  String get proTimelineChart => 'Timeline chart';

  @override
  String get proMonthlyReport => 'Monthly PDF report';

  @override
  String get proCsvExport => 'CSV export';

  @override
  String get understandingNoiseLevels => 'Understanding Noise Levels';

  @override
  String get howLoudIsWorld => 'How loud is the world around you?';

  @override
  String get guideWhisper => 'Whisper, dawn';

  @override
  String get guideQuietOffice => 'Quiet office';

  @override
  String get guideConversation => 'Normal conversation';

  @override
  String get guideTvVacuum => 'TV, vacuum cleaner';

  @override
  String get guideAlarmStreet => 'Alarm, busy street';

  @override
  String get guideProlongedRisk => 'Prolonged exposure risk';

  @override
  String get guideConstruction => 'Construction, subway';

  @override
  String get guideAirplane => 'Airplane takeoff';

  @override
  String get whoGuideline => 'WHO Guideline';

  @override
  String get whoWarningText =>
      'Continuous exposure to 85 dB or above for 8 hours can cause permanent hearing damage.';

  @override
  String get disclaimerContent =>
      'Measurements are for reference only.\n\nSmartphone microphones may have ±5–10 dB variance compared to professional sound level meters.\n\nNot suitable for legal, medical, or official use.';

  @override
  String get ppDataCollectTitle => 'Data We Collect';

  @override
  String get ppDataCollect1 => 'Noise level measurements (dB values)';

  @override
  String get ppDataCollect2 =>
      'Location (optional, only when you share to map)';

  @override
  String get ppDataCollect3 => 'Anonymous device ID (Firebase Anonymous Auth)';

  @override
  String get ppDataNotCollectTitle => 'Data We Do NOT Collect';

  @override
  String get ppDataNotCollect1 => 'Personal information (name, email, phone)';

  @override
  String get ppDataNotCollect2 => 'Audio recordings — no sound is ever stored';

  @override
  String get ppDataNotCollect3 => 'Browsing history or app usage tracking';

  @override
  String get ppAnonAuthTitle => 'Anonymous Authentication';

  @override
  String get ppAnonAuthBody =>
      'SoundSense uses Firebase Anonymous Auth to generate a random device identifier. This ID cannot be traced back to you personally. It is used only to associate your shared map data for deletion requests.';

  @override
  String get ppDataStorageTitle => 'Data Storage';

  @override
  String get ppDataStorageBody =>
      'All measurement sessions are stored locally on your device. Only data you explicitly choose to share is uploaded to Firebase Firestore for the community noise map.';

  @override
  String get ppDataDeletionTitle => 'Data Deletion';

  @override
  String get ppDataDeletionBody =>
      'You can delete all your data at any time using the button below. This removes all local measurement sessions and any data you shared to the noise map.';

  @override
  String get ppContactTitle => 'Contact';

  @override
  String get ppContactBody =>
      'For questions about this privacy policy or data requests, please contact us at:\nsupport@soundsense.app';

  @override
  String get deleteAllMyData => 'Delete All My Data';

  @override
  String get deleteAllDataTitle => 'Delete All Data?';

  @override
  String get deleteAllDataBody =>
      'This will permanently delete:\n\n• All local measurement sessions\n• All your data shared to the noise map\n\nThis action cannot be undone.';

  @override
  String get deleteEverything => 'Delete Everything';

  @override
  String get allDataDeleted => 'All data has been deleted.';

  @override
  String get failedToDeleteData => 'Failed to delete data';

  @override
  String get enableLaterInSettings => 'You can enable this later in Settings';

  @override
  String get levelSilentDesc => 'Library, early morning';

  @override
  String get levelQuietDesc => 'Office, quiet street';

  @override
  String get levelModerateDesc => 'Conversation, cafe';

  @override
  String get levelLoudDesc => 'Busy street, restaurant';

  @override
  String get levelDangerDesc => 'Hearing damage risk';
}
