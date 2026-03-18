import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/route/app_route.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Nhập dữ liệu',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _toolCard(
            cs: cs,
            isDark: isDark,
            icon: Icons.upload_file_rounded,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFECFDF5),
            title: 'Import Sinh Viên',
            subtitle: 'Tải lên danh sách sinh viên từ file Excel (.xlsx)',
            buttonLabel: 'Chọn File',
            buttonStyle: _ButtonStyle.outlined,
            buttonColor: const Color(0xFF10B981),
            onPressed: () => context.push(AppRoutes.studentImport),
          ),
          const SizedBox(height: 10),
          _toolCard(
            cs: cs,
            isDark: isDark,
            icon: Icons.person_add_rounded,
            iconColor: const Color(0xFF3B82F6),
            iconBg: const Color(0xFFEFF6FF),
            title: 'Import Giảng Viên',
            subtitle: 'Cập nhật dữ liệu cán bộ giảng dạy',
            buttonLabel: 'Chọn File',
            buttonStyle: _ButtonStyle.outlined,
            buttonColor: const Color(0xFF3B82F6),
            onPressed: () => context.push(AppRoutes.teacherImport),
          ),
          const SizedBox(height: 10),
          _toolCard(
            cs: cs,
            isDark: isDark,
            icon: Icons.library_books_rounded,
            iconColor: const Color(0xFFF97316),
            iconBg: const Color(0xFFFFF7ED),
            title: 'Import Môn Học',
            subtitle: 'Danh mục học phần, đề cương chi tiết',
            buttonLabel: 'Chọn File',
            buttonStyle: _ButtonStyle.outlined,
            buttonColor: const Color(0xFFF97316),
            onPressed: () => context.push(AppRoutes.subjectImport),
          ),
          const SizedBox(height: 10),
          _toolCard(
            cs: cs,
            isDark: isDark,
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFEFF6FF),
            title: 'Import Ghi Danh (SIS)',
            subtitle: 'Đồng bộ dữ liệu ghi danh từ hệ thống SIS',
            statusLabel: 'Tự động',
            statusColor: const Color(0xFF2563EB),
            buttonLabel: 'Đồng bộ',
            buttonStyle: _ButtonStyle.filled,
            buttonColor: const Color(0xFF2563EB),
            onPressed: () => context.push(AppRoutes.enrollmentImport),
          ),
        ],
      ),
    );
  }

  Widget _toolCard({
    required ColorScheme cs,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? statusLabel,
    Color? statusColor,
    required String buttonLabel,
    required _ButtonStyle buttonStyle,
    required Color buttonColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: isDark ? 0.15 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (statusColor ?? cs.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor ?? cs.primary,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              _buildButton(
                buttonLabel,
                buttonStyle,
                buttonColor,
                onPressed,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    _ButtonStyle style,
    Color color,
    VoidCallback? onPressed,
    bool isDark,
  ) {
    if (style == _ButtonStyle.filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum _ButtonStyle { outlined, filled }

