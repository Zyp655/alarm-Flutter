import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;

  if (!params.containsKey('classId')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing required parameter: classId'},
    );
  }

  final classId = int.parse(params['classId']!);

  try {
    final students = await (db.select(db.schedules).join([
      innerJoin(
        db.users,
        db.users.id.equalsExp(db.schedules.userId),
      ),
    ])
          ..where(db.schedules.classId.equals(classId)))
        .get();

    final stats = <Map<String, dynamic>>[];

    for (final studentRow in students) {
      final student = studentRow.readTable(db.users);
      final studentId = student.id;

      final attendances = await (db.select(db.attendances)
            ..where(
              (a) => a.classId.equals(classId) & a.studentId.equals(studentId),
            ))
          .get();

      final total = attendances.length;
      final present = attendances.where((a) => a.status == 'present').length;
      final absent = attendances.where((a) => a.status == 'absent').length;
      final late = attendances.where((a) => a.status == 'late').length;
      final excused = attendances.where((a) => a.status == 'excused').length;

      final attendanceRate = total > 0 ? (present + excused) / total * 100 : 0;

      stats.add({
        'studentId': studentId,
        'studentName': student.fullName ?? student.email,
        'studentEmail': student.email,
        'total': total,
        'present': present,
        'absent': absent,
        'late': late,
        'excused': excused,
        'attendanceRate': attendanceRate.toStringAsFixed(1),
      });
    }

    return Response.json(body: stats);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
