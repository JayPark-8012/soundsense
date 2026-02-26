import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:soundsense/core/database/isar_provider.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/firebase/anonymous_auth.dart';
import 'package:soundsense/core/firebase/firebase_provider.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// SessionRepository Provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return SessionRepository(isar, ref);
});

/// 세션 CRUD 레포지토리
class SessionRepository {
  SessionRepository(this._isar, this._ref);
  final Isar? _isar; // nullable — 웹에서는 null (WebSessionRepository 사용)
  final Ref? _ref; // nullable — 웹 WebSessionRepository에서는 null

  /// 세션 저장 — 성공 시 저장된 세션 ID 반환
  Future<int> saveSession(MeasurementSession session) async {
    try {
      final id = await _isar!.writeTxn(() {
        return _isar!.measurementSessions.put(session);
      });
      debugPrint('📊 세션 저장 완료 (id: $id)');
      return id;
    } catch (e) {
      debugPrint('❌ 세션 저장 실패: $e');
      rethrow;
    }
  }

  /// 세션 목록 조회
  /// [limitDays] 없으면 전체, 있으면 최근 N일
  Future<List<MeasurementSession>> getSessions({int? limitDays}) async {
    try {
      if (limitDays != null) {
        final cutoff = DateTime.now().subtract(Duration(days: limitDays));
        return _isar!.measurementSessions
            .filter()
            .startedAtGreaterThan(cutoff)
            .sortByStartedAtDesc()
            .findAll();
      }
      return _isar!.measurementSessions
          .where()
          .sortByStartedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('❌ 세션 목록 조회 실패: $e');
      rethrow;
    }
  }

  /// 세션 단건 조회
  Future<MeasurementSession?> getSessionById(int id) async {
    try {
      return _isar!.measurementSessions.get(id);
    } catch (e) {
      debugPrint('❌ 세션 조회 실패 (id: $id): $e');
      rethrow;
    }
  }

  /// 세션 삭제
  Future<bool> deleteSession(int id) async {
    try {
      final deleted = await _isar!.writeTxn(() {
        return _isar!.measurementSessions.delete(id);
      });
      debugPrint('🗑️ 세션 삭제 ${deleted ? "완료" : "실패"} (id: $id)');
      return deleted;
    } catch (e) {
      debugPrint('❌ 세션 삭제 실패 (id: $id): $e');
      rethrow;
    }
  }

  /// Firestore에 세션 업로드 (지도 공유)
  /// 조건: isSharedToMap == true && latitude != null
  /// 실패해도 로컬 저장에 영향 없음 (try-catch)
  Future<void> uploadToFirestore(MeasurementSession session) async {
    // 웹에서는 Firestore 업로드 스킵
    if (kIsWeb) return;

    debugPrint('🔥 uploadToFirestore 시작');
    debugPrint('🔥 조건 체크: isSharedToMap=${session.isSharedToMap}, lat=${session.latitude}');

    // 공유 조건 확인
    if (!session.isSharedToMap || session.latitude == null) {
      debugPrint('🔥 조건 미충족 → 업로드 스킵');
      return;
    }

    try {
      // deviceId 가져오기 — main.dart에서 override 안 됐으면 실패
      late final String deviceId;
      try {
        deviceId = _ref!.read(deviceIdProvider);
      } catch (e) {
        debugPrint('🔥 ❌ deviceIdProvider 읽기 실패 (익명 인증 미완료?): $e');
        return;
      }
      debugPrint('🔥 deviceId=$deviceId');

      // 앱 버전 가져오기
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // 소음 레벨 텍스트
      final level = DbLevel.fromDb(session.avgDb);

      // Firestore 컬렉션 레퍼런스
      final collection = _ref!.read(noiseReportsRef);

      debugPrint('🔥 Firestore 업로드 시도 (avgDb=${session.avgDb}, level=${level.name})');

      // DATA_MODEL.md 기준 필드로 업로드
      final docRef = await collection.add({
        'deviceId': deviceId,
        'lat': session.latitude,
        'lng': session.longitude,
        'avgDb': session.avgDb,
        'maxDb': session.maxDb,
        'level': level.name, // "silent"|"quiet"|"moderate"|"loud"|"danger"
        'recordedAt': Timestamp.fromDate(session.startedAt),
        'appVersion': appVersion,
      });

      debugPrint('🔥 업로드 성공: documentId=${docRef.id}');

      // Firestore 문서 ID를 로컬 세션에 저장 (삭제 요청용)
      session.firestoreId = docRef.id;
      await _isar!.writeTxn(() {
        return _isar!.measurementSessions.put(session);
      });

      debugPrint('🔥 firestoreId 로컬 저장 완료');
    } catch (e, st) {
      // 실패해도 로컬 저장에 영향 없음
      debugPrint('🔥 업로드 실패: error=$e');
      debugPrint('🔥 스택트레이스: $st');
    }
  }
}
