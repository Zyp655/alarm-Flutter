import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/logger_service.dart';
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
        ..where(db.chatMessages.senderId.equals(userId).not())
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
  } catch (e, st) {
    logger.error('GET /chat error', error: e, stackTrace: st, context: 'Chat');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống'},
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

    int relationCount = 0;

    try {
      final oldEnrollment = await db.customSelect(
        '''
        SELECT COUNT(*) AS cnt FROM enrollments e
        JOIN courses c ON c.id = e.course_id
        WHERE (e.user_id = \$1 AND c.instructor_id = \$2)
           OR (e.user_id = \$3 AND c.instructor_id = \$4)
        ''',
        variables: [
          Variable.withInt(user1Id),
          Variable.withInt(user2Id),
          Variable.withInt(user2Id),
          Variable.withInt(user1Id),
        ],
      ).getSingle();
      relationCount += (oldEnrollment.data['cnt'] as int? ?? 0);
    } catch (_) {}

    try {
      final academyEnrollment = await db.customSelect(
        '''
        SELECT COUNT(*) AS cnt FROM course_class_enrollments cce
        JOIN course_classes cc ON cc.id = cce.course_class_id
        WHERE (cce.student_id = \$1 AND cc.teacher_id = \$2)
           OR (cce.student_id = \$3 AND cc.teacher_id = \$4)
        ''',
        variables: [
          Variable.withInt(user1Id),
          Variable.withInt(user2Id),
          Variable.withInt(user2Id),
          Variable.withInt(user1Id),
        ],
      ).getSingle();
      relationCount += (academyEnrollment.data['cnt'] as int? ?? 0);
    } catch (_) {}

    if (relationCount == 0) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {
          'error': 'Bạn chỉ có thể nhắn tin với giảng viên khóa học đã đăng ký',
        },
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
  } catch (e, st) {
    logger.error('POST /chat error', error: e, stackTrace: st, context: 'Chat');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống'},
    );
  }
}
