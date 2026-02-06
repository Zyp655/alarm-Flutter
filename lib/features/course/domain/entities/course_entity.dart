import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int instructorId;
  final double price;
  final List<String>? tags;
  final String level; 
  final int studentCount;
  final int durationMinutes;
  final bool isPublished;
  final int? majorId;
  final String? majorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double rating;
  final int reviewsCount;

  const CourseEntity({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.instructorId,
    required this.price,
    this.tags,
    required this.level,
    required this.durationMinutes,
    this.studentCount = 0,
    required this.isPublished,
    this.majorId,
    this.majorName,
    required this.createdAt,
    this.updatedAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    instructorId,
    price,
    tags,
    level,
    durationMinutes,
    studentCount,
    isPublished,
    majorId,
    majorName,
    createdAt,
    createdAt,
    updatedAt,
    rating,
    reviewsCount,
  ];
}
