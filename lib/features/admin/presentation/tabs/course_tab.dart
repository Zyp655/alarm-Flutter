import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CourseTab extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final bool isLoading;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final void Function(int courseId, bool isPublished) onTogglePublish;
  final void Function(int courseId, String title) onDeleteCourse;

  const CourseTab({
    super.key,
    required this.courses,
    required this.isLoading,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onTogglePublish,
    required this.onDeleteCourse,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBar(
            hintText: 'Tìm môn học...',
            leading: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search_rounded),
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới',
                onPressed: onRefresh,
              ),
            ],
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 4),
            ),
            elevation: const WidgetStatePropertyAll(0),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(
                'Tổng ${courses.length}',
                Icons.menu_book_rounded,
                cs.primary,
                cs.primaryContainer,
              ),
              _chip(
                'Đã xuất bản ${courses.where((c) => c['isPublished'] == true).length}',
                Icons.check_circle_rounded,
                Colors.green,
                Colors.green.shade50,
              ),
              _chip(
                'Bản nháp ${courses.where((c) => c['isPublished'] != true).length}',
                Icons.edit_note_rounded,
                Colors.orange,
                Colors.orange.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: cs.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có môn học nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (_, i) => _CourseCard(
                      course: courses[i],
                      onTogglePublish: onTogglePublish,
                      onDelete: onDeleteCourse,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, IconData icon, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final void Function(int, bool) onTogglePublish;
  final void Function(int, String) onDelete;

  const _CourseCard({
    required this.course,
    required this.onTogglePublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPublished = course['isPublished'] == true;
    final title = course['title'] ?? '';
    final level = course['level'] ?? 'beginner';
    final students = course['studentCount'] ?? 0;
    final rating = (course['averageRating'] as num?)?.toDouble() ?? 0.0;

    final levelConfig = {
      'beginner': (
        label: 'Cơ bản',
        fg: Colors.green.shade800,
        bg: Colors.green.shade50,
      ),
      'intermediate': (
        label: 'Trung bình',
        fg: Colors.blue.shade800,
        bg: Colors.blue.shade50,
      ),
      'advanced': (
        label: 'Nâng cao',
        fg: Colors.purple.shade800,
        bg: Colors.purple.shade50,
      ),
    };
    final lc = levelConfig[level] ?? levelConfig['beginner']!;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isPublished
              ? cs.outlineVariant.withValues(alpha: 0.25)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.menu_book_rounded, color: cs.primary, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _badge(lc.label, lc.fg, lc.bg),
              const SizedBox(width: 4),
              _badge(
                isPublished ? 'Xuất bản' : 'Nháp',
                isPublished ? Colors.green.shade800 : Colors.orange.shade800,
                isPublished ? Colors.green.shade50 : Colors.orange.shade50,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '$students',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
            onSelected: (action) {
              final id = course['id'] as int;
              if (action == 'publish') onTogglePublish(id, isPublished);
              if (action == 'delete') onDelete(id, title);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'publish',
                child: Row(
                  children: [
                    Icon(
                      isPublished
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(isPublished ? 'Ẩn môn học' : 'Xuất bản'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: cs.error),
                    const SizedBox(width: 8),
                    Text('Xoá', style: TextStyle(color: cs.error)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
