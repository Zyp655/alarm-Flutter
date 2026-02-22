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
    final defaultAchievements = [
      {
        'code': 'first_quiz',
        'name': 'Người mới',
        'description': 'Hoàn thành quiz đầu tiên',
        'icon': 'emoji_events',
        'points': 10,
      },
      {
        'code': 'streak_3',
        'name': 'Kiên trì',
        'description': 'Duy trì streak 3 ngày',
        'icon': 'local_fire_department',
        'points': 20,
      },
      {
        'code': 'streak_7',
        'name': 'Chăm chỉ',
        'description': 'Duy trì streak 7 ngày',
        'icon': 'whatshot',
        'points': 50,
      },
      {
        'code': 'streak_30',
        'name': 'Siêu sao',
        'description': 'Duy trì streak 30 ngày',
        'icon': 'stars',
        'points': 200,
      },
      {
        'code': 'perfect_score',
        'name': 'Hoàn hảo',
        'description': 'Đạt 100% điểm trong một quiz',
        'icon': 'military_tech',
        'points': 30,
      },
      {
        'code': 'speed_demon',
        'name': 'Tốc độ',
        'description': 'Hoàn thành quiz trong dưới 1 phút',
        'icon': 'bolt',
        'points': 25,
      },
      {
        'code': 'quiz_master_10',
        'name': 'Quiz Master',
        'description': 'Hoàn thành 10 quiz',
        'icon': 'school',
        'points': 50,
      },
      {
        'code': 'quiz_master_50',
        'name': 'Học giả',
        'description': 'Hoàn thành 50 quiz',
        'icon': 'psychology',
        'points': 150,
      },
      {
        'code': 'multiplayer_winner',
        'name': 'Người chiến thắng',
        'description': 'Thắng một trận multiplayer',
        'icon': 'emoji_flags',
        'points': 40,
      },
      {
        'code': 'top_10',
        'name': 'Top 10',
        'description': 'Lọt vào top 10 bảng xếp hạng',
        'icon': 'leaderboard',
        'points': 60,
      },
    ];
    int inserted = 0;
    for (final ach in defaultAchievements) {
      try {
        await db.into(db.achievements).insert(
              AchievementsCompanion.insert(
                code: ach['code'] as String,
                name: ach['name'] as String,
                description: ach['description'] as String,
                icon: ach['icon'] as String,
                points: Value(ach['points'] as int),
              ),
            );
        inserted++;
      } catch (_) {}
    }
    return Response.json(
      body: {
        'success': true,
        'message': 'Seeded $inserted achievements',
        'total': defaultAchievements.length,
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
