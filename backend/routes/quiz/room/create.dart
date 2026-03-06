import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/game_manager.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final hostId = data['hostId'] as int?;
    final quizId = data['quizId'] as int?;
    final maxPlayers = data['maxPlayers'] as int? ?? 10;
    final questionTimeSeconds = data['questionTimeSeconds'] as int? ?? 30;
    if (hostId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'hostId is required'}),
      );
    }
    if (quizId != null) {
      final quiz = await (db.select(db.quizzes)
            ..where((t) => t.id.equals(quizId)))
          .getSingleOrNull();
      if (quiz == null) {
        return Response(
          statusCode: HttpStatus.badRequest,
          body: jsonEncode({'error': 'Quiz with ID $quizId not found'}),
        );
      }
    }
    final roomCode = _generateRoomCode();
    final roomId = await db.into(db.quizRooms).insert(
          QuizRoomsCompanion.insert(
            roomCode: roomCode,
            hostId: hostId,
            quizId: Value(quizId),
            maxPlayers: Value(maxPlayers),
            questionTimeSeconds: Value(questionTimeSeconds),
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.roomPlayers).insert(
          RoomPlayersCompanion.insert(
            roomId: roomId,
            userId: hostId,
            joinedAt: DateTime.now(),
          ),
        );
    List<Map<String, dynamic>> questionsList = [];
    if (quizId != null) {
      final questions = await (db.select(db.quizQuestions)
            ..where((t) => t.quizId.equals(quizId))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
      questionsList = questions.map((q) {
        dynamic parsedOptions;
        try {
          parsedOptions = jsonDecode(q.options);
        } catch (_) {
          parsedOptions = q.options.split(',');
        }
        return {
          'id': q.id,
          'question': q.question,
          'type': q.questionType,
          'options': parsedOptions,
          'correctIndex': q.correctIndex,
          'correctAnswer': q.correctAnswer,
          'explanation': q.explanation,
        };
      }).toList();
    }
    GameManager().createRoom(roomCode, {
      'id': quizId,
      'questions': questionsList,
    });
    return Response.json(
      body: {
        'success': true,
        'roomId': roomId,
        'roomCode': roomCode,
        'message': 'Room created successfully',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.',
      }),
    );
  }
}

String _generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}
