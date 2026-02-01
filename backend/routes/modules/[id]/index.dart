import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final method = request.method;
  final moduleId = int.tryParse(id);
  if (moduleId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid module ID'},
    );
  }
  if (method == HttpMethod.get) {
    return _getModule(context, moduleId);
  } else if (method == HttpMethod.put) {
    return _updateModule(context, moduleId);
  } else if (method == HttpMethod.delete) {
    return _deleteModule(context, moduleId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getModule(RequestContext context, int moduleId) async {
  try {
    final db = context.read<AppDatabase>();
    final module = await (db.select(db.modules)
          ..where((tbl) => tbl.id.equals(moduleId)))
        .getSingleOrNull();
    if (module == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Module not found'},
      );
    }
    final lessons = await (db.select(db.lessons)
          ..where((tbl) => tbl.moduleId.equals(moduleId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();
    return Response.json(body: {
      'id': module.id,
      'courseId': module.courseId,
      'title': module.title,
      'description': module.description,
      'orderIndex': module.orderIndex,
      'lessons': lessons
          .map((l) => {
                'id': l.id,
                'title': l.title,
                'type': l.type,
                'durationMinutes': l.durationMinutes,
                'orderIndex': l.orderIndex,
              })
          .toList(),
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch module: $e'},
    );
  }
}
Future<Response> _updateModule(RequestContext context, int moduleId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final count = await (db.update(db.modules)
          ..where((tbl) => tbl.id.equals(moduleId)))
        .write(
      ModulesCompanion(
        title: body.containsKey('title')
            ? Value(body['title'] as String)
            : const Value.absent(),
        description: body.containsKey('description')
            ? Value(body['description'] as String?)
            : const Value.absent(),
        orderIndex: body.containsKey('orderIndex')
            ? Value(body['orderIndex'] as int)
            : const Value.absent(),
      ),
    );
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Module not found'},
      );
    }
    return Response.json(body: {'message': 'Module updated successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update module: $e'},
    );
  }
}
Future<Response> _deleteModule(RequestContext context, int moduleId) async {
  try {
    final db = context.read<AppDatabase>();
    await (db.delete(db.lessons)..where((tbl) => tbl.moduleId.equals(moduleId)))
        .go();
    final count = await (db.delete(db.modules)
          ..where((tbl) => tbl.id.equals(moduleId)))
        .go();
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Module not found'},
      );
    }
    return Response.json(body: {'message': 'Module deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete module: $e'},
    );
  }
}