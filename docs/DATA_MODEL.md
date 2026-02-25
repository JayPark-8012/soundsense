# DATA_MODEL.md — 데이터 구조 정의

> Isar 스키마 변경은 마이그레이션 필요 → 처음에 제대로 설계
> 필드 추가/변경 전 반드시 이 문서 확인

---

## 로컬 DB (Isar)

### MeasurementSession
```dart
@collection
class MeasurementSession {
  Id id = Isar.autoIncrement;

  // 시간
  @Index()                          // 날짜 정렬/필터에 인덱스
  late DateTime startedAt;
  late DateTime endedAt;
  late int durationSec;             // 측정 시간 (초)

  // 측정값
  late double avgDb;
  late double maxDb;
  late double minDb;

  // 사용자 입력
  String? memo;                     // 메모 (nullable)

  // 위치 (nullable — 위치 권한 없거나 사용자 거부 시)
  double? latitude;
  double? longitude;
  String? locationName;             // "강남구 역삼동" 또는 직접 입력값

  // 지도 공유
  bool isSharedToMap = false;       // 기본 false
  String? firestoreId;              // 공유 시 Firestore 문서 ID (삭제 요청용)
}
```

### 설계 원칙
```
위치 필드를 처음부터 포함 (nullable)
  → 지도 기능 추가 시 과거 데이터도 활용 가능
  → 위치 없어도 세션 저장 가능

firestoreId 포함
  → 유저가 공유한 데이터 삭제 요청 가능
  → GDPR 대응

durationSec 별도 저장
  → endedAt - startedAt 계산보다 빠른 조회
```

### 주요 쿼리 패턴
```dart
// 최근 7일 (무료 유저)
isar.measurementSessions
  .where()
  .startedAtGreaterThan(DateTime.now().subtract(Duration(days: 7)))
  .sortByStartedAtDesc()
  .findAll()

// 전체 (PRO 유저)
isar.measurementSessions
  .where()
  .sortByStartedAtDesc()
  .findAll()

// 주간 평균 차트용
isar.measurementSessions
  .where()
  .startedAtBetween(weekStart, weekEnd)
  .findAll()
```

---

## Firebase Firestore (지도 공유)

### noiseReports 컬렉션
```
noiseReports/
  {reportId}/                       # 자동 생성 ID
    deviceId:     string            # Firebase Anonymous UID
    lat:          number            # 위도
    lng:          number            # 경도
    avgDb:        number            # 평균 dB
    maxDb:        number            # 최대 dB
    level:        string            # "silent"|"quiet"|"moderate"|"loud"|"danger"
    recordedAt:   timestamp         # 측정 시각
    appVersion:   string            # 버전 추적 (어뷰징 분석용)
```

### 보안 규칙 원칙
```
읽기: 누구나 가능 (지도 조회)
쓰기: 인증된 익명 유저만 (Anonymous Auth)
삭제: 본인 deviceId만 (자신이 올린 데이터만)
수정: 불가 (새로 올리기)
```

### 저장하지 않는 것 (개인정보 보호)
```
❌ 정확한 실시간 위치 추적
❌ 사용자 식별 가능한 정보
❌ 메모 내용
❌ 측정 히스토리 전체
```

---

## 로컬 설정 (SharedPreferences)

```
isOnboardingDone:   bool      온보딩 완료 여부
selectedLocale:     string    "en" | "ko"
is85dbAlertOn:      bool      85dB 경고 알림 (기본 true)
isWeeklyReportOn:   bool      주간 리포트 알림 (기본 false)
```

---

## 향후 추가 예정 필드 (v2)

### MeasurementSession에 추가 예정
```dart
// v2: 상세 분석용
// List<double>? dbSamples;       // 시간별 샘플 (PRO 차트용)
//                                 → 저장 용량 이슈로 신중히 결정
```

### noiseReports에 추가 예정
```
// v2: 커뮤니티 지도용
// upvoteCount:  number           # 신뢰도 투표
// placeId:      string           # Google Places ID
```