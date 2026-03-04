import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _getImportHistory(context);
  }
  if (context.request.method == HttpMethod.post) {
    return _importEnrollments(context);
  }

  return Response.json(
    body: {'error': 'Method not allowed'},
    statusCode: 405,
  );
}

Future<Response> _getImportHistory(RequestContext context) async {
  try {
    final db = context.read<dynamic>();

    try {
      final results = await db
          .customSelect(
            'SELECT id, file_name, total_records, success_count, error_count, status, created_at '
            'FROM enrollment_imports ORDER BY created_at DESC LIMIT 50',
          )
          .get();

      final imports = results
          .map((dynamic row) => {
                'id': row.data['id'],
                'fileName': row.data['file_name'],
                'totalRecords': row.data['total_records'],
                'successCount': row.data['success_count'],
                'errorCount': row.data['error_count'],
                'status': row.data['status'],
                'createdAt': row.data['created_at']?.toString(),
              })
          .toList();

      return Response.json(body: {'imports': imports});
    } catch (_) {
      return Response.json(body: {'imports': <Map<String, dynamic>>[]});
    }
  } catch (e) {
    return Response.json(
      body: {'error': 'Server error: $e'},
      statusCode: 500,
    );
  }
}

Future<Response> _importEnrollments(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final enrollments = body['enrollments'] as List? ?? [];
    final fileName = body['fileName'] as String? ?? 'import.xlsx';

    if (enrollments.isEmpty) {
      return Response.json(
        body: {'error': 'Danh sách ghi danh trống'},
        statusCode: 400,
      );
    }

    final db = context.read<dynamic>();
    int successCount = 0;
    int errorCount = 0;
    final List<Map<String, dynamic>> errors = [];

    for (final entry in enrollments) {
      final enrollment = entry as Map<String, dynamic>;
      final studentCode = enrollment['studentCode'] as String?;
      final classCode = enrollment['classCode'] as String?;

      if (studentCode == null || classCode == null) {
        errorCount++;
        errors.add({'studentCode': studentCode, 'error': 'Missing data'});
        continue;
      }

      try {

        final studentResults = await db
            .customSelect(
              "SELECT id FROM users WHERE email LIKE '\$studentCode%' LIMIT 1",
            )
            .get();

        if ((studentResults as List).isEmpty) {
          errorCount++;
          errors
              .add({'studentCode': studentCode, 'error': 'Student not found'});
          continue;
        }

        final studentId = (studentResults.first as dynamic).data['id'] as int;

        final classResults = await db
            .customSelect(
              "SELECT id FROM course_classes WHERE class_code = '\$classCode' LIMIT 1",
            )
            .get();

        if ((classResults as List).isEmpty) {
          errorCount++;
          errors.add({
            'studentCode': studentCode,
            'classCode': classCode,
            'error': 'Class not found',
          });
          continue;
        }

        final classId = (classResults.first as dynamic).data['id'] as int;

        await db.customStatement(
          'INSERT INTO course_class_enrollments (student_id, class_id, status, enrolled_at) '
          "VALUES ($studentId, $classId, 'enrolled', NOW()) "
          'ON CONFLICT DO NOTHING',
        );

        successCount++;
      } catch (e) {
        errorCount++;
        errors.add({'studentCode': studentCode, 'error': e.toString()});
      }
    }

    try {
      await db.customStatement(
        'INSERT INTO enrollment_imports (file_name, total_records, success_count, error_count, status, created_at) '
        "VALUES ('$fileName', ${enrollments.length}, $successCount, $errorCount, 'completed', NOW())",
      );
    } catch (_) {}

    return Response.json(body: {
      'successCount': successCount,
      'errorCount': errorCount,
      'totalRecords': enrollments.length,
      'errors': errors,
      'status': 'completed',
    });
  } catch (e) {
    return Response.json(
      body: {'error': 'Import failed: $e'},
      statusCode: 500,
    );
  }
}
