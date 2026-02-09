import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../../core/api/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/multiplayer_repository.dart';

class MultiplayerRepositoryImpl implements MultiplayerRepository {
  final http.Client client;
  WebSocketChannel? _channel;
  final _streamController = StreamController<dynamic>.broadcast();

  MultiplayerRepositoryImpl({required this.client});

  @override
  Stream<dynamic> get gameStream => _streamController.stream;

  @override
  Future<Either<Failure, void>> connect(
    String roomCode,
    int userId,
    String userName,
  ) async {
    try {
      final wsUrl = Uri.parse(
        '${ApiConstants.baseUrl.replaceFirst("http", "ws")}/quiz/ws/$roomCode',
      );
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.sink.add(
        jsonEncode({
          'type': 'join_room',
          'user': {'id': userId, 'name': userName},
        }),
      );

      _channel!.stream.listen(
        (message) {
          _streamController.add(jsonDecode(message));
        },
        onError: (error) {
          _streamController.addError(error);
        },
        onDone: () {
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    await _channel?.sink.close(status.goingAway);
    _channel = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> createRoom(int quizId, {int? hostId}) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/quiz/room/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hostId': hostId ?? 1,
          'quizId': quizId,
          'maxPlayers': 10,
          'questionTimeSeconds': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(data['roomCode']);
        } else {
          return Left(ServerFailure(data['error'] ?? 'Unknown error'));
        }
      } else {
        return Left(
          ServerFailure('Không thể tạo phòng chơi. Vui lòng thử lại sau.'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinRoom(String roomCode) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> startGame(String roomCode) async {
    try {
      _channel?.sink.add(jsonEncode({'type': 'start_game'}));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitAnswer(
    String roomCode,
    int questionIndex,
    int answerIndex,
    int userId,
  ) async {
    try {
      _channel?.sink.add(
        jsonEncode({
          'type': 'submit_answer',
          'questionIndex': questionIndex,
          'answerIndex': answerIndex,
          'userId': userId,
        }),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMyQuizzes(int userId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}/quiz/my-quizzes?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right((data['quizzes'] as List?) ?? []);
        } else {
          return Left(ServerFailure(data['error'] ?? 'Unknown error'));
        }
      } else {
        return Left(
          ServerFailure('Không thể tải danh sách quiz. Vui lòng thử lại sau.'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
