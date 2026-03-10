import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<AppDatabase>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final submissionId = body['submissionId'] as int?;

    if (submissionId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'submissionId is required'},
      );
    }

    final submission = await (db.select(db.submissions)
          ..where((s) => s.id.equals(submissionId)))
        .getSingleOrNull();

    if (submission == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Submission not found'},
      );
    }

    final textContent = submission.textContent ?? '';
    final linkUrl = submission.linkUrl ?? '';
    final hasText = textContent.trim().isNotEmpty;
    final hasLink = linkUrl.trim().isNotEmpty;

    final rubric = <Map<String, dynamic>>[];
    double totalAwarded = 0;
    double totalMax = 0;

    if (hasText) {
      final wordCount = textContent.split(RegExp(r'\s+')).length;
      final hasCode = textContent.contains('class ') ||
          textContent.contains('void ') ||
          textContent.contains('```');
      final hasLinks = textContent.contains(RegExp(r'https?://'));
      final hasStructure = textContent.contains('\n');

      final completeness = (wordCount / 200).clamp(0.0, 1.0);
      final compPoints = (completeness * 3).roundToDouble();
      rubric.add({
        'name': 'Hoàn thiện',
        'description': 'Nội dung đầy đủ, bao quát yêu cầu',
        'maxPoints': 3.0,
        'awardedPoints': compPoints,
      });
      totalAwarded += compPoints;
      totalMax += 3;

      final depth = hasCode ? 0.9 : 0.5;
      final depthPoints = (depth * 3).roundToDouble();
      rubric.add({
        'name': 'Chiều sâu',
        'description': 'Phân tích sâu, có ví dụ minh họa',
        'maxPoints': 3.0,
        'awardedPoints': depthPoints,
      });
      totalAwarded += depthPoints;
      totalMax += 3;

      final refScore = hasLinks ? 0.8 : 0.3;
      final refPoints = (refScore * 2).roundToDouble();
      rubric.add({
        'name': 'Tham khảo',
        'description': 'Có nguồn tham khảo hoặc links',
        'maxPoints': 2.0,
        'awardedPoints': refPoints,
      });
      totalAwarded += refPoints;
      totalMax += 2;

      final fmtScore = hasStructure ? 0.7 : 0.4;
      final fmtPoints = (fmtScore * 2).roundToDouble();
      rubric.add({
        'name': 'Trình bày',
        'description': 'Cấu trúc rõ ràng, format hợp lý',
        'maxPoints': 2.0,
        'awardedPoints': fmtPoints,
      });
      totalAwarded += fmtPoints;
      totalMax += 2;
    } else if (hasLink) {
      final isValid = Uri.tryParse(linkUrl)?.hasAbsolutePath ?? false;
      rubric.add({
        'name': 'Link hợp lệ',
        'description': 'URL có thể truy cập được',
        'maxPoints': 5.0,
        'awardedPoints': isValid ? 5.0 : 0.0,
      });
      rubric.add({
        'name': 'Nội dung',
        'description': 'Cần giáo viên đánh giá thủ công',
        'maxPoints': 5.0,
        'awardedPoints': 0.0,
      });
      totalAwarded += isValid ? 5.0 : 0.0;
      totalMax += 10;
    } else {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Submission has no content to grade'},
      );
    }

    final grade = totalMax > 0 ? (totalAwarded / totalMax * 10) : 0.0;
    final confidence = hasText
        ? (0.5 +
                (textContent.split(RegExp(r'\s+')).length > 50 ? 0.2 : 0.0) +
                (textContent.contains('class ') ? 0.1 : 0.0) +
                (textContent.contains(RegExp(r'https?://')) ? 0.1 : 0.0))
            .clamp(0.0, 1.0)
        : 0.3;

    final rubricJsonStr = jsonEncode(rubric);

    await (db.update(db.submissions)..where((s) => s.id.equals(submissionId)))
        .write(SubmissionsCompanion(
      autoGrade: Value(grade),
      autoGradeConfidence: Value(confidence),
      rubricJson: Value(rubricJsonStr),
    ));

    return Response.json(body: {
      'submissionId': submissionId,
      'suggestedGrade': double.parse(grade.toStringAsFixed(1)),
      'confidence': double.parse(confidence.toStringAsFixed(2)),
      'rubric': rubric,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
