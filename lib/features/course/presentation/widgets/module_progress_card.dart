import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/lesson_entity.dart';

class ModuleProgressCard extends StatefulWidget {
  final ModuleEntity module;
  final Map<int, bool> lessonCompletionStatus;
  final VoidCallback? onLessonTap;
  final int moduleIndex;

  const ModuleProgressCard({
    super.key,
    required this.module,
    required this.lessonCompletionStatus,
    this.onLessonTap,
    this.moduleIndex = 0,
  });

  @override
  State<ModuleProgressCard> createState() => _ModuleProgressCardState();
}

class _ModuleProgressCardState extends State<ModuleProgressCard> {
  bool _isExpanded = false;

  List<LessonEntity> get _lessons => widget.module.lessons ?? [];

  int get _completedLessons {
    return _lessons.where((lesson) {
      return widget.lessonCompletionStatus[lesson.id] == true;
    }).length;
  }

  double get _progress {
    if (_lessons.isEmpty) return 0;
    return _completedLessons / _lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _progress == 1.0
                                ? [Colors.green, Colors.green.shade700]
                                : [
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF4834DF),
                                  ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _progress == 1.0
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${widget.moduleIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.module.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: _progress),
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _progress == 1.0
                                                    ? Colors.green
                                                    : const Color(0xFF6C63FF),
                                              ),
                                          minHeight: 5,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$_completedLessons/${_lessons.length}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildLessonList(),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * widget.moduleIndex))
        .fadeIn()
        .slideX(begin: 0.1);
  }

  Widget _buildLessonList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: _lessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          final isCompleted = widget.lessonCompletionStatus[lesson.id] == true;

          return _buildLessonItem(
            lesson: lesson,
            isCompleted: isCompleted,
            isLast: index == _lessons.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonItem({
    required LessonEntity lesson,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : _getLessonTypeIcon(lesson.type),
            size: 18,
            color: isCompleted ? Colors.green : Colors.grey[500],
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.grey[600] : Colors.grey[800],
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey[400],
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              '${lesson.durationMinutes} phút',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
        trailing: isCompleted
            ? null
            : const Icon(
                Icons.play_circle_outline,
                color: Color(0xFF6C63FF),
                size: 22,
              ),
        onTap: widget.onLessonTap,
      ),
    );
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.text:
        return Icons.description_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
      case LessonType.assignment:
        return Icons.assignment_outlined;
    }
  }
}
