# FEATURES.md — 기능 명세 & 완료 체크리스트

> 기능 구현 전 반드시 확인: 무료인가 PRO인가
> 구현 완료 시 체크박스 업데이트 필수

---

## Phase 1 — 프로젝트 기반

- [ ] Flutter 프로젝트 생성
- [ ] pubspec.yaml 패키지 세팅
- [ ] Feature-first 폴더 구조 생성
- [ ] 디자인 시스템 (AppColors, AppTextStyles, AppTheme)
- [ ] go_router 라우팅 설정
- [ ] Firebase 초기화
- [ ] Firebase Anonymous Auth 연동
- [ ] l10n 설정 (EN + KR)

---

## Phase 2 — 측정 기능

### 무료
- [x] 마이크 권한 요청 및 처리
- [x] noise_meter 실시간 dB 스트림 수신
- [x] MeasurementNotifier (Riverpod)
- [x] DbGaugeWidget (반원형 CustomPainter)
  - [x] 피크 홀드 바늘 (빨간선, 3초 감쇄)
- [x] DbNumberDisplay (숫자 + 애니메이션)
- [x] LevelBadge (레벨 텍스트 + 색상)
- [x] WaveformVisualizer (실시간 파형)
- [x] 측정 시작/정지 버튼
- [ ] WakeLock (화면 꺼짐 방지)
- [x] 85dB 초과 햅틱 진동
- [ ] 85dB 초과 경고 배너
- [x] 배경 색상 레벨 연동 (opacity 8~12%)
- [x] 세션 저장 바텀시트
  - [x] Stop 탭 시 자동 등장 (별도 저장 버튼 제거)
  - [x] 기본값: 위치 ON, 지도 공유 ON, 메모 접힘
- [x] Start/Stop 버튼 하단 고정
- [x] 앱바 배경 끊김 수정
- [x] MIN / AVG / MAX 통계 표시
- [x] Fast/Slow 응답 속도 토글 (200ms / 500ms + 이동평균)
- [x] WHO 기준 안전 노출 시간 텍스트
- [ ] 위치 태그 (선택)
- [ ] 지도 공유 토글
- [ ] 소음 레벨 가이드 바텀시트
- [ ] 권한 거부 처리 UI

---

## Phase 3 — 히스토리 기능

### 무료
- [ ] Isar DB 초기화
- [ ] MeasurementSession 모델 (Isar)
- [ ] SessionRepository (CRUD)
- [ ] 히스토리 목록 화면
- [ ] 세션 카드 (날짜, 평균/최대 dB, 시간)
- [ ] 기간 필터 (이번 주 / 이번 달)
- [ ] 주간 막대 차트 (fl_chart) — 최근 7일만
- [ ] 세션 상세 화면 (평균/최대/최소)
- [ ] 소음 분포 바 (Distribution Bar)
- [ ] 세션 공유 (시스템 공유시트)
- [ ] 세션 삭제
- [x] 장소명 탭 → 지도 탭 이동 + 마커 포커스
- [x] 세션 상세 레벨 평가 텍스트
- [x] 청력 안전 시간 계산 표시
- [x] 소음 분포 도넛 차트
- [ ] 같은 장소 평균 비교 텍스트

---

## Phase 4 — 지도 기능

### 무료
- [x] Google Maps API 키 적용
- [x] 다크 맵 스타일 (map_style_dark.json)
- [x] 현재 위치 버튼
- [x] 리플 애니메이션 마커 (NoiseMapMarker)
      - 크기/색상/속도 dB 연동
- [x] 내 측정 기록 마커 표시 (위치 있는 세션만)
- [x] 마커 탭 → 간단 정보 모달 (바텀시트)
      - 장소명, 평균dB, 레벨, 날짜, 측정시간
      - [상세 보기] → session_detail_screen
- [x] Firestore 공유 업로드
- [x] Beta 라벨
- [x] 데이터 없을 때 빈 상태 UI
- [ ] [v2] 클러스터링 (데이터 쌓인 후)

---

## Phase 5 — 온보딩 & 설정

- [x] 온보딩 Step 1: 앱 소개
- [x] 온보딩 Step 2: 소음 기준 안내
- [x] 온보딩 Step 3: 마이크 권한
- [x] 온보딩 Step 4: 위치 권한 (선택)
- [x] 최초 실행 여부 저장 (SharedPreferences)
- [x] kDebugMode 온보딩 리셋 버튼 (설정 화면)
- [x] 설정 화면
- [x] 알림 설정 (85dB 경고, 주간 리포트)
- [x] 언어 전환 (EN / KR)
- [x] 소음 기준 가이드 화면
- [x] 면책 조항 화면
- [x] 개인정보처리방침 화면

---

## Phase 6 — PRO 잠금 UI

- [x] PremiumGuard 위젯 (공통 잠금 처리)
- [x] 히스토리 잠금 방식 변경 (목록 전체 표시 + 상세만 PRO 잠금)
- [x] 세션 시간대별 라인 차트 잠금 처리
- [x] 월간 PDF 리포트 잠금 처리
- [x] CSV 내보내기 잠금 처리
- [x] PRO 업그레이드 바텀시트

---

## Phase 7 — 완성도

- [x] 모든 화면 전환 애니메이션
- [x] 햅틱 피드백 (버튼, 경고)
- [x] dB 숫자 변화 부드러운 보간
- [x] 레벨 색상 크로스페이드
- [x] 게이지 바늘 스프링 애니메이션
- [x] 기기 캘리브레이션 (설정 화면 슬라이더)
- [x] Noise Card 생성 + 공유
      (측정 저장 후 카드 이미지 → 시스템 공유)

---

## Phase 8 — l10n (다국어)

- [ ] EN/KR ARB 파일 분리
- [ ] 모든 하드코딩 문자열 l10n 키로 교체
- [ ] 설정 화면 언어 전환 연동

---

## Phase 9 — 수익화

- [ ] AdMob 초기화 (google_mobile_ads)
- [ ] 전면 광고 (Interstitial) — 세션 저장 3회마다 1회
- [ ] 리워드 광고 (Rewarded) — 무료 유저 PDF 요청 시
- [ ] RevenueCat 초기화 (purchases_flutter)
- [ ] 구독 상품 연동 (월간 / 연간)
- [ ] isPremiumProvider ↔ RevenueCat 연결
- [ ] PremiumBottomSheet ↔ RevenueCat 결제 연결
- [ ] 7일 무료 체험
- [ ] 구독 복원 기능
- [ ] PRO 상태에 따른 광고 제거 (전면 + 리워드 모두)

---

## Phase 10 — 출시 준비

- [ ] 앱 아이콘
- [ ] 스플래시 스크린
- [ ] 스토어 스크린샷 5장 (EN/KR)
- [ ] Google Play 등록
- [ ] App Store 등록

---

## 보류/미결정 기능 (v2 이후)
- 커뮤니티 소음 지도 (타 유저 데이터 표시)
- 홈화면 위젯 (미니 게이지)
- 주간 소음 리포트 알림
- 지도 히트맵
- 장소 검색
- 일본어/독일어 지원
- 다크/라이트 테마 전환