import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/route/app_route.dart';
import '../../../../injection_container.dart';

class AcademicTab extends StatefulWidget {
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
  State<AcademicTab> createState() => _AcademicTabState();
}

class _AcademicTabState extends State<AcademicTab> {
  List<Map<String, dynamic>> _activities = [];
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final api = sl<ApiClient>();
      final res = await api.get('/admin/recent-activities');
      if (mounted) {
        setState(() {
          _activities = List<Map<String, dynamic>>.from(
            res['activities'] ?? [],
          );
          _loadingActivities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingActivities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh();
        await _loadActivities();
      },
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
                  widget.departments.length,
                  Icons.business_rounded,
                  const Color(0xFF2563EB),
                ),
                const SizedBox(width: 12),
                _statCard(
                  cs,
                  isDark,
                  'Học kỳ',
                  widget.semesters.length,
                  Icons.calendar_month_rounded,
                  const Color(0xFF10B981),
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
                  widget.academicCourses.length,
                  Icons.menu_book_rounded,
                  const Color(0xFF7C3AED),
                ),
                const SizedBox(width: 12),
                _statCard(
                  cs,
                  isDark,
                  'Lớp HP',
                  widget.courseClasses.length,
                  Icons.groups_rounded,
                  const Color(0xFFE17055),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context, ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.academicStructure).then((_) => widget.onRefresh()),
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

  IconData _iconFromType(String type) {
    switch (type) {
      case 'department':
        return Icons.business_rounded;
      case 'semester':
        return Icons.calendar_month_rounded;
      case 'course':
        return Icons.menu_book_rounded;
      case 'class':
        return Icons.groups_rounded;
      case 'users':
        return Icons.people_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _colorFromType(String type) {
    switch (type) {
      case 'department':
        return const Color(0xFF2563EB);
      case 'semester':
        return const Color(0xFF10B981);
      case 'course':
        return const Color(0xFF7C3AED);
      case 'class':
        return const Color(0xFFE17055);
      case 'users':
        return const Color(0xFF0984E3);
      default:
        return const Color(0xFF636E72);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
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
        if (_loadingActivities)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_activities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Chưa có hoạt động nào',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._activities.map((a) {
            final type = a['type'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: _activityItem(
                cs,
                isDark,
                icon: _iconFromType(type),
                color: _colorFromType(type),
                title: a['title'] as String? ?? '',
                subtitle:
                    '${a['subtitle'] ?? ''} · ${_formatTime(a['timestamp'] as String?)}',
              ),
            );
          }),
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
