import 'package:equatable/equatable.dart';

enum SearchResultType { course, teacher, lesson, quiz, discussion }

class SearchResult extends Equatable {
  final int id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final double? rating;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.rating,
    this.metadata,
  });

  IconLabel get typeLabel => switch (type) {
    SearchResultType.course => const IconLabel('Khóa học', 'school'),
    SearchResultType.teacher => const IconLabel('Giáo viên', 'person'),
    SearchResultType.lesson => const IconLabel('Bài học', 'menu_book'),
    SearchResultType.quiz => const IconLabel('Quiz', 'quiz'),
    SearchResultType.discussion => const IconLabel('Thảo luận', 'forum'),
  };

  @override
  List<Object?> get props => [id, type, title, subtitle, imageUrl, rating];
}

class IconLabel {
  final String label;
  final String iconName;
  const IconLabel(this.label, this.iconName);
}
