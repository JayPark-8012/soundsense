import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// 온보딩 Step 4 — 위치 권한
class OnboardingPage4 extends ConsumerWidget {
  const OnboardingPage4({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // ─── 아이콘 ───
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text(
                '\u{1F5FA}\u{FE0F}',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ─── 타이틀 ───
          Text(
            context.l10n.onboardingTitle4,
            textAlign: TextAlign.center,
            style: AppTextStyles.dbDisplay.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // ─── 서브 ───
          Text(
            context.l10n.onboardingDesc4,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.enableLaterInSettings,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),

          const Spacer(flex: 2),

          // ─── Allow Location 버튼 ───
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                HapticUtils.light();
                await ref
                    .read(locationPermissionProvider.notifier)
                    .request();
                // 허용이든 거부든 온보딩 완료
                HapticUtils.success();
                onComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.allowLocation,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Maybe Later 버튼 (동등 크기) ───
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticUtils.success();
                onComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.maybeLater,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 하단 여백 (인디케이터 공간)
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
