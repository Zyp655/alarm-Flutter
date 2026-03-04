import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final userId = int.tryParse(id);
  if (userId == null) {
    return Response.json(statusCode: 400, body: {'error': 'ID không hợp lệ'});
  }

  try {
    final db = context.read<AppDatabase>();

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
        body: {'error': 'Không thể khoá tài khoản Admin'},
      );
    }

    final newBanStatus = !user.isBanned;

    await (db.update(db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(isBanned: Value(newBanStatus)),
    );

    return Response.json(body: {
      'success': true,
      'isBanned': newBanStatus,
      'message': newBanStatus
          ? 'Đã khoá tài khoản ${user.email}'
          : 'Đã mở khoá tài khoản ${user.email}',
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}
