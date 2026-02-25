import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/map/providers/map_provider.dart';
import 'package:soundsense/features/map/widgets/marker_info_sheet.dart';

/// 지도 화면 — 탭 3
/// Google Maps + 다크 스타일 + 소음 마커 + 바텀시트
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focusSessionId});

  /// 세션 상세에서 장소 탭 시 전달되는 세션 ID
  final String? focusSessionId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  String? _darkMapStyle;
  bool _didFocusSession = false;

  /// 서울 시청 기본 좌표 (위치 없을 때 초기값)
  static const _defaultPosition = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    // 위치 권한 확인 (아직 unknown이면)
    Future.microtask(() {
      final perm = ref.read(locationPermissionProvider);
      if (perm == LocationPermissionState.unknown) {
        ref.read(locationPermissionProvider.notifier).check();
      }
    });
  }

  /// 다크 맵 스타일 JSON 로드
  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString('assets/map_style_dark.json');
    setState(() => _darkMapStyle = style);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(mapMarkersProvider);
    final currentLocAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ─── Google Maps ───
          _buildMap(markersAsync, currentLocAsync),

          // ─── 상단 Beta 라벨 + Test 버튼 ───
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBetaLabel(),
                if (kDebugMode) ...[
                  const SizedBox(width: 8),
                  _buildTestButton(),
                ],
              ],
            ),
          ),

          // ─── 데이터 없을 때 빈 상태 오버레이 ───
          markersAsync.when(
            data: (markers) =>
                markers.isEmpty ? _buildEmptyOverlay() : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // ─── 현재 위치 버튼 (우하단) ───
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildMyLocationButton(currentLocAsync),
          ),
        ],
      ),
    );
  }

  /// Google Maps 위젯
  Widget _buildMap(
    AsyncValue<List<MarkerData>> markersAsync,
    AsyncValue<LatLng?> currentLocAsync,
  ) {
    // 초기 카메라 위치: 현재 위치 or 기본
    final initialTarget = currentLocAsync.valueOrNull ?? _defaultPosition;

    // 마커 세트 생성
    final markers = <Marker>{};
    if (markersAsync.hasValue) {
      for (final data in markersAsync.value!) {
        markers.add(Marker(
          markerId: MarkerId('session_${data.session.id}'),
          position: data.position,
          icon: data.icon,
          anchor: const Offset(0.5, 0.5),
          onTap: () => MarkerInfoSheet.show(context, data.session),
        ));
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 14,
      ),
      markers: markers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        if (_darkMapStyle != null) {
          // ignore: deprecated_member_use
          controller.setMapStyle(_darkMapStyle);
        }
        // sessionId 포커스 처리
        _focusSessionIfNeeded(markersAsync);
      },
    );
  }

  /// sessionId가 있으면 해당 마커로 카메라 이동 + InfoSheet 오픈
  void _focusSessionIfNeeded(AsyncValue<List<MarkerData>> markersAsync) {
    if (_didFocusSession || widget.focusSessionId == null) return;
    final id = int.tryParse(widget.focusSessionId!);
    if (id == null) return;

    if (!markersAsync.hasValue) return;
    final markers = markersAsync.value!;

    final match = markers.where((m) => m.session.id == id);
    if (match.isEmpty) return;

    _didFocusSession = true;
    final target = match.first;

    // 카메라 이동 후 InfoSheet 오픈
    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(target.position, 16),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          MarkerInfoSheet.show(context, target.session);
        }
      });
    });
  }

  /// Beta 라벨
  Widget _buildBetaLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_rounded,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            'Noise Map',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'BETA',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 오버레이 — 위치 있는 세션 없을 때
  Widget _buildEmptyOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '\u{1F5FA}\u{FE0F}',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  'No noise data yet',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Measure noise and save with location\nto see markers on the map',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [DEBUG] 테스트 데이터 주입 버튼
  Widget _buildTestButton() {
    return GestureDetector(
      onTap: _injectTestData,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          '\u{1F9EA} Test',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  /// [DEBUG] 5개 임시 세션을 Isar에 저장
  Future<void> _injectTestData() async {
    final repo = ref.read(sessionRepositoryProvider);
    final now = DateTime.now();

    final testSessions = [
      _testSession(
        lat: 37.5665, lng: 126.9780,
        avgDb: 45, maxDb: 52, minDb: 38,
        memo: 'Test - Quiet', startedAt: now.subtract(const Duration(hours: 5)),
      ),
      _testSession(
        lat: 37.4979, lng: 127.0276,
        avgDb: 72, maxDb: 85, minDb: 60,
        memo: 'Test - Loud', startedAt: now.subtract(const Duration(hours: 4)),
      ),
      _testSession(
        lat: 37.5563, lng: 126.9236,
        avgDb: 88, maxDb: 98, minDb: 75,
        memo: 'Test - Danger', startedAt: now.subtract(const Duration(hours: 3)),
      ),
      _testSession(
        lat: 37.5219, lng: 126.9245,
        avgDb: 55, maxDb: 65, minDb: 48,
        memo: 'Test - Moderate', startedAt: now.subtract(const Duration(hours: 2)),
      ),
      _testSession(
        lat: 37.5133, lng: 127.1000,
        avgDb: 38, maxDb: 45, minDb: 30,
        memo: 'Test - Silent', startedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    for (final session in testSessions) {
      await repo.saveSession(session);
    }

    // 마커 Provider 새로고침
    ref.invalidate(mapSessionsProvider);
    ref.invalidate(mapMarkersProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('5 test sessions added'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 테스트 세션 생성 헬퍼
  MeasurementSession _testSession({
    required double lat,
    required double lng,
    required double avgDb,
    required double maxDb,
    required double minDb,
    required String memo,
    required DateTime startedAt,
  }) {
    return MeasurementSession()
      ..startedAt = startedAt
      ..endedAt = startedAt.add(const Duration(minutes: 10))
      ..durationSec = 600
      ..avgDb = avgDb
      ..maxDb = maxDb
      ..minDb = minDb
      ..memo = memo
      ..latitude = lat
      ..longitude = lng
      ..locationName = memo.replaceFirst('Test - ', '')
      ..isSharedToMap = false;
  }

  /// 현재 위치 이동 버튼
  Widget _buildMyLocationButton(AsyncValue<LatLng?> currentLocAsync) {
    return FloatingActionButton.small(
      heroTag: 'map_my_location',
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.accent,
      elevation: 4,
      onPressed: () async {
        // 권한 없으면 요청
        final perm = ref.read(locationPermissionProvider);
        if (perm != LocationPermissionState.granted) {
          final result =
              await ref.read(locationPermissionProvider.notifier).request();
          if (result != LocationPermissionState.granted) return;
        }

        // 위치 새로고침
        ref.invalidate(currentLocationProvider);
        final loc = await ref.read(currentLocationProvider.future);
        if (loc != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(loc, 16),
          );
        }
      },
      child: const Icon(Icons.my_location_rounded, size: 20),
    );
  }
}
