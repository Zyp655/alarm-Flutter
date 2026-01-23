import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';

class TeacherTasksPage extends StatefulWidget {
  const TeacherTasksPage({super.key});

  @override
  State<TeacherTasksPage> createState() => _TeacherTasksPageState();
}

class _TeacherTasksPageState extends State<TeacherTasksPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<TeacherBloc>().add(LoadAssignments(authState.user!.id));
    }
  }

  void _showDeleteConfirmation(BuildContext context, int assignmentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xóa Bài Tập"),
        content: const Text("Bạn có chắc chắn muốn xóa bài tập này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess && authState.user != null) {
                context.read<TeacherBloc>().add(
                  DeleteAssignmentRequested(assignmentId, authState.user!.id),
                );
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text("Quản lý bài tập")),
          body: BlocConsumer<TeacherBloc, TeacherState>(
            listener: (context, state) {
              if (state is TeacherError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AssignmentCreatedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tạo bài tập thành công!")),
                );
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess && authState.user != null) {
                  context.read<TeacherBloc>().add(
                    LoadAssignments(authState.user!.id),
                  );
                }
              } else if (state is AssignmentUpdatedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cập nhật bài tập thành công!")),
                );
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess && authState.user != null) {
                  context.read<TeacherBloc>().add(
                    LoadAssignments(authState.user!.id),
                  );
                }
              } else if (state is AssignmentDeletedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xóa bài tập thành công!")),
                );
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess && authState.user != null) {
                  context.read<TeacherBloc>().add(
                    LoadAssignments(authState.user!.id),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is TeacherLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AssignmentsLoaded) {
                if (state.assignments.isEmpty) {
                  return const Center(child: Text("Chưa có bài tập nào."));
                }
                return ListView.builder(
                  itemCount: state.assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = state.assignments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          assignment.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (assignment.description != null)
                              Text(assignment.description!),
                            const SizedBox(height: 4),
                            Text(
                              "Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(assignment.dueDate)}",
                            ),
                            Text("Điểm thưởng: ${assignment.rewardPoints}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final teacherBloc = context.read<TeacherBloc>();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => BlocProvider.value(
                                    value: teacherBloc,
                                    child: EditTaskDialog(
                                      assignment: assignment,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(
                                  context,
                                  assignment.id!,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text("Đang tải dữ liệu..."));
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final teacherBloc = context.read<TeacherBloc>();
              showDialog(
                context: context,
                builder: (ctx) => BlocProvider.value(
                  value: teacherBloc,
                  child: const CreateTaskDialog(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
