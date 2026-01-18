import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart';
import '../../../schedule/presentation/utils/excel_schedule_parser.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';

// 👇 IMPORT DIALOG CỦA SINH VIÊN
import '../../../schedule/presentation/widgets/schedule_dialogs.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'teacher_student_list_page.dart';

class TeacherClassListPage extends StatefulWidget {
  const TeacherClassListPage({super.key});

  @override
  State<TeacherClassListPage> createState() => _TeacherClassListPageState();
}

class _TeacherClassListPageState extends State<TeacherClassListPage> {
  int _getCurrentUserId() {
    return sl<SharedPreferences>().getInt('current_user_id') ?? 1;
  }

  // 1. Logic Import Excel (Giữ nguyên)
  Future<void> _pickAndImportExcel(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        List<ScheduleEntity> parsedList = await ExcelScheduleParser.parse(
          filePath,
        );

        if (parsedList.isNotEmpty && mounted) {
          final scheduleMaps = parsedList
              .map(
                (e) => {
                  'subject': e.subject,
                  'room': e.room,
                  'start': e.start.toIso8601String(),
                  'end': e.end.toIso8601String(),
                },
              )
              .toList();

          context.read<TeacherBloc>().add(
            ImportSchedulesRequested(_getCurrentUserId(), scheduleMaps),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đang import dữ liệu...")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  // 👇 2. LOGIC TẠO MỚI (SỬ DỤNG GIAO DIỆN CỦA SINH VIÊN)
  void _onManualCreate(BuildContext context) async {
    // Gọi Form nhập liệu xịn xò của Sinh viên
    final result = await ScheduleDialogs.showScheduleForm(context);

    if (result != null && mounted) {
      final entity = result['schedule'] as ScheduleEntity;
      final int repeatWeeks = result['repeat']
          ? 15
          : 1; // Nếu chọn lặp thì tạo 15 tuần

      // Tạo danh sách lịch để gửi lên Server (Tái sử dụng logic Import)
      List<Map<String, dynamic>> schedulesToSend = [];

      for (int i = 0; i < repeatWeeks; i++) {
        final start = entity.start.add(Duration(days: 7 * i));
        final end = entity.end.add(Duration(days: 7 * i));

        schedulesToSend.add({
          'subject': entity.subject,
          'room': entity.room,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        });
      }

      // Gửi event Import (nhưng chỉ chứa 1 môn vừa tạo)
      context.read<TeacherBloc>().add(
        ImportSchedulesRequested(_getCurrentUserId(), schedulesToSend),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đang tạo lớp học...")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TeacherBloc>()..add(LoadTeacherClasses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản Lý Lớp (GV)"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        floatingActionButton: Builder(
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: "btnExcel",
                backgroundColor: Colors.green,
                tooltip: "Nhập từ Excel",
                onPressed: () => _pickAndImportExcel(ctx),
                child: const Icon(Icons.upload_file),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "btnAdd",
                tooltip: "Tạo lớp mới",
                // 👇 Gọi hàm tạo mới đã sửa
                onPressed: () => _onManualCreate(ctx),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        body: BlocConsumer<TeacherBloc, TeacherState>(
          listener: (context, state) {
            // Gom chung thông báo thành công
            if (state is ImportSuccess || state is ClassCreatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("✅ Cập nhật thành công!"),
                ),
              );
              // Tự động load lại danh sách
              context.read<TeacherBloc>().add(LoadTeacherClasses());
            }
          },
          builder: (context, state) {
            if (state is TeacherLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TeacherError) {
              return Center(
                child: Text(
                  "Lỗi: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (state is TeacherLoaded) {
              final schedules = state.schedules;
              final subjects = schedules.map((e) => e.subject).toSet().toList();

              if (subjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.class_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Chưa có lớp học nào.\nNhấn nút + để tạo lớp mới.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subjectName = subjects[index];
                  final classSchedules = schedules
                      .where((s) => s.subject == subjectName)
                      .toList();
                  final distinctStudentCount = classSchedules
                      .map((e) => e.userId)
                      .toSet()
                      .length;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.class_, color: Colors.blue),
                      ),
                      title: Text(
                        subjectName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Sĩ số: $distinctStudentCount sinh viên"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherStudentListPage(
                              subjectName: subjectName,
                              allSchedules: schedules,
                            ),
                          ),
                        ).then((_) {
                          context.read<TeacherBloc>().add(LoadTeacherClasses());
                        });
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
