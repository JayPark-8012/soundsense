import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';

// ─── 기간 필터 ───

/// 히스토리 기간 필터
enum HistoryFilter { thisWeek, thisMonth }

/// 현재 선택된 필터
final historyFilterProvider = StateProvider<HistoryFilter>(
  (ref) => HistoryFilter.thisWeek,
);

// ─── 세션 목록 ───

/// 세션 목록 Provider — 필터와 PRO 상태에 따라 조회
final sessionListProvider =
    FutureProvider<List<MeasurementSession>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);
  final isPremium = ref.watch(isPremiumProvider);

  if (filter == HistoryFilter.thisWeek) {
    // 무료: 7일, PRO: 7일 (이번 주)
    return repo.getSessions(limitDays: AppConstants.freeHistoryLimitDays);
  }

  // 이번 달 필터
  if (isPremium) {
    return repo.getSessions(limitDays: 30);
  }

  // 무료 유저 → 7일만 (이번 달 필터여도 제한)
  return repo.getSessions(limitDays: AppConstants.freeHistoryLimitDays);
});

// ─── 주간 차트 데이터 ───

/// 최근 7일 날짜별 평균 dB (차트용)
/// 키: 해당 날짜의 자정 (시간 제거), 값: 평균 dB
final weeklyChartProvider =
    FutureProvider<Map<DateTime, double>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final sessions =
      await repo.getSessions(limitDays: AppConstants.freeHistoryLimitDays);

  // 최근 7일 날짜 생성
  final now = DateTime.now();
  final result = <DateTime, double>{};

  for (var i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day - i);
    result[date] = 0.0;
  }

  // 날짜별 세션 그룹핑 → 평균 계산
  final grouped = <DateTime, List<double>>{};
  for (final session in sessions) {
    final date = DateTime(
      session.startedAt.year,
      session.startedAt.month,
      session.startedAt.day,
    );
    grouped.putIfAbsent(date, () => []).add(session.avgDb);
  }

  // 평균 계산
  for (final entry in grouped.entries) {
    if (result.containsKey(entry.key) && entry.value.isNotEmpty) {
      final sum = entry.value.reduce((a, b) => a + b);
      result[entry.key] = sum / entry.value.length;
    }
  }

  return result;
});
