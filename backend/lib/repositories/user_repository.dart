import 'package:backend/database/database.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';

class UserRepository {
  final AppDatabase db;

  UserRepository(this.db);

  Future<User> createUser(
      {required String email, required String password}) async {
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    return await db.into(db.users).insertReturning(UsersCompanion.insert(
          email: email,
          passwordHash: hashedPassword,
        ));
  }

  Future<User?> getUserByEmail(String email) async {
    return await (db.select(db.users)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  bool verifyPassword(String rawPassword, String hashedPassword) {
    return BCrypt.checkpw(rawPassword, hashedPassword);
  }

  Future<void> saveResetToken(String email, String token) async {
    final expiry = DateTime.now().add(Duration(minutes: 15));

    await (db.update(db.users)..where((t) => t.email.equals(email))).write(
      UsersCompanion(
        resetToken: Value(token),
        resetTokenExpiry: Value(expiry),
      ),
    );
  }
}
