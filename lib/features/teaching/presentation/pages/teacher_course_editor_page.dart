import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/content_analyzer_service.dart';
import '../../../../features/course/domain/entities/module_entity.dart';
import '../../../../features/course/domain/entities/lesson_entity.dart';
import '../../../../features/course/presentation/bloc/course_detail_bloc.dart';
import '../../../../features/course/presentation/bloc/course_detail_event.dart';
import '../../../../features/course/presentation/bloc/course_detail_state.dart';
import '../../../../injection_container.dart';
import '../widgets/dialogs/module_dialogs.dart';
import '../widgets/dialogs/add_lesson_dialog.dart';
import '../widgets/dialogs/edit_lesson_dialog.dart';
import '../widgets/dialogs/video_preview_dialog.dart';
import '../widgets/dialogs/quiz_preview_dialog.dart';
import '../widgets/dialogs/ai_quiz_loading_dialog.dart';

class TeacherCourseEditorPage extends StatelessWidget {
  final int courseId;

  const TeacherCourseEditorPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<CourseDetailBloc>()..add(LoadCourseDetailEvent(courseId)),
      child: const TeacherCourseEditorView(),
    );
  }
}

class TeacherCourseEditorView extends StatefulWidget {
  const TeacherCourseEditorView({super.key});

  @override
  State<TeacherCourseEditorView> createState() =>
      _TeacherCourseEditorViewState();
}

class _TeacherCourseEditorViewState extends State<TeacherCourseEditorView> {
  final Map<int, Map<String, dynamic>?> _moduleQuizzes = {};
  final Set<int> _loadingQuizModules = {};

