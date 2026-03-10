import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final userIdStr = params['userId'];
  if (userIdStr == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'userId is required'},
    );
  }
  final userId = int.tryParse(userIdStr);
  if (userId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'userId must be an integer'},
    );
  }

  final db = context.read<AppDatabase>();

  final profile = await (db.select(db.studentProfiles)
        ..where((t) => t.userId.equals(userId)))
      .getSingleOrNull();

  if (profile == null ||
      profile.studentClass == null ||
      profile.studentClass!.isEmpty) {
    return Response.json(body: {
      'synced': 0,
      'message': 'Không tìm thấy lớp sinh viên',
      'enrollments': <Map<String, dynamic>>[],
    });
  }

  final normalizedStudentClass = profile.studentClass!
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
      .toLowerCase();

  final allClasses = await db.select(db.courseClasses).get();
  int synced = 0;
  final enrolledClasses = <Map<String, dynamic>>[];

  for (final cls in allClasses) {
    final normalizedClassCode =
        cls.classCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

    final isMatch = normalizedClassCode == normalizedStudentClass ||
        normalizedClassCode.contains(normalizedStudentClass) ||
        normalizedStudentClass.contains(normalizedClassCode);
    if (!isMatch) continue;

    final existing = await (db.select(db.courseClassEnrollments)
          ..where((e) =>
              e.courseClassId.equals(cls.id) & e.studentId.equals(userId)))
        .getSingleOrNull();

    if (existing == null) {
      await db.into(db.courseClassEnrollments).insert(
            CourseClassEnrollmentsCompanion.insert(
              courseClassId: cls.id,
              studentId: userId,
              status: const Value('enrolled'),
              source: const Value('auto-sync'),
              enrolledAt: DateTime.now(),
            ),
          );
      synced++;
    }

    final course = await (db.select(db.academicCourses)
          ..where((c) => c.id.equals(cls.academicCourseId)))
        .getSingleOrNull();

    enrolledClasses.add({
      'courseClassId': cls.id,
      'classCode': cls.classCode,
      'courseName': course?.name ?? '',
      'courseCode': course?.code ?? '',
      'isNew': existing == null,
    });
  }

  return Response.json(body: {
    'synced': synced,
    'message': synced > 0
        ? 'Đã đăng ký $synced lớp học phần mới'
        : 'Đã đồng bộ, không có lớp mới',
    'enrollments': enrolledClasses,
  });
}
