# ARCHITECTURE.md — 폴더 구조 & 설계 원칙

---

## 전체 폴더 구조
```
lib/
├── main.dart
├── app.dart                      # 앱 루트, 테마, 라우팅
│
├── core/                         # 앱 전체 공통 기반
│   ├── database/
│   │   ├── isar_provider.dart    # Isar 인스턴스
│   │   └── session_repository.dart
│   ├── firebase/
│   │   ├── firebase_provider.dart
│   │   └── anonymous_auth.dart   # 익명 기기 ID
│   ├── permissions/
│   │   ├── microphone_permission.dart
│   │   └── location_permission.dart
│   ├── theme/
│   │   ├── app_colors.dart       # 모든 색상 정의
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── db_calculator.dart    # dB 계산 유틸
│       └── date_formatter.dart
│
├── features/                     # 기능별 모듈
│   ├── measurement/              # 탭1: 측정
│   │   ├── providers/
│   │   │   └── measurement_provider.dart
│   │   ├── widgets/
│   │   │   ├── db_gauge_widget.dart
│   │   │   ├── db_number_display.dart
│   │   │   ├── level_badge.dart
│   │   │   └── waveform_visualizer.dart
│   │   └── screens/
│   │       ├── measurement_screen.dart
│   │       └── save_session_sheet.dart
│   │
│   ├── history/                  # 탭2: 기록
│   │   ├── providers/
│   │   │   └── history_provider.dart
│   │   ├── widgets/
│   │   │   ├── session_card.dart
│   │   │   └── weekly_bar_chart.dart
│   │   └── screens/
│   │       ├── history_screen.dart
│   │       └── session_detail_screen.dart
│   │
│   ├── map/                      # 탭3: 지도
│   │   ├── providers/
│   │   │   └── map_provider.dart
│   │   ├── widgets/
│   │   │   ├── noise_map_marker.dart
│   │   │   └── location_detail_sheet.dart
│   │   └── screens/
│   │       └── map_screen.dart
│   │
│   └── settings/                 # 탭4: 설정
│       ├── providers/
│       │   └── settings_provider.dart
│       └── screens/
│           ├── settings_screen.dart
│           └── noise_guide_screen.dart
│
├── shared/                       # feature 간 공유 컴포넌트
│   ├── widgets/
│   │   ├── premium_guard.dart    # PRO 기능 게이트
│   │   ├── premium_banner.dart   # PRO 유도 배너
│   │   └── premium_bottom_sheet.dart
│   ├── constants/
│   │   ├── db_levels.dart        # 소음 레벨 기준값 + 색상
│   │   └── app_constants.dart
│   └── providers/
│       ├── premium_provider.dart # PRO 상태 관리
│       └── locale_provider.dart  # 언어 설정
│
└── l10n/                         # 국제화
    ├── app_en.arb                # 영어
    └── app_ko.arb                # 한국어
```

---

## 의존성 규칙
```
features → core       ✅ OK
features → shared     ✅ OK
shared   → core       ✅ OK
core     → features   ❌ 금지
core     → shared     ❌ 금지
features → features   ❌ 금지 (직접 참조 금지, shared 경유)
```

---

## 새 기능 추가 시 판단 기준

새 기능이 생기면 아래 순서로 위치 결정:

```
1. 특정 탭에만 쓰이는가?
   → YES: 해당 feature 폴더 안에
   → NO: shared/widgets/ 또는 shared/providers/

2. 앱 전체 기반 기능인가? (DB, 권한, 테마 등)
   → YES: core/ 폴더

3. 여러 feature에서 쓰이는가?
   → YES: shared/ 폴더
```

---

## 라우팅 구조 (go_router)
```
/                   → MeasurementScreen (홈)
/history            → HistoryScreen
/history/:id        → SessionDetailScreen
/map                → MapScreen
/settings           → SettingsScreen
/settings/guide     → NoiseGuideScreen
/onboarding         → OnboardingScreen (최초 1회)
```