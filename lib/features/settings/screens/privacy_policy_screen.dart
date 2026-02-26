import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/core/database/isar_provider.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/firebase/anonymous_auth.dart';
import 'package:soundsense/core/firebase/firebase_provider.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';

/// 개인정보처리방침 화면
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.privacyPolicy),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 1. 수집 데이터 ───
          _buildPolicyCard(
            icon: Icons.storage_rounded,
            title: context.l10n.ppDataCollectTitle,
            items: [
              context.l10n.ppDataCollect1,
              context.l10n.ppDataCollect2,
              context.l10n.ppDataCollect3,
            ],
          ),
          const SizedBox(height: 12),

          // ─── 2. 미수집 데이터 ───
          _buildPolicyCard(
            icon: Icons.shield_rounded,
            iconColor: AppColors.success,
            title: context.l10n.ppDataNotCollectTitle,
            items: [
              context.l10n.ppDataNotCollect1,
              context.l10n.ppDataNotCollect2,
              context.l10n.ppDataNotCollect3,
            ],
          ),
          const SizedBox(height: 12),

          // ─── 3. 익명 인증 ───
          _buildPolicyCard(
            icon: Icons.fingerprint_rounded,
            title: context.l10n.ppAnonAuthTitle,
            body: context.l10n.ppAnonAuthBody,
          ),
          const SizedBox(height: 12),

          // ─── 4. 데이터 저장 ───
          _buildPolicyCard(
            icon: Icons.smartphone_rounded,
            title: context.l10n.ppDataStorageTitle,
            body: context.l10n.ppDataStorageBody,
          ),
          const SizedBox(height: 12),

          // ─── 5. 데이터 삭제 ───
          _buildPolicyCard(
            icon: Icons.delete_sweep_rounded,
            iconColor: AppColors.warning,
            title: context.l10n.ppDataDeletionTitle,
            body: context.l10n.ppDataDeletionBody,
          ),
          const SizedBox(height: 12),

          // ─── 6. 연락처 ───
          _buildPolicyCard(
            icon: Icons.email_outlined,
            title: context.l10n.ppContactTitle,
            body: context.l10n.ppContactBody,
          ),
          const SizedBox(height: 24),

          // ─── 내 데이터 모두 삭제 버튼 ───
          _buildDeleteButton(context, ref),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 정책 카드 — 아이콘 + 제목 + 항목 리스트 or 본문
  Widget _buildPolicyCard({
    required IconData icon,
    Color? iconColor,
    required String title,
    List<String>? items,
    String? body,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(icon, size: 22, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 본문 or 항목 리스트
          if (body != null)
            Text(
              body,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          if (items != null)
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  /// 내 데이터 모두 삭제 버튼
  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteConfirmation(context, ref),
        icon: const Icon(Icons.delete_forever_rounded),
        label: Text(context.l10n.deleteAllMyData),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(
              context.l10n.deleteAllDataTitle,
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.deleteAllDataBody,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.cancel,
              style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAllData(context, ref);
            },
            child: Text(
              context.l10n.deleteEverything,
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 데이터 삭제 실행 — Isar 전체 삭제 + Firestore 본인 데이터 삭제
  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    try {
      final isar = ref.read(isarProvider);
      final deviceId = ref.read(deviceIdProvider);
      final collection = ref.read(noiseReportsRef);

      // 1. Firestore에서 본인 deviceId 기준 문서 삭제
      try {
        final query = await collection
            .where('deviceId', isEqualTo: deviceId)
            .get();
        for (final doc in query.docs) {
          await doc.reference.delete();
        }
        debugPrint(
            '\uD83D\uDDD1\uFE0F Firestore \uBCF8\uC778 \uB370\uC774\uD130 ${query.docs.length}\uAC1C \uC0AD\uC81C \uC644\uB8CC');
      } catch (e) {
        debugPrint('\u26A0\uFE0F Firestore \uC0AD\uC81C \uC2E4\uD328 (\uBB34\uC2DC): $e');
      }

      // 2. Isar 로컬 DB 전체 삭제
      await isar.writeTxn(() async {
        await isar.measurementSessions.clear();
      });
      debugPrint('\uD83D\uDDD1\uFE0F Isar \uC804\uCCB4 \uC0AD\uC81C \uC644\uB8CC');

      // 성공 스낵바
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.allDataDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('\u274C \uB370\uC774\uD130 \uC0AD\uC81C \uC2E4\uD328: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToDeleteData),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
