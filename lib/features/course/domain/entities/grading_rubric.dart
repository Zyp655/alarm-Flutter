import 'package:equatable/equatable.dart';

class RubricCriterion extends Equatable {
  final String name;
  final String description;
  final double maxPoints;
  final double awardedPoints;

  const RubricCriterion({
    required this.name,
    required this.description,
    required this.maxPoints,
    this.awardedPoints = 0,
  });

  RubricCriterion copyWith({double? awardedPoints}) => RubricCriterion(
    name: name,
    description: description,
    maxPoints: maxPoints,
    awardedPoints: awardedPoints ?? this.awardedPoints,
  );

  @override
  List<Object?> get props => [name, description, maxPoints, awardedPoints];
}

class GradingRubric extends Equatable {
  final String title;
  final List<RubricCriterion> criteria;

  const GradingRubric({required this.title, required this.criteria});

  double get maxTotal => criteria.fold(0.0, (sum, c) => sum + c.maxPoints);

  double get awardedTotal =>
      criteria.fold(0.0, (sum, c) => sum + c.awardedPoints);

  double get gradeOutOfTen => maxTotal > 0 ? (awardedTotal / maxTotal * 10) : 0;

  @override
  List<Object?> get props => [title, criteria];
}
