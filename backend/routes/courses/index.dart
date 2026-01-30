import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  if (method == HttpMethod.get) {
    return _getCourses(context);
  } else if (method == HttpMethod.post) {
    return _createCourse(context);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getCourses(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final queryParams = context.request.uri.queryParameters;

    var query = db.select(db.courses);

    if (queryParams.containsKey('search')) {
      final search = queryParams['search']!;
      query = query..where((tbl) => tbl.title.contains(search));
    }

    if (queryParams.containsKey('level')) {
      final level = queryParams['level']!;
      query = query..where((tbl) => tbl.level.equals(level));
    }

    if (queryParams.containsKey('instructorId')) {
      final instructorId = int.tryParse(queryParams['instructorId']!);
      if (instructorId != null) {
        query = query..where((tbl) => tbl.instructorId.equals(instructorId));
      }
    }

    final courses = await query.get();

    final coursesJson = courses
        .map((course) => {
              'id': course.id,
              'title': course.title,
              'description': course.description,
              'thumbnailUrl': course.thumbnailUrl,
              'instructorId': course.instructorId,
              'price': course.price,
              'tags': course.tags,
              'level': course.level,
              'durationMinutes': course.durationMinutes,
              'isPublished': course.isPublished,
              'createdAt': course.createdAt.toIso8601String(),
              'updatedAt': course.updatedAt?.toIso8601String(),
            })
        .toList();

    return Response.json(body: {'courses': coursesJson});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch courses: $e'},
    );
  }
}

Future<Response> _createCourse(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    if (!body.containsKey('title') || !body.containsKey('instructorId')) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'title and instructorId are required'},
      );
    }

    final course = await db.into(db.courses).insertReturning(
          CoursesCompanion.insert(
            title: body['title'] as String,
            instructorId: body['instructorId'] as int,
            description: Value(body['description'] as String?),
            thumbnailUrl: Value(body['thumbnailUrl'] as String?),
            price: Value((body['price'] as num?)?.toDouble() ?? 0.0),
            tags: Value(body['tags'] as String?),
            level: Value(body['level'] as String? ?? 'beginner'),
            durationMinutes: Value(body['durationMinutes'] as int? ?? 0),
            isPublished: Value(body['isPublished'] as bool? ??
                true), 
            createdAt: DateTime.now(),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Course created successfully',
        'course': {
          'id': course.id,
          'title': course.title,
          'description': course.description,
          'thumbnailUrl': course.thumbnailUrl,
          'instructorId': course.instructorId,
          'price': course.price,
          'tags': course.tags,
          'level': course.level,
          'durationMinutes': course.durationMinutes,
          'isPublished': course.isPublished,
          'createdAt': course.createdAt.toIso8601String(),
          'updatedAt': course.updatedAt?.toIso8601String(),
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create course: $e'},
    );
  }
}
