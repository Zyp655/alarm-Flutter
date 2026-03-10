import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/openai_grading_service.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final submissionId = int.tryParse(id);
  if (submissionId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'ID submission không hợp lệ'},
    );
  }

  try {
    final db = context.read<AppDatabase>();

    final submission = await (db.select(db.submissions)
          ..where((s) => s.id.equals(submissionId)))
        .getSingleOrNull();

    if (submission == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Không tìm thấy bài nộp'},
      );
    }

    final assignment = await (db.select(db.assignments)
          ..where((a) => a.id.equals(submission.assignmentId)))
        .getSingleOrNull();

    if (assignment == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Không tìm thấy bài tập'},
      );
    }

    final studentContent = submission.textContent ?? '';
    if (studentContent.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error':
              'Bài nộp không có nội dung text để chấm. Chỉ hỗ trợ chấm bài dạng text.',
        },
      );
    }

    final result = await OpenAIGradingService.gradeSubmission(
      assignmentTitle: assignment.title,
      assignmentDescription: assignment.description ?? '',
      studentSubmission: studentContent,
    );

    final score = (result['score'] as num).toDouble();
    final feedback = result['feedback'] as String;
    final suggestions = result['suggestions'] as String;

    await (db.update(db.submissions)..where((s) => s.id.equals(submissionId)))
        .write(
      SubmissionsCompanion(
        autoGrade: Value(score),
        feedback: Value('$feedback\n\n💡 Đề xuất cải thiện:\n$suggestions'),
        grade: Value(score),
        maxGrade: const Value(10.0),
        gradedAt: Value(DateTime.now()),
        status: const Value('graded'),
      ),
    );

    return Response.json(body: {
      'message': 'Chấm bài AI thành công',
      'submissionId': submissionId,
      'score': score,
      'feedback': feedback,
      'suggestions': suggestions,
      'autoGrade': score,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi chấm bài AI: $e'},
    );
  }
}
