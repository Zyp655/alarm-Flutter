import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';

class TeacherUpdateDialog {
  static void show(
    BuildContext context,
    ScheduleEntity studentSchedule, {
    required int teacherId,
    required Function() onSuccess,
  }) {
    final absenceCtrl = TextEditingController(
      text: studentSchedule.currentAbsences.toString(),
    );
    final midtermCtrl = TextEditingController(
      text: studentSchedule.midtermScore?.toString() ?? '',
    );
    final finalCtrl = TextEditingController(
      text: studentSchedule.finalScore?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cập nhật: ${studentSchedule.subject}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: absenceCtrl,
                decoration: const InputDecoration(
                  labelText: "Số buổi nghỉ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: midtermCtrl,
                decoration: const InputDecoration(
                  labelText: "Điểm Giữa Kỳ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: finalCtrl,
                decoration: const InputDecoration(
                  labelText: "Điểm Cuối Kỳ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final int? absences = int.tryParse(absenceCtrl.text);
              final double? midterm = double.tryParse(midtermCtrl.text);
              final double? finalScore = double.tryParse(finalCtrl.text);

              context.read<TeacherBloc>().add(
                UpdateScoreRequested(
                  teacherId: teacherId,
                  scheduleId: studentSchedule.id!,
                  absences: absences,
                  midtermScore: midterm,
                  finalScore: finalScore,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
}
