import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';

/// 웹 첫 실행 시 인메모리 저장소에 샘플 세션 10개 삽입
class MockDataSeeder {
  const MockDataSeeder._();

  static Future<void> seed(SessionRepository repo) async {
    debugPrint('🌱 웹 샘플 데이터 삽입 시작');

    final now = DateTime.now();
    final rng = math.Random(42);

    final sessions = <MeasurementSession>[
      _session(
        name: '강남역', lat: 37.4979, lng: 127.0276,
        avgDb: 72, maxDb: 85, minDb: 58,
        startedAt: now.subtract(const Duration(days: 0, hours: 3)),
        durationSec: 420, rng: rng,
      ),
      _session(
        name: '홍대입구', lat: 37.5563, lng: 126.9236,
        avgDb: 78, maxDb: 92, minDb: 65,
        startedAt: now.subtract(const Duration(days: 1, hours: 5)),
        durationSec: 600, rng: rng,
      ),
      _session(
        name: '이태원', lat: 37.5345, lng: 126.9946,
        avgDb: 88, maxDb: 98, minDb: 75,
        startedAt: now.subtract(const Duration(days: 1, hours: 10)),
        durationSec: 300, rng: rng,
      ),
      _session(
        name: '여의도 공원', lat: 37.5264, lng: 126.9246,
        avgDb: 38, maxDb: 48, minDb: 28,
        startedAt: now.subtract(const Duration(days: 2, hours: 2)),
        durationSec: 900, rng: rng,
      ),
      _session(
        name: '서울역', lat: 37.5547, lng: 126.9707,
        avgDb: 68, maxDb: 82, minDb: 55,
        startedAt: now.subtract(const Duration(days: 2, hours: 8)),
        durationSec: 480, rng: rng,
      ),
      _session(
        name: '북촌 한옥마을', lat: 37.5826, lng: 126.9831,
        avgDb: 42, maxDb: 55, minDb: 32,
        startedAt: now.subtract(const Duration(days: 3, hours: 4)),
        durationSec: 720, rng: rng,
      ),
      _session(
        name: '잠실 롯데타워', lat: 37.5126, lng: 127.1025,
        avgDb: 62, maxDb: 75, minDb: 50,
        startedAt: now.subtract(const Duration(days: 4, hours: 1)),
        durationSec: 540, rng: rng,
      ),
      _session(
        name: '명동', lat: 37.5636, lng: 126.9869,
        avgDb: 82, maxDb: 95, minDb: 70,
        startedAt: now.subtract(const Duration(days: 5, hours: 6)),
        durationSec: 360, rng: rng,
      ),
      _session(
        name: '성수동 카페거리', lat: 37.5445, lng: 127.0560,
        avgDb: 55, maxDb: 68, minDb: 42,
        startedAt: now.subtract(const Duration(days: 5, hours: 12)),
        durationSec: 660, rng: rng,
      ),
      _session(
        name: '광화문', lat: 37.5760, lng: 126.9769,
        avgDb: 65, maxDb: 78, minDb: 52,
        startedAt: now.subtract(const Duration(days: 6, hours: 3)),
        durationSec: 510, rng: rng,
      ),
    ];

    for (final s in sessions) {
      await repo.saveSession(s);
    }

    debugPrint('🌱 웹 샘플 데이터 10개 삽입 완료');
  }

  static MeasurementSession _session({
    required String name,
    required double lat,
    required double lng,
    required double avgDb,
    required double maxDb,
    required double minDb,
    required DateTime startedAt,
    required int durationSec,
    required math.Random rng,
  }) {
    return MeasurementSession()
      ..startedAt = startedAt
      ..endedAt = startedAt.add(Duration(seconds: durationSec))
      ..durationSec = durationSec
      ..avgDb = avgDb
      ..maxDb = maxDb
      ..minDb = minDb
      ..latitude = lat
      ..longitude = lng
      ..locationName = name
      ..isSharedToMap = false
      ..memo = null;
  }
}
