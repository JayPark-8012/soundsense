import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 주간 막대 차트 위젯
/// 최근 7일 날짜별 평균 dB, 레벨 색상 막대
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.data});

  /// 키: 날짜 (자정), 값: 평균 dB (0이면 데이터 없음)
  final Map<DateTime, double> data;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Weekly Average',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 차트
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final db = rod.toY;
                      if (db == 0) return null;
                      return BarTooltipItem(
                        '${db.toStringAsFixed(1)} dB',
                        AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  // 하단 요일 라벨
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sortedEntries[index].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _weekdayLabel(date.weekday),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 좌측 dB 라벨
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 120) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(sortedEntries),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<MapEntry<DateTime, double>> entries,
  ) {
    return List.generate(entries.length, (index) {
      final db = entries[index].value;
      final color = db > 0
          ? DbLevel.fromDb(db).color
          : AppColors.surfaceLight;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: db > 0 ? db : 2, // 0이면 최소 막대 높이
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 120,
              color: AppColors.surfaceLight.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    });
  }

  /// 요일 약어
  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '',
    };
  }
}
