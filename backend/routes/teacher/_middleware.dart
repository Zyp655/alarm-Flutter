import 'package:backend/database/database.dart';
import 'package:backend/repositories/teacher_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<TeacherRepository>((context) {
    return TeacherRepository(context.read<AppDatabase>());
  }));
}