  void _loadQuizForModule(int moduleId) async {
    if (_loadingQuizModules.contains(moduleId)) return;
    _loadingQuizModules.add(moduleId);

    try {
      final service = ContentAnalyzerService();
      final result = await service.getSavedQuiz(moduleId: moduleId);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa nội dung'),
        backgroundColor: const Color(0xFFFF6636),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CourseDetailBloc, CourseDetailState>(
        listener: (context, state) {
          if (state is CourseDetailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is CourseDetailLoading || state is CourseDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseDetailLoaded) {
            return _buildContent(context, state);
          } else if (state is CourseDetailError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_module',
        onPressed: () => ModuleDialogs.showAddModule(context),
        label: const Text('Thêm chương'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF6636),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailLoaded state) {
    if (state.modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Text(
              'Chưa có nội dung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu bằng việc thêm chương mới!',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      itemCount: state.modules.length,
      itemBuilder: (context, index) {
        final module = state.modules[index];
        return _ModuleTimelineItem(
          module: module,
          index: index,
          totalCount: state.modules.length,
          moduleQuizzes: _moduleQuizzes,
          loadingQuizModules: _loadingQuizModules,
          onLoadQuiz: _loadQuizForModule,
        );
      },
    );
  }
}

class _ModuleTimelineItem extends StatelessWidget {
  final ModuleEntity module;
  final int index;
  final int totalCount;
  final Map<int, Map<String, dynamic>?> moduleQuizzes;
  final Set<int> loadingQuizModules;
  final void Function(int) onLoadQuiz;

  const _ModuleTimelineItem({
    required this.module,
    required this.index,
    required this.totalCount,
    required this.moduleQuizzes,
    required this.loadingQuizModules,
    required this.onLoadQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = index == totalCount - 1;
    final isFirst = index == 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 14,
                color: isFirst ? Colors.transparent : Colors.grey[300],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6636),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6636).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isLast)
                Positioned(
                  left: -46,
                  top: 42,
                  bottom: 0,
                  child: Container(width: 2, color: Colors.grey[300]),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _ModuleCard(
                  module: module,
                  moduleQuizzes: moduleQuizzes,
                  loadingQuizModules: loadingQuizModules,
                  onLoadQuiz: onLoadQuiz,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleEntity module;
  final Map<int, Map<String, dynamic>?> moduleQuizzes;
  final Set<int> loadingQuizModules;
  final void Function(int) onLoadQuiz;

  const _ModuleCard({
    required this.module,
    required this.moduleQuizzes,
    required this.loadingQuizModules,
    required this.onLoadQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    module.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                  onPressed: () =>
                      ModuleDialogs.showUpdateModule(context, module),
                ),
              ],
            ),
            subtitle: Text(
              '${module.lessons?.length ?? 0} bài học',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            children: [
              Container(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 8),

              if (module.lessons != null)
                ...module.lessons!.map((lesson) => _LessonItem(lesson: lesson)),

              _QuizSection(
                moduleId: module.id,
                moduleQuizzes: moduleQuizzes,
                loadingQuizModules: loadingQuizModules,
                onLoadQuiz: onLoadQuiz,
              ),

              _AddLessonButton(moduleId: module.id),

              const SizedBox(height: 16),

              _AIQuizSection(module: module, onQuizReload: onLoadQuiz),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final LessonEntity lesson;
  const _LessonItem({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        lesson.type == LessonType.video ? Icons.play_circle : Icons.article,
        color: Colors.grey[700],
      ),
      title: Text(lesson.title),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            EditLessonDialog.show(context, lesson);
          } else if (value == 'delete') {
            _showDeleteConfirmation(context, lesson);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Chỉnh sửa'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Xóa', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        if (lesson.type == LessonType.video && lesson.contentUrl != null) {
          showDialog(
            context: context,
            builder: (context) =>
                VideoPreviewDialog(videoUrl: lesson.contentUrl!),
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(BuildContext mainContext, LessonEntity lesson) {
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa bài học "${lesson.title}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CourseDetailBloc>(mainContext).add(
                DeleteLessonEvent(
                  courseId:
                      (BlocProvider.of<CourseDetailBloc>(mainContext).state
                              as CourseDetailLoaded)
                          .course
                          .id,
                  moduleId: lesson.moduleId,
                  lessonId: lesson.id,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  final int moduleId;
  final Map<int, Map<String, dynamic>?> moduleQuizzes;
  final Set<int> loadingQuizModules;
  final void Function(int) onLoadQuiz;

  const _QuizSection({
    required this.moduleId,
    required this.moduleQuizzes,
    required this.loadingQuizModules,
    required this.onLoadQuiz,
  });

  @override
  Widget build(BuildContext context) {
    if (!moduleQuizzes.containsKey(moduleId) &&
        !loadingQuizModules.contains(moduleId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onLoadQuiz(moduleId);
      });
    }

    if (loadingQuizModules.contains(moduleId)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Đang tải quiz...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final quizData = moduleQuizzes[moduleId];
    final hasQuiz =
        quizData != null &&
        quizData['quiz'] != null &&
        quizData['questions'] != null &&
        (quizData['questions'] as List).isNotEmpty;

    if (!hasQuiz) return const SizedBox.shrink();

    final quiz = quizData['quiz'] as Map<String, dynamic>;
    final questions = quizData['questions'] as List;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6636).withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6636).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz, color: Color(0xFFFF6636), size: 24),
        ),
        title: Text(
          quiz['topic'] ?? 'Bài kiểm tra',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${questions.length} câu hỏi',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFFFF6636)),
              onPressed: () => _showQuizPreview(context, moduleId),
              tooltip: 'Xem quiz',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa bài kiểm tra')),
                );
              },
              tooltip: 'Xóa quiz',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuizPreview(BuildContext context, int moduleId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ContentAnalyzerService();
      final result = await service.getSavedQuiz(moduleId: moduleId);

      if (!context.mounted) return;
      Navigator.pop(context);

      if (result != null &&
          result['quiz'] != null &&
          result['questions'] != null) {
        final questions = result['questions'] as List;
        if (questions.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                QuizPreviewDialog(quizData: result, moduleId: moduleId),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz chưa có câu hỏi nào.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa có quiz nào được tạo cho chương này.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _AddLessonButton extends StatelessWidget {
  final int moduleId;
  const _AddLessonButton({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AddLessonDialog.show(context, moduleId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6636).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Color(0xFFFF6636), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Thêm bài học mới',
              style: TextStyle(
                color: Color(0xFFFF6636),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIQuizSection extends StatelessWidget {
  final ModuleEntity module;
  final void Function(int) onQuizReload;

  const _AIQuizSection({required this.module, required this.onQuizReload});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Quiz Generator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tự động tạo câu hỏi trắc nghiệm dựa trên nội dung chương này.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQuizPreview(context, module.id),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Xem trước'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D3436),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showGenerateQuizDialog(context, module.id),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Tạo Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3436),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showGenerateQuizDialog(
    BuildContext context,
    int moduleId,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIQuizLoadingDialog(moduleId: moduleId),
    );

    if (saved == true) {
      onQuizReload(moduleId);
    }
  }

  Future<void> _showQuizPreview(BuildContext context, int moduleId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ContentAnalyzerService();
      final result = await service.getSavedQuiz(moduleId: moduleId);

      if (!context.mounted) return;
      Navigator.pop(context);

      if (result != null &&
          result['quiz'] != null &&
          result['questions'] != null) {
        final questions = result['questions'] as List;
        if (questions.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) =>
                QuizPreviewDialog(quizData: result, moduleId: moduleId),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz chưa có câu hỏi nào.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa có quiz nào được tạo cho chương này.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
