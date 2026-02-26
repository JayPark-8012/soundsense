import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soundsense/core/platform/platform_providers.dart'
    show kWebMockLatitude, kWebMockLongitude;
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/firebase/firebase_provider.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/features/map/widgets/noise_map_marker.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

// ─── 위치 있는 세션 목록 ───

/// 위치 정보(lat/lng)가 있는 세션만 필터링하여 반환
final mapSessionsProvider =
    FutureProvider<List<MeasurementSession>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final all = await repo.getSessions();
  final filtered = all
      .where((s) => s.latitude != null && s.longitude != null)
      .toList();
  debugPrint('🗺️ mapSessions: 전체 ${all.length}개 → 위치 있는 ${filtered.length}개');
  return filtered;
});

// ─── 마커 데이터 ───

/// 세션별 마커 데이터 — 위치 + BitmapDescriptor
class MarkerData {
  const MarkerData({
    required this.session,
    required this.position,
    required this.icon,
  });

  final MeasurementSession session;
  final LatLng position;
  final BitmapDescriptor icon;
}

/// 위치 있는 세션 → Google Maps Marker 데이터로 변환
/// 로컬 Isar + Firestore noiseReports 병합 (중복 제거)
final mapMarkersProvider = FutureProvider<List<MarkerData>>((ref) async {
  // ─── 1. 로컬 마커 ───
  final sessions = await ref.watch(mapSessionsProvider.future);
  debugPrint('🗺️ mapMarkers: 로컬 ${sessions.length}개 세션 → 비트맵 변환 시작');
  final localMarkers = <MarkerData>[];

  for (final session in sessions) {
    final level = DbLevel.fromDb(session.avgDb);
    try {
      final icon = await widgetToMarkerBitmap(
        avgDb: session.avgDb,
        level: level,
      );
      localMarkers.add(MarkerData(
        session: session,
        position: LatLng(session.latitude!, session.longitude!),
        icon: icon,
      ));
    } catch (e, st) {
      debugPrint('❌ 마커 비트맵 변환 실패 (id: ${session.id}): $e\n$st');
    }
  }

  // ─── 2. Firestore 마커 병합 ───
  List<MarkerData> firestoreMarkers = [];
  try {
    firestoreMarkers = await ref.watch(firestoreReportsProvider.future);
  } catch (e) {
    debugPrint('🗺️ Firestore 마커 로드 실패: $e');
  }

  // 로컬 세션의 firestoreId 목록 (중복 제거용)
  final localFirestoreIds = localMarkers
      .where((m) => m.session.firestoreId != null)
      .map((m) => m.session.firestoreId!)
      .toSet();

  // Firestore 마커 중 로컬에 없는 것만 추가
  final uniqueFirestoreMarkers = firestoreMarkers
      .where((m) =>
          m.session.firestoreId != null &&
          !localFirestoreIds.contains(m.session.firestoreId))
      .toList();

  debugPrint(
      '🗺️ mapMarkers 최종: 로컬 ${localMarkers.length}개 + Firestore ${uniqueFirestoreMarkers.length}개');
  return [...localMarkers, ...uniqueFirestoreMarkers];
});

// ─── Firestore noiseReports 조회 ───

/// Firestore noiseReports 컬렉션에서 최근 데이터를 가져와 마커로 변환
final firestoreReportsProvider =
    FutureProvider<List<MarkerData>>((ref) async {
  if (kIsWeb) return [];

  try {
    final collection = ref.read(noiseReportsRef);
    debugPrint('🗺️ [Firestore] noiseReports 조회 시작');

    final snapshot = await collection
        .orderBy('recordedAt', descending: true)
        .limit(200)
        .get();

    debugPrint('🗺️ [Firestore] 결과: ${snapshot.docs.length}개 문서');

    final markers = <MarkerData>[];
    for (final doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final avgDb = (data['avgDb'] as num).toDouble();
        final maxDb = (data['maxDb'] as num?)?.toDouble() ?? avgDb;
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final level = DbLevel.fromDb(avgDb);
        final recordedAt = data['recordedAt'] is Timestamp
            ? (data['recordedAt'] as Timestamp).toDate()
            : DateTime.now();

        // Firestore 데이터를 MeasurementSession으로 변환
        final session = MeasurementSession()
          ..startedAt = recordedAt
          ..endedAt = recordedAt
          ..durationSec = 0 // Firestore에 duration 없음
          ..avgDb = avgDb
          ..maxDb = maxDb
          ..minDb = avgDb // Firestore에 minDb 없음
          ..latitude = lat
          ..longitude = lng
          ..firestoreId = doc.id
          ..isSharedToMap = true;

        final icon = await widgetToMarkerBitmap(avgDb: avgDb, level: level);
        markers.add(MarkerData(
          session: session,
          position: LatLng(lat, lng),
          icon: icon,
        ));
      } catch (e) {
        debugPrint('❌ Firestore 마커 변환 실패 (doc: ${doc.id}): $e');
      }
    }

    debugPrint('🗺️ [Firestore] 마커 변환 완료: ${markers.length}개');
    return markers;
  } catch (e) {
    debugPrint('🗺️ [Firestore] noiseReports 조회 실패: $e');
    return [];
  }
});

// ─── 현재 위치 ───

/// 현재 내 위치를 가져오는 Provider
/// 위치 권한이 허용된 경우에만 위치 반환
final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  // 웹: 서울시청 고정 좌표
  if (kIsWeb) {
    return const LatLng(kWebMockLatitude, kWebMockLongitude);
  }

  final permState = ref.watch(locationPermissionProvider);
  if (permState != LocationPermissionState.granted) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    debugPrint('📍 getCurrentPosition 실패, lastKnown 시도: $e');
    // 타임아웃 등 실패 시 마지막 알려진 위치 폴백
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LatLng(last.latitude, last.longitude);
      }
    } catch (e2) {
      debugPrint('📍 getLastKnownPosition도 실패: $e2');
    }
    return null;
  }
});
