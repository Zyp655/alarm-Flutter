import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/course/domain/entities/module_entity.dart';
import '../../../../features/course/domain/entities/lesson_entity.dart';

class ModuleCardWidget extends StatelessWidget {
  final ModuleEntity module;
  final VoidCallback? onEdit;
  final VoidCallback? onAddLesson;
  final Widget Function(LessonEntity)? lessonBuilder;
  final Widget? aiQuizSection;

  const ModuleCardWidget({
    super.key,
    required this.module,
    this.onEdit,
    this.onAddLesson,
    this.lessonBuilder,
    this.aiQuizSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    module.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                    onPressed: onEdit,
                  ),
              ],
            ),
            subtitle: Text(
              '${module.lessons?.length ?? 0} bài học',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            children: [
              Container(height: 1, color: Colors.grey[100]),
              AppSpacing.gapV8,
              if (module.lessons != null && lessonBuilder != null)
                ...module.lessons!.map(lessonBuilder!),
              if (onAddLesson != null) _AddLessonButton(onTap: onAddLesson!),
              AppSpacing.gapV16,
              if (aiQuizSection != null) aiQuizSection!,
              AppSpacing.gapV16,
            ],
          ),
        ),
      ),
    );
  }
}

class _AddLessonButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddLessonButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
            ),
            AppSpacing.gapH12,
            const Text(
              'Thêm bài học mới',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
