import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final taskId = int.tryParse(id);
  if (taskId == null) {
    return Response(statusCode: 400, body: 'ID không hợp lệ');
  }
  final userId = context.read<int>();
  final db = context.read<AppDatabase>();
  if (context.request.method == HttpMethod.delete) {
    final rowsAffected = await (db.delete(db.tasks)
          ..where((t) => t.id.equals(taskId) & t.userId.equals(userId)))
        .go();
    if (rowsAffected > 0) {
      return Response.json(body: {'message': 'Đã xóa thành công'});
    } else {
      return Response(statusCode: 404, body: 'Không tìm thấy task');
    }
  }
  if (context.request.method == HttpMethod.put) {
    try {
      final json = await context.request.json() as Map<String, dynamic>;
      await (db.update(db.tasks)
            ..where((t) => t.id.equals(taskId) & t.userId.equals(userId)))
          .write(
        TasksCompanion(
          title: Value(json['title'] as String),
          description: Value(json['description'] as String?),
          dueDate: Value(DateTime.parse(json['dueDate'] as String)),
          isCompleted: Value(json['isCompleted'] as bool),
        ),
      );
      final updatedTask = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      return Response.json(body: {
        'id': updatedTask.id,
        'title': updatedTask.title,
        'description': updatedTask.description,
        'dueDate': updatedTask.dueDate.toIso8601String(),
        'isCompleted': updatedTask.isCompleted,
        'userId': updatedTask.userId,
      });
    } catch (e) {
      return Response.json(statusCode: 400, body: {'error': e.toString()});
    }
  }
  return Response(statusCode: 405);
}