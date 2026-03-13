import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();

    await (db.update(db.users)..where((u) => u.id.equals(1))).write(
      UsersCompanion(email: Value('leehieu655@gmail.com')),
    );

    await (db.update(db.users)..where((u) => u.id.equals(4))).write(
      UsersCompanion(email: Value('1@gmail.com')),
    );

    final users = await db.select(db.users).get();
    final userList = users
        .map((u) => {
              'id': u.id,
              'fullName': u.fullName,
              'email': u.email,
            })
        .toList();

    return Response.json(
      body: {
        'message': 'Emails restored successfully!',
        'users': userList,
      },
    );
  } catch (e) {
    return Response.json(body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}
