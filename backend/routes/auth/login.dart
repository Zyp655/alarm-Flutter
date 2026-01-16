import 'package:backend/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final repo = context.read<UserRepository>();

  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || password == null || email.isEmpty || password.isEmpty) {
    return Response.json(
        statusCode: 400,
        body: {'error': 'Vui lòng nhập đầy đủ email và mật khẩu'}
    );
  }

  final user = await repo.getUserByEmail(email);

  if (user == null ||
      !repo.verifyPassword(password, user.passwordHash)) {
    return Response.json(
        statusCode: 401, body: {'error': 'Sai email hoặc mật khẩu'});
  }

  final jwt = JWT({'id': user.id, 'email': user.email});
  final token = jwt.sign(SecretKey('my_secret_key_123'));

  return Response.json(body: {'token': token, 'userId': user.id});
}