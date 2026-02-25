# CONVENTIONS.md — 코딩 컨벤션 & 네이밍 규칙

---

## 파일명
```
전부 snake_case 사용
measurement_screen.dart     ✅
MeasurementScreen.dart      ❌

위젯 파일은 반드시 _widget.dart로 끝내기
db_gauge_widget.dart        ✅
db_gauge.dart               ❌ (위젯인데 _widget 없음)

스크린 파일은 반드시 _screen.dart로 끝내기
measurement_screen.dart     ✅

바텀시트는 _sheet.dart
save_session_sheet.dart     ✅

Provider/Notifier는 _provider.dart
measurement_provider.dart   ✅
```

---

## 클래스명 (PascalCase)
```
위젯:     DbGaugeWidget, LevelBadge, SessionCard
스크린:   MeasurementScreen, HistoryScreen
Provider: MeasurementNotifier, HistoryNotifier
모델:     MeasurementSession
Repository: SessionRepository
```

---

## Riverpod 네이밍 패턴
```
// Provider
final measurementProvider = StateNotifierProvider<MeasurementNotifier, MeasurementState>

// Notifier
class MeasurementNotifier extends StateNotifier<MeasurementState>

// 읽기 전용 Provider
final sessionListProvider = FutureProvider<List<MeasurementSession>>

// 규칙: 기능명 + Provider / 기능명 + Notifier
측정: measurementProvider, MeasurementNotifier
히스토리: historyProvider, HistoryNotifier
지도: mapProvider, MapNotifier
프리미엄: premiumProvider, PremiumNotifier
```

---

## 상수 위치
```
소음 레벨 기준값, 색상:    lib/shared/constants/db_levels.dart
앱 전체 상수 (키값 등):    lib/shared/constants/app_constants.dart
색상:                      lib/core/theme/app_colors.dart
```

---

## 주석
```
언어: 한국어로 통일
스타일: /// 문서 주석 (퍼블릭 API)
        // 인라인 주석 (복잡한 로직 설명)

예시:
/// 실시간 dB 값을 소음 레벨로 변환하는 유틸리티
double calculateAvgDb(List<double> samples) {
  // 로그 평균 계산 (단순 산술 평균 X, 에너지 평균 사용)
  ...
}
```

---

## 국제화 (l10n) 규칙
```
UI에 표시되는 모든 문자열 → l10n 파일에서 가져오기
하드코딩 절대 금지

// 금지
Text('Measure')                          ❌

// 올바른 방법
Text(context.l10n.measureButtonLabel)    ✅

키 네이밍: camelCase, 화면명_역할
measureButtonLabel
historyEmptyMessage
settingsPremiumTitle
```

---

## 에러 처리
```
// 모든 async 함수는 try-catch
// 에러는 Riverpod State의 error 필드로 전달
// UI에서 에러 상태 반드시 처리

sealed class MeasurementState {
  const MeasurementState();
}
class MeasurementIdle extends MeasurementState {}
class MeasurementActive extends MeasurementState { ... }
class MeasurementError extends MeasurementState { final String message; }
```

---

## 금지 사항
```
❌ setState() 사용
❌ UI 파일에 비즈니스 로직
❌ 문자열 하드코딩 (l10n 사용)
❌ 색상 하드코딩 (AppColors 사용)
❌ 숫자 매직 넘버 (상수 파일에 정의)
❌ BuildContext를 Provider 밖에서 저장
```