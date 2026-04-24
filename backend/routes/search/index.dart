import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/embedding_service.dart';
import 'package:backend/helpers/env_helper.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  final query = (params['q'] ?? '').trim().toLowerCase();

  if (query.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Query parameter "q" is required'},
    );
  }

  final typeFilter = params['type'];
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
  final offset = (page - 1) * limit;

  try {
    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'] ?? '';
    final useVector = apiKey.isNotEmpty;

    List<double> queryVec = [];
    if (useVector) {
      try {
        final embeddingService = EmbeddingService(openaiApiKey: apiKey, db: db);
        queryVec = await embeddingService.generateEmbedding(query);
      } catch (_) {}
    }

    final results = <Map<String, dynamic>>[];

    if (typeFilter == null || typeFilter == 'course') {
      if (queryVec.isNotEmpty) {
        final vecSql = '[${queryVec.join(',')}]';
        final rows = await db.customSelect(
          '''SELECT c.id, c.title, c.description, c.thumbnail_url, c.level, c.price, c.tags,
                    u.full_name AS instructor_name,
                    1 - (c.embedding <=> '$vecSql'::vector) AS score
             FROM courses c
             LEFT JOIN users u ON u.id = c.instructor_id
             WHERE c.is_published = true AND c.embedding IS NOT NULL
             ORDER BY c.embedding <=> '$vecSql'::vector
             LIMIT $limit OFFSET $offset''',
        ).get();

        for (final r in rows) {
          results.add({
            'id': r.read<int>('id'),
            'type': 'course',
            'title': r.read<String>('title'),
            'subtitle': r.readNullable<String>('instructor_name') ?? 'Unknown',
            'score': r.read<double>('score'),
            'thumbnailUrl': r.readNullable<String>('thumbnail_url'),
            'metadata': {
              'level': r.readNullable<String>('level'),
              'price': r.readNullable<double>('price'),
            },
          });
        }
      }

      if (results.isEmpty) {
        final courseQuery = db.select(db.courses)
          ..where(
            (c) =>
                c.title.lower().like('%$query%') |
                c.description.lower().like('%$query%') |
                c.tags.lower().like('%$query%'),
          )
          ..where((c) => c.isPublished.equals(true))
          ..limit(limit, offset: offset);

        final courses = await courseQuery.get();
        for (final c in courses) {
          final instructor = await (db.select(db.users)
                ..where((u) => u.id.equals(c.instructorId)))
              .getSingleOrNull();

          final reviews = await (db.select(db.courseReviews)
                ..where((r) => r.courseId.equals(c.id)))
              .get();
          double? avgRating;
          if (reviews.isNotEmpty) {
            avgRating =
                reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                    reviews.length;
          }

          results.add({
            'id': c.id,
            'type': 'course',
            'title': c.title,
            'subtitle': instructor?.fullName ?? 'Unknown instructor',
            'rating': avgRating != null
                ? double.parse(avgRating.toStringAsFixed(1))
                : null,
            'thumbnailUrl': c.thumbnailUrl,
            'metadata': {
              'level': c.level,
              'price': c.price,
            },
          });
        }
      }
    }

    if (typeFilter == null || typeFilter == 'teacher') {
      final teacherQuery = db.select(db.users)
        ..where(
          (u) => u.role.equals(1) & u.fullName.lower().like('%$query%'),
        )
        ..limit(limit, offset: offset);

      final teachers = await teacherQuery.get();
      for (final t in teachers) {
        final courseCount = await (db.selectOnly(db.courses)
              ..addColumns([db.courses.id.count()])
              ..where(db.courses.instructorId.equals(t.id))
              ..where(db.courses.isPublished.equals(true)))
            .getSingle()
            .then((row) => row.read(db.courses.id.count()) ?? 0);

        results.add({
          'id': t.id,
          'type': 'teacher',
          'title': t.fullName ?? t.email,
          'subtitle': '$courseCount khóa học',
          'rating': null,
          'metadata': {'email': t.email},
        });
      }
    }

    if (typeFilter == null || typeFilter == 'lesson') {
      if (queryVec.isNotEmpty) {
        final vecSql = '[${queryVec.join(',')}]';
        final rows = await db.customSelect(
          '''SELECT l.id, l.title, l.type, l.duration_minutes,
                    c.id AS course_id, c.title AS course_title,
                    1 - (l.embedding <=> '$vecSql'::vector) AS score
             FROM lessons l
             JOIN modules m ON m.id = l.module_id
             JOIN courses c ON c.id = m.course_id
             WHERE c.is_published = true AND l.embedding IS NOT NULL
             ORDER BY l.embedding <=> '$vecSql'::vector
             LIMIT $limit OFFSET $offset''',
        ).get();

        for (final r in rows) {
          results.add({
            'id': r.read<int>('id'),
            'type': 'lesson',
            'title': r.read<String>('title'),
            'subtitle': r.readNullable<String>('course_title') ?? '',
            'score': r.read<double>('score'),
            'metadata': {
              'courseId': r.readNullable<int>('course_id'),
              'type': r.readNullable<String>('type'),
              'durationMinutes': r.readNullable<int>('duration_minutes'),
            },
          });
        }
      }

      if (results.where((r) => r['type'] == 'lesson').isEmpty) {
        final lessonQuery = db.select(db.lessons).join([
          innerJoin(db.modules, db.modules.id.equalsExp(db.lessons.moduleId)),
          innerJoin(db.courses, db.courses.id.equalsExp(db.modules.courseId)),
        ]);
        lessonQuery.where(db.lessons.title.lower().like('%$query%'));
        lessonQuery.where(db.courses.isPublished.equals(true));
        lessonQuery.orderBy([OrderingTerm.asc(db.lessons.title)]);
        lessonQuery.limit(limit, offset: offset);

        final lessonRows = await lessonQuery.get();
        for (final row in lessonRows) {
          final lesson = row.readTable(db.lessons);
          final course = row.readTable(db.courses);

          results.add({
            'id': lesson.id,
            'type': 'lesson',
            'title': lesson.title,
            'subtitle': course.title,
            'rating': null,
            'metadata': {
              'courseId': course.id,
              'type': lesson.type,
              'durationMinutes': lesson.durationMinutes,
            },
          });
        }
      }
    }

    results.sort((a, b) {
      final scoreA = (a['score'] as double?) ?? 0.0;
      final scoreB = (b['score'] as double?) ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    return Response.json(body: {
      'query': query,
      'type': typeFilter,
      'semantic': queryVec.isNotEmpty,
      'results': results,
      'pagination': {
        'page': page,
        'limit': limit,
      },
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
