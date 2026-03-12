import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
    super.imageUrl,
    super.rating,
    super.metadata,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as int,
      type: _parseType(json['type'] as String),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['thumbnailUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static SearchResultType _parseType(String t) => switch (t) {
    'course' => SearchResultType.course,
    'teacher' => SearchResultType.teacher,
    'lesson' => SearchResultType.lesson,
    'quiz' => SearchResultType.quiz,
    'discussion' => SearchResultType.discussion,
    _ => SearchResultType.course,
  };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'thumbnailUrl': imageUrl,
      'rating': rating,
      'metadata': metadata,
    };
  }
}
