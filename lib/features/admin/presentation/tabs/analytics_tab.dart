import 'package:flutter/material.dart';
import '../widgets/bento_cards.dart';
import '../pages/department_user_list_page.dart';

class AnalyticsTab extends StatelessWidget {
  final Map<String, dynamic> analytics;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const AnalyticsTab({
    super.key,
    required this.analytics,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_rounded, size: 64, color: cs.outlineVariant),
            const SizedBox(height: 12),
            Text('Đang tải...', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              cs,
              icon: Icons.people_alt_rounded,
              color: cs.primary,
              label: 'Người dùng',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SoftAnalyticsCard(
                  label: 'Tổng Users',
                  count: analytics['totalUsers'] ?? 0,
                  icon: Icons.people_alt_rounded,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                SoftAnalyticsCard(
                  label: 'Sinh viên',
                  count: analytics['students'] ?? 0,
                  icon: Icons.school_rounded,
                  color: const Color(0xFF6C5CE7),
                  onTap: () => _navigateToDepartmentList(
                    context,
                    role: 0,
                    label: 'Sinh viên',
                    color: const Color(0xFF6C5CE7),
                    icon: Icons.school_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SoftAnalyticsCard(
                  label: 'Giảng viên',
                  count: analytics['teachers'] ?? 0,
                  icon: Icons.cast_for_education_rounded,
                  color: const Color(0xFF0984E3),
                  onTap: () => _navigateToDepartmentList(
                    context,
                    role: 1,
                    label: 'Giảng viên',
                    color: const Color(0xFF0984E3),
                    icon: Icons.cast_for_education_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                SoftAnalyticsCard(
                  label: 'Admin',
                  count: analytics['admins'] ?? 0,
                  icon: Icons.shield_rounded,
                  color: cs.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SoftAnalyticsCard(
                  label: 'Bị khoá',
                  count: analytics['banned'] ?? 0,
                  icon: Icons.block_rounded,
                  color: cs.error,
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 32),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: 28),
            _sectionHeader(
              cs,
              icon: Icons.menu_book_rounded,
              color: Colors.teal,
              label: 'Môn học',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SoftAnalyticsCard(
                  label: 'Tổng môn học',
                  count: analytics['totalCourses'] ?? 0,
                  icon: Icons.menu_book_rounded,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                SoftAnalyticsCard(
                  label: 'Đã xuất bản',
                  count: analytics['publishedCourses'] ?? 0,
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SoftAnalyticsCard(
                  label: 'Tổng ghi danh',
                  count: analytics['totalEnrollments'] ?? 0,
                  icon: Icons.people_outline_rounded,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    ColorScheme cs, {
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  void _navigateToDepartmentList(
    BuildContext context, {
    required int role,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentUserListPage(
          args: DepartmentUserListArgs(
            role: role,
            roleLabel: label,
            accentColor: color,
            roleIcon: icon,
          ),
        ),
      ),
    );
  }
}
