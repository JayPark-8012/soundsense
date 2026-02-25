import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/history/providers/history_provider.dart';
import 'package:soundsense/features/history/widgets/session_card.dart';
import 'package:soundsense/features/history/widgets/weekly_bar_chart.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/widgets/premium_guard.dart';

/// 히스토리 화면 — 탭 2
/// 주간 차트 + 기간 필터 + 세션 카드 목록
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionListProvider);
    final chartAsync = ref.watch(weeklyChartProvider);
    final filter = ref.watch(historyFilterProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(sessionListProvider);
          ref.invalidate(weeklyChartProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ─── 주간 차트 ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: chartAsync.when(
                  data: (data) => WeeklyBarChart(data: data),
                  loading: () => _buildChartPlaceholder(),
                  error: (_, _) => _buildChartPlaceholder(),
                ),
              ),
            ),

            // ─── 기간 필터 탭 ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterTabs(ref, filter, isPremium),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ─── 세션 목록 ───
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: sessions.length + 1,
                    itemBuilder: (context, index) {
                      // 마지막: PremiumGuard 잠금 카드
                      if (index == sessions.length) {
                        return PremiumGuard(
                          featureName: 'Unlimited History',
                          lockedChild: _buildHistoryLockedCard(),
                          child: const SizedBox.shrink(),
                        );
                      }
                      return SessionCard(session: sessions[index]);
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load sessions',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /// 기간 필터 탭 — This Week / This Month
  Widget _buildFilterTabs(
    WidgetRef ref,
    HistoryFilter current,
    bool isPremium,
  ) {
    return Row(
      children: [
        _buildFilterChip(
          ref: ref,
          label: 'This Week',
          filter: HistoryFilter.thisWeek,
          isSelected: current == HistoryFilter.thisWeek,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          ref: ref,
          label: 'This Month',
          filter: HistoryFilter.thisMonth,
          isSelected: current == HistoryFilter.thisMonth,
          locked: !isPremium,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required WidgetRef ref,
    required String label,
    required HistoryFilter filter,
    required bool isSelected,
    bool locked = false,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(historyFilterProvider.notifier).state = filter;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (locked) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No measurements yet',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start measuring noise levels and your sessions will appear here.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 차트 로딩 플레이스홀더
  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// PRO 잠금 카드 — 7일 이전 기록 잠금 (PremiumGuard lockedChild)
  Widget _buildHistoryLockedCard() {
    return Opacity(
      opacity: 0.85,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.proGold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 28,
              color: AppColors.proGold.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Records before ${AppConstants.freeHistoryLimitDays} days',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.proGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlock with PRO',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.proGold.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
