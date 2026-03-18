import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

class InsightsTab extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? insightsData;

  const InsightsTab({
    super.key,
    required this.isLoading,
    required this.insightsData,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = AppColors.darkSurface;
    const inputBg = AppColors.darkSurfaceVariant;
    const primaryOrange = AppColors.accent;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }

    if (insightsData == null) {
      return Center(
        child: Text(
          'Chưa có dữ liệu phân tích.',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final moduleStats = (insightsData!['moduleStats'] as List)
        .cast<Map<String, dynamic>>();
    final aiInsights = insightsData!['aiInsights'] as Map<String, dynamic>;
    final aiSummary =
        aiInsights['summary'] as String? ?? 'Chưa có phân tích từ AI.';
    final recommendations =
        (aiInsights['recommendations'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkSurfaceVariant, cardBg],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Phân tích AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aiSummary,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                if (recommendations.isNotEmpty) ...[
                  const Divider(color: Colors.white10, height: 24),
                  const Text(
                    'Đề xuất:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ...recommendations.map(
                    (r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Phễu rơi rớt (Drop-off Rate)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barGroups: moduleStats.asMap().entries.map((e) {
                  final index = e.key;
                  final stat = e.value;
                  final dropRate =
                      ((stat['dropOffRate'] as double? ?? 0) * 100);
                  final barWidth = moduleStats.length == 1 ? 40.0 : (moduleStats.length <= 3 ? 24.0 : 16.0);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dropRate,
                        color: dropRate > 30
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        width: barWidth,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < moduleStats.length) {
                          final title = moduleStats[index]['title'] as String? ?? 'M${index + 1}';
                          final display = title.length > 12 ? '${title.substring(0, 12)}...' : title;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                display,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
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
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Chi tiết từng chương',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...moduleStats.map(
            (stat) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'M${moduleStats.indexOf(stat) + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['title'] as String? ?? 'Module',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text(
                              'Rơi rớt: ${(stat['dropOffRate'] * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.redAccent.withAlpha(200),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ĐTB Quiz: ${stat['avgQuizScore'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
