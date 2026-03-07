import 'package:equatable/equatable.dart';

class CourseClassEntity extends Equatable {
  final int id;
  final String classCode;
  final String courseName;
  final String courseCode;
  final int courseId;
  final int credits;
  final String courseType;
  final String teacherName;
  final String? room;
  final String? schedule;
  final int maxStudents;
  final int enrolledCount;
  final String? semesterName;
  final String? departmentName;
  final String? description;
  final String? thumbnailUrl;
  final int? moduleCount;

  final int? enrollmentId;
  final String? enrollmentStatus;
  final double progressPercent;
  final DateTime? enrolledAt;
  final DateTime? completedAt;

  const CourseClassEntity({
    required this.id,
    required this.classCode,
    required this.courseName,
    required this.courseCode,
    required this.courseId,
    required this.credits,
    required this.courseType,
    required this.teacherName,
    this.room,
    this.schedule,
    required this.maxStudents,
    required this.enrolledCount,
    this.semesterName,
    this.departmentName,
    this.description,
    this.thumbnailUrl,
    this.moduleCount,
    this.enrollmentId,
    this.enrollmentStatus,
    this.progressPercent = 0.0,
    this.enrolledAt,
    this.completedAt,
  });

  bool get isRequired => courseType == 'required';
  bool get isEnrolled => enrollmentStatus == 'enrolled';
  bool get isCompleted =>
      enrollmentStatus == 'completed' || progressPercent >= 100;
  bool get isFull => enrolledCount >= maxStudents;

  factory CourseClassEntity.fromCourseEntity(dynamic course) {
    return CourseClassEntity(
      id: 0,
      classCode: course.code ?? '',
      courseName: course.name ?? '',
      courseCode: course.code ?? '',
      courseId: course.id,
      credits: course.credits ?? 0,
      courseType: course.courseType ?? 'required',
      teacherName: '',
      maxStudents: 0,
      enrolledCount: 0,
      departmentName: course.departmentName,
      description: course.description,
      thumbnailUrl: course.thumbnailUrl,
      moduleCount: course.moduleCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    classCode,
    courseName,
    courseCode,
    courseId,
    credits,
    courseType,
    teacherName,
    room,
    schedule,
    maxStudents,
    enrolledCount,
    semesterName,
    departmentName,
    enrollmentId,
    enrollmentStatus,
    progressPercent,
  ];
}
