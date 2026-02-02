import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/database/database.dart';
Future<Response> onRequest(RequestContext context, String code) async {
  final db = context.read<AppDatabase>();
  switch (context.request.method) {
    case HttpMethod.get:
      return _getRoom(db, code);
    case HttpMethod.delete:
      return _deleteRoom(db, code);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: jsonEncode({'error': 'Method not allowed'}),
      );
  }
}
Future<Response> _getRoom(AppDatabase db, String code) async {
  try {
    final room = await (db.select(db.quizRooms)
          ..where((t) => t.roomCode.equals(code.toUpperCase())))
        .getSingleOrNull();
    if (room == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Room not found'}),
      );
    }
    final players = await (db.select(db.roomPlayers)
          ..where((t) => t.roomId.equals(room.id)))
        .get();
    final playerIds = players.map((p) => p.userId).toList();
    final users =
        await (db.select(db.users)..where((t) => t.id.isIn(playerIds))).get();
    final userMap = {for (var u in users) u.id: u};
    final playerList = players.map((p) {
      final user = userMap[p.userId];
      return {
        'userId': p.userId,
        'name': user?.fullName ?? 'Player ${p.userId}',
        'score': p.score,
        'isReady': p.isReady,
        'isHost': p.userId == room.hostId,
      };
    }).toList();
    return Response.json(
      body: {
        'success': true,
        'room': {
          'id': room.id,
          'roomCode': room.roomCode,
          'hostId': room.hostId,
          'quizId': room.quizId,
          'status': room.status,
          'currentQuestion': room.currentQuestion,
          'questionTimeSeconds': room.questionTimeSeconds,
          'maxPlayers': room.maxPlayers,
        },
        'players': playerList,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': e.toString()}),
    );
  }
}
Future<Response> _deleteRoom(AppDatabase db, String code) async {
  try {
    final room = await (db.select(db.quizRooms)
          ..where((t) => t.roomCode.equals(code.toUpperCase())))
        .getSingleOrNull();
    if (room == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Room not found'}),
      );
    }
    await (db.delete(db.roomPlayers)..where((t) => t.roomId.equals(room.id)))
        .go();
    await (db.delete(db.quizRooms)..where((t) => t.id.equals(room.id))).go();
    return Response.json(
      body: {
        'success': true,
        'message': 'Room deleted',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': e.toString()}),
    );
  }
}