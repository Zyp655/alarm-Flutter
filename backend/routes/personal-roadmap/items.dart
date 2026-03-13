import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method == HttpMethod.post) return _addItem(context);
  if (method == HttpMethod.put) return _updateItem(context);
  if (method == HttpMethod.delete) return _deleteItem(context);
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _addItem(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final roadmapId = body['roadmapId'] as int?;
    final academicCourseId = body['academicCourseId'] as int?;

    if (roadmapId == null || academicCourseId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'roadmapId and academicCourseId are required'},
      );
    }

    final existing = await (db.select(db.personalRoadmapItems)
          ..where((i) => i.roadmapId.equals(roadmapId))
          ..where((i) => i.academicCourseId.equals(academicCourseId)))
        .getSingleOrNull();

    if (existing != null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Môn học đã có trong lộ trình'},
      );
    }

    final maxOrder = await (db.select(db.personalRoadmapItems)
          ..where((i) => i.roadmapId.equals(roadmapId))
          ..orderBy([(i) => OrderingTerm.desc(i.orderIndex)])
          ..limit(1))
        .getSingleOrNull();

    final newOrder = (maxOrder?.orderIndex ?? -1) + 1;

    final id = await db.into(db.personalRoadmapItems).insert(
          PersonalRoadmapItemsCompanion.insert(
            roadmapId: roadmapId,
            academicCourseId: academicCourseId,
            semesterOrder: Value(body['semesterOrder'] as int? ?? 1),
            orderIndex: Value(newOrder),
            isRequired: Value(false),
            addedAt: DateTime.now(),
          ),
        );

    await (db.update(db.personalRoadmaps)..where((r) => r.id.equals(roadmapId)))
        .write(PersonalRoadmapsCompanion(
      isCustomized: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'message': 'Đã thêm môn học vào lộ trình', 'itemId': id},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}

Future<Response> _updateItem(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final itemId = body['itemId'] as int?;
    if (itemId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'itemId is required'},
      );
    }

    final updates = PersonalRoadmapItemsCompanion(
      note: body.containsKey('note')
          ? Value(body['note'] as String?)
          : const Value.absent(),
      semesterOrder: body.containsKey('semesterOrder')
          ? Value(body['semesterOrder'] as int)
          : const Value.absent(),
      orderIndex: body.containsKey('orderIndex')
          ? Value(body['orderIndex'] as int)
          : const Value.absent(),
      status: body.containsKey('status')
          ? Value(body['status'] as String)
          : const Value.absent(),
    );

    await (db.update(db.personalRoadmapItems)
          ..where((i) => i.id.equals(itemId)))
        .write(updates);

    return Response.json(body: {'message': 'Cập nhật thành công'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}

Future<Response> _deleteItem(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final itemId =
        int.tryParse(context.request.uri.queryParameters['itemId'] ?? '');
    if (itemId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'itemId is required'},
      );
    }

    final item = await (db.select(db.personalRoadmapItems)
          ..where((i) => i.id.equals(itemId)))
        .getSingleOrNull();

    if (item == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Không tìm thấy item'},
      );
    }

    await (db.delete(db.personalRoadmapItems)
          ..where((i) => i.id.equals(itemId)))
        .go();

    await (db.update(db.personalRoadmaps)
          ..where((r) => r.id.equals(item.roadmapId)))
        .write(PersonalRoadmapsCompanion(
      isCustomized: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    return Response.json(body: {'message': 'Đã xóa môn khỏi lộ trình'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi: $e'},
    );
  }
}
