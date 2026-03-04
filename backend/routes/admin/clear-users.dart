import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }

  try {
    final db = context.read<AppDatabase>();

    final nonAdminUsers =
        await (db.select(db.users)..where((t) => t.role.equals(2).not())).get();

    if (nonAdminUsers.isEmpty) {
      return Response.json(
        body: {
          'success': true,
          'message': 'Không có user nào cần xóa',
          'deleted': 0,
        },
      );
    }

    final userIds = nonAdminUsers.map((u) => u.id).toList();

    await db.transaction(() async {
      for (final uid in userIds) {
        await (db.delete(db.courseClassEnrollments)
              ..where((t) => t.studentId.equals(uid)))
            .go();

        await (db.delete(db.enrollments)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.studentProfiles)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.lessonProgress)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.quizAttempts)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.quizStatistics)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.roomPlayers)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.leaderboards)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.userStreaks)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.userAchievements)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.studentActivityLogs)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.courseReviews)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.studyPlans)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.learningActivities)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.commentVotes)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.commentMentions)
              ..where((t) => t.mentionedUserId.equals(uid)))
            .go();

        await (db.delete(db.comments)..where((t) => t.userId.equals(uid))).go();

        await (db.delete(db.chatMessages)..where((t) => t.senderId.equals(uid)))
            .go();

        await (db.delete(db.chatConversations)
              ..where((t) => t.user1Id.equals(uid) | t.user2Id.equals(uid)))
            .go();

        await (db.delete(db.notifications)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.tasks)..where((t) => t.userId.equals(uid))).go();

        await (db.delete(db.schedules)..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.teacherApplications)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.personalRoadmaps)
              ..where((t) => t.userId.equals(uid)))
            .go();

        await (db.delete(db.enrollmentImports)
              ..where((t) => t.adminId.equals(uid)))
            .go();
      }

      await (db.delete(db.users)..where((t) => t.role.equals(2).not())).go();
    });

    return Response.json(
      body: {
        'success': true,
        'message': 'Đã xóa ${userIds.length} user (giữ lại admin)',
        'deleted': userIds.length,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': '$e',
      }),
    );
  }
}
