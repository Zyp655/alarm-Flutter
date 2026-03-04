import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final subjectsList = body['subjects'] as List<dynamic>? ?? [];

    if (subjectsList.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Danh sách môn học trống'},
      );
    }

    final allDepartments = await db.select(db.departments).get();
    final deptMapByName = <String, int>{};
    final deptMapByCode = <String, int>{};
    for (final d in allDepartments) {
      final nameLower = d.name.toLowerCase().trim();
      deptMapByName[nameLower] = d.id;
      if (nameLower.startsWith('khoa ')) {
        deptMapByName[nameLower.substring(5).trim()] = d.id;
      }
      deptMapByCode[d.code.toLowerCase().trim()] = d.id;
    }

    int created = 0;
    int skipped = 0;
    final errors = <String>[];
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < subjectsList.length; i++) {
      final s = subjectsList[i] as Map<String, dynamic>;
      final code = (s['code'] as String?)?.trim() ?? '';
      final name = (s['name'] as String?)?.trim() ?? '';
      final department = (s['department'] as String?)?.trim() ?? '';
      final creditsStr = (s['credits']?.toString())?.trim() ?? '3';
      final semester = (s['semester'] as String?)?.trim() ?? '';

      if (code.isEmpty || name.isEmpty) {
        errors.add('Dòng ${i + 1}: Thiếu mã môn hoặc tên môn');
        continue;
      }

      final credits = int.tryParse(creditsStr) ?? 3;

      final existing = await (db.select(db.academicCourses)
            ..where((t) => t.code.equals(code)))
          .getSingleOrNull();

      if (existing != null) {
        skipped++;
        results.add({'code': code, 'status': 'skipped (already exists)'});
        continue;
      }

      int? departmentId;
      if (department.isNotEmpty) {
        departmentId = deptMapByName[department.toLowerCase()] ??
            deptMapByCode[department.toLowerCase()];
        if (departmentId == null) {
          errors.add(
              'Dòng ${i + 1}: Khoa "$department" không tồn tại trong hệ thống');
          continue;
        }
      }

      if (departmentId == null) {
        errors.add('Dòng ${i + 1}: Thiếu thông tin khoa');
        continue;
      }

      await db.into(db.academicCourses).insert(
            AcademicCoursesCompanion.insert(
              name: name,
              code: code,
              credits: Value(credits),
              departmentId: departmentId,
              description: semester.isNotEmpty
                  ? Value('Kỳ: $semester')
                  : const Value.absent(),
              courseType: semester.isNotEmpty
                  ? Value(semester)
                  : const Value('required'),
              isPublished: const Value(true),
              createdAt: DateTime.now(),
            ),
          );

      created++;
      results.add({'code': code, 'name': name, 'status': 'created'});
    }

    return Response.json(body: {
      'message': 'Import hoàn tất',
      'created': created,
      'skipped': skipped,
      'errors': errors,
      'results': results,
    });
  } catch (e) {
    return Response(
      statusCode: 500,
      body: jsonEncode({'error': 'Lỗi hệ thống: $e'}),
    );
  }
}
