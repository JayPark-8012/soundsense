import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soundsense/core/platform/platform_providers.dart'
    show kWebMockLatitude, kWebMockLongitude;
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/features/history/providers/history_provider.dart';
import 'package:soundsense/features/map/providers/map_provider.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 위치 태그 옵션
enum _LocationOption {
  current,  // 현재 위치 사용
  manual,   // 직접 입력
  skip,     // 건너뛰기
}

/// 세션 저장 바텀시트
/// DATA_MODEL.md MeasurementSession 필드 기준
class SaveSessionSheet extends ConsumerStatefulWidget {
  const SaveSessionSheet({
    super.key,
    required this.avgDb,
    required this.maxDb,
    required this.minDb,
    required this.startedAt,
    required this.sampleCount,
  });

  final double avgDb;
  final double maxDb;
  final double minDb;
  final DateTime startedAt;
  final int sampleCount;

  @override
  ConsumerState<SaveSessionSheet> createState() => _SaveSessionSheetState();
}

class _SaveSessionSheetState extends ConsumerState<SaveSessionSheet> {
  final _memoController = TextEditingController();
  final _locationNameController = TextEditingController();

  _LocationOption _locationOption = _LocationOption.current;  // 기본: 현재 위치
  bool _isSharedToMap = true;  // 기본: 지도 공유 ON
  bool _isMemoExpanded = false;  // 메모: 접힘 상태로 시작
  bool _isFetchingLocation = false;
  bool _isSaving = false;
  bool _isSaved = false;

