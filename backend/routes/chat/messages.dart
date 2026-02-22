import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';


Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getMessages(context, db);
    case HttpMethod.post:
      return _sendMessage(context, db);
    case HttpMethod.put:
      return _markAsRead(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getMessages(RequestContext context, AppDatabase db) async {
  final params = context.request.uri.queryParameters;
  final conversationId = int.tryParse(params['conversationId'] ?? '');

  if (conversationId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'conversationId is required'},
    );
  }

  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
  final offset = (page - 1) * limit;

  try {
    final query = db.select(db.chatMessages).join([
      innerJoin(db.users, db.users.id.equalsExp(db.chatMessages.senderId)),
    ]);
    query.where(db.chatMessages.conversationId.equals(conversationId));
    query.orderBy([OrderingTerm.asc(db.chatMessages.createdAt)]);
    query.limit(limit, offset: offset);

    final rows = await query.get();

    final messages = rows.map((row) {
      final msg = row.readTable(db.chatMessages);
      final sender = row.readTable(db.users);
      return {
        'id': msg.id,
        'senderId': msg.senderId,
        'senderName': sender.fullName ?? sender.email,
        'content': msg.content,
        'messageType': msg.messageType,
        'isRead': msg.isRead,
        'createdAt': msg.createdAt.toIso8601String(),
      };
    }).toList();

    return Response.json(body: {
      'conversationId': conversationId,
      'messages': messages,
      'pagination': {'page': page, 'limit': limit},
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to load messages: $e'},
    );
  }
}

Future<Response> _sendMessage(RequestContext context, AppDatabase db) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final conversationId = body['conversationId'] as int?;
    final senderId = body['senderId'] as int?;
    final content = body['content'] as String?;
    final messageType = body['messageType'] as String? ?? 'text';

    if (conversationId == null || senderId == null || content == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'conversationId, senderId, content are required'},
      );
    }

    final now = DateTime.now();

    final id = await db.into(db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            conversationId: conversationId,
            senderId: senderId,
            content: content,
            messageType: Value(messageType),
            createdAt: now,
          ),
        );

    await (db.update(db.chatConversations)
          ..where((c) => c.id.equals(conversationId)))
        .write(ChatConversationsCompanion(updatedAt: Value(now)));

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'createdAt': now.toIso8601String()},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to send message: $e'},
    );
  }
}

Future<Response> _markAsRead(RequestContext context, AppDatabase db) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final conversationId = body['conversationId'] as int?;
    final readerId = body['readerId'] as int?;

    if (conversationId == null || readerId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'conversationId and readerId are required'},
      );
    }

    final count = await (db.update(db.chatMessages)
          ..where(
            (m) =>
                m.conversationId.equals(conversationId) &
                m.senderId.isNotValue(readerId) &
                m.isRead.equals(false),
          ))
        .write(const ChatMessagesCompanion(isRead: Value(true)));

    return Response.json(body: {
      'message': 'Marked $count messages as read',
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to mark as read: $e'},
    );
  }
}
