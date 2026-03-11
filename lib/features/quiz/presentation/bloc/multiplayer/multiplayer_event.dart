import 'package:equatable/equatable.dart';

abstract class MultiplayerEvent extends Equatable {
  const MultiplayerEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToServer extends MultiplayerEvent {
  final String roomCode;
  final int userId;
  final String userName;
  const ConnectToServer(this.roomCode, this.userId, this.userName);
  @override
  List<Object?> get props => [roomCode, userId, userName];
}

class CreateRoomEvent extends MultiplayerEvent {
  final int quizId;
  final int userId;
  final String userName;
  const CreateRoomEvent(this.quizId, this.userId, this.userName);
  @override
  List<Object?> get props => [quizId, userId, userName];
}

class StartGameEvent extends MultiplayerEvent {
  final String roomCode;
  const StartGameEvent(this.roomCode);
  @override
  List<Object?> get props => [roomCode];
}

class SubmitAnswerEvent extends MultiplayerEvent {
  final String roomCode;
  final int questionIndex;
  final int answerIndex;
  final int userId;
  const SubmitAnswerEvent({
    required this.roomCode,
    required this.questionIndex,
    required this.answerIndex,
    required this.userId,
  });
  @override
  List<Object?> get props => [roomCode, questionIndex, answerIndex, userId];
}

class DisconnectEvent extends MultiplayerEvent {}

class UpdateGameState extends MultiplayerEvent {
  final Map<String, dynamic> data;
  const UpdateGameState(this.data);
  @override
  List<Object?> get props => [data];
}

class LoadQuizzes extends MultiplayerEvent {
  final int userId;
  const LoadQuizzes(this.userId);
  @override
  List<Object?> get props => [userId];
}
