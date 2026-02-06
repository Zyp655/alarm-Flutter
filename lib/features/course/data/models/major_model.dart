import '../../domain/entities/major_entity.dart';

class MajorModel extends MajorEntity {
  const MajorModel({
    required super.id,
    required super.name,
    required super.code,
    super.description,
    super.iconUrl,
    super.courseCount,
    required super.createdAt,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      courseCount: (json['courseCount'] as int?) ?? 0,
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
      'description': description,
      'iconUrl': iconUrl,
      'courseCount': courseCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MajorEntity toEntity() {
    return MajorEntity(
      id: id,
      name: name,
      code: code,
      description: description,
      iconUrl: iconUrl,
      courseCount: courseCount,
      createdAt: createdAt,
    );
  }
}
