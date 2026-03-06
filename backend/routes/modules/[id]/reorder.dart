import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

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
