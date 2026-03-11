import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/multiplayer_repository.dart';
import 'multiplayer_event.dart';
import 'multiplayer_state.dart';

class MultiplayerBloc extends Bloc<MultiplayerEvent, MultiplayerState> {
  final MultiplayerRepository repository;
  StreamSubscription? _streamSubscription;
  String? _currentRoomCode;

  MultiplayerBloc({required this.repository}) : super(MultiplayerInitial()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<ConnectToServer>(_onConnectToServer);
    on<UpdateGameState>(_onUpdateGameState);
    on<DisconnectEvent>(_onDisconnect);
    on<StartGameEvent>(_onStartGame);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<LoadQuizzes>(_onLoadQuizzes);
  }

  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<MultiplayerState> emit,
  ) async {
    emit(const MultiplayerLoading('Loading quizzes...'));
    final result = await repository.getMyQuizzes(event.userId);
    result.fold(
      (failure) => emit(MultiplayerError(failure.message)),
      (quizzes) => emit(QuizzesLoaded(quizzes)),
    );
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<MultiplayerState> emit,
  ) async {
    emit(const MultiplayerLoading('Creating room...'));
    final result = await repository.createRoom(
      event.quizId,
      hostId: event.userId,
    );
    result.fold((failure) => emit(MultiplayerError(failure.message)), (
      roomCode,
    ) {
      add(ConnectToServer(roomCode, event.userId, event.userName));
    });
  }

  Future<void> _onConnectToServer(
    ConnectToServer event,
    Emitter<MultiplayerState> emit,
  ) async {
    _currentRoomCode = event.roomCode;
    emit(const MultiplayerLoading('Connecting...'));
    final result = await repository.connect(
      event.roomCode,
      event.userId,
      event.userName,
    );

    await result.fold(
      (failure) async => emit(MultiplayerError(failure.message)),
      (_) async {
        _streamSubscription?.cancel();
        _streamSubscription = repository.gameStream.listen((data) {
          add(UpdateGameState(data));
        });
      },
    );
  }

  void _onUpdateGameState(
    UpdateGameState event,
    Emitter<MultiplayerState> emit,
  ) {
    final data = event.data;
    final type = data['type'] as String?;
    debugPrint('DEBUG Bloc received: $data');

    if (type == 'room_update' || type == 'player_joined') {
      final roomData = data['room'] as Map<String, dynamic>?;
      final players = data['players'] as List? ?? [];
      emit(
        MultiplayerLobby(
          roomCode: roomData?['code'] ?? _currentRoomCode ?? '',
          players: players,
          isHost: data['isHost'] == true,
        ),
      );
    } else if (type == 'game_start' || type == 'next_question') {
      final question = data['question'] as Map<String, dynamic>? ?? {};
      emit(
        MultiplayerGameStarted(
          roomCode: _currentRoomCode ?? '',
          question: question,
          questionIndex: (data['currentQuestionIndex'] as int?) ?? 0,
          totalQuestions: (data['totalQuestions'] as int?) ?? 0,
          timeLeft: (data['timeLeft'] as int?) ?? 30,
        ),
      );
    } else if (type == 'game_over') {
      emit(MultiplayerResult(data['leaderboard'] as List? ?? []));
    }
  }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<MultiplayerState> emit,
  ) async {
    await repository.startGame(event.roomCode);
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<MultiplayerState> emit,
  ) async {
    await repository.submitAnswer(
      event.roomCode,
      event.questionIndex,
      event.answerIndex,
      event.userId,
    );
  }

  Future<void> _onDisconnect(
    DisconnectEvent event,
    Emitter<MultiplayerState> emit,
  ) async {
    await _streamSubscription?.cancel();
    await repository.disconnect();
    emit(MultiplayerInitial());
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }
}
