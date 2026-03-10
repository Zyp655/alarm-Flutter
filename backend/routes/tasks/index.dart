import 'package:backend/database/database.dart';
import 'package:backend/helpers/pagination.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final userId = context.read<int>();
  final db = context.read<AppDatabase>();
  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    final pg = Pagination.fromQuery(params);

    final countQuery = db.selectOnly(db.tasks)
      ..addColumns([db.tasks.id.count()])
      ..where(db.tasks.userId.equals(userId));
    final total = (await countQuery.getSingle()).read(db.tasks.id.count()) ?? 0;

    final tasks = await (db.select(db.tasks)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.dueDate)])
          ..limit(pg.limit, offset: pg.offset))
        .get();
    final jsonList = tasks.map((task) {
      return {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'isCompleted': task.isCompleted,
        'userId': task.userId,
      };
    }).toList();
    return Response.json(body: pg.wrap(jsonList, total: total));
  }
  if (context.request.method == HttpMethod.post) {
    try {
      final json = await context.request.json() as Map<String, dynamic>;
      final newTask = await db.into(db.tasks).insertReturning(
            TasksCompanion.insert(
              userId: userId,
              title: json['title'] as String,
              description: Value(json['description'] as String?),
              dueDate: DateTime.parse(json['dueDate'] as String),
              isCompleted: Value(json['isCompleted'] as bool? ?? false),
            ),
          );
      return Response.json(body: {
        'id': newTask.id,
        'title': newTask.title,
        'description': newTask.description,
        'dueDate': newTask.dueDate.toIso8601String(),
        'isCompleted': newTask.isCompleted,
        'userId': newTask.userId,
      });
    } catch (e) {
      return Response.json(
          statusCode: 400,
          body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
    }
  }
  return Response(statusCode: 405);
}
