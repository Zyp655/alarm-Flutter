import 'dart:isolate';
import 'package:bcrypt/bcrypt.dart';

class IsolateUtils {
  static Future<String> hashPassword(String password) async {
    return Isolate.run(() => BCrypt.hashpw(password, BCrypt.gensalt()));
  }

  static Future<bool> checkPassword(String raw, String hashed) async {
    return Isolate.run(() => BCrypt.checkpw(raw, hashed));
  }
}
