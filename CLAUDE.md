# CLAUDE.md — SoundSense 개발 지침서
> Claude Code가 모든 작업 전에 반드시 읽는 파일

---

## 이 앱이 무엇인가
소음 측정기로 시작해서 소음 지도 플랫폼으로 진화하는 글로벌 앱.
Flutter (iOS + Android) | 영어 + 한국어 동시 지원 | 로그인 없음

---

## 코드 작성 전 반드시 확인할 파일
1. `docs/ARCHITECTURE.md` — 어느 폴더에 파일을 만들지
2. `docs/FEATURES.md` — 이 기능이 무료인지 PRO인지
3. `docs/DATA_MODEL.md` — 데이터 구조 변경 전 확인
4. `docs/CONVENTIONS.md` — 네이밍 규칙

---

## 절대 규칙 (위반 금지)

### 상태관리
- Riverpod만 사용 (setState, ChangeNotifier 금지)
- UI 파일에 비즈니스 로직 작성 금지
- 모든 로직은 Provider 또는 Notifier에만

### 아키텍처
- Feature-first 폴더 구조 엄수
- features → core 의존성 OK
- core → features 의존성 금지
- 새 기능 = 새 feature 폴더

### 국제화
- UI 문자열 하드코딩 절대 금지
- 모든 텍스트는 l10n 파일에서 관리
- 영어(EN) + 한국어(KR) 동시 작성

### PRO 기능 처리
- PRO 기능 구현 전 반드시 FEATURES.md 확인
- PRO 체크는 반드시 PremiumGuard 위젯 사용
- PRO 팝업은 세션당 최대 1회, 측정 화면에서는 절대 금지

---

## 기술 스택 (변경 금지)
```
상태관리:   flutter_riverpod
네비게이션: go_router
로컬 DB:    isar
지도:       google_maps_flutter
백엔드:     Firebase Firestore
인증:       Firebase Anonymous Auth
위치:       geolocator
차트:       fl_chart
광고:       google_mobile_ads (AdMob)
인앱결제:   purchases_flutter (RevenueCat)
국제화:     flutter_localizations
```

---

## 디자인 원칙
- 다크 테마 기본
- 측정 화면에 광고 없음 (핵심 차별점)
- 모든 전환에 애니메이션 (200~300ms)
- 소음 레벨 색상: 파랑/초록/노랑/주황/빨강 (constants/db_levels.dart 참조)

---

## 기능 완료 시 처리
기능 구현 완료 후 반드시:
1. `docs/FEATURES.md` 체크박스 업데이트
2. 새 모델 추가 시 `docs/DATA_MODEL.md` 업데이트