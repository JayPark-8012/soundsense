import 'package:isar/isar.dart';

part 'measurement_session.g.dart';

/// 측정 세션 모델 — DATA_MODEL.md 기준
/// Isar @collection, 모든 필드 포함
@collection
class MeasurementSession {
  Id id = Isar.autoIncrement;

  // ─── 시간 ───
  @Index() // 날짜 정렬/필터에 인덱스
  late DateTime startedAt;
  late DateTime endedAt;
  late int durationSec; // 측정 시간 (초)

  // ─── 측정값 ───
  late double avgDb;
  late double maxDb;
  late double minDb;

  // ─── 사용자 입력 ───
  String? memo; // 메모 (nullable)

  // ─── 위치 (nullable — 위치 권한 없거나 사용자 거부 시) ───
  double? latitude;
  double? longitude;
  String? locationName; // "강남구 역삼동" 또는 직접 입력값

  // ─── 지도 공유 ───
  bool isSharedToMap = false; // 기본 false
  String? firestoreId; // 공유 시 Firestore 문서 ID (삭제 요청용)

  // ─── 시계열 데이터 ───
  List<double> dbSamples = []; // 1초 간격 dB 샘플 (Timeline Chart용)
}
