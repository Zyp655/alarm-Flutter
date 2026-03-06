import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/route/app_route.dart';

class AcademicTab extends StatelessWidget {
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> academicCourses;
  final List<Map<String, dynamic>> courseClasses;
  final Future<void> Function() onRefresh;

  const AcademicTab({
    super.key,
    required this.departments,
    required this.semesters,
    required this.academicCourses,
    required this.courseClasses,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard(
                  cs,
                  isDark,
                  'Khoa',
                  departments.length,
                  Icons.business_rounded,
                  const Color(0xFF2563EB),
                  '+2%',
                ),
                const SizedBox(width: 12),
                _statCard(
                  cs,
                  isDark,
                  'Học kỳ',
                  semesters.length,
                  Icons.calendar_month_rounded,
                  const Color(0xFF10B981),
                  '+1%',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(
                  cs,
                  isDark,
                  'Học phần',
                  academicCourses.length,
                  Icons.menu_book_rounded,
                  const Color(0xFF7C3AED),
                  '+8%',
                ),
                const SizedBox(width: 12),
                _statCard(
                  cs,
                  isDark,
                  'Lớp HP',
                  courseClasses.length,
                  Icons.groups_rounded,
                  const Color(0xFFE17055),
                  '+13%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCta(context, cs, isDark),
            const SizedBox(height: 28),
            _buildRecentActivity(cs, isDark),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    ColorScheme cs,
    bool isDark,
    String label,
    int count,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHigh : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(
              0xFFE2E8F0,
            ).withValues(alpha: isDark ? 0.15 : 0.5),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 12,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    trend,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context, ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.academicStructure).then((_) => onRefresh()),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý đào tạo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cấu hình chương trình & môn học',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Truy cập',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ColorScheme cs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        _activityItem(
          cs,
          isDark,
          icon: Icons.update_rounded,
          color: const Color(0xFF2563EB),
          title: 'Cập nhật Học kỳ 1 (2023-2024)',
          subtitle: 'Hệ thống · 2 giờ trước',
        ),
        const SizedBox(height: 1),
        _activityItem(
          cs,
          isDark,
          icon: Icons.add_circle_outline_rounded,
          color: const Color(0xFF10B981),
          title: 'Thêm 12 Lớp Học phần mới',
          subtitle: 'Admin Khoa CNTT · Hôm qua, 14:30',
        ),
        const SizedBox(height: 1),
        _activityItem(
          cs,
          isDark,
          icon: Icons.file_download_outlined,
          color: const Color(0xFF7C3AED),
          title: 'Import danh sách sinh viên Khoá 15',
          subtitle: 'Phòng đào tạo · 12/02/2025',
        ),
      ],
    );
  }

  Widget _activityItem(
    ColorScheme cs,
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHigh : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(
              0xFFE2E8F0,
            ).withValues(alpha: isDark ? 0.15 : 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
