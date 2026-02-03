import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final assignmentId = int.parse(id);
  final params = context.request.uri.queryParameters;
  if (!params.containsKey('userId')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing userId parameter'},
    );
  }
  final studentId = int.parse(params['userId']!);
  try {
    final submission = await (db.select(db.submissions)
          ..where(
            (s) =>
                s.assignmentId.equals(assignmentId) &
                s.studentId.equals(studentId),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.version)])
          ..limit(1))
        .getSingleOrNull();
    if (submission == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'No submission found'},
      );
    }
    return Response.json(
      body: {
        'id': submission.id,
        'assignmentId': submission.assignmentId,
        'studentId': submission.studentId,
        'fileUrl': submission.fileUrl,
        'fileName': submission.fileName,
        'fileSize': submission.fileSize,
        'linkUrl': submission.linkUrl,
        'textContent': submission.textContent,
        'submittedAt': submission.submittedAt.toIso8601String(),
        'isLate': submission.isLate,
        'status': submission.status,
        'grade': submission.grade,
        'maxGrade': submission.maxGrade,
        'feedback': submission.feedback,
        'gradedAt': submission.gradedAt?.toIso8601String(),
        'version': submission.version,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}