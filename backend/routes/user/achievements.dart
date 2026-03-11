import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  final userId = int.tryParse(params['userId'] ?? '');
  if (userId == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: jsonEncode({'error': 'userId is required'}),
    );
  }
  switch (context.request.method) {
    case HttpMethod.get:
      return _getAchievements(db, userId);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: jsonEncode({'error': 'Method not allowed'}),
      );
  }
}

Future<Response> _getAchievements(AppDatabase db, int userId) async {
  try {
    final allAchievements = await db.select(db.achievements).get();
    final userAchievements = await (db.select(db.userAchievements)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final earnedIds = userAchievements.map((ua) => ua.achievementId).toSet();
    final result = allAchievements.map((a) {
      final earned = earnedIds.contains(a.id);
      final userAch = userAchievements.firstWhere(
        (ua) => ua.achievementId == a.id,
        orElse: () => UserAchievement(
          id: 0,
          userId: userId,
          achievementId: a.id,
          earnedAt: DateTime.now(),
        ),
      );
      return {
        'id': a.id,
        'code': a.code,
        'name': a.name,
        'description': a.description,
        'icon': a.icon,
        'points': a.points,
        'earned': earned,
        'earnedAt': earned ? userAch.earnedAt.toIso8601String() : null,
      };
    }).toList();
    final totalPoints = allAchievements
        .where((a) => earnedIds.contains(a.id))
        .fold<int>(0, (sum, a) => sum + a.points);
    return Response.json(
      body: {
        'success': true,
        'achievements': result,
        'totalEarned': earnedIds.length,
        'totalAvailable': allAchievements.length,
        'totalPoints': totalPoints,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}
