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

      final isTeacher = user.role == 1 || user.role == 2;

      if (isTeacher) {
        String? departmentName;
        if (user.departmentId != null) {
          final dept = await (db.select(db.departments)
                ..where((t) => t.id.equals(user.departmentId!)))
              .getSingleOrNull();
          departmentName = dept?.name;
        }

        return Response.json(
          body: {
            'id': user.id,
            'email': user.email,
            'fullName': user.fullName,
            'role': user.role,
            'department': departmentName,
            'teacherId': user.resetToken,
          },
        );
      } else {
        final studentProfile = await (db.select(db.studentProfiles)
              ..where((s) => s.userId.equals(userId)))
            .getSingleOrNull();

        String? className;
        if (studentProfile != null) {
          className = studentProfile.studentClass;
        }

        return Response.json(
          body: {
            'id': user.id,
            'email': user.email,
            'fullName': user.fullName,
            'role': user.role,
            'studentId': studentProfile?.studentId,
            'major': studentProfile?.major,
            'academicYear': studentProfile?.academicYear,
            'avatarUrl': studentProfile?.avatarUrl,
            'className': className,
          },
        );
      }
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();
      final isTeacher = user != null && (user.role == 1 || user.role == 2);

      if (isTeacher) {
        final department = body['department'] as String? ?? '';
        final teacherCode = body['teacherId'] as String? ?? '';

        int? departmentId;
        if (department.isNotEmpty) {
          final depts = await db.select(db.departments).get();
          for (final d in depts) {
            final nameLower = d.name.toLowerCase().trim();
            if (nameLower == department.toLowerCase().trim()) {
              departmentId = d.id;
              break;
            }
            if (nameLower.startsWith('khoa ') &&
                nameLower.substring(5).trim() ==
                    department.toLowerCase().trim()) {
              departmentId = d.id;
              break;
            }
          }
        }

        await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
          UsersCompanion(
            fullName: Value(body['fullName'] as String?),
            resetToken: teacherCode.isNotEmpty
                ? Value(teacherCode)
                : const Value.absent(),
            departmentId: departmentId != null
                ? Value(departmentId)
                : const Value.absent(),
          ),
        );
      } else {
        await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
          UsersCompanion(fullName: Value(body['fullName'] as String?)),
        );

        if (body['studentId'] != null ||
            body['major'] != null ||
            body['avatarUrl'] != null ||
            body['className'] != null) {
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
                academicYear: Value(body['academicYear'] as String?),
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
                    academicYear: Value(body['academicYear'] as String?),
                    avatarUrl: Value(body['avatarUrl'] as String?),
                  ),
                );
          }
        }
      }

      return Response.json(body: {'message': 'Cập nhật thành công'});
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  return Response(statusCode: 405);
}
