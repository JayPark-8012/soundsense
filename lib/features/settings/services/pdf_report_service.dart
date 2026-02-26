import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:soundsense/core/database/measurement_session.dart';

/// 월간 PDF 리포트 서비스
class PdfReportService {
  /// 이번 달 세션 기반 PDF 생성 후 공유 시트 표시
  /// 세션이 비어있으면 false 반환 (호출자가 SnackBar 처리)
  static Future<bool> generateMonthlyReport(
    List<MeasurementSession> allSessions,
  ) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // 이번 달 세션 필터
    final sessions = allSessions
        .where((s) =>
            s.startedAt.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
            s.startedAt.isBefore(monthEnd.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    if (sessions.isEmpty) return false;

    try {
      final pdf = pw.Document();
      final yearMonth = DateFormat('yyyy MMMM').format(now);
      final dateFmt = DateFormat('MM/dd HH:mm');

      // ─── 요약 데이터 계산 ───
      final totalCount = sessions.length;
      final avgDb = sessions.map((s) => s.avgDb).reduce((a, b) => a + b) /
          totalCount;
      final maxDbSession =
          sessions.reduce((a, b) => a.maxDb > b.maxDb ? a : b);
      final loudestLocation = maxDbSession.locationName ?? '-';

      // ─── PDF 페이지 생성 ───
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildHeader(yearMonth),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            // 표지 영역
            pw.Center(
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'SoundSense',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Monthly Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    yearMonth,
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                ],
              ),
            ),

            // ─── 요약 섹션 ───
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildSummaryRow(
                      'Total Measurements', totalCount.toString()),
                  pw.SizedBox(height: 6),
                  _buildSummaryRow(
                      'Average dB', '${avgDb.toStringAsFixed(1)} dB'),
                  pw.SizedBox(height: 6),
                  _buildSummaryRow(
                    'Highest dB',
                    '${maxDbSession.maxDb.toStringAsFixed(1)} dB',
                  ),
                  pw.SizedBox(height: 6),
                  _buildSummaryRow('Loudest Location', loudestLocation),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // ─── 세션 테이블 ───
            pw.Text(
              'Session Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellHeight: 28,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
              headers: ['Date', 'Location', 'Avg dB', 'Max dB', 'Duration'],
              data: sessions.map((s) {
                return [
                  dateFmt.format(s.startedAt),
                  s.locationName ?? '-',
                  s.avgDb.toStringAsFixed(1),
                  s.maxDb.toStringAsFixed(1),
                  _formatDuration(s.durationSec),
                ];
              }).toList(),
            ),
          ],
        ),
      );

      // ─── 파일 저장 + 공유 ───
      final dir = await getTemporaryDirectory();
      final ym = DateFormat('yyyyMM').format(now);
      final fileName = 'soundsense_${ym}_report.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SoundSense Monthly Report - $yearMonth',
      );

      return true;
    } catch (e) {
      debugPrint('PDF report error: $e');
      rethrow;
    }
  }

  // ─── 헤더 ───
  static pw.Widget _buildHeader(String yearMonth) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SoundSense',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            yearMonth,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 푸터 (면책 문구 + 페이지 번호) ───
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Measurements are for reference only. Smartphone microphones may have '
            '\u00b15-10dB variance compared to professional sound level meters. '
            'Not suitable for legal, medical, or official use.',
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey500,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 요약 행 ───
  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// 초 → "Xm Ys" 포맷
  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}
