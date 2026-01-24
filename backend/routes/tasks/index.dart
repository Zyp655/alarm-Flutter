import 'package:backend/database/database.dart';
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
    final tasks = await (db.select(db.tasks)
          ..where((t) => t.userId.equals(userId)))
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

    return Response.json(body: jsonList);
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
      return Response.json(statusCode: 400, body: {'error': e.toString()});
    }
  }

  return Response(statusCode: 405);
}
