import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/course/domain/entities/module_entity.dart';
import '../../../../features/course/presentation/bloc/course_detail_bloc.dart';
import '../../../../features/course/presentation/bloc/course_detail_state.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../pages/teacher_ai_quiz_page.dart';

class AssignmentSection extends StatefulWidget {
  final ModuleEntity module;
  final int courseId;

  const AssignmentSection({
    super.key,
    required this.module,
    required this.courseId,
  });

  @override
  State<AssignmentSection> createState() => _AssignmentSectionState();
}

class _AssignmentSectionState extends State<AssignmentSection> {
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final api = sl<ApiClient>();
      final data = await api.get('/modules/${widget.module.id}/quizzes');
      if (mounted) {
        setState(() {
          _quizzes = List<Map<String, dynamic>>.from(data['quizzes'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('[_loadQuizzes] moduleId=${widget.module.id} error: $e');
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final api = sl<ApiClient>();
      final data = await api.get(
        '/teacher/assignments?moduleId=${widget.module.id}',
      );
      if (mounted) {
        setState(() {
          _assignments = List<Map<String, dynamic>>.from(data['assignments'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[_loadAssignments] error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAssignment(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài tập'),
        content: const Text('Bạn có chắc chắn muốn xóa bài tập này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final api = sl<ApiClient>();
      await api.delete('/teacher/assignments/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài tập!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadAssignments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa bài tập: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_add, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Tạo bài tập mới'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề bài tập *',
                    hintText: 'VD: Bài tập thực hành Chương 1',
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Nội dung yêu cầu',
                    hintText: 'Nhập yêu cầu bài tập...',
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: const TimeOfDay(hour: 23, minute: 59),
                      );
                      setDialogState(() {
                        selectedDueDate = DateTime(
                          picked.year, picked.month, picked.day,
                          time?.hour ?? 23, time?.minute ?? 59,
                        );
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hạn nộp',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedDueDate.day}/${selectedDueDate.month}/${selectedDueDate.year} – ${selectedDueDate.hour.toString().padLeft(2, '0')}:${selectedDueDate.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_rounded, size: 16, color: AppColors.textSecondary(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _createAssignment(
                  titleController.text.trim(),
                  descController.text.trim(),
                  selectedDueDate,
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tạo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAssignment(String title, String description, DateTime dueDate) async {
    try {
      final courseId =
          (BlocProvider.of<CourseDetailBloc>(context).state as CourseDetailLoaded)
              .course
              .id;
      final api = sl<ApiClient>();
      final authState = context.read<AuthBloc>().state;
      final teacherId = (authState is AuthSuccess && authState.user != null)
          ? authState.user!.id
          : 1;
      await api.post('/teacher/create_assignment', {
        'classId': courseId,
        'teacherId': teacherId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'moduleId': widget.module.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo bài tập thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAssignments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo bài tập: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 30 : 15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.assignment_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Bài tập',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (_assignments.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_assignments.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_assignments.isEmpty)
            Text(
              'Chưa có bài tập nào cho chương này',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            )
          else
            ..._assignments.map(
              (a) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(8)
                      : Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['title'] ?? 'Bài tập',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _deleteAssignment(a['id']),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_quizzes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(isDark ? 30 : 15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.quiz_rounded, color: AppColors.accent, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Quiz AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._quizzes.map(
              (q) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accent.withAlpha(12)
                      : AppColors.accent.withAlpha(8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['topic'] ?? 'Quiz',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${q['questionCount'] ?? 0} câu · ${q['difficulty'] ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓ Đã tạo',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCreateAssignmentDialog,
                  icon: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  label: Text('Tạo bài tập', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherAiQuizPage(
                          courseId: widget.courseId,
                          moduleId: widget.module.id,
                        ),
                      ),
                    ).then((created) {
                      if (created == true) _loadQuizzes();
                    });
                  },
                  icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                  label: const Text('Tạo Quiz AI', style: TextStyle(fontSize: 13, color: AppColors.accent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accent.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
