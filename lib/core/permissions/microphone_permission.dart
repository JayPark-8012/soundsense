import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// 마이크 권한 상태
enum MicPermissionState {
  unknown,           // 아직 확인 안 함
  granted,           // 허용됨
  denied,            // 거부됨 (재요청 가능)
  permanentlyDenied, // 영구 거부됨 (설정에서만 변경 가능)
}

/// 마이크 권한 관리 Provider
final micPermissionProvider =
    StateNotifierProvider<MicPermissionNotifier, MicPermissionState>(
  (ref) => MicPermissionNotifier(),
);

class MicPermissionNotifier extends StateNotifier<MicPermissionState> {
  MicPermissionNotifier() : super(MicPermissionState.unknown);

  /// 현재 권한 상태 확인 (요청 없이 조회만)
  Future<void> check() async {
    try {
      final status = await Permission.microphone.status;
      state = _mapStatus(status);
    } catch (e) {
      state = MicPermissionState.denied;
    }
  }

  /// 권한 요청 다이얼로그 표시
  Future<MicPermissionState> request() async {
    try {
      final status = await Permission.microphone.request();
      state = _mapStatus(status);
    } catch (e) {
      state = MicPermissionState.denied;
    }
    return state;
  }

  /// 영구 거부 여부 확인
  bool get isPermanentlyDenied =>
      state == MicPermissionState.permanentlyDenied;

  /// 설정 앱 열기 (영구 거부 시 사용)
  Future<bool> openSettings() => openAppSettings();

  MicPermissionState _mapStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited =>
        MicPermissionState.granted,
      PermissionStatus.permanentlyDenied =>
        MicPermissionState.permanentlyDenied,
      _ => MicPermissionState.denied,
    };
  }
}
