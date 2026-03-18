import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _sectionRow(
              cs,
              icon: Icons.people_alt_rounded,
              label: 'Người dùng',
              trailing: _realtimeBadge(),
            ),
            const SizedBox(height: 14),
            _heroUserCard(cs, isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                _userStatCard(
                  cs,
                  isDark,
                  label: 'Sinh viên',
                  count: analytics['students'] ?? 0,
                  icon: Icons.school_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFF5F3FF),
                  onTap: () => _navToDept(
                    context,
                    0,
                    'Sinh viên',
                    const Color(0xFF7C3AED),
                    Icons.school_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                _userStatCard(
                  cs,
                  isDark,
                  label: 'Giảng viên',
                  count: analytics['teachers'] ?? 0,
                  icon: Icons.cast_for_education_rounded,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                  onTap: () => _navToDept(
                    context,
                    1,
                    'Giảng viên',
                    const Color(0xFF2563EB),
                    Icons.cast_for_education_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _userStatCard(
                  cs,
                  isDark,
                  label: 'Admin',
                  count: analytics['admins'] ?? 0,
                  icon: Icons.shield_rounded,
                  color: const Color(0xFF10B981),
                  bg: const Color(0xFFECFDF5),
                ),
                const SizedBox(width: 10),
                _userStatCard(
                  cs,
                  isDark,
                  label: 'Bị khoá',
                  count: analytics['banned'] ?? 0,
                  icon: Icons.block_rounded,
                  color: const Color(0xFFEF4444),
                  bg: const Color(0xFFFEF2F2),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _sectionRow(
              cs,
              icon: Icons.menu_book_rounded,
              label: 'MÔN HỌC',
              isUpperCase: true,
            ),
            const SizedBox(height: 14),
            _courseRow(
              cs,
              isDark,
              icon: Icons.library_books_rounded,
              label: 'Tổng môn học',
              count: analytics['totalCourses'] ?? 0,
            ),
            const SizedBox(height: 1),
            _courseRow(
              cs,
              isDark,
              icon: Icons.check_circle_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'Đã xuất bản',
              count: analytics['publishedCourses'] ?? 0,
            ),

          ],
        ),
      ),
    );
  }

  Widget _realtimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'CẬP NHẬT TRỰC TIẾP',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroUserCard(ColorScheme cs, bool isDark) {
    final total = analytics['totalUsers'] ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG NGƯỜI DÙNG',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),

            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatNumber(total),
            style: GoogleFonts.montserrat(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _sparkline(),
        ],
      ),
    );
  }

  Widget _sparkline() {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        size: const Size(double.infinity, 28),
        painter: _SparklinePainter(),
      ),
    );
  }



  Widget _userStatCard(
    ColorScheme cs,
    bool isDark, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? cs.surfaceContainerHigh : bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color.withValues(alpha: 0.4),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatNumber(count),
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseRow(
    ColorScheme cs,
    bool isDark, {
    required IconData icon,
    Color? iconColor,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Icon(icon, color: iconColor ?? cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionRow(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    Widget? trailing,
    bool isUpperCase = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              isUpperCase ? label : label,
              style: GoogleFonts.inter(
                fontSize: isUpperCase ? 12 : 16,
                fontWeight: FontWeight.w700,
                color: isUpperCase ? cs.onSurfaceVariant : cs.onSurface,
                letterSpacing: isUpperCase ? 1.5 : 0,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  void _navToDept(
    BuildContext context,
    int role,
    String label,
    Color color,
    IconData icon,
  ) {
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

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final groups = <String>[];
      for (int i = s.length; i > 0; i -= 3) {
        groups.insert(0, s.substring(i - 3 < 0 ? 0 : i - 3, i));
      }
      return groups.join(',');
    }
    return '$n';
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final values = [
      0.3,
      0.4,
      0.35,
      0.5,
      0.45,
      0.6,
      0.55,
      0.7,
      0.65,
      0.8,
      0.75,
      0.9,
    ];
    final path = Path();
    final w = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * w;
      final y = size.height * (1 - values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * w;
        final prevY = size.height * (1 - values[i - 1]);
        final controlX1 = prevX + w * 0.5;
        final controlX2 = x - w * 0.5;
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }
    canvas.drawPath(path, paint);

    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    const barW = 18.0;
    final startX = size.width - (4 * (barW + 6));
    for (int i = 0; i < 4; i++) {
      final h = size.height * (0.4 + i * 0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + i * (barW + 6), size.height - h, barW, h),
          const Radius.circular(3),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
