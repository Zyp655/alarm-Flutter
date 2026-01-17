import 'package:backend/database/database.dart';
import 'package:backend/repositories/student_repository.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';

final _db = AppDatabase();

Handler middleware(Handler handler) {
  _db.customSelect('SELECT 1').get();

  return handler
      .use(requestLogger())
      .use(provider<StudentRepository>((_) => StudentRepository(_db)))
      .use(provider<UserRepository>((_) => UserRepository(_db)))
      .use(provider<AppDatabase>((_) => _db));
}