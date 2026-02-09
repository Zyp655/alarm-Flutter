import 'package:equatable/equatable.dart';

class QuizStatisticsModel extends Equatable {
  final int id;
  final String topic;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
  final double averageScore;
  final double skillLevel;
  final DateTime? lastAttemptAt;

  const QuizStatisticsModel({
    required this.id,
    required this.topic,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageScore,
    required this.skillLevel,
    this.lastAttemptAt,
  });

  factory QuizStatisticsModel.fromJson(Map<String, dynamic> json) {
    return QuizStatisticsModel(
      id: json['id'] as int,
      topic: json['topic'] as String,
      totalAttempts: json['totalAttempts'] as int,
      totalCorrect: json['totalCorrect'] as int,
      totalQuestions: json['totalQuestions'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      skillLevel: (json['skillLevel'] as num).toDouble(),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'totalAttempts': totalAttempts,
    'totalCorrect': totalCorrect,
    'totalQuestions': totalQuestions,
    'averageScore': averageScore,
    'skillLevel': skillLevel,
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    topic,
    totalAttempts,
    totalCorrect,
    totalQuestions,
    averageScore,
    skillLevel,
    lastAttemptAt,
  ];
}

class QuizStatisticsSummary extends Equatable {
  final int totalTopics;
  final int totalAttempts;
  final double overallAverageScore;
  final List<String> weakTopics;
  final List<String> strongTopics;

  const QuizStatisticsSummary({
    required this.totalTopics,
    required this.totalAttempts,
    required this.overallAverageScore,
    required this.weakTopics,
    required this.strongTopics,
  });

  factory QuizStatisticsSummary.fromJson(Map<String, dynamic> json) {
    return QuizStatisticsSummary(
      totalTopics: json['totalTopics'] as int,
      totalAttempts: json['totalAttempts'] as int,
      overallAverageScore: (json['overallAverageScore'] as num).toDouble(),
      weakTopics: List<String>.from(json['weakTopics'] as List),
      strongTopics: List<String>.from(json['strongTopics'] as List),
    );
  }

  @override
  List<Object?> get props => [
    totalTopics,
    totalAttempts,
    overallAverageScore,
    weakTopics,
    strongTopics,
  ];
}

class QuizStatisticsResponse extends Equatable {
  final List<QuizStatisticsModel> statistics;
  final QuizStatisticsSummary summary;

  const QuizStatisticsResponse({
    required this.statistics,
    required this.summary,
  });

  factory QuizStatisticsResponse.fromJson(Map<String, dynamic> json) {
    final statsList = (json['statistics'] as List)
        .map((s) => QuizStatisticsModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return QuizStatisticsResponse(
      statistics: statsList,
      summary: QuizStatisticsSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  List<Object?> get props => [statistics, summary];
}
