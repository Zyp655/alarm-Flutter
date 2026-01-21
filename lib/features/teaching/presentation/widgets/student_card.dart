import 'package:flutter/material.dart';
import '../../domain/entities/student_entity.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;
  final int index;
  final VoidCallback onEdit;

  const StudentCard({
    super.key,
    required this.student,
    required this.index,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          foregroundColor: Colors.blue.shade800,
          child: Text("${index + 1}"),
        ),
        title: Text(
          "Sinh viên: ${student.studentName}\nID: ${student.studentId}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                Icons.person_off,
                Colors.red,
                "Nghỉ: ${student.currentAbsences}",
              ),
              _buildInfoChip(
                Icons.calendar_view_week,
                Colors.orange,
                "GK: ${student.midtermScore ?? '-'}",
              ),
              _buildInfoChip(
                Icons.grade,
                Colors.green,
                "CK: ${student.finalScore ?? '-'}",
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blue),
          onPressed: onEdit,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }
}
