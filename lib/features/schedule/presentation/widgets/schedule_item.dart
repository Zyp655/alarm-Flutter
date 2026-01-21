import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/enitities/schedule_entity.dart';
import '../pages/schedule_detail_page.dart';

class ScheduleItem extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;

    final now = DateTime.now();
    if (schedule.start.difference(now).inMinutes <= 60 && schedule.start.isAfter(now)) {
      cardColor = Colors.yellow.shade50;
      borderColor = Colors.orange;
    }

    if (schedule.currentAbsences >= schedule.maxAbsences - 1) {
      borderColor = Colors.red;
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 2),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduleDetailPage(schedule: schedule),
            ),
          );
        },
        leading: const Icon(Icons.class_, color: Colors.blue),
        title: Text(
          schedule.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${schedule.room} - ${DateFormat('dd/MM HH:mm').format(schedule.start)}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('HH:mm').format(schedule.end)),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}