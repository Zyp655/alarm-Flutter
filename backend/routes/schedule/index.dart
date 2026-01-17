import 'package:backend/repositories/student_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final userId = context.read<int>();
  final repo = context.read<StudentRepository>();

  if (context.request.method == HttpMethod.get) {
    final list = await repo.getSchedules(userId);
    final jsonList = list.map((e) => {
      'id': e.id,
      'subject': e.subjectName,
      'room': e.room,
      'start': e.startTime.toIso8601String(),
      'end': e.endTime.toIso8601String(),
      'note': e.note,
    }).toList();
    return Response.json(body: jsonList);
  }

  if (context.request.method == HttpMethod.post) {
    final json = await context.request.json();

    if (json is List) {
      for (var item in json) {
        final map = item as Map<String, dynamic>;
        await repo.addSchedule(
          userId,
          map['subject'] as String,
          DateTime.parse(map['start'] as String),
          DateTime.parse(map['end'] as String),
          map['room'] as String? ?? '',
        );
      }
      return Response.json(body: {'message': 'Đã import ${json.length} lịch học'});
    }

    else if (json is Map<String, dynamic>) {
      await repo.addSchedule(
        userId,
        json['subject'] as String,
        DateTime.parse(json['start'] as String),
        DateTime.parse(json['end'] as String),
        json['room'] as String? ?? '',
      );
      return Response.json(body: {'message': 'Đã thêm lịch học'});
    }

    return Response.json(
      statusCode: 400,
      body: {'error': 'Dữ liệu không hợp lệ'},
    );
  }

  return Response(statusCode: 405);
}