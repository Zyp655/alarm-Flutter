import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import '../../lib/database/database.dart';
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
    final userId = int.tryParse(params['userId'] ?? '');
    final topic = params['topic'];
    if (userId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'userId is required'}),
      );
    }
    var query = db.select(db.quizStatistics)
      ..where((t) => t.userId.equals(userId));
    if (topic != null && topic.isNotEmpty) {
      query = query..where((t) => t.topic.equals(topic));
    }
    final stats = await (query
          ..orderBy([(t) => OrderingTerm.desc(t.lastAttemptAt)]))
        .get();
    final statsList = stats.map((s) {
      return {
        'id': s.id,
        'topic': s.topic,
        'totalAttempts': s.totalAttempts,
        'totalCorrect': s.totalCorrect,
        'totalQuestions': s.totalQuestions,
        'averageScore': s.averageScore,
        'skillLevel': s.skillLevel,
        'lastAttemptAt': s.lastAttemptAt?.toIso8601String(),
      };
    }).toList();
    double overallScore = 0;
    int totalAttempts = 0;
    for (final s in stats) {
      overallScore += s.averageScore * s.totalAttempts;
      totalAttempts += s.totalAttempts;
    }
    if (totalAttempts > 0) {
      overallScore = overallScore / totalAttempts;
    }
    final weakTopics =
        stats.where((s) => s.skillLevel < 0.5).map((s) => s.topic).toList();
    final strongTopics =
        stats.where((s) => s.skillLevel >= 0.7).map((s) => s.topic).toList();
    return Response.json(
      body: {
        'success': true,
        'statistics': statsList,
        'summary': {
          'totalTopics': stats.length,
          'totalAttempts': totalAttempts,
          'overallAverageScore': overallScore,
          'weakTopics': weakTopics,
          'strongTopics': strongTopics,
        },
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