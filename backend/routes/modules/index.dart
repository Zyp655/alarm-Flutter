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
  } else if (method == HttpMethod.put) {
    return _reorderModules(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _reorderModules(RequestContext context) async {
  final db = context.read<AppDatabase>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final courseId = body['courseId'] as int?;
    final orderedIds = (body['moduleIds'] as List?)?.cast<int>();

    if (courseId == null || orderedIds == null || orderedIds.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'courseId and moduleIds[] are required'},
      );
    }

    for (var i = 0; i < orderedIds.length; i++) {
      await (db.update(db.modules)
            ..where(
              (m) => m.id.equals(orderedIds[i]) & m.courseId.equals(courseId),
            ))
          .write(ModulesCompanion(orderIndex: Value(i)));
    }

    return Response.json(body: {
      'message': 'Module order updated',
      'newOrder': orderedIds,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
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
                'createdAt': m.createdAt.toIso8601String(),
              })
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

Future<Response> _createModule(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final courseId = body['courseId'] as int?;
    final academicCourseId = body['academicCourseId'] as int?;
    final title = body['title'] as String?;

    if ((courseId == null && academicCourseId == null) || title == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error': 'courseId (or academicCourseId) and title are required'
        },
      );
    }

    int? resolvedCourseId;
    int? resolvedAcademicCourseId;

    if (academicCourseId != null) {
      resolvedAcademicCourseId = academicCourseId;
    } else if (courseId != null) {
      final ac = await (db.select(db.academicCourses)
            ..where((c) => c.id.equals(courseId)))
          .getSingleOrNull();
      if (ac != null) {
        resolvedAcademicCourseId = courseId;
      } else {
        resolvedCourseId = courseId;
      }
    }

    final existingModules = await (db.select(db.modules)
          ..where((tbl) {
            if (resolvedAcademicCourseId != null) {
              return tbl.academicCourseId.equals(resolvedAcademicCourseId);
            }
            return tbl.courseId.equals(resolvedCourseId!);
          }))
        .get();

    final nextOrder = existingModules.length;
    final moduleId = await db.into(db.modules).insert(
          ModulesCompanion.insert(
            courseId: Value(resolvedCourseId),
            academicCourseId: Value(resolvedAcademicCourseId),
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
      body: {'error': 'Không thể tạo chương. Vui lòng thử lại sau: $e'},
    );
  }
}
