import 'package:backend/repositories/teacher_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  try {
    final repo = context.read<TeacherRepository>();
    final schedules = await repo.getAllStudentSchedules();

    return Response.json(
      body: schedules.map((e) => {
        'id': e.id,
        'subject': e.subjectName,
        'room': e.room,
        'startTime': e.startTime.toIso8601String(),
        'endTime': e.endTime.toIso8601String(),
        'currentAbsences': e.currentAbsences,
        'maxAbsences': e.maxAbsences,
        'midtermScore': e.midtermScore,
        'finalScore': e.finalScore,
        'targetScore': e.targetScore,
      }).toList(),
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Lỗi server: $e');
  }
}