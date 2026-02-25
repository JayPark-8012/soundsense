import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

/// 면책 조항 화면 — 영어 + 한국어 병기
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Disclaimer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── 경고 아이콘 헤더 ───
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),

            // ─── 영어 면책 ───
            _buildSection(
              lang: 'English',
              content: 'Measurements are for reference only.\n\n'
                  'Smartphone microphones may have \u00b15\u201310 dB variance '
                  'compared to professional sound level meters.\n\n'
                  'Not suitable for legal, medical, or official use.',
            ),
            const SizedBox(height: 16),

            // ─── 한국어 면책 ───
            _buildSection(
              lang: '\uD55C\uAD6D\uC5B4',
              content: '\uCE21\uC815\uAC12\uC740 \uCC38\uACE0\uC6A9\uC785\uB2C8\uB2E4.\n\n'
                  '\uC2A4\uB9C8\uD2B8\uD3F0 \uB9C8\uC774\uD06C \uD2B9\uC131\uC0C1 \uC804\uBB38 \uC18C\uC74C\uACC4 \uB300\uBE44 '
                  '\u00b15~10 dB \uC624\uCC28\uAC00 \uBC1C\uC0DD\uD560 \uC218 \uC788\uC2B5\uB2C8\uB2E4.\n\n'
                  '\uBC95\uC801 \uBD84\uC7C1, \uC758\uB8CC\uC801 \uD310\uB2E8\uC758 \uACF5\uC2DD \uC790\uB8CC\uB85C '
                  '\uC0AC\uC6A9\uD560 \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String lang,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 언어 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lang,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 본문
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
