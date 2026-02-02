import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
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
    final roomCode = data['roomCode'] as String?;
    final hostId = data['hostId'] as int?;
    if (roomCode == null || hostId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'roomCode and hostId are required'}),
      );
    }
    final room = await (db.select(db.quizRooms)
          ..where((t) => t.roomCode.equals(roomCode.toUpperCase())))
        .getSingleOrNull();
    if (room == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Room not found'}),
      );
    }
    if (room.hostId != hostId) {
      return Response(
        statusCode: HttpStatus.forbidden,
        body: jsonEncode({'error': 'Only host can start the game'}),
      );
    }
    if (room.quizId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'No quiz selected for room'}),
      );
    }
    await (db.update(db.quizRooms)..where((t) => t.id.equals(room.id))).write(
      QuizRoomsCompanion(
        status: const Value('playing'),
        startedAt: Value(DateTime.now()),
      ),
    );
    final questions = await (db.select(db.quizQuestions)
          ..where((t) => t.quizId.equals(room.quizId!))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final questionList = questions.map((q) {
      return {
        'id': q.id,
        'question': q.question,
        'options': jsonDecode(q.options),
        'questionType': q.questionType,
      };
    }).toList();
    return Response.json(
      body: {
        'success': true,
        'message': 'Game started',
        'totalQuestions': questions.length,
        'questionTimeSeconds': room.questionTimeSeconds,
        'questions': questionList,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': e.toString(),
      }),
    );
  }
}