  // 현재 위치 정보 (가져온 후 저장)
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // 시트 열리자마자 현재 위치 자동 가져오기
    Future.microtask(() => _fetchCurrentLocation());
  }

  @override
  void dispose() {
    _memoController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  /// 세션 데이터 계산
  DateTime get _endedAt => DateTime.now();
  int get _durationSec => _endedAt.difference(widget.startedAt).inSeconds;
  DbLevel get _level => DbLevel.fromDb(widget.avgDb);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 드래그 핸들 ───
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 제목 ───
            Center(
              child: Text(
                '측정 완료! 💾',
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 세션 요약 카드 ───
            _buildSessionSummary(),
            const SizedBox(height: 20),

            // ─── 위치 태그 ───
            _buildLocationSection(),
            const SizedBox(height: 20),

            // ─── 지도 공유 토글 ───
            _buildMapShareToggle(),
            const SizedBox(height: 16),

            // ─── 메모 (접힘/펼침) ───
            _buildMemoSection(),
            const SizedBox(height: 28),

            // ─── 저장하기 버튼 ───
            _buildSaveButton(),
            const SizedBox(height: 8),

            // ─── 저장 안 함 버튼 ───
            _buildDiscardButton(),
          ],
        ),
      ),
    );
  }

  /// 세션 요약 카드 — 평균 dB 크게 + 측정 시간
  Widget _buildSessionSummary() {
    final duration = _durationSec;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    final timeText = minutes > 0
        ? '${minutes}m ${seconds}s'
        : '${seconds}s';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _level.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _level.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // 평균 dB 대형 표시
          Text(
            '${widget.avgDb.toStringAsFixed(1)} dB',
            style: AppTextStyles.dbDisplay.copyWith(
              color: _level.color,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _level.labelEn,
            style: AppTextStyles.levelLabel.copyWith(
              color: _level.color,
            ),
          ),
          const SizedBox(height: 16),
          // MIN / MAX / 시간 한 줄
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryRow('MIN', widget.minDb),
              const SizedBox(width: 20),
              _buildSummaryRow('MAX', widget.maxDb),
              const SizedBox(width: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)} dB',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 메모 섹션 — 접힘 상태로 시작, 탭하면 펼침
  Widget _buildMemoSection() {
    if (!_isMemoExpanded) {
      return GestureDetector(
        onTap: () => setState(() => _isMemoExpanded = true),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Add memo',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memo',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          autofocus: true,
          maxLines: 2,
          maxLength: 200,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Add a note about this session...',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            counterStyle: AppTextStyles.caption,
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  /// 위치 태그 섹션
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Tag',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // 3개 옵션 라디오
        _buildLocationRadio(
          option: _LocationOption.current,
          icon: Icons.my_location_rounded,
          label: 'Use current location',
        ),
        _buildLocationRadio(
          option: _LocationOption.manual,
          icon: Icons.edit_location_alt_rounded,
          label: 'Enter manually',
        ),
        _buildLocationRadio(
          option: _LocationOption.skip,
          icon: Icons.location_off_rounded,
          label: 'Skip',
        ),

        // 현재 위치 가져오는 중 표시
        if (_locationOption == _LocationOption.current && _isFetchingLocation)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Getting location...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

        // 위치 가져온 후 좌표 표시
        if (_locationOption == _LocationOption.current &&
            !_isFetchingLocation &&
            _latitude != null)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Text(
              '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),

        // 직접 입력 필드
        if (_locationOption == _LocationOption.manual)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 8),
            child: TextField(
              controller: _locationNameController,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Gangnam Station, Office...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationRadio({
    required _LocationOption option,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _locationOption == option;

    return InkWell(
      onTap: () => _onLocationOptionChanged(option),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 위치 옵션 변경 처리
  void _onLocationOptionChanged(_LocationOption option) {
    setState(() {
      _locationOption = option;
      // 지도 공유는 위치 있을 때만 가능
      if (option == _LocationOption.skip) {
        _isSharedToMap = false;
      }
    });

    // 현재 위치 선택 시 위치 가져오기
    if (option == _LocationOption.current) {
      _fetchCurrentLocation();
    }
  }

  /// 현재 위치 가져오기
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    // 웹: 서울시청 고정 좌표
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _latitude = kWebMockLatitude;
          _longitude = kWebMockLongitude;
          _isFetchingLocation = false;
        });
      }
      return;
    }

    try {
      // 위치 권한 확인 및 요청
      final locPermission = ref.read(locationPermissionProvider);
      if (locPermission != LocationPermissionState.granted) {
        final result =
            await ref.read(locationPermissionProvider.notifier).request();
        if (result != LocationPermissionState.granted) {
          // 권한 거부 시 Skip으로 전환
          if (mounted) {
            setState(() {
              _locationOption = _LocationOption.skip;
              _isFetchingLocation = false;
            });
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
      if (mounted) {
        setState(() {
          _locationOption = _LocationOption.skip;
          _isFetchingLocation = false;
        });
      }
    }
  }

  /// 지도 공유 토글
  Widget _buildMapShareToggle() {
    // 위치 없으면 토글 비활성
    final hasLocation = _locationOption != _LocationOption.skip;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public_rounded,
            size: 20,
            color: hasLocation ? AppColors.accent : AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share to Noise Map',
                  style: AppTextStyles.body.copyWith(
                    color: hasLocation
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLocation
                      ? 'Help others discover noise levels in your area'
                      : 'Add location to enable sharing',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isSharedToMap,
            onChanged: hasLocation
                ? (value) => setState(() => _isSharedToMap = value)
                : null,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  /// 저장하기 CTA 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isSaving || _isSaved) ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isSaved ? AppColors.success : AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: _isSaved
              ? AppColors.success
              : AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSaved
              ? const Icon(
                  Icons.check_circle_rounded,
                  key: ValueKey('saved'),
                  size: 28,
                  color: Colors.white,
                )
              : _isSaving
                  ? const SizedBox(
                      key: ValueKey('saving'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Text(
                      '\u{1F4BE} 저장하기',
                      key: const ValueKey('save'),
                      style: AppTextStyles.levelLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
        ),
      ),
    );
  }

  /// 저장 안 함 버튼
  Widget _buildDiscardButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        onPressed: () {
          HapticUtils.light();
          Navigator.of(context).pop(false);
        },
        child: Text(
          '저장 안 함',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  /// 저장 처리 — Isar DB에 세션 저장
  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final endedAt = _endedAt;
    final durationSec = endedAt.difference(widget.startedAt).inSeconds;

    // 위치 정보 정리
    String? locationName;
    double? lat = _latitude;
    double? lng = _longitude;

    if (_locationOption == _LocationOption.manual) {
      locationName = _locationNameController.text.trim().isNotEmpty
          ? _locationNameController.text.trim()
          : null;
      lat = null;
      lng = null;
    } else if (_locationOption == _LocationOption.skip) {
      lat = null;
      lng = null;
    }

    // ─── MeasurementSession 생성 ───
    final session = MeasurementSession()
      ..startedAt = widget.startedAt
      ..endedAt = endedAt
      ..durationSec = durationSec
      ..avgDb = widget.avgDb
      ..maxDb = widget.maxDb
      ..minDb = widget.minDb
      ..memo = _memoController.text.trim().isNotEmpty
          ? _memoController.text.trim()
          : null
      ..latitude = lat
      ..longitude = lng
      ..locationName = locationName
      ..isSharedToMap = _isSharedToMap;

    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.saveSession(session);
      debugPrint('💾 saveSession 완료 (isSharedToMap=${session.isSharedToMap}, lat=${session.latitude})');

      // Firestore 업로드 (지도 공유 선택 시)
      debugPrint('💾 uploadToFirestore 호출');
      await repo.uploadToFirestore(session);

      // 히스토리 + 지도 Provider 새로고침
      ref.invalidate(sessionListProvider);
      ref.invalidate(weeklyChartProvider);
      ref.invalidate(mapSessionsProvider);
      ref.invalidate(mapMarkersProvider);
      ref.invalidate(firestoreReportsProvider);

      if (mounted) {
        HapticUtils.success();
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        // 체크 아이콘 애니메이션 후 닫기
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    } catch (e) {
      debugPrint('❌ 세션 저장 실패: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save session: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
