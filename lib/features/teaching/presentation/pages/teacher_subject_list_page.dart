import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/subject_entity.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'subject_detail_page.dart';

class TeacherSubjectListPage extends StatefulWidget {
  const TeacherSubjectListPage({super.key});

  @override
  State<TeacherSubjectListPage> createState() => _TeacherSubjectListPageState();
}

class _TeacherSubjectListPageState extends State<TeacherSubjectListPage> {
  int _getCurrentUserId() {
    return sl<SharedPreferences>().getInt('current_user_id') ?? 1;
  }

  void _showSubjectDialog(BuildContext context, {SubjectEntity? subject}) {
    final isEditing = subject != null;
    final nameController = TextEditingController(text: subject?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Sửa Môn Học" : "Tạo Môn Học Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tên môn (VD: Lập trình Mobile)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;

              if (name.isNotEmpty) {
                if (isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chức năng sửa đang phát triển"),
                    ),
                  );
                } else {
                  context.read<TeacherBloc>().add(
                    CreateSubjectRequested(
                      _getCurrentUserId(),
                      name,
                      3, // Default credits
                      '', // No code
                    ),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(isEditing ? "Lưu" : "Tạo"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, SubjectEntity subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa Môn Học?"),
        content: Text(
          "Bạn có chắc muốn xóa môn '${subject.name}' và toàn bộ các lớp bên trong không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Chức năng xóa đang phát triển")),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadSubjects(_getCurrentUserId()));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Quản Lý Môn Học"),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showSubjectDialog(context),
            child: const Icon(Icons.add),
          ),
          body: BlocConsumer<TeacherBloc, TeacherState>(
            listener: (context, state) {
              if (state is SubjectCreatedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tạo môn học thành công!"),
                    backgroundColor: Colors.green,
                  ),
                );
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

              if (state is SubjectsLoaded) {
                final subjects = state.subjects;
                if (subjects.isEmpty) {
                  return const Center(
                    child: Text("Chưa có môn học nào. Nhấn + để tạo."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return _buildSubjectCard(context, subject);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, SubjectEntity subject) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          radius: 25,
          child: const Icon(Icons.menu_book, color: Colors.blue),
        ),
        title: Text(
          "Môn ${subject.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // Subtitle removed as requested to show only name
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Sửa thông tin"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Xóa môn"),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') _showSubjectDialog(context, subject: subject);
            if (value == 'delete') _confirmDeleteSubject(context, subject);
          },
        ),
        onTap: () {
          // 👇 SỬA LỖI Ở ĐÂY: Dùng .then() để load lại dữ liệu khi quay về
          final teacherBloc = context.read<TeacherBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: teacherBloc,
                child: SubjectDetailPage(
                  subject: subject,
                  teacherId: _getCurrentUserId(),
                ),
              ),
            ),
          ).then((_) {
            // Khi quay lại từ trang chi tiết -> Load lại danh sách môn học
            teacherBloc.add(LoadSubjects(_getCurrentUserId()));
          });
        },
      ),
    );
  }
}
