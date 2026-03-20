import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/course/domain/entities/lesson_entity.dart';
import '../../../../features/course/presentation/bloc/course_detail_bloc.dart';
import '../../../../features/course/presentation/bloc/course_detail_event.dart';
import '../../../../features/course/presentation/bloc/course_detail_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/dialogs/edit_lesson_dialog.dart';
import '../widgets/dialogs/video_preview_dialog.dart';
import '../pages/teacher_ai_quiz_page.dart';

class LessonItem extends StatelessWidget {
  final LessonEntity lesson;
  final Color accentColor;
  final int courseId;

  const LessonItem({
    super.key,
    required this.lesson,
    required this.accentColor,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVideo = lesson.type == LessonType.video;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isVideo
                ? const Color(0xFF3498DB).withAlpha(isDark ? 30 : 15)
                : const Color(0xFF9B59B6).withAlpha(isDark ? 30 : 15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isVideo ? Icons.play_circle_rounded : Icons.article_rounded,
            color: isVideo ? const Color(0xFF3498DB) : const Color(0xFF9B59B6),
            size: 20,
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          isVideo ? 'Video' : 'Tài liệu',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              EditLessonDialog.show(context, lesson);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, lesson);
            } else if (value == 'quiz_ai') {
              _openAiQuiz(context, lesson);
            }
          },
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: AppColors.textSecondary(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            if (lesson.type == LessonType.text)
              const PopupMenuItem(
                value: 'quiz_ai',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Tạo Quiz AI', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (isVideo && lesson.contentUrl != null) {
            showDialog(
              context: context,
              builder: (context) =>
                  VideoPreviewDialog(videoUrl: lesson.contentUrl!),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext mainContext, LessonEntity lesson) {
    final isDark = Theme.of(mainContext).brightness == Brightness.dark;
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bài học "${lesson.title}"?',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary(mainContext)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CourseDetailBloc>(mainContext).add(
                DeleteLessonEvent(
                  courseId:
                      (BlocProvider.of<CourseDetailBloc>(mainContext).state
                              as CourseDetailLoaded)
                          .course
                          .id,
                  moduleId: lesson.moduleId,
                  lessonId: lesson.id,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAiQuiz(BuildContext context, LessonEntity lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherAiQuizPage(
          courseId: courseId,
          moduleId: lesson.moduleId,
          initialContent: lesson.textContent,
        ),
      ),
    );
  }
}
