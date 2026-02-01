import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  if (method == HttpMethod.get) {
    return _getMajors(context);
  } else if (method == HttpMethod.post) {
    return _createMajor(context);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getMajors(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();

    final majorsResult = await db.select(db.majors).get();

    final List<Map<String, dynamic>> majorsWithCount = [];

    for (final major in majorsResult) {
      final courseCount = await (db.selectOnly(db.courses)
            ..addColumns([db.courses.id.count()])
            ..where(db.courses.majorId.equals(major.id)))
          .map((row) => row.read(db.courses.id.count()))
          .getSingle();

      majorsWithCount.add({
        'id': major.id,
        'name': major.name,
        'code': major.code,
        'description': major.description,
        'iconUrl': major.iconUrl,
        'courseCount': courseCount ?? 0,
        'createdAt': major.createdAt.toIso8601String(),
      });
    }

    return Response.json(body: {'majors': majorsWithCount});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch majors: $e'},
    );
  }
}

Future<Response> _createMajor(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final name = body['name'] as String?;
    final code = body['code'] as String?;

    if (name == null || code == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'name and code are required'},
      );
    }

    final existing = await (db.select(db.majors)
          ..where((m) => m.code.equals(code)))
        .getSingleOrNull();

    if (existing != null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Major with code $code already exists'},
      );
    }

    final major = await db.into(db.majors).insertReturning(
          MajorsCompanion.insert(
            name: name,
            code: code,
            description: Value(body['description'] as String?),
            iconUrl: Value(body['iconUrl'] as String?),
            createdAt: DateTime.now(),
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Major created successfully',
        'major': {
          'id': major.id,
          'name': major.name,
          'code': major.code,
          'description': major.description,
          'iconUrl': major.iconUrl,
          'createdAt': major.createdAt.toIso8601String(),
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create major: $e'},
    );
  }
}
