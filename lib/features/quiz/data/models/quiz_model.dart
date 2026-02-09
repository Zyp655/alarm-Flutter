import '../../domain/entities/quiz_entity.dart';

class QuizModel {
  final int? id;
  final int? createdBy;
  final String topic;
  final String difficulty;
  final List<QuestionModel> questions;
  final DateTime? createdAt;
  final bool isPublic;
  final double? adaptiveLevel;

  QuizModel({
    this.id,
    this.createdBy,
    required this.topic,
    required this.difficulty,
    required this.questions,
    this.createdAt,
    this.isPublic = false,
    this.adaptiveLevel,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] != null
        ? (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList()
        : <QuestionModel>[];

    return QuizModel(
      id: json['id'] as int?,
      createdBy: json['createdBy'] as int?,
      topic: json['topic'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'medium',
      questions: questionsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      isPublic: json['isPublic'] as bool? ?? false,
      adaptiveLevel: json['adaptiveLevel'] != null
          ? (json['adaptiveLevel'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (createdBy != null) 'createdBy': createdBy,
    'topic': topic,
    'difficulty': difficulty,
    'questions': questions.map((q) => q.toJson()).toList(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'isPublic': isPublic,
    if (adaptiveLevel != null) 'adaptiveLevel': adaptiveLevel,
  };

  QuizEntity toEntity() {
    return QuizEntity(
      id: id,
      createdBy: createdBy,
      topic: topic,
      difficulty: difficulty,
      questions: questions.map((q) => q.toEntity()).toList(),
      createdAt: createdAt ?? DateTime.now(),
      isPublic: isPublic,
      adaptiveLevel: adaptiveLevel,
    );
  }
}

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String questionType;
  final String? correctAnswer;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.questionType = 'multiple_choice',
    this.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] as String? ?? '',
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : <String>[],
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      questionType: json['questionType'] as String? ?? 'multiple_choice',
      correctAnswer: json['correctAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    if (explanation != null) 'explanation': explanation,
    'questionType': questionType,
    if (correctAnswer != null) 'correctAnswer': correctAnswer,
  };

  QuestionEntity toEntity() {
    return QuestionEntity(
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      questionType: QuestionTypeExtension.fromString(questionType),
      correctAnswer: correctAnswer,
    );
  }
}
