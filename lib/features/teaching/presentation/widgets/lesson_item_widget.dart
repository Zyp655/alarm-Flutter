import 'package:flutter/material.dart';
import '../../../../features/course/domain/entities/lesson_entity.dart';

class LessonItemWidget extends StatelessWidget {
  final LessonEntity lesson;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LessonItemWidget({
    super.key,
    required this.lesson,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        lesson.type == LessonType.video ? Icons.play_circle : Icons.article,
        color: Colors.grey[700],
      ),
      title: Text(lesson.title),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit?.call();
              break;
            case 'delete':
              onDelete?.call();
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ];
        },
      ),
      onTap: onTap,
    );
  }
}
