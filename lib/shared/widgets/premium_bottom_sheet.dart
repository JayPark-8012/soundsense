import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/services/purchase_service.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// PRO 업그레이드 유도 바텀시트
/// 골드 컬러 포인트 + 다크 배경
class PremiumBottomSheet extends ConsumerStatefulWidget {
  const PremiumBottomSheet({super.key, required this.featureName});

  /// 어떤 기능에서 열렸는지 (e.g. "Timeline Chart")
  final String featureName;

  /// 바텀시트 표시 헬퍼
  static Future<void> show(
    BuildContext context, {
    required String featureName,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PremiumBottomSheet(featureName: featureName),
    );
  }

  @override
  ConsumerState<PremiumBottomSheet> createState() =>
      _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends ConsumerState<PremiumBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 골드 상단 바 ───
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.proGradientStart, AppColors.proGradientEnd],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24),

                // ─── 골드 배지 ───
                _buildProBadge(context),
                const SizedBox(height: 24),

                // ─── 기능 목록 ───
                _buildFeatureList(context),
                const SizedBox(height: 24),

                // ─── 가격 표시 ───
                _buildPricing(context),
                const SizedBox(height: 24),

                // ─── 메인 CTA ───
                _buildBuyButton(context),
                const SizedBox(height: 12),

                // ─── Maybe Later ───
                _buildMaybeLater(context),
                const SizedBox(height: 4),

                // ─── 구매 복원 ───
                _buildRestorePurchase(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 골드 배지 "SoundSense PRO"
  Widget _buildProBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.proGradientStart, AppColors.proGradientEnd],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u{1F451}',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.soundsensePro,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// PRO 기능 목록 5개
  Widget _buildFeatureList(BuildContext context) {
    final features = [
      ('\u{2728}', context.l10n.proUnlimitedHistory),
      ('\u{1F4CA}', context.l10n.proTimelineChart),
      ('\u{1F4C4}', context.l10n.proMonthlyReport),
      ('\u{1F4C1}', context.l10n.proCsvExport),
      ('\u{1F6AB}', context.l10n.proAdFree),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.proGold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.proGold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  features[i].$1,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  features[i].$2,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 가격 표시
  Widget _buildPricing(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.proPricing,
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.proGold,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.oneTimePurchase,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// "Get Lifetime PRO" CTA
  Widget _buildBuyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _onPurchase(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.proGold,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.proGold.withValues(alpha: 0.5),
          elevation: 4,
          shadowColor: AppColors.proGold.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.background,
                ),
              )
            : Text(
                context.l10n.getLifetimePro,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  /// "Maybe Later" 텍스트 버튼
  Widget _buildMaybeLater(BuildContext context) {
    return TextButton(
      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(
        context.l10n.maybeLater,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// "Restore Purchase" 텍스트 버튼
  Widget _buildRestorePurchase(BuildContext context) {
    return TextButton(
      onPressed: _isLoading ? null : () => _onRestore(context),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 36),
      ),
      child: Text(
        context.l10n.restorePurchase,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// 구매 처리 — 취소: 무시 / 성공: PRO 갱신+스낵바 / 실패: 다이얼로그
  Future<void> _onPurchase(BuildContext context) async {
    HapticUtils.medium();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(purchaseServiceProvider);
      final result = await service.purchasePro();

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 취소 (null) → 조용히 무시
      if (result == null) return;

      // 성공 → PRO 상태 즉시 갱신 + 바텀시트 닫기 + 스낵바
      await ref.read(premiumStatusProvider.notifier).refresh();
      HapticUtils.success();
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('\u{1F389} ${l10n.proActivated}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('구매 에러: $e');
      _showErrorDialog(l10n.purchaseFailedTitle, l10n.purchaseFailedMessage);
    }
  }

  /// 구매 복원 처리 — 성공(PRO): 갱신+스낵바 / 구매 없음: 안내 스낵바 / 실패: 다이얼로그
  Future<void> _onRestore(BuildContext context) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(purchaseServiceProvider);
      final restored = await service.restorePurchases();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (restored) {
        // PRO 복원 성공
        await ref.read(premiumStatusProvider.notifier).refresh();
        HapticUtils.success();
        nav.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('\u{1F389} ${l10n.proActivated}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // 이전 구매 없음
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.restoreNoPurchase),
            backgroundColor: AppColors.proGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('복원 에러: $e');
      _showErrorDialog(l10n.restoreFailedTitle, l10n.restoreFailedMessage);
    }
  }

  /// 에러 다이얼로그 (에러코드 숨김, 유저에게 심플 메시지만)
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.ok,
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
