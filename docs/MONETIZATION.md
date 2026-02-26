# MONETIZATION.md — 수익화 전략 & 기준선

> PRO 기능 구현 시 이 문서가 기준
> 가격, 광고 위치, 잠금 처리 방식 모두 여기서 확인

---

## 수익 구조

```
Revenue Stream 1: 광고 (AdMob)
  → 배너 광고 없음 — 전면(인터스티셜) + 리워드만 사용
  → 전면: 세션 저장 3회마다 1회
  → 리워드: 무료 유저 PDF 리포트 요청 시 (선택)
  → 측정 화면 광고 없음 (절대 금지)

Revenue Stream 2: 프리미엄 구독 (RevenueCat)
  → 월간 / 연간 구독
  → 7일 무료 체험 제공
```

---

## PRO 가격 정책

| 플랜 | 글로벌 (USD) | 한국 (KRW) |
|------|-------------|-----------|
| 월간 | $2.99/month | ₩3,900/월 |
| 연간 | $19.99/year | ₩24,900/년 |
| 절약 | 44% 절약 | 47% 절약 |
| 무료 체험 | 7일 | 7일 |

### RevenueCat 상품 ID
```
monthly:  soundsense_pro_monthly
annual:   soundsense_pro_annual
```

---

## 광고 전략 & 규칙

### 광고 유형 (배너 없음)
```
전면 광고 (Interstitial):
  트리거:   세션 저장 3회마다 1회 (saveCount % 3 == 0)
  첫 저장:  절대 표시 안 함 (첫 경험 보호)
  최소 간격: 3분 (연속 저장 시 보호)
  CPM:     $2~8 (지역별)

리워드 광고 (Rewarded):
  트리거:   무료 유저 PDF 리포트 요청 시
  안내:    "광고 시청 후 PDF 1회 다운로드"
  원칙:    유저 선택 — 강제 아님
  CPM:     $10~30
```

### 광고 절대 금지 위치
```
❌ 측정 화면 (앱의 핵심, 집중 방해 금지)
❌ 온보딩 화면
❌ 소음 가이드 바텀시트
❌ 저장 바텀시트
❌ 지도 화면
```

### PRO 유저
```
모든 광고 완전 제거 (전면 + 리워드 모두)
```

---

## PRO 기능 잠금 처리 방식

### PremiumGuard 위젯 사용
```dart
// 사용법
PremiumGuard(
  child: SessionTimelineChart(...),  // 실제 PRO 기능
  lockedChild: LockedChartPlaceholder(),  // 잠금 시 표시
)

// 규칙
- 잠긴 기능은 흐리게(opacity 0.4) 보여주고 자물쇠 아이콘
- 탭하면 PRO 업그레이드 바텀시트 등장
- 팝업은 세션당 최대 1회
```

### PRO 유도 문구 톤
```
✅ "Unlock with PRO"
✅ "Available in PRO"
✅ "See more with PRO"
❌ "Upgrade or lose access"
❌ "This feature requires PRO"  (명령조)
❌ 느낌표 과다 사용
```

---

## PRO 상태 체크

```dart
// premiumProvider에서 중앙 관리
// 모든 PRO 기능은 이것만 참조

final isPremiumProvider = Provider<bool>((ref) {
  // RevenueCat 구독 상태 확인
});

// 사용법 (Riverpod)
final isPremium = ref.watch(isPremiumProvider);
```

---

## 수익 목표 (참고)

```
월 수익 목표 (MAU 1,000명):
  전면 광고:    저장 3회당 1회 × CPM $3~5 = 월 $30~80
  리워드 광고:  PDF 요청 10% × CPM $15 = 월 $10~30
  구독:        전환율 2% × $2.99 = 월 $60
  합계:        월 $100~170

MAU 10,000명 달성 시:
  전면 광고:    월 $300~800
  리워드 광고:  월 $100~300
  구독:        월 $600
  합계:        월 $1,000~1,700
```

---

## 구독 복원 처리

```
설정 화면에 "Restore Purchases" 버튼 필수
(App Store 심사 요구사항)

RevenueCat.restorePurchases() 호출
성공 시 PRO 상태 즉시 업데이트
실패 시 에러 메시지 표시
```