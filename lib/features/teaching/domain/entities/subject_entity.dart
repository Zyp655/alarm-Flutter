class SubjectEntity {
  final int? id;
  final String name;
  final String? code;
  final int credits;

  SubjectEntity({
    this.id,
    required this.name,
    this.code,
    required this.credits,
  });
}