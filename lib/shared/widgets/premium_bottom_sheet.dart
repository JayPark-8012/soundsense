import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

/// PRO 업그레이드 유도 바텀시트
/// 골드 컬러 포인트 + 다크 배경
class PremiumBottomSheet extends StatelessWidget {
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
                _buildProBadge(),
                const SizedBox(height: 24),

                // ─── 기능 목록 ───
                _buildFeatureList(),
                const SizedBox(height: 24),

                // ─── 가격 표시 ───
                _buildPricing(),
                const SizedBox(height: 24),

                // ─── 메인 CTA ───
                _buildTrialButton(context),
                const SizedBox(height: 12),

                // ─── Maybe Later ───
                _buildMaybeLater(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 골드 배지 "SoundSense PRO"
  Widget _buildProBadge() {
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
            'SoundSense PRO',
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

  /// PRO 기능 목록 4개
  Widget _buildFeatureList() {
    const features = [
      ('\u{2728}', 'Unlimited history'),
      ('\u{1F4CA}', 'Timeline chart'),
      ('\u{1F4C4}', 'Monthly PDF report'),
      ('\u{1F4C1}', 'CSV export'),
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
  Widget _buildPricing() {
    return Column(
      children: [
        Text(
          '\$2.99/month or \$19.99/year (44% off)',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\u{20A9}3,900/\uC6D4 or \u{20A9}24,900/\uB144 (47% \uC808\uC57D)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// "Start 7-Day Free Trial" CTA
  Widget _buildTrialButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Coming soon! RevenueCat integration pending'),
              backgroundColor: AppColors.proGold,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.proGold,
          foregroundColor: AppColors.background,
          elevation: 4,
          shadowColor: AppColors.proGold.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Start 7-Day Free Trial',
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
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(
        'Maybe Later',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
