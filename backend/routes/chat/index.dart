import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';


Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getConversations(context, db);
    case HttpMethod.post:
      return _createConversation(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getConversations(
  RequestContext context,
  AppDatabase db,
) async {
  final userId =
      int.tryParse(context.request.uri.queryParameters['userId'] ?? '');

  if (userId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'userId is required'},
    );
  }

  try {
    final query = db.select(db.chatConversations)
      ..where((c) => c.user1Id.equals(userId) | c.user2Id.equals(userId))
      ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]);

    final conversations = await query.get();
    final result = <Map<String, dynamic>>[];

    for (final conv in conversations) {
      final partnerId = conv.user1Id == userId ? conv.user2Id : conv.user1Id;

      final partner = await (db.select(db.users)
            ..where((u) => u.id.equals(partnerId)))
          .getSingleOrNull();

      final lastMsgQuery = db.select(db.chatMessages)
        ..where((m) => m.conversationId.equals(conv.id))
        ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
        ..limit(1);
      final lastMsg = await lastMsgQuery.getSingleOrNull();

      final unreadQuery = db.selectOnly(db.chatMessages)
        ..addColumns([db.chatMessages.id.count()])
        ..where(db.chatMessages.conversationId.equals(conv.id))
        ..where(db.chatMessages.senderId.isNotValue(userId))
        ..where(db.chatMessages.isRead.equals(false));
      final unreadResult = await unreadQuery.getSingle();
      final unreadCount = unreadResult.read(db.chatMessages.id.count()) ?? 0;

      result.add({
        'id': conv.id,
        'participantId': partnerId,
        'participantName': partner?.fullName ?? partner?.email ?? 'Unknown',
        'isTeacher': (partner?.role ?? 0) == 1,
        'unreadCount': unreadCount,
        'lastMessage': lastMsg != null
            ? {
                'id': lastMsg.id,
                'senderId': lastMsg.senderId,
                'content': lastMsg.content,
                'createdAt': lastMsg.createdAt.toIso8601String(),
              }
            : null,
        'updatedAt': conv.updatedAt.toIso8601String(),
      });
    }

    return Response.json(body: {'conversations': result});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to load conversations: $e'},
    );
  }
}

Future<Response> _createConversation(
  RequestContext context,
  AppDatabase db,
) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final user1Id = body['user1Id'] as int?;
    final user2Id = body['user2Id'] as int?;

    if (user1Id == null || user2Id == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'user1Id and user2Id are required'},
      );
    }

    final existing = await (db.select(db.chatConversations)
          ..where(
            (c) =>
                (c.user1Id.equals(user1Id) & c.user2Id.equals(user2Id)) |
                (c.user1Id.equals(user2Id) & c.user2Id.equals(user1Id)),
          ))
        .getSingleOrNull();

    if (existing != null) {
      return Response.json(body: {
        'id': existing.id,
        'isNew': false,
      });
    }

    final now = DateTime.now();
    final id = await db.into(db.chatConversations).insert(
          ChatConversationsCompanion.insert(
            user1Id: user1Id,
            user2Id: user2Id,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'isNew': true},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create conversation: $e'},
    );
  }
}
