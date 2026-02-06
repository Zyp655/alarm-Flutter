import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.thumbnailUrl,
    required super.instructorId,
    required super.price,
    super.tags,
    required super.level,
    required super.durationMinutes,
    super.studentCount,
    required super.isPublished,
    super.majorId,
    super.majorName,
    required super.createdAt,
    super.updatedAt,
    super.rating,
    super.reviewsCount,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? 'Untitled Course',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      instructorId: (json['instructorId'] as int?) ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      tags: json['tags'] != null ? (json['tags'] as String).split(',') : null,
      level: (json['level'] as String?) ?? 'beginner',
      durationMinutes: (json['durationMinutes'] as int?) ?? 0,
      studentCount: (json['studentCount'] as int?) ?? 0,
      isPublished: (json['isPublished'] as bool?) ?? false,
      majorId: json['majorId'] as int?,
      majorName: json['majorName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'instructorId': instructorId,
      'price': price,
      'tags': tags?.join(','),
      'level': level,
      'durationMinutes': durationMinutes,
      'studentCount': studentCount,
      'isPublished': isPublished,
      'majorId': majorId,
      'majorName': majorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }

  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      instructorId: instructorId,
      price: price,
      tags: tags,
      level: level,
      durationMinutes: durationMinutes,
      studentCount: studentCount,
      isPublished: isPublished,
      majorId: majorId,
      majorName: majorName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rating: rating,
      reviewsCount: reviewsCount,
    );
  }
}
