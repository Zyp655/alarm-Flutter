import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
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
      return _getStreak(db, userId);
    case HttpMethod.post:
      return _updateStreak(db, userId);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: jsonEncode({'error': 'Method not allowed'}),
      );
  }
}

Future<Response> _getStreak(AppDatabase db, int userId) async {
  try {
    final streak = await (db.select(db.userStreaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    if (streak == null) {
      return Response.json(
        body: {
          'success': true,
          'streak': {
            'currentStreak': 0,
            'longestStreak': 0,
            'totalDaysActive': 0,
            'lastActivityDate': null,
          },
        },
      );
    }
    return Response.json(
      body: {
        'success': true,
        'streak': {
          'currentStreak': streak.currentStreak,
          'longestStreak': streak.longestStreak,
          'totalDaysActive': streak.totalDaysActive,
          'lastActivityDate': streak.lastActivityDate?.toIso8601String(),
        },
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}

Future<Response> _updateStreak(AppDatabase db, int userId) async {
  try {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final existing = await (db.select(db.userStreaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.userStreaks).insert(
            UserStreaksCompanion.insert(
              userId: userId,
              currentStreak: const Value(1),
              longestStreak: const Value(1),
              totalDaysActive: const Value(1),
              lastActivityDate: Value(todayDate),
            ),
          );
      return Response.json(
        body: {
          'success': true,
          'streak': {
            'currentStreak': 1,
            'longestStreak': 1,
            'totalDaysActive': 1,
            'streakIncreased': true,
          },
        },
      );
    }
    final lastDate = existing.lastActivityDate;
    if (lastDate != null) {
      final lastDateOnly =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = todayDate.difference(lastDateOnly).inDays;
      if (diff == 0) {
        return Response.json(
          body: {
            'success': true,
            'streak': {
              'currentStreak': existing.currentStreak,
              'longestStreak': existing.longestStreak,
              'totalDaysActive': existing.totalDaysActive,
              'streakIncreased': false,
              'message': 'Already updated today',
            },
          },
        );
      }
      int newStreak;
      if (diff == 1) {
        newStreak = existing.currentStreak + 1;
      } else {
        newStreak = 1;
      }
      final newLongest = newStreak > existing.longestStreak
          ? newStreak
          : existing.longestStreak;
      await (db.update(db.userStreaks)..where((t) => t.id.equals(existing.id)))
          .write(UserStreaksCompanion(
        currentStreak: Value(newStreak),
        longestStreak: Value(newLongest),
        totalDaysActive: Value(existing.totalDaysActive + 1),
        lastActivityDate: Value(todayDate),
      ));
      return Response.json(
        body: {
          'success': true,
          'streak': {
            'currentStreak': newStreak,
            'longestStreak': newLongest,
            'totalDaysActive': existing.totalDaysActive + 1,
            'streakIncreased': diff == 1,
            'streakBroken': diff > 1,
          },
        },
      );
    }
    return Response.json(
      body: {
        'success': true,
        'streak': {'currentStreak': 1}
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}
