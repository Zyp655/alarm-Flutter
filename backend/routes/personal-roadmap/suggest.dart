import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final departmentId =
        int.tryParse(context.request.uri.queryParameters['departmentId'] ?? '');
    final roadmapId =
        int.tryParse(context.request.uri.queryParameters['roadmapId'] ?? '');

    if (departmentId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'departmentId is required'},
      );
    }

    final allCourses = await (db.select(db.academicCourses)
          ..where((c) => c.departmentId.equals(departmentId)))
        .get();

    List<int> existingCourseIds = [];
    if (roadmapId != null) {
      final existingItems = await (db.select(db.personalRoadmapItems)
            ..where((i) => i.roadmapId.equals(roadmapId)))
          .get();
      existingCourseIds = existingItems.map((i) => i.academicCourseId).toList();
    }

    final suggestions = allCourses
        .where((c) => !existingCourseIds.contains(c.id))
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'code': c.code,
              'credits': c.credits,
              'courseType': c.courseType,
              'description': c.description,
            })
        .toList();

    return Response.json(body: {'suggestions': suggestions});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}
