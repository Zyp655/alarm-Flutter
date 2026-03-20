import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/dialogs/add_lesson_dialog.dart';

class AddLessonButton extends StatelessWidget {
  final int moduleId;

  const AddLessonButton({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AddLessonDialog.show(context, moduleId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withAlpha(60)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Thêm bài học mới',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
