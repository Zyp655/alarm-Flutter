import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/lesson_entity.dart';
import '../bloc/course_detail_bloc.dart';
import '../bloc/course_detail_event.dart';
import '../bloc/course_detail_state.dart';
import '../../../../injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/services/content_analyzer_service.dart';
import 'course_submissions_page.dart';
import 'module_quiz_page.dart';
import '../widgets/study_plan_setup_dialog.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/presentation/bloc/schedule_event.dart';

class CourseDetailPage extends StatelessWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final userId = sl<SharedPreferences>().getInt('current_user_id');

    return BlocProvider(
      create: (context) =>
          sl<CourseDetailBloc>()
            ..add(LoadCourseDetailEvent(courseId, userId: userId)),
      child: CourseDetailView(userId: userId),
    );
  }
}

class CourseDetailView extends StatefulWidget {
  final int? userId;

  const CourseDetailView({super.key, this.userId});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Quiz tracking per module
  final Map<int, Map<String, dynamic>?> _moduleQuizzes = {};
  final Set<int> _loadingQuizModules = {};

  void _loadQuizForModule(int moduleId) async {
    if (_loadingQuizModules.contains(moduleId) ||
        _moduleQuizzes.containsKey(moduleId))
      return;
    _loadingQuizModules.add(moduleId);

    try {
      final result = await ContentAnalyzerService().getSavedQuiz(
        moduleId: moduleId,
      );
      if (mounted) {
        setState(() {
          _moduleQuizzes[moduleId] = result;
          _loadingQuizModules.remove(moduleId);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingQuizModules.remove(moduleId));
      }
    }
  }

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
      body: BlocConsumer<CourseDetailBloc, CourseDetailState>(
        listener: (context, state) {
          if (state is CourseDetailLoaded) {
            if (state.actionError != null) {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.7),
                builder: (context) =>
                    _buildActionErrorDialog(context, state.actionError!),
              );
            } else if (state.isJustEnrolled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Đăng ký khóa học thành công!'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF00C853),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => StudyPlanSetupDialog(
                  courseId: state.course.id,
                  onSaved: () {
                    sl<ScheduleBloc>().add(LoadSchedules());
                  },
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is CourseDetailLoading || state is CourseDetailInitial) {
            return _buildLoadingState();
          } else if (state is CourseDetailLoaded) {
            return _buildContent(context, state);
          } else if (state is CourseDetailError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildActionErrorDialog(BuildContext context, String message) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                size: 32,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Thông báo",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Đã hiểu",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(expandedHeight: 280, pinned: true),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 24, width: 200, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 60, color: Colors.white),
                  const SizedBox(height: 24),
                  Container(height: 200, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
          ),
          const SizedBox(height: 24),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailLoaded state) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildHeroAppBar(context, state.course),
            SliverToBoxAdapter(child: _buildCourseHeader(state.course)),
            if (state.enrollment != null)
              SliverToBoxAdapter(child: _buildGlobalProgressBar(state)),
            SliverToBoxAdapter(child: _buildStatsRow(state)),
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCurriculumTab(state.modules, state.course.id),
                    _buildAboutTab(state.course),
                    _buildReviewsTab(),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        _buildBottomCTA(context, state),
      ],
    );
  }

  Widget _buildHeroAppBar(BuildContext context, CourseEntity course) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFFFF6636),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            course.thumbnailUrl != null
                ? Image.network(
                    course.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
                  )
                : _buildGradientPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ).animate().scale(delay: 300.ms),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                course.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black38)],
                ),
                maxLines: 2,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6636), Color(0xFFF94C10)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.school, size: 64, color: Colors.white38),
      ),
    );
  }

  Widget _buildCourseHeader(CourseEntity course) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (course.price == 0)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MIỄN PHÍ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (course.price == 0) const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6636), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE8E8F4),
                  child: Icon(Icons.person, color: Color(0xFFFF6636)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giảng viên',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const Text(
                      'Nguyễn Văn A',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6636)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Theo dõi',
                  style: TextStyle(color: Color(0xFFFF6636)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildGlobalProgressBar(CourseDetailLoaded state) {
    final enrollment = state.enrollment;
    if (enrollment == null) return const SizedBox.shrink();

    final progress = enrollment.progressPercent / 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ học tập',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${enrollment.progressPercent.toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6636),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFFFF6636),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CourseDetailLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.people_outline,
            '${state.course.studentCount}',
            'Học viên',
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.play_circle_outline,
            '${state.modules.length}',
            'Bài học',
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.access_time,
            '${state.course.durationMinutes}m',
            'Thời lượng',
          ),
          _buildDivider(),
          _buildStatItem(Icons.star, '${state.course.rating}', 'Đánh giá'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6636), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[200]);
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFF6636),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFFF6636),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Nội dung'),
          Tab(text: 'Giới thiệu'),
          Tab(text: 'Đánh giá'),
        ],
      ),
    );
  }

  Widget _buildCurriculumTab(List<ModuleEntity> modules, int courseId) {
    if (modules.isEmpty) {
      return const Center(child: Text('Nội dung đang được cập nhật...'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6636).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFFFF6636),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                module.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                '${module.lessons?.length ?? 0} bài học',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              children: [
                // Lesson items
                ...?module.lessons?.map(
                  (lesson) => _buildLessonItem(lesson, modules, courseId),
                ),
                // Quiz item - load and display if exists
                Builder(
                  builder: (context) {
                    // Trigger quiz load
                    if (!_moduleQuizzes.containsKey(module.id) &&
                        !_loadingQuizModules.contains(module.id)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadQuizForModule(module.id);
                      });
                    }

                    final quizData = _moduleQuizzes[module.id];
                    final hasQuiz =
                        quizData != null &&
                        quizData['quiz'] != null &&
                        quizData['questions'] != null &&
                        (quizData['questions'] as List).isNotEmpty;

                    if (hasQuiz) {
                      final quiz = quizData['quiz'] as Map<String, dynamic>;
                      final questions = quizData['questions'] as List;

                      // Check if all lessons in module are completed
                      final lessons = module.lessons ?? [];
                      final completedLessons = lessons
                          .where((l) => l.isCompleted)
                          .length;
                      final allLessonsCompleted =
                          lessons.isNotEmpty &&
                          completedLessons == lessons.length;

                      return _buildQuizLessonItem(
                        module.id,
                        quiz['topic'] ?? 'Bài kiểm tra',
                        questions.length,
                        isLocked: !allLessonsCompleted,
                        completedLessons: completedLessons,
                        totalLessons: lessons.length,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
      },
    );
  }

  Widget _buildQuizLessonItem(
    int moduleId,
    String title,
    int questionCount, {
    bool isLocked = false,
    int completedLessons = 0,
    int totalLessons = 0,
  }) {
    // If locked, show locked state
    if (isLocked) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[200]!, Colors.grey[100]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          subtitle: Text(
            '🔒 Hoàn thành $completedLessons/$totalLessons bài để mở khóa',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Khóa',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hoàn thành tất cả ${totalLessons - completedLessons} bài học còn lại để mở khóa quiz!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getQuizResult(moduleId),
      builder: (context, snapshot) {
        final result = snapshot.data;
        final isCompleted = result != null;
        final score = result?['score'] as int? ?? 0;
        final total = result?['total'] as int? ?? questionCount;
        final percentage = result?['percentage'] as int? ?? 0;
        final isPassing = percentage >= 70;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted
                  ? (isPassing
                        ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                        : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)])
                  : [
                      const Color(0xFFFF6636).withOpacity(0.1),
                      const Color(0xFFFFE0B2),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? (isPassing
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3))
                  : const Color(0xFFFF6636).withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isPassing
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800))
                    : const Color(0xFFFF6636),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompleted
                    ? (isPassing ? Icons.check_circle : Icons.refresh)
                    : Icons.quiz,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPassing ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$score/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              isCompleted
                  ? (isPassing
                        ? '✅ Đã hoàn thành • $percentage%'
                        : '⚠️ Cần cải thiện • $percentage%')
                  : '$questionCount câu hỏi trắc nghiệm',
              style: TextStyle(
                color: isCompleted
                    ? (isPassing ? Colors.green[700] : Colors.orange[700])
                    : Colors.grey[600],
                fontSize: 12,
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isPassing ? Colors.green[100] : const Color(0xFFFF6636))
                    : const Color(0xFFFF6636),
                borderRadius: BorderRadius.circular(20),
                border: isCompleted && isPassing
                    ? Border.all(color: Colors.green)
                    : null,
              ),
              child: Text(
                isCompleted ? (isPassing ? 'Xem lại' : 'Làm lại') : 'Làm bài',
                style: TextStyle(
                  color: isCompleted && isPassing
                      ? Colors.green[700]
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ModuleQuizPage(moduleId: moduleId, moduleTitle: title),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getQuizResult(int moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_result_$moduleId';
    final resultJson = prefs.getString(key);
    if (resultJson != null) {
      return jsonDecode(resultJson) as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, LessonEntity?> _findAdjacentLessons(
    List<ModuleEntity> modules,
    LessonEntity currentLesson,
  ) {
    LessonEntity? previousLesson;
    LessonEntity? nextLesson;

    final allLessons = <LessonEntity>[];
    for (final module in modules) {
      if (module.lessons != null) {
        allLessons.addAll(module.lessons!);
      }
    }

    final currentIndex = allLessons.indexWhere((l) => l.id == currentLesson.id);

    if (currentIndex != -1) {
      if (currentIndex > 0) {
        previousLesson = allLessons[currentIndex - 1];
      }
      if (currentIndex < allLessons.length - 1) {
        nextLesson = allLessons[currentIndex + 1];
      }
    }

    return {'previous': previousLesson, 'next': nextLesson};
  }

  Widget _buildLessonItem(
    LessonEntity lesson,
    List<ModuleEntity> allModules,
    int courseId,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          lesson.isCompleted
              ? Icons.check_circle
              : (lesson.type == LessonType.video
                    ? Icons.play_circle_fill
                    : Icons.article),
          color: lesson.isCompleted
              ? const Color(0xFF00C853)
              : const Color(0xFFFF6636),
          size: 20,
        ),
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          fontSize: 14,
          color: lesson.isCompleted ? Colors.grey[600] : Colors.black,
          decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${lesson.durationMinutes}m',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!lesson.isCompleted)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(Icons.check, color: Colors.grey[400], size: 18),
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF00C853),
                size: 18,
              ),
            ),
        ],
      ),
      onTap: () {
        final adjacent = _findAdjacentLessons(allModules, lesson);
        Navigator.pushNamed(
          context,
          AppRoutes.lessonPlayer,
          arguments: {
            'lesson': lesson,
            'userId': widget.userId,
            'previousLesson': adjacent['previous'],
            'nextLesson': adjacent['next'],
          },
        ).then((_) {
          if (mounted) {
            context.read<CourseDetailBloc>().add(
              LoadCourseDetailEvent(courseId, userId: widget.userId),
            );
          }
        });
      },
      onLongPress: lesson.type == LessonType.assignment
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseSubmissionsPage(
                    assignmentId: lesson.id,
                    assignmentTitle: lesson.title,
                  ),
                ),
              );
            }
          : null,
    );
  }

  Widget _buildAboutTab(CourseEntity course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả khóa học',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            course.description ?? 'Chưa có mô tả chi tiết.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bạn sẽ học được gì?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...[
            'Nắm vững kiến thức nền tảng',
            'Thực hành qua các bài tập thực tế',
            'Xây dựng dự án hoàn chỉnh',
            'Nhận chứng chỉ hoàn thành',
          ].map((item) => _buildCheckItem(item)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Chưa có đánh giá', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context, CourseDetailLoaded state) {
    final isEnrolled = state.enrollment != null;

    // Find next incomplete lesson
    LessonEntity? nextLesson;
    int completedCount = 0;
    int totalLessons = 0;

    for (final module in state.modules) {
      if (module.lessons != null) {
        for (final lesson in module.lessons!) {
          totalLessons++;
          if (lesson.isCompleted) {
            completedCount++;
          } else if (nextLesson == null) {
            nextLesson = lesson;
          }
        }
      }
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (!isEnrolled) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá khóa học',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      state.course.price == 0
                          ? 'Miễn phí'
                          : '${state.course.price.toStringAsFixed(0)}₫',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6636),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isEnrolled && nextLesson != null) {
                      // Navigate directly to lesson player
                      final adjacent = _findAdjacentLessons(
                        state.modules,
                        nextLesson,
                      );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.lessonPlayer,
                        arguments: {
                          'lesson': nextLesson,
                          'userId': widget.userId,
                          'previousLesson': adjacent['previous'],
                          'nextLesson': adjacent['next'],
                        },
                      ).then((_) {
                        if (mounted) {
                          context.read<CourseDetailBloc>().add(
                            LoadCourseDetailEvent(
                              state.course.id,
                              userId: widget.userId,
                            ),
                          );
                        }
                      });
                    } else if (isEnrolled) {
                      Navigator.pushNamed(context, AppRoutes.myCourses);
                    } else {
                      context.read<CourseDetailBloc>().add(
                        EnrollInCourseEvent(
                          userId: widget.userId ?? 0,
                          courseId: state.course.id,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6636),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEnrolled ? Icons.play_arrow : Icons.school,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isEnrolled
                                  ? (nextLesson != null
                                        ? (completedCount == 0
                                              ? 'Bắt đầu học'
                                              : 'Tiếp tục học')
                                        : '🎉 Hoàn thành khóa học!')
                                  : 'Đăng ký ngay',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isEnrolled && totalLessons > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bài $completedCount/$totalLessons',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, delay: 300.ms);
  }
}
