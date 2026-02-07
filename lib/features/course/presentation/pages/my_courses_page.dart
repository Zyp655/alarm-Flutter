import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import '../../../../injection_container.dart';
import '../../../../core/route/app_route.dart'; 

class MyCoursesPage extends StatelessWidget {
  final int userId;

  const MyCoursesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyCoursesBloc>()..add(LoadMyCoursesEvent(userId)),
      child: MyCoursesView(userId: userId),
    );
  }
}

class MyCoursesView extends StatefulWidget {
  final int userId;

  const MyCoursesView({super.key, required this.userId});

  @override
  State<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends State<MyCoursesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Học tập',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6C63FF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang học'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: BlocBuilder<MyCoursesBloc, MyCoursesState>(
        builder: (context, state) {
          if (state is MyCoursesLoading || state is MyCoursesInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyCoursesError) {
            return _buildErrorState(state.message);
          } else if (state is MyCoursesLoaded) {
            final allCourses = state.enrollments;
            final inProgress = allCourses.where((e) => !e.isCompleted).toList();
            final completed = allCourses.where((e) => e.isCompleted).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCourseList(allCourses, 'Chưa đăng ký khóa học nào'),
                _buildCourseList(inProgress, 'Không có khóa học đang học'),
                _buildCourseList(completed, 'Chưa có khóa học hoàn thành'),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCourseList(List<EnrollmentEntity> courses, String emptyMessage) {
    if (courses.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MyCoursesBloc>().add(RefreshMyCoursesEvent(widget.userId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(courses[index])
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Khám phá khóa học'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MyCoursesBloc>().add(
                RefreshMyCoursesEvent(widget.userId),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(EnrollmentEntity enrollment) {
    final progress = enrollment.progressPercent / 100;
    final isCompleted = enrollment.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.courseDetail,
            arguments: enrollment.courseId,
          );
                },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 30,
                lineWidth: 6,
                percent: progress.clamp(0.0, 1.0),
                center: isCompleted
                    ? const Icon(Icons.check, color: Color(0xFF00C853))
                    : Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                progressColor: isCompleted
                    ? const Color(0xFF00C853)
                    : const Color(0xFF6C63FF),
                backgroundColor: Colors.grey[100]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.course?.title ??
                          'Khóa học #${enrollment.courseId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Đã hoàn thành',
                          style: TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Đã học: ${_formatDate(enrollment.enrolledAt)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF00C853).withOpacity(0.1)
                      : const Color(0xFF6C63FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isCompleted ? Icons.replay : Icons.play_arrow,
                    color: isCompleted
                        ? const Color(0xFF00C853)
                        : const Color(0xFF6C63FF),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.courseDetail,
                      arguments: enrollment.courseId,
                    );
                                    },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
