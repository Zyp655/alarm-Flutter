import 'package:equatable/equatable.dart';

class MajorEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? iconUrl;
  final int courseCount;
  final DateTime createdAt;

  const MajorEntity({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.iconUrl,
    this.courseCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    iconUrl,
    courseCount,
    createdAt,
  ];
}
