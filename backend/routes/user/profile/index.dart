import 'package:backend/repositories/student_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<int>();
  final repo = context.read<StudentRepository>();

  if (context.request.method == HttpMethod.get) {
    final profile = await repo.getProfile(userId);
    if (profile == null) {
      return Response.json(body: {});
    }
    return Response.json(body: {
      'fullName': profile.fullName,
      'studentId': profile.studentId,
      'major': profile.major,
      'avatarUrl': profile.avatarUrl,
    });
  }

  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;

    await repo.updateProfile(
      userId,
      body['fullName'] as String,
      body['studentId'] as String? ?? '',
      body['major'] as String? ?? '',
    );

    return Response.json(body: {'message': 'Cập nhật hồ sơ thành công'});
  }

  return Response(statusCode: 405);
}