import 'package:backend/database/database.dart';
import 'package:backend/utils/grade_calculator.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final classId = int.tryParse(id);

  if (classId == null) {
    return Response(statusCode: 400, body: 'Invalid Class ID');
  }

  try {
    final classExists = await (db.select(db.classes)
          ..where((t) => t.id.equals(classId)))
        .getSingleOrNull();

    if (classExists == null) {
      return Response(statusCode: 404, body: 'Class not found');
    }

    final query = db.select(db.schedules).join([
      innerJoin(db.users, db.users.id.equalsExp(db.schedules.userId)),
      leftOuterJoin(
          db.studentProfiles, db.studentProfiles.userId.equalsExp(db.users.id)),
    ])
      ..where(db.schedules.classId.equals(classId));

    final result = await query.get();

    final students = result
        .where((row) =>
            row.readTable(db.schedules).userId != classExists.teacherId)
        .map((row) {
      final schedule = row.readTable(db.schedules);
      final user = row.readTable(db.users);
      final profile = row.readTableOrNull(db.studentProfiles);

      return {
        'id': schedule.id,
        'userId': user.id,
        'fullName': profile?.fullName ?? user.fullName ?? user.email,
        'studentId': profile?.studentId,
        'email': user.email,
        'currentAbsences': schedule.currentAbsences,
        'maxAbsences': schedule.maxAbsences,
        'midtermScore': schedule.midtermScore,
        'finalScore': schedule.finalScore,
        'examScore': schedule.examScore,
        'targetScore': schedule.targetScore,
        'overallScore': GradeCalculator.calculateOverallScore(
          credits: schedule.credits,
          midtermScore: schedule.midtermScore,
          finalScore: schedule.finalScore,
          examScore: schedule.examScore,
          currentAbsences: schedule.currentAbsences,
          maxAbsences: schedule.maxAbsences,
        ),
      };
    }).toList();

    return Response.json(body: students);
  } catch (e) {
    print('Error in get students: $e');
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
