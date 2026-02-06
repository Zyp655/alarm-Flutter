import '../../domain/entities/module_entity.dart';
import 'lesson_model.dart';

class ModuleModel extends ModuleEntity {
  @override
  final List<LessonModel>? lessons;

  const ModuleModel({
    required super.id,
    required super.courseId,
    required super.title,
    super.description,
    required super.orderIndex,
    required super.createdAt,
    this.lessons,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: (json['id'] as int?) ?? 0,
      courseId: (json['courseId'] as int?) ?? 0,
      title: (json['title'] as String?) ?? 'Untitled Module',
      description: json['description'] as String?,
      orderIndex: (json['orderIndex'] as int?) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lessons: json['lessons'] != null
          ? (json['lessons'] as List)
                .map(
                  (lessonJson) =>
                      LessonModel.fromJson(lessonJson as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      if (lessons != null) 'lessons': lessons!.map((l) => l.toJson()).toList(),
    };
  }
}
