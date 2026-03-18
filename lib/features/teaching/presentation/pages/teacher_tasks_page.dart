import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../widgets/edit_task_dialog.dart';
import 'assignment_submissions_page.dart';

import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text(
          'Qu\u1ea3n l\u00fd b\u00e0i t\u1eadp',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is AssignmentCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('T\u1ea1o b\u00e0i t\u1eadp th\u00e0nh c\u00f4ng!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AssignmentUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('C\u1eadp nh\u1eadt th\u00e0nh c\u00f4ng!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AssignmentDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('X\u00f3a th\u00e0nh c\u00f4ng!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TeacherLoading ||
              state is AssignmentCreatedSuccess ||
              state is AssignmentUpdatedSuccess ||
              state is AssignmentDeletedSuccess) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (state is AssignmentsLoaded) {
            if (state.assignments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(isDark ? 20 : 10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: AppColors.primary.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ch\u01b0a c\u00f3 b\u00e0i t\u1eadp n\u00e0o',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'B\u1ea5m + \u0111\u1ec3 t\u1ea1o b\u00e0i t\u1eadp m\u1edbi',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: state.assignments.length,
              itemBuilder: (context, index) {
                final a = state.assignments[index];
                return _buildAssignmentCard(a, isDark);
              },
            );
          } else if (state is TeacherError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    'L\u1ed7i: ${state.message}',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthSuccess && authState.user != null) {
                        context.read<TeacherBloc>().add(
                          LoadAssignments(authState.user!.id),
                        );
                      }
                    },
                    child: const Text('Th\u1eed l\u1ea1i'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(dynamic assignment, bool isDark) {
    final isOverdue = assignment.dueDate.isBefore(DateTime.now());
    final pending = (assignment.totalStudents ?? 0) -
        (assignment.completedStudents ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignmentSubmissionsPage(
                assignmentId: assignment.id!,
                assignmentTitle: assignment.title,
                dueDate: assignment.dueDate.toIso8601String(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isOverdue ? AppColors.error : AppColors.primary)
                          .withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: isOverdue ? AppColors.error : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 13,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.textSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(assignment.dueDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textSecondary(context),
                                fontWeight:
                                    isOverdue ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        final assignmentBloc = context.read<TeacherBloc>();
                        final dialogBloc = di.sl<TeacherBloc>();
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocProvider(
                            create: (_) => dialogBloc,
                            child: EditTaskDialog(
                              assignment: assignment,
                              assignmentBloc: assignmentBloc,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, assignment.id!);
                      }
                    },
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.textSecondary(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Ch\u1ec9nh s\u1eeda'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18,
                                color: AppColors.error),
                            SizedBox(width: 8),
                            Text('X\u00f3a',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (assignment.description != null &&
                  assignment.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildBadge(
                    '${assignment.completedStudents ?? 0} \u0111\u00e3 n\u1ed9p',
                    AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  if (pending > 0)
                    _buildBadge(
                      '$pending ch\u01b0a n\u1ed9p',
                      AppColors.warning,
                    ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext mainCtx, int assignmentId) {
    final isDark = AppColors.isDark(mainCtx);
    showDialog(
      context: mainCtx,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('X\u00f3a b\u00e0i t\u1eadp'),
          ],
        ),
        content: Text(
          'B\u1ea1n c\u00f3 ch\u1eafc ch\u1eafn mu\u1ed1n x\u00f3a b\u00e0i t\u1eadp n\u00e0y?',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'H\u1ee7y',
              style: TextStyle(color: AppColors.textSecondary(mainCtx)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = mainCtx.read<AuthBloc>().state;
              if (authState is AuthSuccess && authState.user != null) {
                mainCtx.read<TeacherBloc>().add(
                  DeleteAssignmentRequested(assignmentId, authState.user!.id),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('X\u00f3a', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
