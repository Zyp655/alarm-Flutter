import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  if (!params.containsKey('userId')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing required parameter: userId'},
    );
  }
  final userId = int.parse(params['userId']!);
  final classId =
      params['classId'] != null ? int.parse(params['classId']!) : null;
  try {
    var query = db.select(db.attendances).join([
      innerJoin(
        db.classes,
        db.classes.id.equalsExp(db.attendances.classId),
      ),
    ])
      ..where(db.attendances.studentId.equals(userId));
    if (classId != null) {
      query = query..where(db.attendances.classId.equals(classId));
    }
    query = query..orderBy([OrderingTerm.desc(db.attendances.date)]);
    final records = await query.get();
    final result = records.map((row) {
      final attendance = row.readTable(db.attendances);
      final classInfo = row.readTable(db.classes);
      return {
        'id': attendance.id,
        'classId': attendance.classId,
        'className': classInfo.className,
        'date': attendance.date.toIso8601String(),
        'status': attendance.status,
        'note': attendance.note,
        'markedAt': attendance.markedAt.toIso8601String(),
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