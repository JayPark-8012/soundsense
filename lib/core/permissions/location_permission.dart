import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// 위치 권한 상태
enum LocationPermissionState {
  unknown,           // 아직 확인 안 함
  granted,           // 허용됨
  denied,            // 거부됨 (재요청 가능)
  permanentlyDenied, // 영구 거부됨 (설정에서만 변경 가능)
}

/// 위치 권한 관리 Provider
final locationPermissionProvider =
    StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
  (ref) => LocationPermissionNotifier(),
);

class LocationPermissionNotifier
    extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier() : super(LocationPermissionState.unknown);

  /// 현재 권한 상태 확인 (요청 없이 조회만)
  Future<void> check() async {
    try {
      final status = await Permission.location.status;
      state = _mapStatus(status);
    } catch (e) {
      state = LocationPermissionState.denied;
    }
  }

  /// 권한 요청 다이얼로그 표시
  Future<LocationPermissionState> request() async {
    try {
      final status = await Permission.location.request();
      state = _mapStatus(status);
    } catch (e) {
      state = LocationPermissionState.denied;
    }
    return state;
  }

  /// 영구 거부 여부 확인
  bool get isPermanentlyDenied =>
      state == LocationPermissionState.permanentlyDenied;

  /// 설정 앱 열기 (영구 거부 시 사용)
  Future<bool> openSettings() => openAppSettings();

  LocationPermissionState _mapStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited =>
        LocationPermissionState.granted,
      PermissionStatus.permanentlyDenied =>
        LocationPermissionState.permanentlyDenied,
      _ => LocationPermissionState.denied,
    };
  }
}
