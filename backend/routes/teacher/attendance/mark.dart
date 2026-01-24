import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;

  if (!body.containsKey('classId') ||
      !body.containsKey('date') ||
      !body.containsKey('teacherId') ||
      !body.containsKey('attendances')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing required fields'},
    );
  }

  final classId = body['classId'] as int;
  final date = DateTime.parse(body['date'] as String);
  final teacherId = body['teacherId'] as int;
  final attendances = body['attendances'] as List;

  try {
    final now = DateTime.now();

    await db.transaction(() async {
      for (final attendance in attendances) {
        final studentId = attendance['studentId'] as int;
        // status now stores the number of periods missed as a String ("0", "1", "2"...)
        final status = attendance['status'] as String;
        final note = attendance['note'] as String?;

        final existing = await (db.select(db.attendances)
              ..where((t) => t.classId.equals(classId))
              ..where((t) => t.studentId.equals(studentId))
              ..where((t) => t.date.equals(date)))
            .getSingleOrNull();

        if (existing != null) {
          // Update
          await (db.update(db.attendances)
                ..where((t) => t.id.equals(existing.id)))
              .write(
            AttendancesCompanion(
              status: Value(status),
              note: Value(note),
              markedBy: Value(teacherId),
              updatedAt: Value(now),
            ),
          );
        } else {
          // Insert
          await db.into(db.attendances).insert(
                AttendancesCompanion.insert(
                  classId: classId,
                  scheduleId: Value(attendance['scheduleId'] as int?),
                  studentId: studentId,
                  date: date,
                  status: status,
                  note: Value(note),
                  markedBy: teacherId,
                  markedAt: now,
                ),
              );
        }
      }
    });

    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'message': 'Attendance marked successfully',
        'count': attendances.length,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
