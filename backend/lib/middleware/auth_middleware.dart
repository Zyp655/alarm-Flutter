import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Handler authMiddleware(Handler handler) {
  return (context) async {
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(statusCode: 401, body: {'error': 'Missing Token'});
    }

    final token = authHeader.substring(7);

    try {
      final jwt = JWT.verify(
          token, SecretKey('my_secret_key_123'));
      final payload = jwt.payload as Map<String, dynamic>;
      final userId = payload['id'] as int;

      final updatedContext = context.provide<int>(() => userId);
      return handler(updatedContext);
    } catch (e) {
      return Response.json(statusCode: 401, body: {'error': 'Invalid Token'});
    }
  };
}
