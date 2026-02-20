import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  if (method == HttpMethod.post) {
    return _createSubmission(context);
  } else if (method == HttpMethod.get) {
    return _getSubmissions(context);
  } else if (method == HttpMethod.put) {
    return _gradeSubmission(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _createSubmission(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final assignmentId = body['assignmentId'] as int?;
    final studentId = body['studentId'] as int?;
    final textContent = body['textContent'] as String?;
    final linkUrl = body['linkUrl'] as String?;
    if (assignmentId == null || studentId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'assignmentId and studentId are required'},
      );
    }
    final existing = await (db.select(db.submissions)
          ..where((tbl) => tbl.assignmentId.equals(assignmentId))
          ..where((tbl) => tbl.studentId.equals(studentId)))
        .getSingleOrNull();
    int submissionId;
    if (existing != null) {
      submissionId = existing.id;
      await (db.update(db.submissions)
            ..where((tbl) => tbl.id.equals(submissionId)))
          .write(
        SubmissionsCompanion(
          textContent: Value(textContent),
          linkUrl: Value(linkUrl),
          submittedAt: Value(DateTime.now()),
          version: Value(existing.version + 1),
          status: const Value('submitted'),
        ),
      );
    } else {
      submissionId = await db.into(db.submissions).insert(
            SubmissionsCompanion.insert(
              assignmentId: assignmentId,
              studentId: studentId,
              textContent: Value(textContent),
              linkUrl: Value(linkUrl),
              submittedAt: DateTime.now(),
              status: 'submitted',
            ),
          );
    }
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': submissionId,
        'message': 'Submission saved successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to save submission: $e'},
    );
  }
}
Future<Response> _gradeSubmission(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final submissionId = body['id'] as int?;
    final grade = body['grade'] as double?;
    if (submissionId == null || grade == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'submissionId and grade are required'},
      );
    }
    await (db.update(db.submissions)
          ..where((tbl) => tbl.id.equals(submissionId)))
        .write(
      SubmissionsCompanion(
        grade: Value(grade),
        status: const Value('graded'),
      ),
    );
    return Response.json(body: {'message': 'Graded successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to grade: $e'},
    );
  }
}
Future<Response> _getSubmissions(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final assignmentIdStr = params['assignmentId'];
    if (assignmentIdStr == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'assignmentId is required'},
      );
    }
    final assignmentId = int.tryParse(assignmentIdStr);
    if (assignmentId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid assignmentId'},
      );
    }
    final query = db.select(db.submissions).join([
      innerJoin(db.users, db.users.id.equalsExp(db.submissions.studentId)),
    ]);
    query.where(db.submissions.assignmentId.equals(assignmentId));
    query.orderBy([OrderingTerm.desc(db.submissions.submittedAt)]);
    final results = await query.get();
    final submissions = results.map((row) {
      final sub = row.readTable(db.submissions);
      final user = row.readTable(db.users);
      return {
        'id': sub.id,
        'studentId': sub.studentId,
        'studentName': user.fullName ?? user.email,
        'textContent': sub.textContent,
        'linkUrl': sub.linkUrl,
        'submittedAt': sub.submittedAt.toIso8601String(),
        'status': sub.status,
        'grade': sub.grade,
      };
    }).toList();
    return Response.json(body: submissions);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch submissions: $e'},
    );
  }
}