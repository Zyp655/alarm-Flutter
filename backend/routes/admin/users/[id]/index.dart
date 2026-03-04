import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/logger_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = int.tryParse(id);
  if (userId == null) {
    return Response.json(statusCode: 400, body: {'error': 'ID không hợp lệ'});
  }

  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getUser(db, userId);
    case HttpMethod.put:
      return _updateUser(context, db, userId);
    case HttpMethod.delete:
      return _deleteUser(db, userId);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _getUser(AppDatabase db, int userId) async {
  try {
    final user = await (db.select(db.users)..where((t) => t.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Không tìm thấy người dùng'},
      );
    }

    return Response.json(body: {
      'id': user.id,
      'email': user.email,
      'fullName': user.fullName,
      'role': user.role,
      'isBanned': user.isBanned,
    });
  } catch (e) {
    return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}

Future<Response> _updateUser(
  RequestContext context,
  AppDatabase db,
  int userId,
) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    final companion = UsersCompanion(
      fullName: body.containsKey('fullName')
          ? Value(body['fullName'] as String?)
          : const Value.absent(),
      role: body.containsKey('role')
          ? Value(body['role'] as int)
          : const Value.absent(),
      email: body.containsKey('email')
          ? Value(body['email'] as String)
          : const Value.absent(),
    );

    final count = await (db.update(db.users)..where((t) => t.id.equals(userId)))
        .write(companion);

    if (count == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Không tìm thấy người dùng'},
      );
    }

    return Response.json(body: {
      'success': true,
      'message': 'Cập nhật thành công',
    });
  } catch (e, st) {
    logger.error('Update user failed',
        error: e, stackTrace: st, context: 'admin/users/update');
    final errorString = e.toString();
    if (errorString.contains('23505')) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'Email đã tồn tại'},
      );
    }
    return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}

Future<Response> _deleteUser(AppDatabase db, int userId) async {
  try {
    final user = await (db.select(db.users)..where((t) => t.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Không tìm thấy người dùng'},
      );
    }

    if (user.role == 2) {
      return Response.json(
        statusCode: 403,
        body: {'error': 'Không thể xoá tài khoản Admin'},
      );
    }

    await (db.delete(db.studentProfiles)..where((t) => t.userId.equals(userId)))
        .go();

    await (db.delete(db.users)..where((t) => t.id.equals(userId))).go();

    return Response.json(body: {
      'success': true,
      'message': 'Đã xoá người dùng ${user.email}',
    });
  } catch (e) {
    return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}
