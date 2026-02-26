// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'SoundSense';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get skip => '건너뛰기';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get close => '닫기';

  @override
  String get retry => '다시 시도';

  @override
  String get pro => 'PRO';

  @override
  String get tabMeasure => '측정';

  @override
  String get tabHistory => '기록';

  @override
  String get tabMap => '지도';

  @override
  String get tabSettings => '설정';

  @override
  String get startMeasuring => '측정 시작';

  @override
  String get stopAndSave => '정지 & 저장';

  @override
  String safeExposure(String time) {
    return '안전 노출 시간: $time 남음';
  }

  @override
  String get safeForExtended => '장시간 노출 안전 🟢';

  @override
  String get responseFast => '빠름';

  @override
  String get responseSlow => '느림';

  @override
  String get minLabel => '최소';

  @override
  String get avgLabel => '평균';

  @override
  String get maxLabel => '최대';

  @override
  String get dbUnit => 'dB';

  @override
  String get levelSilent => '매우 조용';

  @override
  String get levelQuiet => '조용';

  @override
  String get levelModerate => '보통';

  @override
  String get levelLoud => '시끄러움';

  @override
  String get levelDanger => '위험';

  @override
  String get saveSession => '측정 저장';

  @override
  String get sessionSaved => '저장되었습니다!';

  @override
  String get dontSave => '저장 안 함';

  @override
  String get addMemo => '+ 메모 추가';

  @override
  String get shareToMap => '소음 지도에 공유';

  @override
  String get includeLocation => '위치 포함';

  @override
  String get measurementComplete => '측정 완료 💾';

  @override
  String get historyTitle => '기록';

  @override
  String get historyEmpty => '측정 기록이 없습니다';

  @override
  String get historyEmptySub => '마이크 버튼을 눌러\n첫 번째 측정을 시작하세요';

  @override
  String get startMeasuringBtn => '측정 시작';

  @override
  String get lastSevenDays => '최근 7일';

  @override
  String get allHistory => '전체 기록';

  @override
  String get duration => '측정 시간';

  @override
  String get location => '위치';

  @override
  String get unknownLocation => '위치 없음';

  @override
  String get sessionDetail => '측정 상세';

  @override
  String get levelEvaluation => '레벨 평가';

  @override
  String get safeExposureTime => '안전 노출 시간';

  @override
  String get noiseDistribution => '소음 분포';

  @override
  String get exportCsv => 'CSV 내보내기';

  @override
  String get noiseCard => '노이즈 카드';

  @override
  String get shareResult => '결과 공유';

  @override
  String get deleteSession => '삭제';

  @override
  String get deleteConfirm => '이 측정을 삭제할까요?';

  @override
  String get deleteConfirmDesc => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get mapTitle => '소음 지도';

  @override
  String get mapEmpty => '소음 데이터가 없습니다';

  @override
  String get mapEmptySub => '위치를 포함해 측정을 저장하면\n지도에서 확인할 수 있어요';

  @override
  String get goMeasure => '측정하러 가기';

  @override
  String get mapBeta => '베타';

  @override
  String get currentLocation => '현재 위치';

  @override
  String get settingsTitle => '설정';

  @override
  String get calibration => '마이크 캘리브레이션';

  @override
  String get calibrationDesc => '전문 소음계와 비교해서\n필요시 조정하세요';

  @override
  String get calibrationDefault => '0.0 dB (기본값)';

  @override
  String get resetDefault => '기본값으로 초기화';

  @override
  String get noiseAlert => '소음 경고';

  @override
  String get noiseAlertDesc => '85dB 초과 시 알림';

  @override
  String get language => '언어';

  @override
  String get proFeatures => 'PRO 기능';

  @override
  String get monthlyPdf => '월간 PDF 리포트';

  @override
  String get csvExport => 'CSV 내보내기';

  @override
  String get noiseGuide => '소음 레벨 가이드';

  @override
  String get disclaimer => '면책 조항';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get version => '버전';

  @override
  String get resetOnboarding => '온보딩 다시 보기';

  @override
  String get onboardingTitle1 => '주변의 소음을\n측정해보세요';

  @override
  String get onboardingDesc1 => '실시간 소음 측정,\n기록 & 소음 지도';

  @override
  String get getStarted => '시작하기 →';

  @override
  String get onboardingTitle2 => '소음 기준을 알아보세요';

  @override
  String get onboardingDesc2 => 'WHO는 청력 보호를 위해\n85dB 이상 노출 제한을 권고합니다';

  @override
  String get onboardingTitle3 => '측정을 시작해볼까요';

  @override
  String get allowMicrophone => '마이크 허용';

  @override
  String get noAudioRecorded => '✓ 오디오는 녹음/저장되지 않습니다';

  @override
  String get onlyDbMeasured => '✓ 데시벨 수치만 측정됩니다';

  @override
  String get dataOnDevice => '✓ 데이터는 기기에만 저장됩니다';

  @override
  String get onboardingTitle4 => '측정 위치를 태그하세요';

  @override
  String get onboardingDesc4 => '위치를 자동 태그하고\n커뮤니티 소음 지도에 기여하세요';

  @override
  String get allowLocation => '위치 허용';

  @override
  String get maybeLater => '나중에';

  @override
  String get unlockPro => 'PRO로 잠금 해제';

  @override
  String get getLifetimePro => 'Lifetime PRO 구매';

  @override
  String get proFeature1 => '✨ 무제한 기록';

  @override
  String get proFeature2 => '📊 타임라인 차트';

  @override
  String get proFeature3 => '📄 월간 PDF 리포트';

  @override
  String get proFeature4 => '📁 CSV 내보내기';

  @override
  String get proFeature5 => '🚫 광고 없는 사용';

  @override
  String get restorePurchase => '구매 복원';

  @override
  String get purchaseFailedTitle => '구매 실패';

  @override
  String get purchaseFailedMessage => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';

  @override
  String get restoreFailedTitle => '복원 실패';

  @override
  String get restoreFailedMessage => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';

  @override
  String get proActivated => 'PRO가 활성화되었습니다!';

  @override
  String get restoreNoPurchase => '이전 구매 내역이 없습니다.';

  @override
  String get ok => '확인';

  @override
  String get locationUnavailable => '위치를 가져올 수 없습니다';

  @override
  String get locationPermissionDenied => '위치 권한이 거부되었습니다.\n설정에서 허용해주세요.';

  @override
  String get micPermissionDenied => '소음 측정을 위해\n마이크 권한이 필요합니다.';

  @override
  String get uploadFailed => '지도 업로드 실패. 로컬에 저장됨.';

  @override
  String get comingSoon => '준비 중입니다!';

  @override
  String get noMeasurementsToExport => '내보낼 측정 데이터가 없습니다';

  @override
  String get noMeasurementsThisMonth => '이번 달 측정 데이터가 없습니다';

  @override
  String get noiseCardDisclaimer => '참고용입니다. ±5-10dB 오차가 있을 수 있습니다.';

  @override
  String get saveToPhotos => '사진 저장';

  @override
  String get share => '공유';

  @override
  String get measuredWith => 'SoundSense로 측정';

  @override
  String get micAccessRequired => '마이크 접근 필요';

  @override
  String get micPermDeniedPermanent =>
      '마이크 접근이 영구적으로 거부되었습니다.\n기기 설정에서 허용해주세요.';

  @override
  String get micPermNeeded => '소음 측정을 위해\n마이크 접근이 필요합니다.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get immediateHearingRisk => '즉각적인 청력 손상 위험!';

  @override
  String get memo => '메모';

  @override
  String get memoHint => '이 세션에 대한 메모를 추가하세요...';

  @override
  String get enterManually => '직접 입력';

  @override
  String get gettingLocation => '위치 가져오는 중...';

  @override
  String get locationHint => '예: 강남역, 사무실...';

  @override
  String get shareToMapDesc => '주변 소음 수준을 다른 사용자에게 알려주세요';

  @override
  String get addLocationToShare => '공유하려면 위치를 추가하세요';

  @override
  String get failedToSave => '저장 실패';

  @override
  String get failedToLoadSessions => '세션을 불러오지 못했습니다';

  @override
  String get failedToLoadSession => '세션을 불러오지 못했습니다';

  @override
  String get failedToSaveSession => '세션 저장에 실패했습니다';

  @override
  String get failedToExportCsv => 'CSV 내보내기에 실패했습니다';

  @override
  String get failedToGenerateCard => '카드 생성에 실패했습니다';

  @override
  String get failedToGeneratePdf => 'PDF 리포트 생성에 실패했습니다';

  @override
  String get invalidSessionId => '잘못된 세션 ID';

  @override
  String get sessionNotFound => '세션을 찾을 수 없습니다';

  @override
  String get timelineChart => '타임라인 차트';

  @override
  String get evalSilent => '매우 평화로운 환경';

  @override
  String get evalQuiet => '편안한 소음 수준';

  @override
  String get evalModerate => '일상적인 소음 수준';

  @override
  String get evalLoud => '장시간 노출 시 피로감 유발 가능';

  @override
  String get evalDanger => '⚠️ 장시간 노출 시 청력 손상 위험';

  @override
  String get safeForExtendedExposure => '장시간 노출 안전';

  @override
  String safeHours(String hours) {
    return '$hours시간';
  }

  @override
  String safeMinutes(String minutes) {
    return '$minutes분';
  }

  @override
  String get levelDistribution => '레벨 분포';

  @override
  String get locationRecorded => '위치 기록됨';

  @override
  String get sharedBadge => '공유됨';

  @override
  String get availableInPro => 'PRO에서 사용 가능';

  @override
  String get noTimelineData => '이 세션의 타임라인 데이터가 없습니다';

  @override
  String get noiseShareText => 'SoundSense 소음 데이터';

  @override
  String get savedToPhotos => '사진에 저장됨';

  @override
  String get saving => '저장 중...';

  @override
  String get sharing => '공유 중...';

  @override
  String get shareNoiseReport => 'SoundSense - 소음 리포트';

  @override
  String shareDate(String date) {
    return '날짜: $date';
  }

  @override
  String shareLevel(String level) {
    return '레벨: $level';
  }

  @override
  String shareAvg(String value) {
    return '평균: $value dB';
  }

  @override
  String shareMax(String value) {
    return '최대: $value dB';
  }

  @override
  String shareMin(String value) {
    return '최소: $value dB';
  }

  @override
  String shareLocationLabel(String location) {
    return '위치: $location';
  }

  @override
  String shareMemoLabel(String memo) {
    return '메모: $memo';
  }

  @override
  String get dbAvg => 'dB 평균';

  @override
  String get weeklyAverage => '주간 평균';

  @override
  String get weekMon => '월';

  @override
  String get weekTue => '화';

  @override
  String get weekWed => '수';

  @override
  String get weekThu => '목';

  @override
  String get weekFri => '금';

  @override
  String get weekSat => '토';

  @override
  String get weekSun => '일';

  @override
  String get viewDetails => '상세 보기';

  @override
  String get information => '정보';

  @override
  String get soundsensePro => 'SoundSense PRO';

  @override
  String get proDesc => '무제한 기록, 상세 차트 등을 잠금 해제하세요';

  @override
  String get proFromPrice => '단돈 ₩9,900';

  @override
  String get proActiveDesc => '모든 프리미엄 기능이 활성화되어 있습니다.';

  @override
  String get proActiveLabel => 'Active';

  @override
  String get calibrationSubtitle => '측정값이 너무 높거나 낮으면 조정하세요';

  @override
  String get calibrationWarning => '이 기기는 공인 측정 장치가 아닙니다. 값은 근사치입니다.';

  @override
  String get proPricing => '₩9,900 1회 결제';

  @override
  String get oneTimePurchase => '1회 결제 · 구독 없음';

  @override
  String get proLifetime => '평생 이용';

  @override
  String get proAdFree => '광고 없는 사용';

  @override
  String get proUnlimitedHistory => '무제한 기록';

  @override
  String get proTimelineChart => '타임라인 차트';

  @override
  String get proMonthlyReport => '월간 PDF 리포트';

  @override
  String get proCsvExport => 'CSV 내보내기';

  @override
  String get understandingNoiseLevels => '소음 수준 이해하기';

  @override
  String get howLoudIsWorld => '주변은 얼마나 시끄러울까요?';

  @override
  String get guideWhisper => '속삭임, 새벽';

  @override
  String get guideQuietOffice => '조용한 사무실';

  @override
  String get guideConversation => '일상 대화';

  @override
  String get guideTvVacuum => 'TV, 청소기';

  @override
  String get guideAlarmStreet => '알람, 번화한 거리';

  @override
  String get guideProlongedRisk => '장시간 노출 위험';

  @override
  String get guideConstruction => '공사장, 지하철';

  @override
  String get guideAirplane => '비행기 이륙';

  @override
  String get whoGuideline => 'WHO 가이드라인';

  @override
  String get whoWarningText => '85 dB 이상에 8시간 연속 노출되면 영구적인 청력 손상을 유발할 수 있습니다.';

  @override
  String get disclaimerContent =>
      '측정값은 참고용입니다.\n\n스마트폰 마이크 특성상 전문 소음계 대비 ±5~10 dB 오차가 발생할 수 있습니다.\n\n법적 분쟁, 의료적 판단의 공식 자료로 사용할 수 없습니다.';

  @override
  String get ppDataCollectTitle => '수집하는 데이터';

  @override
  String get ppDataCollect1 => '소음 측정값 (dB 수치)';

  @override
  String get ppDataCollect2 => '위치 (선택, 지도 공유 시에만)';

  @override
  String get ppDataCollect3 => '익명 기기 ID (Firebase 익명 인증)';

  @override
  String get ppDataNotCollectTitle => '수집하지 않는 데이터';

  @override
  String get ppDataNotCollect1 => '개인정보 (이름, 이메일, 전화번호)';

  @override
  String get ppDataNotCollect2 => '오디오 녹음 — 소리를 저장하지 않습니다';

  @override
  String get ppDataNotCollect3 => '브라우징 기록 또는 앱 사용 추적';

  @override
  String get ppAnonAuthTitle => '익명 인증';

  @override
  String get ppAnonAuthBody =>
      'SoundSense는 Firebase 익명 인증을 사용하여 임의의 기기 식별자를 생성합니다. 이 ID는 개인을 추적하는 데 사용할 수 없습니다. 공유된 지도 데이터의 삭제 요청을 위해서만 사용됩니다.';

  @override
  String get ppDataStorageTitle => '데이터 저장';

  @override
  String get ppDataStorageBody =>
      '모든 측정 세션은 기기에 로컬로 저장됩니다. 명시적으로 공유를 선택한 데이터만 커뮤니티 소음 지도를 위해 Firebase Firestore에 업로드됩니다.';

  @override
  String get ppDataDeletionTitle => '데이터 삭제';

  @override
  String get ppDataDeletionBody =>
      '아래 버튼을 사용하여 언제든지 모든 데이터를 삭제할 수 있습니다. 이 기능은 모든 로컬 측정 세션과 소음 지도에 공유한 데이터를 제거합니다.';

  @override
  String get ppContactTitle => '문의';

  @override
  String get ppContactBody =>
      '이 개인정보처리방침 또는 데이터 요청에 대한 질문은 아래로 연락해주세요:\nsupport@soundsense.app';

  @override
  String get deleteAllMyData => '내 데이터 모두 삭제';

  @override
  String get deleteAllDataTitle => '모든 데이터를 삭제할까요?';

  @override
  String get deleteAllDataBody =>
      '다음 항목이 영구 삭제됩니다:\n\n• 모든 로컬 측정 세션\n• 소음 지도에 공유한 모든 데이터\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteEverything => '모두 삭제';

  @override
  String get allDataDeleted => '모든 데이터가 삭제되었습니다.';

  @override
  String get failedToDeleteData => '데이터 삭제에 실패했습니다';

  @override
  String get enableLaterInSettings => '나중에 설정에서 활성화할 수 있습니다';

  @override
  String get levelSilentDesc => '도서관, 이른 아침';

  @override
  String get levelQuietDesc => '사무실, 조용한 거리';

  @override
  String get levelModerateDesc => '대화, 카페';

  @override
  String get levelLoudDesc => '번화한 거리, 레스토랑';

  @override
  String get levelDangerDesc => '청력 손상 위험';
}
