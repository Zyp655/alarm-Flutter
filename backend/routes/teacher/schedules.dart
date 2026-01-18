import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();

  try {
    final query = db.select(db.schedules).join([
      leftOuterJoin(db.classes, db.classes.id.equalsExp(db.schedules.classId)),
    ]);

    final result = await query.get();

    final list = result.map((row) {
      final schedule = row.readTable(db.schedules);
      final classInfo = row.readTableOrNull(db.classes);

      return {
        'id': schedule.id,
        'userId': schedule.userId,
        'subject': schedule.subjectName,
        'room': schedule.room,
        'startTime': schedule.startTime.toIso8601String(),
        'endTime': schedule.endTime.toIso8601String(),
        'currentAbsences': schedule.currentAbsences,
        'maxAbsences': schedule.maxAbsences,
        'midtermScore': schedule.midtermScore,
        'finalScore': schedule.finalScore,
        'targetScore': schedule.targetScore,
        'classCode': classInfo?.classCode,
      };
    }).toList();

    return Response.json(body: list);
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}