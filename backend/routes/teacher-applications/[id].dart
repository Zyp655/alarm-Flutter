import 'package:backend/database/database.dart';
import 'package:backend/helpers/notification_helper.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<int>();
  final db = context.read<AppDatabase>();

  if (id == 'my') {
    if (context.request.method != HttpMethod.get) {
      return Response(statusCode: 405);
    }
    return _handleMy(db, userId);
  }

  final appId = int.tryParse(id);

  if (appId == null) {
    return Response.json(statusCode: 400, body: {'error': 'ID không hợp lệ'});
  }

  if (context.request.method == HttpMethod.get) {
    try {
      final app = await (db.select(db.teacherApplications)
            ..where((t) => t.id.equals(appId)))
          .getSingleOrNull();

      if (app == null) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Không tìm thấy đơn đăng ký'},
        );
      }

      final currentUser = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();

      if (app.userId != userId &&
          (currentUser == null ||
              (currentUser.role != 1 && currentUser.role != 2))) {
        return Response.json(
          statusCode: 403,
          body: {'error': 'Không có quyền truy cập'},
        );
      }

      return Response.json(body: {
        'id': app.id,
        'userId': app.userId,
        'fullName': app.fullName,
        'expertise': app.expertise,
        'experience': app.experience,
        'qualifications': app.qualifications,
        'reason': app.reason,
        'status': app.status,
        'adminNote': app.adminNote,
        'createdAt': app.createdAt.toIso8601String(),
        'reviewedAt': app.reviewedAt?.toIso8601String(),
      });
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {

      final currentUser = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();

      if (currentUser == null ||
          (currentUser.role != 1 && currentUser.role != 2)) {
        return Response.json(
          statusCode: 403,
          body: {'error': 'Không có quyền thực hiện'},
        );
      }

      final app = await (db.select(db.teacherApplications)
            ..where((t) => t.id.equals(appId)))
          .getSingleOrNull();

      if (app == null) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Không tìm thấy đơn đăng ký'},
        );
      }

      if (app.status != 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Đơn này đã được xử lý'},
        );
      }

      final body = await context.request.json() as Map<String, dynamic>;
      final newStatus = body['status'] as int?;
      final adminNote = body['adminNote'] as String?;

      if (newStatus == null || (newStatus != 1 && newStatus != 2)) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Status phải là 1 (duyệt) hoặc 2 (từ chối)'},
        );
      }

      await (db.update(db.teacherApplications)
            ..where((t) => t.id.equals(appId)))
          .write(TeacherApplicationsCompanion(
        status: Value(newStatus),
        adminNote: Value(adminNote),
        reviewedAt: Value(DateTime.now()),
      ));

      if (newStatus == 1) {
        await (db.update(db.users)..where((u) => u.id.equals(app.userId)))
            .write(const UsersCompanion(role: Value(1)));
      }

      final isApproved = newStatus == 1;
      await NotificationHelper.createNotification(
        db: db,
        userId: app.userId,
        type: 'teacher_application_result',
        title: isApproved
            ? '🎉 Chúc mừng! Đơn đăng ký giảng viên đã được duyệt'
            : 'Đơn đăng ký giảng viên bị từ chối',
        message: isApproved
            ? 'Bạn đã trở thành giảng viên. Hãy đăng nhập lại để bắt đầu.'
            : 'Đơn đăng ký của bạn đã bị từ chối.${adminNote != null ? " Lý do: $adminNote" : ""}',
        relatedId: appId,
        relatedType: 'teacher_application',
      );

      return Response.json(body: {
        'message': isApproved
            ? 'Đã duyệt đơn đăng ký giảng viên'
            : 'Đã từ chối đơn đăng ký',
      });
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  return Response(statusCode: 405);
}

Future<Response> _handleMy(AppDatabase db, int userId) async {
  try {
    final app = await (db.select(db.teacherApplications)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    if (app == null) {
      return Response.json(body: {'hasApplication': false});
    }

    return Response.json(body: {
      'hasApplication': true,
      'id': app.id,
      'fullName': app.fullName,
      'expertise': app.expertise,
      'experience': app.experience,
      'qualifications': app.qualifications,
      'reason': app.reason,
      'status': app.status,
      'statusText': _statusText(app.status),
      'adminNote': app.adminNote,
      'createdAt': app.createdAt.toIso8601String(),
      'reviewedAt': app.reviewedAt?.toIso8601String(),
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

String _statusText(int status) {
  switch (status) {
    case 0:
      return 'Đang chờ duyệt';
    case 1:
      return 'Đã được duyệt';
    case 2:
      return 'Bị từ chối';
    default:
      return 'Không xác định';
  }
}
