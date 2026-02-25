/// 앱 전체 상수 정의
/// 매직 넘버 금지 — 반드시 AppConstants 사용
abstract final class AppConstants {
  static const appName = 'SoundSense';

  /// 무료 유저 히스토리 조회 제한 (일)
  static const freeHistoryLimitDays = 7;

  /// 소음 경고 임계값 (dB)
  static const dangerThresholdDb = 85.0;
}
