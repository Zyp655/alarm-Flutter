import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

class NotificationHelper {
  static Future<void> createNotification({
    required AppDatabase db,
    required int userId,
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    int? relatedId,
    String? relatedType,
  }) async {
    await db.into(db.notifications).insert(
          NotificationsCompanion.insert(
            userId: userId,
            type: type,
            title: title,
            message: message,
            actionUrl: Value(actionUrl),
            relatedId: Value(relatedId),
            relatedType: Value(relatedType),
            createdAt: DateTime.now(),
          ),
        );
  }

  static Future<void> createBatchNotifications({
    required AppDatabase db,
    required List<int> userIds,
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    int? relatedId,
    String? relatedType,
  }) async {
    final now = DateTime.now();

    await db.batch((batch) {
      for (final userId in userIds) {
        batch.insert(
          db.notifications,
          NotificationsCompanion.insert(
            userId: userId,
            type: type,
            title: title,
            message: message,
            actionUrl: Value(actionUrl),
            relatedId: Value(relatedId),
            relatedType: Value(relatedType),
            createdAt: now,
          ),
        );
      }
    });
  }

  static Future<void> notifyClassStudents({
    required AppDatabase db,
    required int classId,
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    int? relatedId,
    String? relatedType,
  }) async {
    final students = await (db.select(db.schedules)
          ..where((s) => s.classId.equals(classId)))
        .get();

    final userIds = students.map((s) => s.userId).toSet().toList();

    if (userIds.isNotEmpty) {
      await createBatchNotifications(
        db: db,
        userIds: userIds,
        type: type,
        title: title,
        message: message,
        actionUrl: actionUrl,
        relatedId: relatedId,
        relatedType: relatedType,
      );
    }
  }
}
