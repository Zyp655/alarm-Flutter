import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final int credits;
  final String courseType;
  final String? description;
  final String? thumbnailUrl;
  final String? departmentName;
  final int? moduleCount;
  final int? classCount;
  final bool isPublished;
  final DateTime createdAt;

  const CourseEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    required this.courseType,
    this.description,
    this.thumbnailUrl,
    this.departmentName,
    this.moduleCount,
    this.classCount,
    required this.isPublished,
    required this.createdAt,
  });

  bool get isRequired => courseType == 'required';

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    credits,
    courseType,
    description,
    thumbnailUrl,
    departmentName,
    moduleCount,
    classCount,
    isPublished,
    createdAt,
  ];
}
