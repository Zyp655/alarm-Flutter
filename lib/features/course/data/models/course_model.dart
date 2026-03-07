import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.name,
    required super.code,
    required super.credits,
    required super.courseType,
    super.description,
    super.thumbnailUrl,
    super.departmentName,
    super.moduleCount,
    super.classCount,
    required super.isPublished,
    required super.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      credits: (json['credits'] as int?) ?? 3,
      courseType: (json['courseType'] as String?) ?? 'required',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      departmentName: json['departmentName'] as String?,
      moduleCount: json['moduleCount'] as int?,
      classCount: json['classCount'] as int?,
      isPublished: (json['isPublished'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'credits': credits,
      'courseType': courseType,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'departmentName': departmentName,
      'moduleCount': moduleCount,
      'classCount': classCount,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
