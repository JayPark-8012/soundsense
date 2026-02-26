import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/permissions/microphone_permission.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// 온보딩 Step 3 — 마이크 권한
class OnboardingPage3 extends ConsumerWidget {
  const OnboardingPage3({super.key, required this.onNext});

  final VoidCallback onNext;

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
                '\u{1F399}\u{FE0F}',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ─── 타이틀 ───
          Text(
            "Let's start measuring",
            textAlign: TextAlign.center,
            style: AppTextStyles.dbDisplay.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // ─── 체크리스트 ───
          _buildCheckItem('No audio is recorded or stored'),
          const SizedBox(height: 12),
          _buildCheckItem('Only decibel levels are measured'),
          const SizedBox(height: 12),
          _buildCheckItem('Data stays on your device'),

          const Spacer(flex: 2),

          // ─── Allow Microphone 버튼 ───
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                HapticUtils.light();
                final result =
                    await ref.read(micPermissionProvider.notifier).request();
                // 허용이든 거부든 다음 페이지로 이동
                if (result == MicPermissionState.granted) {
                  onNext();
                } else {
                  // 거부 시에도 다음으로 (측정 화면에서 재요청)
                  onNext();
                }
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
                'Allow Microphone',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Skip 텍스트 버튼 ───
          TextButton(
            onPressed: onNext,
            child: Text(
              'Skip',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 하단 여백 (인디케이터 공간)
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.success,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
