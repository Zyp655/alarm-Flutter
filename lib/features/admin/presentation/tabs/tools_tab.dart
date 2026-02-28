import 'package:flutter/material.dart';
import '../../../../core/route/app_route.dart';

class ToolsTab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSeedUsers;
  final VoidCallback onSeedAchievements;
  final VoidCallback onSeedRoadmap;
  final VoidCallback onImportFile;
  final VoidCallback onAssignRoadmapTeacher;

  const ToolsTab({
    super.key,
    required this.isLoading,
    required this.onSeedUsers,
    required this.onSeedAchievements,
    required this.onSeedRoadmap,
    required this.onImportFile,
    required this.onAssignRoadmapTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _toolCard(
            cs: cs,
            icon: Icons.group_add_rounded,
            iconColor: cs.onPrimaryContainer,
            iconBg: cs.primaryContainer,
            title: 'Tạo Dữ Liệu Mẫu',
            subtitle: '1 Admin · 2 Giảng viên · 2 Sinh viên',
            buttonLabel: 'Seed Users',
            buttonColor: cs.primaryContainer,
            buttonTextColor: cs.onPrimaryContainer,
            onPressed: isLoading ? null : onSeedUsers,
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.upload_file_rounded,
            iconColor: Colors.teal.shade800,
            iconBg: Colors.teal.shade50,
            title: 'Import Sinh Viên',
            subtitle: 'CSV hoặc Excel · Mã SV, Họ Tên, Lớp, Khoa',
            buttonLabel: 'Chọn File',
            buttonColor: Colors.teal.shade50,
            buttonTextColor: Colors.teal.shade800,
            onPressed: isLoading ? null : onImportFile,
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.emoji_events_rounded,
            iconColor: Colors.amber.shade800,
            iconBg: Colors.amber.shade50,
            title: 'Seed Achievements',
            subtitle: 'Tạo danh hiệu, huy chương mẫu',
            buttonLabel: 'Seed',
            buttonColor: Colors.amber.shade50,
            buttonTextColor: Colors.amber.shade800,
            onPressed: isLoading ? null : onSeedAchievements,
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.map_rounded,
            iconColor: Colors.indigo.shade800,
            iconBg: Colors.indigo.shade50,
            title: 'Seed Roadmap & Khoá học',
            subtitle: 'Tạo lộ trình và khoá học mẫu',
            buttonLabel: 'Seed',
            buttonColor: Colors.indigo.shade50,
            buttonTextColor: Colors.indigo.shade800,
            onPressed: isLoading ? null : onSeedRoadmap,
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.how_to_reg_rounded,
            iconColor: Colors.green.shade800,
            iconBg: Colors.green.shade50,
            title: 'Duyệt đơn Giảng viên',
            subtitle: 'Xem & duyệt đơn đăng ký làm giảng viên',
            buttonLabel: 'Duyệt',
            buttonColor: Colors.green.shade50,
            buttonTextColor: Colors.green.shade800,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.teacherApplications),
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.person_pin_rounded,
            iconColor: Colors.deepPurple.shade800,
            iconBg: Colors.deepPurple.shade50,
            title: 'Gán Roadmap cho GV',
            subtitle: 'Assign tất cả khóa roadmap cho 1 giảng viên',
            buttonLabel: 'Gán',
            buttonColor: Colors.deepPurple.shade50,
            buttonTextColor: Colors.deepPurple.shade800,
            onPressed: isLoading ? null : onAssignRoadmapTeacher,
          ),
          const SizedBox(height: 16),
          _toolCard(
            cs: cs,
            icon: Icons.assignment_ind_rounded,
            iconColor: Colors.blue.shade800,
            iconBg: Colors.blue.shade50,
            title: 'Import Ghi Danh (SIS)',
            subtitle: 'Import danh sách ghi danh từ file Excel/CSV',
            buttonLabel: 'Import',
            buttonColor: Colors.blue.shade50,
            buttonTextColor: Colors.blue.shade800,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.enrollmentImport),
          ),
          if (isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _toolCard({
    required ColorScheme cs,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required Color buttonTextColor,
    required VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 0,
      shadowColor: cs.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
