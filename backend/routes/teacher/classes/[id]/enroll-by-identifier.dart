import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final classId = int.tryParse(id);
  if (classId == null) {
    return Response(statusCode: 400, body: 'Invalid Class ID');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final teacherId = body['teacherId'] as int?;
    final identifiers = (body['identifiers'] as List?)?.cast<String>() ?? [];

    if (teacherId == null || identifiers.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Thiếu teacherId hoặc identifiers'},
      );
    }

    final classRow = await (db.select(db.classes)
          ..where((t) => t.id.equals(classId)))
        .getSingleOrNull();

    if (classRow == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Không tìm thấy lớp'},
      );
    }

    if (classRow.teacherId != teacherId) {
      return Response.json(
        statusCode: 403,
        body: {'error': 'Bạn không có quyền ghi danh cho lớp này'},
      );
    }

    final templateSchedules = await (db.select(db.schedules)
          ..where((s) => s.classId.equals(classId))
          ..limit(1))
        .get();

    final template =
        templateSchedules.isNotEmpty ? templateSchedules.first : null;

    var subjectName = '';
    var room = '';
    var credits = 2;
    var maxAbsences = 6;

    if (template != null) {
      subjectName = template.subjectName;
      room = template.room ?? '';
      credits = template.credits;
      maxAbsences = template.maxAbsences;
    }

    final enrolled = <String>[];
    final notFound = <String>[];
    final alreadyEnrolled = <String>[];

    for (final identifier in identifiers) {
      final trimmed = identifier.trim();
      if (trimmed.isEmpty) continue;

      User? user;

      user = await (db.select(db.users)..where((u) => u.email.equals(trimmed)))
          .getSingleOrNull();

      if (user == null) {
        final profile = await (db.select(db.studentProfiles)
              ..where((p) => p.studentId.equals(trimmed)))
            .getSingleOrNull();

        if (profile != null) {
          user = await (db.select(db.users)
                ..where((u) => u.id.equals(profile.userId)))
              .getSingleOrNull();
        }
      }

      if (user == null) {
        notFound.add(trimmed);
        continue;
      }

      final existing = await (db.select(db.schedules)
            ..where(
                (s) => s.userId.equals(user!.id) & s.classId.equals(classId)))
          .get();

      if (existing.isNotEmpty) {
        alreadyEnrolled.add(trimmed);
        continue;
      }

      final allClassSchedules = await (db.select(db.schedules)
            ..where(
                (s) => s.classId.equals(classId) & s.userId.equals(teacherId))
            ..orderBy([(s) => OrderingTerm.asc(s.startTime)]))
          .get();

      if (allClassSchedules.isEmpty) {
        await db.into(db.schedules).insert(SchedulesCompanion.insert(
              userId: user.id,
              classId: Value(classId),
              subjectName: subjectName,
              room: Value(room),
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 2)),
              credits: Value(credits),
              maxAbsences: Value(maxAbsences),
            ));
      } else {
        for (final ts in allClassSchedules) {
          await db.into(db.schedules).insert(SchedulesCompanion.insert(
                userId: user.id,
                classId: Value(classId),
                subjectName: ts.subjectName,
                room: Value(ts.room ?? ''),
                startTime: ts.startTime,
                endTime: ts.endTime,
                note: Value(ts.note ?? ''),
                notificationMinutes: Value(ts.notificationMinutes ?? 15),
                credits: Value(ts.credits),
                maxAbsences: Value(ts.maxAbsences),
              ));
        }
      }

      enrolled.add(trimmed);
    }

    return Response.json(body: {
      'enrolled': enrolled,
      'notFound': notFound,
      'alreadyEnrolled': alreadyEnrolled,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
