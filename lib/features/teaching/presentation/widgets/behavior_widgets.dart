import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BehaviorOverviewCard extends StatelessWidget {
  final String courseTitle;
  final int totalStudents;
  final Map<String, dynamic> engagement;

  const BehaviorOverviewCard({
    super.key,
    required this.courseTitle,
    required this.totalStudents,
    required this.engagement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text('$totalStudents sinh viên', style: TextStyle(color: Colors.white.withAlpha(200))),
                const SizedBox(height: 4),
                Text(
                  '⭐ ${engagement['excellent'] ?? 0}  ✅ ${engagement['good'] ?? 0}  ⚡ ${engagement['fair'] ?? 0}  🔴 ${engagement['low'] ?? 0}',
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

class BehaviorPieChart extends StatelessWidget {
  final Map<String, dynamic> engagement;
  final int totalStudents;

  const BehaviorPieChart({
    super.key,
    required this.engagement,
    required this.totalStudents,
  });

  @override
  Widget build(BuildContext context) {
    if (totalStudents == 0) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final excellent = (engagement['excellent'] as int? ?? 0).toDouble();
    final good = (engagement['good'] as int? ?? 0).toDouble();
    final fair = (engagement['fair'] as int? ?? 0).toDouble();
    final low = (engagement['low'] as int? ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Phân bố Engagement',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (excellent > 0) _section(excellent, AppColors.success),
                  if (good > 0) _section(good, AppColors.primary),
                  if (fair > 0) _section(fair, AppColors.warning),
                  if (low > 0) _section(low, AppColors.error),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legend('Xuất sắc', AppColors.success),
              _legend('Tốt', AppColors.primary),
              _legend('Trung bình', AppColors.warning),
              _legend('Nguy cơ', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: '${value.toInt()}',
      titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      radius: 50,
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class RiskStudentSection extends StatelessWidget {
  final List<Map<String, dynamic>> riskStudents;
  final bool nudging;
  final ValueChanged<Map<String, dynamic>> onNudge;

  const RiskStudentSection({
    super.key,
    required this.riskStudents,
    required this.nudging,
    required this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(isDark ? 25 : 12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                '⚠️ Sinh viên nguy cơ (${riskStudents.length})',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...riskStudents.take(10).map((s) => _buildTile(cs, isDark, s)),
        ],
      ),
    );
  }

  Widget _buildTile(ColorScheme cs, bool isDark, Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.error.withAlpha(30),
            child: Text(
              (s['name'] as String).isNotEmpty ? (s['name'] as String)[0].toUpperCase() : '?',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'] as String, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Hoàn thành: ${s['completionRate']}% · Quiz: ${s['avgQuizScore']}% · Offline: ${s['daysInactive']} ngày',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: TextButton.icon(
              onPressed: nudging ? null : () => onNudge(s),
              icon: Icon(Icons.notifications_active_rounded, size: 14, color: AppColors.error),
              label: Text('Nudge', style: TextStyle(fontSize: 11, color: AppColors.error)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: AppColors.error.withAlpha(80)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color accent;

  const SuggestionCard({
    super.key,
    required this.title,
    required this.items,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: TextStyle(color: cs.onSurface, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
