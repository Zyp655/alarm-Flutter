import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/usecases/quiz_usecases.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GenerateQuizUseCase generateQuiz;
  final GenerateQuizFromImageUseCase generateQuizFromImage;
  final GenerateAdaptiveQuizUseCase generateAdaptiveQuiz;
  final SaveQuizUseCase saveQuiz;
  final GetQuizByIdUseCase getQuizById;
  final GetMyQuizzesUseCase getMyQuizzes;
  final SubmitQuizUseCase submitQuiz;
  final GetQuizStatisticsUseCase getStatistics;

  QuizEntity? _currentQuiz;
  List<dynamic> _userAnswers = [];

  QuizBloc({
    required this.generateQuiz,
    required this.generateQuizFromImage,
    required this.generateAdaptiveQuiz,
    required this.saveQuiz,
    required this.getQuizById,
    required this.getMyQuizzes,
    required this.submitQuiz,
    required this.getStatistics,
  }) : super(QuizInitial()) {
    on<GenerateQuizEvent>(_onGenerateQuiz);
    on<GenerateQuizFromImageEvent>(_onGenerateQuizFromImage);
    on<GenerateAdaptiveQuizEvent>(_onGenerateAdaptiveQuiz);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<SubmitQuizToServerEvent>(_onSubmitQuizToServer);
    on<SaveQuizEvent>(_onSaveQuiz);
    on<LoadQuizEvent>(_onLoadQuiz);
    on<LoadMyQuizzesEvent>(_onLoadMyQuizzes);
    on<LoadStatisticsEvent>(_onLoadStatistics);
    on<ResetQuizEvent>(_onResetQuiz);
  }

  Future<void> _onGenerateQuiz(
    GenerateQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await generateQuiz(
      topic: event.topic,
      numQuestions: event.numQuestions,
      difficulty: event.difficulty,
      subjectContext: event.subjectContext,
      questionTypes: event.questionTypes,
      videoUrl: event.videoUrl,
    );

    result.fold((failure) => emit(QuizError(failure.message)), (quiz) {
      _currentQuiz = quiz;
      _userAnswers = List.filled(quiz.questions.length, null);
      emit(QuizGenerated(quiz));
    });
  }

  Future<void> _onGenerateQuizFromImage(
    GenerateQuizFromImageEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await generateQuizFromImage(
      imageBytes: event.imageBytes,
      numQuestions: event.numQuestions,
      difficulty: event.difficulty,
    );

    result.fold((failure) => emit(QuizError(failure.message)), (quiz) {
      _currentQuiz = quiz;
      _userAnswers = List.filled(quiz.questions.length, null);
      emit(QuizGenerated(quiz));
    });
  }

  Future<void> _onGenerateAdaptiveQuiz(
    GenerateAdaptiveQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await generateAdaptiveQuiz(
      userId: event.userId,
      topic: event.topic,
      numQuestions: event.numQuestions,
    );

    result.fold((failure) => emit(QuizError(failure.message)), (quiz) {
      _currentQuiz = quiz;
      _userAnswers = List.filled(quiz.questions.length, null);
      emit(QuizGenerated(quiz));
    });
  }

  void _onAnswerQuestion(AnswerQuestionEvent event, Emitter<QuizState> emit) {
    if (_currentQuiz == null) return;

    _userAnswers[event.questionIndex] = event.answer;

    emit(
      QuizInProgress(
        quiz: _currentQuiz!,
        currentQuestionIndex: event.questionIndex,
        userAnswers: List.from(_userAnswers),
      ),
    );
  }

  void _onSubmitQuiz(SubmitQuizEvent event, Emitter<QuizState> emit) {
    if (_currentQuiz == null) return;

    final result = QuizResultEntity(
      quiz: _currentQuiz!,
      userAnswers: List.from(_userAnswers),
    );

    emit(QuizCompleted(result));
  }

  Future<void> _onSubmitQuizToServer(
    SubmitQuizToServerEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await submitQuiz(
      userId: event.userId,
      quizId: event.quizId,
      answers: _userAnswers,
      timeSpentSeconds: event.timeSpentSeconds,
    );

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (data) => emit(
        QuizSubmittedToServer(
          attemptId: data['attemptId'] as int,
          correctCount: data['correctCount'] as int,
          totalQuestions: data['totalQuestions'] as int,
          scorePercentage: (data['scorePercentage'] as num).toDouble(),
          passed: data['passed'] as bool,
        ),
      ),
    );
  }

  Future<void> _onSaveQuiz(SaveQuizEvent event, Emitter<QuizState> emit) async {
    if (_currentQuiz == null) {
      emit(const QuizError('No quiz to save'));
      return;
    }

    emit(QuizLoading());

    final result = await saveQuiz(
      userId: event.userId,
      quiz: _currentQuiz!,
      isPublic: event.isPublic,
    );

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (quizId) => emit(QuizSaved(quizId)),
    );
  }

  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoading());

    final result = await getQuizById(event.quizId);

    result.fold((failure) => emit(QuizError(failure.message)), (quiz) {
      _currentQuiz = quiz;
      _userAnswers = List.filled(quiz.questions.length, null);
      emit(QuizGenerated(quiz));
    });
  }

  Future<void> _onLoadMyQuizzes(
    LoadMyQuizzesEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getMyQuizzes(event.userId);

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (quizzes) => emit(MyQuizzesLoaded(quizzes)),
    );
  }

  Future<void> _onLoadStatistics(
    LoadStatisticsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getStatistics(event.userId, topic: event.topic);

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (stats) => emit(StatisticsLoaded(stats)),
    );
  }

  void _onResetQuiz(ResetQuizEvent event, Emitter<QuizState> emit) {
    _currentQuiz = null;
    _userAnswers = [];
    emit(QuizInitial());
  }
}
