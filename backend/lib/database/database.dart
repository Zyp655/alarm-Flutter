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

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get teacherId => integer().references(Users, #id)();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  IntColumn get credits => integer().withDefault(const Constant(3))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().nullable().references(Subjects, #id)();
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
  IntColumn get notificationMinutes => integer().nullable()();
  IntColumn get currentAbsences => integer().withDefault(const Constant(0))();
  RealColumn get midtermScore => real().nullable()();
  RealColumn get finalScore => real().nullable()();
  RealColumn get targetScore => real().withDefault(const Constant(4.0))();
  IntColumn get credits => integer().withDefault(const Constant(2))();
  IntColumn get maxAbsences => integer().withDefault(const Constant(6))();
  TextColumn get type => text().withDefault(const Constant('classSession'))();
  TextColumn get format => text().withDefault(const Constant('offline'))();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class Assignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id)();
  IntColumn get teacherId => integer().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get rewardPoints => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get actionUrl => text().nullable()();
  IntColumn get relatedId => integer().nullable()();
  TextColumn get relatedType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Submissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assignmentId => integer().references(Assignments, #id)();
  @ReferenceName('submissionsStudent')
  IntColumn get studentId => integer().references(Users, #id)();
  TextColumn get fileUrl => text().nullable()();
  TextColumn get fileName => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get linkUrl => text().nullable()();
  TextColumn get textContent => text().nullable()();
  DateTimeColumn get submittedAt => dateTime()();
  BoolColumn get isLate => boolean().withDefault(const Constant(false))();
  TextColumn get status => text()();
  RealColumn get grade => real().nullable()();
  RealColumn get maxGrade => real().nullable()();
  TextColumn get feedback => text().nullable()();
  DateTimeColumn get gradedAt => dateTime().nullable()();
  @ReferenceName('submissionsGrader')
  IntColumn get gradedBy => integer().nullable().references(Users, #id)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get previousVersionId =>
      integer().nullable().references(Submissions, #id)();
}

class Attendances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id)();
  IntColumn get scheduleId => integer().nullable().references(Schedules, #id)();
  @ReferenceName('attendancesStudent')
  IntColumn get studentId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  @ReferenceName('attendancesMarker')
  IntColumn get markedBy => integer().references(Users, #id)();
  DateTimeColumn get markedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class StudentAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assignmentId => integer().references(Assignments, #id)();
  IntColumn get studentId => integer().references(Users, #id)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get rewardClaimed =>
      boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [
  Users,
  StudentProfiles,
  Schedules,
  Classes,
  Subjects,
  Assignments,
  StudentAssignments,
  Notifications,
  Submissions,
  Attendances,
  Tasks,
])
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        for (final table in allTables) {
          await m.createTable(table);
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (to == 3) {
          await m.drop(submissions);
          await m.drop(studentAssignments);
          await m.drop(attendances);
          await m.drop(assignments);
          await m.drop(schedules);
          await m.drop(classes);
          await m.drop(subjects);
          await m.drop(studentProfiles);
          await m.drop(tasks);
          await m.drop(notifications);
          await m.drop(users);

          for (final table in allTables) {
            await m.createTable(table);
          }
        }
      },
    );
  }
}
