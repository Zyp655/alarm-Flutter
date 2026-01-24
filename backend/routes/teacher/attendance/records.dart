import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;

  if (!params.containsKey('classId') || !params.containsKey('date')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing required parameters: classId, date'},
    );
  }

  final classId = int.parse(params['classId']!);
  final date = DateTime.parse(params['date']!);

  try {
    final records = await (db.select(db.attendances).join([
      innerJoin(
        db.users,
        db.users.id.equalsExp(db.attendances.studentId),
      ),
    ])
          ..where(
            db.attendances.classId.equals(classId) &
                db.attendances.date.equals(date),
          ))
        .get();

    final result = records.map((row) {
      final attendance = row.readTable(db.attendances);
      final student = row.readTable(db.users);

      return {
        'id': attendance.id,
        'classId': attendance.classId,
        'studentId': attendance.studentId,
        'studentName': student.fullName ?? student.email,
        'studentEmail': student.email,
        'date': attendance.date.toIso8601String(),
        'status': attendance.status,
        'note': attendance.note,
        'markedBy': attendance.markedBy,
        'markedAt': attendance.markedAt.toIso8601String(),
        'updatedAt': attendance.updatedAt?.toIso8601String(),
      };
    }).toList();

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
