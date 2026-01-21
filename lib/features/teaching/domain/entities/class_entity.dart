class ClassEntity {
  final int? id;
  final String className;
  final String classCode;
  final int? subjectId;
  final int studentCount;

  ClassEntity({
    this.id,
    required this.className,
    required this.classCode,
    this.subjectId,
    this.studentCount = 0,
  });
}