import '../../domain/entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.moduleId,
    required super.title,
    required super.type,
    super.contentUrl,
    super.textContent,
    super.quizId,
    super.assignmentId,
    required super.durationMinutes,
    required super.isFreePreview,
    required super.orderIndex,
    super.isCompleted,
    required super.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: (json['id'] as int?) ?? 0,
      moduleId: (json['moduleId'] as int?) ?? 0,
      title: (json['title'] as String?) ?? 'Untitled Lesson',
      type: _parseLessonType(json['type'] as String?),
      contentUrl: json['contentUrl'] as String?,
      textContent: json['textContent'] as String?,
      quizId: json['quizId'] as int?,
      assignmentId: json['assignmentId'] as int?,
      durationMinutes: (json['durationMinutes'] as int?) ?? 0,
      isFreePreview: (json['isFreePreview'] as bool?) ?? false,
      orderIndex: (json['orderIndex'] as int?) ?? 0,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  static LessonType _parseLessonType(String? type) {
    switch (type) {
      case 'video':
        return LessonType.video;
      case 'text':
        return LessonType.text;
      case 'quiz':
        return LessonType.quiz;
      case 'assignment':
        return LessonType.assignment;
      default:
        return LessonType.text;
    }
  }

  static String _lessonTypeToString(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'video';
      case LessonType.text:
        return 'text';
      case LessonType.quiz:
        return 'quiz';
      case LessonType.assignment:
        return 'assignment';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'type': _lessonTypeToString(type),
      'contentUrl': contentUrl,
      'textContent': textContent,
      'quizId': quizId,
      'assignmentId': assignmentId,
      'durationMinutes': durationMinutes,
      'isFreePreview': isFreePreview,
      'orderIndex': orderIndex,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
