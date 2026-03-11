import 'package:backend/database/database.dart';
import 'package:backend/helpers/notification_helper.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<int>();
  final db = context.read<AppDatabase>();

  if (context.request.method == HttpMethod.post) {
    try {

      final existing = await (db.select(db.teacherApplications)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.status.isIn([0, 1])))
          .getSingleOrNull();

      if (existing != null) {
        final statusText = existing.status == 0
            ? 'Bạn đã có đơn đang chờ duyệt'
            : 'Bạn đã là giảng viên';
        return Response.json(statusCode: 409, body: {'error': statusText});
      }

      final body = await context.request.json() as Map<String, dynamic>;
      final fullName = body['fullName'] as String? ?? '';
      final expertise = body['expertise'] as String? ?? '';
      final experience = body['experience'] as String? ?? '';
      final qualifications = body['qualifications'] as String? ?? '';
      final reason = body['reason'] as String? ?? '';

      if (fullName.isEmpty || expertise.isEmpty || reason.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Vui lòng điền đầy đủ thông tin bắt buộc'},
        );
      }

      final app = await db.into(db.teacherApplications).insertReturning(
            TeacherApplicationsCompanion.insert(
              userId: userId,
              fullName: fullName,
              expertise: expertise,
              experience: experience,
              qualifications: qualifications,
              reason: reason,
              createdAt: DateTime.now(),
            ),
          );

      final admins =
          await (db.select(db.users)..where((u) => u.role.equals(2))).get();
      if (admins.isNotEmpty) {
        await NotificationHelper.createBatchNotifications(
          db: db,
          userIds: admins.map((a) => a.id).toList(),
          type: 'teacher_application',
          title: 'Đơn đăng ký giảng viên mới',
          message: '$fullName đã gửi đơn đăng ký trở thành giảng viên',
          relatedId: app.id,
          relatedType: 'teacher_application',
        );
      }

      return Response.json(
        statusCode: 201,
        body: {
          'message': 'Đơn đăng ký đã được gửi thành công',
          'id': app.id,
        },
      );
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  if (context.request.method == HttpMethod.get) {
    try {

      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();

      if (user == null || (user.role != 1 && user.role != 2)) {
        return Response.json(
          statusCode: 403,
          body: {'error': 'Không có quyền truy cập'},
        );
      }

      final statusFilter = context.request.uri.queryParameters['status'];

      var query = db.select(db.teacherApplications);
      if (statusFilter != null) {
        final statusInt = int.tryParse(statusFilter);
        if (statusInt != null) {
          query = query..where((t) => t.status.equals(statusInt));
        }
      }

      query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

      final apps = await query.get();

      return Response.json(
        body: apps
            .map((a) => {
                  'id': a.id,
                  'userId': a.userId,
                  'fullName': a.fullName,
                  'expertise': a.expertise,
                  'experience': a.experience,
                  'qualifications': a.qualifications,
                  'reason': a.reason,
                  'status': a.status,
                  'adminNote': a.adminNote,
                  'createdAt': a.createdAt.toIso8601String(),
                  'reviewedAt': a.reviewedAt?.toIso8601String(),
                })
            .toList(),
      );
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
      );
    }
  }

  return Response(statusCode: 405);
}
