import 'package:backend/database/database.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<AppDatabase>((context) => AppDatabase()))
      .use(authMiddleware);
}