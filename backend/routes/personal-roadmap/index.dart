import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method == HttpMethod.get) return _getRoadmap(context);
  if (method == HttpMethod.post) return _createRoadmap(context);
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getRoadmap(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final userId =
        int.tryParse(context.request.uri.queryParameters['userId'] ?? '');
    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

    var roadmap = await (db.select(db.personalRoadmaps)
          ..where((r) => r.userId.equals(userId)))
        .getSingleOrNull();

    if (roadmap == null) {
      roadmap = await _autoGenerateRoadmap(db, userId);
      if (roadmap == null) {
        return Response.json(body: {
          'roadmap': null,
          'message': 'Sinh viên chưa thuộc khoa nào, không thể tạo lộ trình',
        });
      }
    }

    final items = await (db.select(db.personalRoadmapItems)
          ..where((i) => i.roadmapId.equals(roadmap!.id))
          ..orderBy([
            (i) => OrderingTerm.asc(i.semesterOrder),
            (i) => OrderingTerm.asc(i.orderIndex)
          ]))
        .get();

    final itemsJson = <Map<String, dynamic>>[];
    for (final item in items) {
      final course = await (db.select(db.academicCourses)
            ..where((c) => c.id.equals(item.academicCourseId)))
          .getSingleOrNull();

      final classIds = await (db.select(db.courseClasses)
            ..where((cc) => cc.academicCourseId.equals(item.academicCourseId)))
          .get();
      final classIdList = classIds.map((c) => c.id).toList();

      final enrollment = classIdList.isEmpty
          ? null
          : await (db.select(db.courseClassEnrollments)
                ..where((e) => e.studentId.equals(userId))
                ..where((e) => e.courseClassId.isIn(classIdList)))
              .getSingleOrNull();

      String status = item.status;
      if (enrollment != null) {
        if (enrollment.completedAt != null) {
          status = 'completed';
        } else {
          status = 'in_progress';
        }
      }

      String? departmentName;
      if (course != null) {
        final dept = await (db.select(db.departments)
              ..where((d) => d.id.equals(course.departmentId)))
            .getSingleOrNull();
        departmentName = dept?.name;
      }

      itemsJson.add({
        'id': item.id,
        'roadmapId': item.roadmapId,
        'academicCourseId': item.academicCourseId,
        'courseName': course?.name ?? '',
        'courseCode': course?.code ?? '',
        'credits': course?.credits ?? 0,
        'courseType': course?.courseType ?? 'required',
        'departmentName': departmentName,
        'semesterOrder': item.semesterOrder,
        'orderIndex': item.orderIndex,
        'isRequired': item.isRequired,
        'status': status,
        'note': item.note,
      });
    }

    final completedCount =
        itemsJson.where((i) => i['status'] == 'completed').length;
    final inProgressCount =
        itemsJson.where((i) => i['status'] == 'in_progress').length;
    final totalCredits =
        itemsJson.fold<int>(0, (sum, i) => sum + (i['credits'] as int));
    final completedCredits = itemsJson
        .where((i) => i['status'] == 'completed')
        .fold<int>(0, (sum, i) => sum + (i['credits'] as int));

    return Response.json(body: {
      'roadmap': {
        'id': roadmap.id,
        'userId': roadmap.userId,
        'departmentId': roadmap.departmentId,
        'title': roadmap.title,
        'description': roadmap.description,
        'isCustomized': roadmap.isCustomized,
        'createdAt': roadmap.createdAt.toIso8601String(),
      },
      'items': itemsJson,
      'stats': {
        'total': itemsJson.length,
        'completed': completedCount,
        'inProgress': inProgressCount,
        'pending': itemsJson.length - completedCount - inProgressCount,
        'totalCredits': totalCredits,
        'completedCredits': completedCredits,
      },
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}

Future<PersonalRoadmap?> _autoGenerateRoadmap(
    AppDatabase db, int userId) async {
  final user = await (db.select(db.users)..where((u) => u.id.equals(userId)))
      .getSingleOrNull();
  if (user == null) return null;

  int? departmentId = user.departmentId;
  if (departmentId == null) {
    final profile = await (db.select(db.studentProfiles)
          ..where((p) => p.userId.equals(userId)))
        .getSingleOrNull();
    departmentId = profile?.departmentId;
  }
  if (departmentId == null) return null;

  final dept = await (db.select(db.departments)
        ..where((d) => d.id.equals(departmentId!)))
      .getSingleOrNull();

  final now = DateTime.now();
  final roadmapId = await db.into(db.personalRoadmaps).insert(
        PersonalRoadmapsCompanion.insert(
          userId: userId,
          departmentId: Value(departmentId),
          title: 'Lộ trình ${dept?.name ?? 'học tập'}',
          description:
              Value('Lộ trình cá nhân tự động sinh từ chương trình đào tạo'),
          createdAt: now,
          updatedAt: Value(now),
        ),
      );

  final courses = await (db.select(db.academicCourses)
        ..where((c) => c.departmentId.equals(departmentId!))
        ..orderBy([(c) => OrderingTerm.asc(c.id)]))
      .get();

  for (var i = 0; i < courses.length; i++) {
    final course = courses[i];
    final semester = (i ~/ 6) + 1;
    await db.into(db.personalRoadmapItems).insert(
          PersonalRoadmapItemsCompanion.insert(
            roadmapId: roadmapId,
            academicCourseId: course.id,
            semesterOrder: Value(semester),
            orderIndex: Value(i),
            isRequired: Value(course.courseType == 'required'),
            addedAt: now,
          ),
        );
  }

  return await (db.select(db.personalRoadmaps)
        ..where((r) => r.id.equals(roadmapId)))
      .getSingle();
}

Future<Response> _createRoadmap(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as int?;
    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

    final existingRoadmaps = await (db.select(db.personalRoadmaps)
          ..where((r) => r.userId.equals(userId)))
        .get();
    final roadmapIds = existingRoadmaps.map((r) => r.id).toList();
    if (roadmapIds.isNotEmpty) {
      await (db.delete(db.personalRoadmapItems)
            ..where((i) => i.roadmapId.isIn(roadmapIds)))
          .go();
    }
    await (db.delete(db.personalRoadmaps)
          ..where((r) => r.userId.equals(userId)))
        .go();

    final roadmap = await _autoGenerateRoadmap(db, userId);
    if (roadmap == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error': 'Không thể tạo lộ trình: sinh viên chưa thuộc khoa nào'
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'message': 'Đã tạo lộ trình mới', 'roadmapId': roadmap.id},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}
