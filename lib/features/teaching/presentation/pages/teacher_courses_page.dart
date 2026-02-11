import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../course/presentation/bloc/course_list_bloc.dart';
import '../../../course/presentation/bloc/course_list_event.dart';
import '../../../course/presentation/bloc/course_list_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import 'teacher_course_editor_page.dart';
import 'teacher_students_page.dart';
import 'teacher_course_stats_page.dart';

class TeacherCoursesPage extends StatefulWidget {
  final int teacherId;

  const TeacherCoursesPage({super.key, required this.teacherId});

  @override
  State<TeacherCoursesPage> createState() => _TeacherCoursesPageState();
}

class _TeacherCoursesPageState extends State<TeacherCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Quản lý Khóa học'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      body: BlocProvider(
        create: (context) => di.sl<CourseListBloc>()
          ..add(
            LoadCoursesEvent(
              instructorId: widget.teacherId,
              showUnpublished: true,
            ),
          ),
        child: Builder(
          builder: (context) {
            return BlocBuilder<CourseListBloc, CourseListState>(
              builder: (context, state) {
                if (state is CourseListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimaryDark,
                    ),
                  );
                } else if (state is CourseListError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                } else if (state is CourseListLoaded) {
                  final myCourses = state.courses
                      .where((c) => c.instructorId == widget.teacherId)
                      .toList();

                  if (myCourses.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCoursesList(context, myCourses);
                }
                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[600]),
          AppSpacing.gapV16,
          Text(
            'Bạn chưa có khóa học nào',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          AppSpacing.gapV8,
          ElevatedButton.icon(
            onPressed: () => _showCreateCourseDialog(
              context,
              context.read<CourseListBloc>(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tạo khóa học'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, List<dynamic> myCourses) {
    return Stack(
      children: [
        ListView.builder(
          padding: AppSpacing.paddingLg,
          itemCount: myCourses.length + 1,
          itemBuilder: (context, index) {
            if (index == myCourses.length) return const SizedBox(height: 80);
            return _CourseCard(
              course: myCourses[index],
              onTap: () => _showCourseActions(context, myCourses[index]),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'teacher_create_course',
            onPressed: () => _showCreateCourseDialog(
              context,
              context.read<CourseListBloc>(),
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showCourseActions(BuildContext context, dynamic course) {
    final bloc = context.read<CourseListBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: AppDecorations.bottomSheetShape,
      builder: (bottomSheetContext) => Container(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDecorations.dragHandle(),
            AppSpacing.gapV20,
            Text(
              course.title,
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.gapV24,
            _ActionTile(
              icon: Icons.people,
              title: 'Quản lý sinh viên',
              subtitle: 'Xem danh sách và tiến độ học',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherStudentsPage(
                      teacherId: widget.teacherId,
                      initialCourseId: course.id,
                    ),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.analytics,
              title: 'Thống kê khóa học',
              subtitle: 'Xem số liệu và đánh giá',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherCourseStatsPage(
                      teacherId: widget.teacherId,
                      courseId: course.id,
                    ),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.edit,
              title: 'Chỉnh sửa khóa học',
              subtitle: 'Cập nhật nội dung và bài học',
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeacherCourseEditorPage(courseId: course.id),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              title: 'Xóa khóa học',
              subtitle: 'Hành động này không thể hoàn tác',
              isDestructive: true,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showDeleteConfirmationDialog(
                  context,
                  course,
                  bloc,
                  scaffoldMessenger,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    dynamic course,
    CourseListBloc bloc,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: AppDecorations.dialogShape,
        title: const Text(
          'Xóa khóa học?',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa khóa học "${course.title}"? Dữ liệu bài học và học viên sẽ bị xóa và không thể khôi phục.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(DeleteCourseEvent(course.id));
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Đang xóa khóa học...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Xóa vĩnh viễn',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCourseDialog(
    BuildContext context,
    CourseListBloc courseListBloc,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedLevel = 'beginner';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: AppDecorations.dialogShape,
        title: const Text(
          'Tạo khóa học mới',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: AppDecorations.darkInputDecoration(
                  labelText: 'Tên khóa học *',
                ),
              ),
              AppSpacing.gapV12,
              TextField(
                controller: descController,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                maxLines: 3,
                decoration: AppDecorations.darkInputDecoration(
                  labelText: 'Mô tả',
                ),
              ),
              AppSpacing.gapV12,
              DropdownButtonFormField<String>(
                value: selectedLevel,
                dropdownColor: AppColors.darkSurfaceVariant,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: AppDecorations.darkInputDecoration(
                  labelText: 'Cấp độ',
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Cơ bản')),
                  DropdownMenuItem(
                    value: 'intermediate',
                    child: Text('Trung cấp'),
                  ),
                  DropdownMenuItem(value: 'advanced', child: Text('Nâng cao')),
                ],
                onChanged: (value) {
                  selectedLevel = value ?? 'beginner';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                courseListBloc.add(
                  CreateCourseEvent(
                    title: titleController.text,
                    description: descController.text,
                    level: selectedLevel,
                    instructorId: widget.teacherId,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.darkCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.borderRadiusLg,
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: AppDecorations.iconContainer(
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    AppSpacing.gapH12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.gapV4,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: course.isPublished
                                    ? AppDecorations.publishedBadge
                                    : AppDecorations.draftBadge,
                                child: Text(
                                  course.isPublished ? 'Công khai' : 'Nháp',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              AppSpacing.gapH8,
                              Text(
                                course.level,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                if (course.description != null &&
                    course.description!.isNotEmpty) ...[
                  AppSpacing.gapV12,
                  Text(
                    course.description!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.textPrimaryDark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red.withOpacity(0.7) : Colors.grey[400],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
