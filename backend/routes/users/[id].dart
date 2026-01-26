import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = context.read<AppDatabase>();
  final userId = int.tryParse(id);

  if (userId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid user ID'});
  }

  if (context.request.method == HttpMethod.get) {
    try {
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();

      if (user == null) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'User not found'},
        );
      }

      final studentProfile = await (db.select(db.studentProfiles)
            ..where((s) => s.userId.equals(userId)))
          .getSingleOrNull();

      return Response.json(
        body: {
          'id': user.id,
          'email': user.email,
          'fullName': user.fullName,
          'role': user.role,
          'studentId': studentProfile?.studentId,
          'major': studentProfile?.major,
          'avatarUrl': studentProfile?.avatarUrl,
        },
      );
    } catch (e) {
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;

      await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          fullName: Value(body['fullName'] as String?),
        ),
      );

      if (body['studentId'] != null ||
          body['major'] != null ||
          body['avatarUrl'] != null) {
        final existingProfile = await (db.select(db.studentProfiles)
              ..where((s) => s.userId.equals(userId)))
            .getSingleOrNull();

        if (existingProfile != null) {
          await (db.update(db.studentProfiles)
                ..where((s) => s.userId.equals(userId)))
              .write(
            StudentProfilesCompanion(
              studentId: Value(body['studentId'] as String?),
              major: Value(body['major'] as String?),
              avatarUrl: Value(body['avatarUrl'] as String?),
            ),
          );
        } else {
          await db.into(db.studentProfiles).insert(
                StudentProfilesCompanion.insert(
                  userId: userId,
                  fullName: body['fullName'] as String? ?? '',
                  studentId: Value(body['studentId'] as String?),
                  major: Value(body['major'] as String?),
                  avatarUrl: Value(body['avatarUrl'] as String?),
                ),
              );
        }
      }

      return Response.json(body: {'message': 'Cập nhật thành công'});
    } catch (e) {
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  return Response(statusCode: 405);
}
