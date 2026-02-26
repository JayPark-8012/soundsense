import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_screen.dart'
    show kOnboardingDoneKey;
import 'package:soundsense/features/settings/providers/settings_provider.dart';
import 'package:soundsense/features/settings/screens/disclaimer_screen.dart';
import 'package:soundsense/features/settings/screens/noise_guide_screen.dart';
import 'package:soundsense/features/settings/screens/privacy_policy_screen.dart';
import 'package:soundsense/shared/providers/calibration_provider.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/widgets/premium_bottom_sheet.dart';
import 'package:soundsense/shared/widgets/premium_guard.dart';

/// 설정 화면 — 탭 4
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final is85dbAlert = ref.watch(is85dbAlertProvider);
    final isWeeklyReport = ref.watch(isWeeklyReportProvider);
    final selectedLocale = ref.watch(selectedLocaleProvider);
    final calibrationOffset = ref.watch(calibrationOffsetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── PRO 카드 ───
            _buildProCard(context),
            const SizedBox(height: 24),

            // ─── 캘리브레이션 섹션 ───
            _buildSectionHeader('Calibration'),
            const SizedBox(height: 8),
            _buildCalibrationSection(ref, calibrationOffset),
            const SizedBox(height: 24),

            // ─── 알림 섹션 ───
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 8),
            _buildToggleTile(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              title: '85dB Warning',
              subtitle: 'Alert when noise exceeds 85dB',
              value: is85dbAlert,
              onChanged: (_) =>
                  ref.read(is85dbAlertProvider.notifier).toggle(),
            ),
            _buildToggleTile(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.accent,
              title: 'Weekly Report',
              subtitle: 'Get weekly noise summary',
              value: isWeeklyReport,
              onChanged: (_) =>
                  ref.read(isWeeklyReportProvider.notifier).toggle(),
            ),
            const SizedBox(height: 24),

            // ─── 언어 섹션 ───
            _buildSectionHeader('Language'),
            const SizedBox(height: 8),
            _buildLanguageSelector(
              selectedLocale: selectedLocale,
              onChanged: (locale) =>
                  ref.read(selectedLocaleProvider.notifier).setLocale(locale),
            ),
            const SizedBox(height: 24),

            // ─── PRO 기능 섹션 ───
            _buildSectionHeader('PRO Features'),
            const SizedBox(height: 8),
            PremiumGuard(
              featureName: 'Monthly PDF Report',
              lockedChild: _buildLockedProTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Monthly PDF Report',
              ),
              child: _buildInfoTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Monthly PDF Report',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('PDF report coming soon'),
                      backgroundColor: AppColors.proGold,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            PremiumGuard(
              featureName: 'CSV Export',
              lockedChild: _buildLockedProTile(
                icon: Icons.file_download_outlined,
                title: 'CSV Export',
              ),
              child: _buildInfoTile(
                icon: Icons.file_download_outlined,
                title: 'CSV Export',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('CSV export coming soon'),
                      backgroundColor: AppColors.proGold,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ─── 정보 섹션 ───
            _buildSectionHeader('Information'),
            const SizedBox(height: 8),
            _buildInfoTile(
              icon: Icons.volume_up_rounded,
              title: 'Noise Level Guide',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NoiseGuideScreen()),
              ),
            ),
            _buildInfoTile(
              icon: Icons.gavel_rounded,
              title: 'Disclaimer',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
              ),
            ),
            _buildInfoTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            _buildVersionTile(),

            // ─── Debug 섹션 (kDebugMode only) ───
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Debug'),
              const SizedBox(height: 8),
              _buildToggleTile(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.proGold,
                title: 'PRO Mode',
                subtitle: 'Toggle premium features for testing',
                value: ref.watch(debugPremiumProvider),
                onChanged: (_) =>
                    ref.read(debugPremiumProvider.notifier).toggle(),
              ),
              _buildInfoTile(
                icon: Icons.refresh_rounded,
                title: 'Reset Onboarding',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(kOnboardingDoneKey, false);
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── PRO 카드 ───

  Widget _buildProCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.proGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.proGold.withValues(alpha: 0.08),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '\u{1F451}',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'SoundSense PRO',
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.proGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock full history, detailed charts, and more',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'From \$2.99/month',
            style: AppTextStyles.body.copyWith(
              color: AppColors.proGoldLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                PremiumBottomSheet.show(context, featureName: 'SoundSense PRO');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.proGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Start Free Trial',
                style: AppTextStyles.body.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 캘리브레이션 섹션 ───

  Widget _buildCalibrationSection(WidgetRef ref, double offset) {
    final Color trackColor;
    if (offset < 0) {
      trackColor = AppColors.accent;
    } else if (offset > 0) {
      trackColor = AppColors.levelLoud;
    } else {
      trackColor = AppColors.levelQuiet;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 22, color: trackColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Microphone Offset',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Adjust if readings seem too high or low',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)} dB',
                style: AppTextStyles.body.copyWith(
                  color: trackColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: trackColor,
              inactiveTrackColor: trackColor.withValues(alpha: 0.2),
              thumbColor: trackColor,
              overlayColor: trackColor.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: offset,
              min: -10.0,
              max: 10.0,
              divisions: 200,
              onChanged: (value) {
                ref
                    .read(calibrationOffsetProvider.notifier)
                    .setOffset(double.parse(value.toStringAsFixed(1)));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-10 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              if (offset != 0.0)
                GestureDetector(
                  onTap: () => ref
                      .read(calibrationOffsetProvider.notifier)
                      .setOffset(0.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reset to Default',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              Text(
                '+10 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is not a certified measurement device. Values are approximate.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 섹션 헤더 ───

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── 토글 타일 ───

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  // ─── 언어 선택기 ───

  Widget _buildLanguageSelector({
    required String selectedLocale,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildLanguageOption(
            label: 'English',
            locale: 'en',
            isSelected: selectedLocale == 'en',
            onTap: () => onChanged('en'),
          ),
          _buildLanguageOption(
            label: '\uD55C\uAD6D\uC5B4',
            locale: 'ko',
            isSelected: selectedLocale == 'ko',
            onTap: () => onChanged('ko'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String locale,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 정보 타일 ───

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── PRO 잠금 타일 (lockedChild) ───

  Widget _buildLockedProTile({
    required IconData icon,
    required String title,
  }) {
    return Opacity(
      opacity: 0.85,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.proGold.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.proGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.proGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 앱 버전 타일 ───

  Widget _buildVersionTile() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '...';

        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                'App Version',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                version,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
