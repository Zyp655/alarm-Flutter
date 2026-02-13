import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';


Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final teacherEmail = body['teacherEmail'] as String?;

    if (teacherEmail == null || teacherEmail.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'teacherEmail is required'},
      );
    }

    final teacher = await (db.select(db.users)
          ..where((u) => u.email.equals(teacherEmail)))
        .getSingleOrNull();

    if (teacher == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Teacher not found with email: $teacherEmail'},
      );
    }

    final roadmapCourseTitles = [
      'Git & Version Control',
      'Ngôn ngữ lập trình (Python/Node.js)',
      'Database & SQL',
      'REST API Development',
      'Authentication & Security',
      'Caching & Performance',
      'Testing Backend',
      'Docker & Containerization',
      'CI/CD Pipeline',
      'Cloud Services',
      'HTML5 Fundamentals',
      'CSS3 Styling',
      'JavaScript Core',
      'JavaScript Advanced',
      'TypeScript',
      'React Fundamentals',
      'State Management',
      'Modern CSS & Styling',
      'Frontend Testing',
      'Web Performance',
      'Frontend Deployment',
    ];

    int updatedCount = 0;

    for (final title in roadmapCourseTitles) {
      final result = await (db.update(db.courses)
            ..where((c) => c.title.equals(title)))
          .write(CoursesCompanion(instructorId: Value(teacher.id)));
      updatedCount += result;
    }

    return Response.json(body: {
      'message': 'Roadmap courses assigned to teacher successfully',
      'teacherId': teacher.id,
      'teacherEmail': teacher.email,
      'teacherName': teacher.fullName,
      'updatedCoursesCount': updatedCount,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to assign teacher: $e'},
    );
  }
}
