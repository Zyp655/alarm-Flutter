import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  if (method == HttpMethod.get) {
    return _getModules(context);
  } else if (method == HttpMethod.post) {
    return _createModule(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getModules(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final courseIdStr = params['courseId'];
    if (courseIdStr == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'courseId is required'},
      );
    }
    final courseId = int.tryParse(courseIdStr);
    if (courseId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid courseId'},
      );
    }
    final modules = await (db.select(db.modules)
          ..where((tbl) => tbl.courseId.equals(courseId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();
    return Response.json(
      body: modules
          .map((m) => {
                'id': m.id,
                'courseId': m.courseId,
                'title': m.title,
                'description': m.description,
                'orderIndex': m.orderIndex,
              })
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch modules: $e'},
    );
  }
}
Future<Response> _createModule(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final courseId = body['courseId'] as int?;
    final title = body['title'] as String?;
    if (courseId == null || title == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'courseId and title are required'},
      );
    }
    final existingModules = await (db.select(db.modules)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .get();
    final nextOrder = existingModules.length;
    final moduleId = await db.into(db.modules).insert(
          ModulesCompanion.insert(
            courseId: courseId,
            title: title,
            description: Value(body['description'] as String?),
            orderIndex: nextOrder,
            createdAt: DateTime.now(),
          ),
        );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': moduleId,
        'message': 'Module created successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create module: $e'},
    );
  }
}