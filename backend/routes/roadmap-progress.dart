import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final userId =
        int.tryParse(context.request.uri.queryParameters['userId'] ?? '');

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

    final result = <Map<String, dynamic>>[];

    final allCourses = await (db.select(db.courses)
          ..where((c) => c.isPublished.equals(true)))
        .get();

    for (final title in roadmapCourseTitles) {
      final course =
          allCourses.where((c) => c.title == title).cast<Course?>().firstOrNull;

      if (course != null) {
        final modules = await (db.select(db.modules)
              ..where((m) => m.courseId.equals(course.id)))
            .get();

        int totalLessons = 0;
        int completedLessons = 0;

        for (final module in modules) {
          final lessons = await (db.select(db.lessons)
                ..where((l) => l.moduleId.equals(module.id)))
              .get();
          totalLessons += lessons.length;

          if (userId != null) {
            for (final lesson in lessons) {
              final progressList = await (db.select(db.lessonProgress)
                    ..where((p) => p.userId.equals(userId))
                    ..where((p) => p.lessonId.equals(lesson.id)))
                  .get();

              if (progressList.isNotEmpty && progressList.first.isCompleted) {
                completedLessons++;
              }
            }
          }
        }

        result.add({
          'id': course.id,
          'title': course.title,
          'totalLessons': totalLessons,
          'completedLessons': completedLessons,
          'isCompleted': completedLessons == totalLessons && totalLessons > 0,
        });
      }
    }

    return Response.json(body: {'courses': result});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
