import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
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
final mapMarkersProvider = FutureProvider<List<MarkerData>>((ref) async {
  final sessions = await ref.watch(mapSessionsProvider.future);
  debugPrint('🗺️ mapMarkers: ${sessions.length}개 세션 → 비트맵 변환 시작');
  final markers = <MarkerData>[];

  for (final session in sessions) {
    final level = DbLevel.fromDb(session.avgDb);
    try {
      final icon = await widgetToMarkerBitmap(
        avgDb: session.avgDb,
        level: level,
      );
      markers.add(MarkerData(
        session: session,
        position: LatLng(session.latitude!, session.longitude!),
        icon: icon,
      ));
    } catch (e, st) {
      debugPrint('❌ 마커 비트맵 변환 실패 (id: ${session.id}): $e\n$st');
    }
  }

  debugPrint('🗺️ mapMarkers: 변환 완료 ${markers.length}개');
  return markers;
});

// ─── 현재 위치 ───

/// 현재 내 위치를 가져오는 Provider
/// 위치 권한이 허용된 경우에만 위치 반환
final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  final permState = ref.watch(locationPermissionProvider);
  if (permState != LocationPermissionState.granted) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    debugPrint('현재 위치 가져오기 실패: $e');
    return null;
  }
});
