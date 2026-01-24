import 'package:backend/database/database.dart';
import 'package:backend/repositories/student_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final userId = context.read<int>();
  final db = context.read<AppDatabase>();
  final repo = context.read<StudentRepository>();

  if (context.request.method == HttpMethod.get) {
    final query = db.select(db.schedules).join([
      leftOuterJoin(db.classes, db.classes.id.equalsExp(db.schedules.classId)),
    ])
      ..where(db.schedules.userId.equals(userId));

    final result = await query.get();

    final jsonList = result.map((row) {
      final schedule = row.readTable(db.schedules);
      final classInfo = row.readTableOrNull(db.classes);

      return {
        'id': schedule.id,
        'userId': schedule.userId,
        'subject': schedule.subjectName,
        'room': schedule.room,
        'start': schedule.startTime.toIso8601String(),
        'end': schedule.endTime.toIso8601String(),
        'note': schedule.note,
        'classCode': classInfo?.classCode,
        'credits': schedule.credits,
        'currentAbsences': schedule.currentAbsences,
        'maxAbsences': schedule.maxAbsences,
        'midtermScore': schedule.midtermScore,
        'finalScore': schedule.finalScore,
        'targetScore': schedule.targetScore,
        'type': schedule.type,
        'format': schedule.format,
      };
    }).toList();

    return Response.json(body: jsonList);
  }

  if (context.request.method == HttpMethod.post) {
    try {
      final json = await context.request.json();

      if (json is List) {
        await db.batch((batch) {
          for (var item in json) {
            final map = item as Map<String, dynamic>;
            final credits = map['credits'] as int? ?? 3;

            batch.insert(
              db.schedules,
              SchedulesCompanion.insert(
                userId: userId,
                subjectName: map['subject'] as String,
                startTime: DateTime.parse(map['start'] as String),
                endTime: DateTime.parse(map['end'] as String),
                room: Value(map['room'] as String? ?? ''),
                credits: Value(credits),
                maxAbsences: Value(credits * 3),
                type: Value(map['type'] as String? ?? 'classSession'),
                format: Value(map['format'] as String? ?? 'offline'),
              ),
            );
          }
        });
        return Response.json(
            body: {'message': 'Đã import ${json.length} lịch học'});
      } else if (json is Map<String, dynamic>) {
        final credits = json['credits'] as int? ?? 3;

        await db.into(db.schedules).insert(
              SchedulesCompanion.insert(
                userId: userId,
                subjectName: json['subject'] as String,
                startTime: DateTime.parse(json['start'] as String),
                endTime: DateTime.parse(json['end'] as String),
                room: Value(json['room'] as String? ?? ''),
                credits: Value(credits),
                maxAbsences: Value(credits * 3),
                type: Value(json['type'] as String? ?? 'classSession'),
                format: Value(json['format'] as String? ?? 'offline'),
              ),
            );
        return Response.json(body: {'message': 'Đã thêm lịch học'});
      }

      return Response.json(
        statusCode: 400,
        body: {'error': 'Dữ liệu không hợp lệ'},
      );
    } catch (e) {
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  return Response(statusCode: 405);
}
