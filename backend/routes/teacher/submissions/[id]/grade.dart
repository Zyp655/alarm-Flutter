import 'package:backend/database/database.dart';
import 'package:backend/helpers/notification_helper.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final submissionId = int.parse(id);
  final body = await context.request.json() as Map<String, dynamic>;

  if (!body.containsKey('grade') || !body.containsKey('teacherId')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing required fields: grade, teacherId'},
    );
  }

  final grade = (body['grade'] as num).toDouble();
  final teacherId = body['teacherId'] as int;
  final feedback = body['feedback'] as String?;

  try {
    final submission = await (db.select(db.submissions)
          ..where((s) => s.id.equals(submissionId)))
        .getSingleOrNull();

    if (submission == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Submission not found'},
      );
    }

    await (db.update(db.submissions)..where((s) => s.id.equals(submissionId)))
        .write(
      SubmissionsCompanion(
        grade: Value(grade),
        feedback: Value(feedback),
        status: const Value('graded'),
        gradedAt: Value(DateTime.now()),
        gradedBy: Value(teacherId),
      ),
    );

    final assignment = await (db.select(db.assignments)
          ..where((a) => a.id.equals(submission.assignmentId)))
        .getSingle();

    await NotificationHelper.createNotification(
      db: db,
      userId: submission.studentId,
      type: 'grade_updated',
      title: 'Bài tập đã được chấm',
      message: '${assignment.title} - Điểm: $grade',
      relatedId: submission.assignmentId,
      relatedType: 'assignment',
    );

    return Response.json(
      body: {
        'success': true,
        'message': 'Submission graded successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
