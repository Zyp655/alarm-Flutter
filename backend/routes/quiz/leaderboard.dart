import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final classId = int.tryParse(params['classId'] ?? '');
    final period = params['period'] ?? 'all_time';
    final limit = int.tryParse(params['limit'] ?? '10') ?? 10;
    var query = db.select(db.leaderboards)
      ..where((t) => t.period.equals(period))
      ..orderBy([(t) => OrderingTerm.desc(t.totalScore)])
      ..limit(limit);
    if (classId != null) {
      query = query..where((t) => t.classId.equals(classId));
    }
    final entries = await query.get();
    if (entries.isEmpty) {
      return Response.json(
        body: {
          'success': true,
          'period': period,
          'classId': classId,
          'leaderboard': <Map<String, dynamic>>[],
        },
      );
    }
    final userIds = entries.map((e) => e.userId).toList();
    final users =
        await (db.select(db.users)..where((t) => t.id.isIn(userIds))).get();
    final userMap = {for (var u in users) u.id: u};
    final leaderboard = entries.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final e = entry.value;
      final user = userMap[e.userId];
      return <String, dynamic>{
        'rank': rank,
        'userId': e.userId,
        'name': user?.fullName ?? 'User ${e.userId}',
        'totalScore': e.totalScore,
        'quizzesCompleted': e.quizzesCompleted,
      };
    }).toList();
    return Response.json(
      body: {
        'success': true,
        'period': period,
        'classId': classId,
        'leaderboard': leaderboard,
      },
    );
  } catch (e) {
    print('Leaderboard Check Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': e.toString(),
      }),
    );
  }
}