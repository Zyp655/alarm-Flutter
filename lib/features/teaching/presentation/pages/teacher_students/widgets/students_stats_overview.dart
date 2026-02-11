import 'package:flutter/material.dart';
import '../../../widgets/stat_card_widget.dart';

class StudentsStatsOverview extends StatelessWidget {
  final int totalStudents;
  final int atRiskCount;
  final double averageScore;
  final int activeCount;

  const StudentsStatsOverview({
    super.key,
    required this.totalStudents,
    required this.atRiskCount,
    required this.averageScore,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          StatCardWidget(
            icon: Icons.people_outline_rounded,
            iconColor: Colors.blueAccent,
            value: totalStudents.toString(),
            label: 'Tổng HV',
          ),
          const SizedBox(width: 16),
          StatCardWidget(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.redAccent,
            value: atRiskCount.toString(),
            label: 'Cần chú ý',
          ),
          const SizedBox(width: 16),
          StatCardWidget(
            icon: Icons.analytics_outlined,
            iconColor: Colors.greenAccent,
            value: '${averageScore.toStringAsFixed(1)}%',
            label: 'Điểm TB',
          ),
          const SizedBox(width: 16),
          StatCardWidget(
            icon: Icons.timer_outlined,
            iconColor: Colors.purpleAccent,
            value: activeCount.toString(),
            label: 'Hoạt động',
          ),
        ],
      ),
    );
  }
}
