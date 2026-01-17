import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get email => text().unique()();

  TextColumn get passwordHash => text()();

  TextColumn get fullName => text().nullable()();

  TextColumn get resetToken => text().nullable()();

  IntColumn get role => integer().withDefault(const Constant(0))();

  DateTimeColumn get resetTokenExpiry => dateTime().nullable()();
}

class StudentProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id)();

  TextColumn get fullName => text().withLength(min: 1, max: 100)();

  TextColumn get studentId => text().nullable()();

  TextColumn get major => text().nullable()();

  TextColumn get avatarUrl => text().nullable()();
}

class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get className => text()();

  TextColumn get classCode => text().unique()();

  IntColumn get teacherId => integer().references(Users, #id)();

  DateTimeColumn get createdAt => dateTime()();
}

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id)();

  IntColumn get classId => integer().nullable().references(Classes, #id)();

  TextColumn get subjectName => text()();

  TextColumn get room => text().nullable()();

  DateTimeColumn get startTime => dateTime()();

  DateTimeColumn get endTime => dateTime()();

  TextColumn get note => text().nullable()();

  TextColumn get imagePath => text().nullable()();

  IntColumn get currentAbsences => integer().withDefault(const Constant(0))();

  IntColumn get maxAbsences => integer().withDefault(const Constant(3))();

  RealColumn get midtermScore => real().nullable()();

  RealColumn get finalScore => real().nullable()();

  RealColumn get targetScore => real().withDefault(const Constant(4.0))();
}

@DriftDatabase(tables: [Users, StudentProfiles, Schedules, Classes])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(PgDatabase(
          endpoint: Endpoint(
            host: 'localhost',
            database: 'alarmm_db',
            username: 'postgres',
            password: 'my_super_secret_password',
          ),
          settings: const ConnectionSettings(sslMode: SslMode.disable),
        ));

  @override
  int get schemaVersion => 6;
}
