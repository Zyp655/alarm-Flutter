import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final assignmentId = int.parse(id);

  try {
    final submissions = await (db.select(db.submissions).join([
      innerJoin(
        db.users,
        db.users.id.equalsExp(db.submissions.studentId),
      ),
    ])
          ..where(db.submissions.assignmentId.equals(assignmentId))
          ..orderBy([OrderingTerm.desc(db.submissions.submittedAt)]))
        .get();

    final latestSubmissions = <int, dynamic>{};
    for (final row in submissions) {
      final submission = row.readTable(db.submissions);
      final student = row.readTable(db.users);

      if (!latestSubmissions.containsKey(submission.studentId) ||
          submission.version >
              (latestSubmissions[submission.studentId]!['version'] as int)) {
        latestSubmissions[submission.studentId] = {
          'id': submission.id,
          'assignmentId': submission.assignmentId,
          'studentId': submission.studentId,
          'studentName': student.fullName ?? student.email,
          'studentEmail': student.email,
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
        };
      }
    }

    return Response.json(body: latestSubmissions.values.toList());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
