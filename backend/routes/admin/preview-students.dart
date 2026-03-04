import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final classCode = context.request.uri.queryParameters['classCode'];
  if (classCode == null || classCode.trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'classCode is required',
        'count': 0,
        'students': <Map<String, dynamic>>[]
      },
    );
  }

  try {
    final db = context.read<AppDatabase>();
    final normalizedCode =
        classCode.trim().replaceAll(RegExp(r'[-\s]'), '').toLowerCase();

    final allProfiles = await db.select(db.studentProfiles).get();
    final matched = <Map<String, dynamic>>[];

    for (final profile in allProfiles) {
      if (profile.studentClass == null || profile.studentClass!.isEmpty) {
        continue;
      }

      final normalizedStudentClass =
          profile.studentClass!.replaceAll(RegExp(r'[-\s]'), '').toLowerCase();

      if (normalizedStudentClass == normalizedCode) {
        final user = await (db.select(db.users)
              ..where((u) => u.id.equals(profile.userId)))
            .getSingleOrNull();

        matched.add({
          'id': profile.userId,
          'fullName': user?.fullName ?? profile.fullName,
          'studentId': profile.studentId,
          'email': user?.email ?? '',
          'studentClass': profile.studentClass,
        });
      }
    }

    return Response.json(body: {
      'count': matched.length,
      'students': matched,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': '$e', 'count': 0, 'students': <Map<String, dynamic>>[]},
    );
  }
}
