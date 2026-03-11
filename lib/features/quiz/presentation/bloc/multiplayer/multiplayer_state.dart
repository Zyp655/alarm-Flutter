import 'package:equatable/equatable.dart';

abstract class MultiplayerState extends Equatable {
  const MultiplayerState();

  @override
  List<Object?> get props => [];
}

class MultiplayerInitial extends MultiplayerState {}

class MultiplayerLoading extends MultiplayerState {
  final String message;
  const MultiplayerLoading(this.message);
  @override
  List<Object?> get props => [message];
}

class QuizzesLoaded extends MultiplayerState {
  final List<dynamic> quizzes;
  const QuizzesLoaded(this.quizzes);
  @override
  List<Object?> get props => [quizzes];
}

class MultiplayerLobby extends MultiplayerState {
  final String roomCode;
  final List<dynamic> players;
  final bool isHost;

  const MultiplayerLobby({
    required this.roomCode,
    required this.players,
    required this.isHost,
  });

  @override
  List<Object?> get props => [roomCode, players, isHost];
}

class MultiplayerGameStarted extends MultiplayerState {
  final String roomCode;
  final Map<String, dynamic> question;
  final int questionIndex;
  final int totalQuestions;
  final int timeLeft;

  const MultiplayerGameStarted({
    required this.roomCode,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.timeLeft,
  });

  @override
  List<Object?> get props => [
    roomCode,
    question,
    questionIndex,
    totalQuestions,
    timeLeft,
  ];
}

class MultiplayerResult extends MultiplayerState {
  final List<dynamic> leaderboard;
  const MultiplayerResult(this.leaderboard);
  @override
  List<Object?> get props => [leaderboard];
}

class MultiplayerError extends MultiplayerState {
  final String message;
  const MultiplayerError(this.message);
  @override
  List<Object?> get props => [message];
}
