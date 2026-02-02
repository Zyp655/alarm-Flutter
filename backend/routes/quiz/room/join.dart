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
    final userId = data['userId'] as int?;
    final roomCode = data['roomCode'] as String?;
    if (userId == null || roomCode == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'userId and roomCode are required'}),
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
    if (room.status != 'waiting') {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'Game already started'}),
      );
    }
    final playerCount = await (db.select(db.roomPlayers)
          ..where((t) => t.roomId.equals(room.id)))
        .get()
        .then((list) => list.length);
    if (playerCount >= room.maxPlayers) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'Room is full'}),
      );
    }
    final existing = await (db.select(db.roomPlayers)
          ..where((t) => t.roomId.equals(room.id) & t.userId.equals(userId)))
        .getSingleOrNull();
    if (existing != null) {
      return Response.json(
        body: {
          'success': true,
          'message': 'Already in room',
          'roomId': room.id,
        },
      );
    }
    await db.into(db.roomPlayers).insert(
          RoomPlayersCompanion.insert(
            roomId: room.id,
            userId: userId,
            joinedAt: DateTime.now(),
          ),
        );
    final players = await (db.select(db.roomPlayers)
          ..where((t) => t.roomId.equals(room.id)))
        .get();
    return Response.json(
      body: {
        'success': true,
        'roomId': room.id,
        'roomCode': room.roomCode,
        'hostId': room.hostId,
        'playerCount': players.length,
        'maxPlayers': room.maxPlayers,
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