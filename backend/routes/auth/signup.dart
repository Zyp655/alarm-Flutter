import 'package:dart_frog/dart_frog.dart';
import 'package:backend/repositories/user_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final repo = context.read<UserRepository>();
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final user = await repo.createUser(
        email: body['email'] as String,
        password: body['password'] as String
    );

    return Response.json(body: {'message': 'User created', 'id': user.id});
  } catch (e) {
    return Response.json(statusCode: 400, body: {'error': 'Email already exists or invalid'});
  }
}