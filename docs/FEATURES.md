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
- [ ] 마이크 권한 요청 및 처리
- [ ] noise_meter 실시간 dB 스트림 수신
- [ ] MeasurementNotifier (Riverpod)
- [ ] DbGaugeWidget (반원형 CustomPainter)
- [ ] DbNumberDisplay (숫자 + 애니메이션)
- [ ] LevelBadge (레벨 텍스트 + 색상)
- [ ] WaveformVisualizer (실시간 파형)
- [ ] 측정 시작/정지 버튼
- [ ] WakeLock (화면 꺼짐 방지)
- [ ] 85dB 초과 햅틱 진동
- [ ] 85dB 초과 경고 배너
- [ ] 배경 색상 레벨 연동 (opacity 8~12%)
- [ ] 세션 저장 바텀시트
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

### PRO
- [ ] 히스토리 7일 이상 조회 잠금 처리
- [ ] 세션 시간대별 라인 차트 잠금 처리
- [ ] 월간 PDF 리포트 잠금 처리
- [ ] CSV 내보내기 잠금 처리

---

## Phase 4 — 지도 기능

### 무료
- [ ] 위치 권한 요청 및 처리
- [ ] Google Maps 연동
- [ ] 내 측정 기록 마커 표시 (v1: 내 데이터만)
- [ ] 마커 색상 = 소음 레벨 색상
- [ ] 마커 탭 → 세션 요약 바텀시트
- [ ] Firestore 공유 데이터 업로드
- [ ] "Measure Here" CTA 버튼
- [ ] Beta 라벨 표시 (v1 기간)

---

## Phase 5 — 온보딩 & 설정

- [ ] 온보딩 Step 1: 앱 소개
- [ ] 온보딩 Step 2: 소음 기준 안내
- [ ] 온보딩 Step 3: 마이크 권한
- [ ] 온보딩 Step 4: 위치 권한 (선택)
- [ ] 최초 실행 여부 저장 (SharedPreferences)
- [ ] 설정 화면
- [ ] 알림 설정 (85dB 경고, 주간 리포트)
- [ ] 언어 전환 (EN / KR)
- [ ] 소음 기준 가이드 화면
- [ ] 면책 조항 화면
- [ ] 개인정보처리방침 화면

---

## Phase 6 — 수익화

- [ ] AdMob 배너 광고 (히스토리 화면 하단)
- [ ] RevenueCat 초기화
- [ ] 구독 상품 연동 (월간 / 연간)
- [ ] PremiumGuard 위젯
- [ ] PRO 업그레이드 바텀시트
- [ ] 7일 무료 체험
- [ ] 구독 복원 기능
- [ ] PRO 상태에 따른 광고 제거

---

## Phase 7 — 퀄리티 & 출시

- [ ] 모든 화면 전환 애니메이션
- [ ] 햅틱 피드백 (버튼, 경고)
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