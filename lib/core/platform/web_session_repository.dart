import 'package:flutter/foundation.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';

/// 웹 전용 인메모리 세션 저장소
/// Isar 3.x가 웹을 지원하지 않으므로 인메모리 List로 대체
class WebSessionRepository extends SessionRepository {
  WebSessionRepository() : super(null, null);

  final List<MeasurementSession> _sessions = [];
  int _nextId = 1;

  @override
  Future<int> saveSession(MeasurementSession session) async {
    session.id = _nextId++;
    _sessions.add(session);
    debugPrint('📊 [Web] 세션 저장 완료 (id: ${session.id})');
    return session.id;
  }

  @override
  Future<List<MeasurementSession>> getSessions({int? limitDays}) async {
    var result = List<MeasurementSession>.from(_sessions);
    if (limitDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: limitDays));
      result = result.where((s) => s.startedAt.isAfter(cutoff)).toList();
    }
    result.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return result;
  }

  @override
  Future<MeasurementSession?> getSessionById(int id) async {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> deleteSession(int id) async {
    final before = _sessions.length;
    _sessions.removeWhere((s) => s.id == id);
    final deleted = _sessions.length < before;
    debugPrint('🗑️ [Web] 세션 삭제 ${deleted ? "완료" : "실패"} (id: $id)');
    return deleted;
  }

  @override
  Future<void> uploadToFirestore(MeasurementSession session) async {
    // 웹에서는 Firestore 업로드 스킵
  }
}
