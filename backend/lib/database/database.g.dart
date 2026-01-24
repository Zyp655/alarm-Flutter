// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resetTokenMeta =
      const VerificationMeta('resetToken');
  @override
  late final GeneratedColumn<String> resetToken = GeneratedColumn<String>(
      'reset_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
      'role', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _resetTokenExpiryMeta =
      const VerificationMeta('resetTokenExpiry');
  @override
  late final GeneratedColumn<DateTime> resetTokenExpiry =
      GeneratedColumn<DateTime>('reset_token_expiry', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, email, passwordHash, fullName, resetToken, role, resetTokenExpiry];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    }
    if (data.containsKey('reset_token')) {
      context.handle(
          _resetTokenMeta,
          resetToken.isAcceptableOrUnknown(
              data['reset_token']!, _resetTokenMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('reset_token_expiry')) {
      context.handle(
          _resetTokenExpiryMeta,
          resetTokenExpiry.isAcceptableOrUnknown(
              data['reset_token_expiry']!, _resetTokenExpiryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name']),
      resetToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reset_token']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!,
      resetTokenExpiry: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reset_token_expiry']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String email;
  final String passwordHash;
  final String? fullName;
  final String? resetToken;
  final int role;
  final DateTime? resetTokenExpiry;
  const User(
      {required this.id,
      required this.email,
      required this.passwordHash,
      this.fullName,
      this.resetToken,
      required this.role,
      this.resetTokenExpiry});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || resetToken != null) {
      map['reset_token'] = Variable<String>(resetToken);
    }
    map['role'] = Variable<int>(role);
    if (!nullToAbsent || resetTokenExpiry != null) {
      map['reset_token_expiry'] = Variable<DateTime>(resetTokenExpiry);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      passwordHash: Value(passwordHash),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      resetToken: resetToken == null && nullToAbsent
          ? const Value.absent()
          : Value(resetToken),
      role: Value(role),
      resetTokenExpiry: resetTokenExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(resetTokenExpiry),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      resetToken: serializer.fromJson<String?>(json['resetToken']),
      role: serializer.fromJson<int>(json['role']),
      resetTokenExpiry:
          serializer.fromJson<DateTime?>(json['resetTokenExpiry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'fullName': serializer.toJson<String?>(fullName),
      'resetToken': serializer.toJson<String?>(resetToken),
      'role': serializer.toJson<int>(role),
      'resetTokenExpiry': serializer.toJson<DateTime?>(resetTokenExpiry),
    };
  }

  User copyWith(
          {int? id,
          String? email,
          String? passwordHash,
          Value<String?> fullName = const Value.absent(),
          Value<String?> resetToken = const Value.absent(),
          int? role,
          Value<DateTime?> resetTokenExpiry = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        fullName: fullName.present ? fullName.value : this.fullName,
        resetToken: resetToken.present ? resetToken.value : this.resetToken,
        role: role ?? this.role,
        resetTokenExpiry: resetTokenExpiry.present
            ? resetTokenExpiry.value
            : this.resetTokenExpiry,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      resetToken:
          data.resetToken.present ? data.resetToken.value : this.resetToken,
      role: data.role.present ? data.role.value : this.role,
      resetTokenExpiry: data.resetTokenExpiry.present
          ? data.resetTokenExpiry.value
          : this.resetTokenExpiry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('resetToken: $resetToken, ')
          ..write('role: $role, ')
          ..write('resetTokenExpiry: $resetTokenExpiry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, email, passwordHash, fullName, resetToken, role, resetTokenExpiry);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.fullName == this.fullName &&
          other.resetToken == this.resetToken &&
          other.role == this.role &&
          other.resetTokenExpiry == this.resetTokenExpiry);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String?> fullName;
  final Value<String?> resetToken;
  final Value<int> role;
  final Value<DateTime?> resetTokenExpiry;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.fullName = const Value.absent(),
    this.resetToken = const Value.absent(),
    this.role = const Value.absent(),
    this.resetTokenExpiry = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String passwordHash,
    this.fullName = const Value.absent(),
    this.resetToken = const Value.absent(),
    this.role = const Value.absent(),
    this.resetTokenExpiry = const Value.absent(),
  })  : email = Value(email),
        passwordHash = Value(passwordHash);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? fullName,
    Expression<String>? resetToken,
    Expression<int>? role,
    Expression<DateTime>? resetTokenExpiry,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (fullName != null) 'full_name': fullName,
      if (resetToken != null) 'reset_token': resetToken,
      if (role != null) 'role': role,
      if (resetTokenExpiry != null) 'reset_token_expiry': resetTokenExpiry,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<String?>? fullName,
      Value<String?>? resetToken,
      Value<int>? role,
      Value<DateTime?>? resetTokenExpiry}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      resetToken: resetToken ?? this.resetToken,
      role: role ?? this.role,
      resetTokenExpiry: resetTokenExpiry ?? this.resetTokenExpiry,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (resetToken.present) {
      map['reset_token'] = Variable<String>(resetToken.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (resetTokenExpiry.present) {
      map['reset_token_expiry'] = Variable<DateTime>(resetTokenExpiry.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('resetToken: $resetToken, ')
          ..write('role: $role, ')
          ..write('resetTokenExpiry: $resetTokenExpiry')
          ..write(')'))
        .toString();
  }
}

class $StudentProfilesTable extends StudentProfiles
    with TableInfo<$StudentProfilesTable, StudentProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _majorMeta = const VerificationMeta('major');
  @override
  late final GeneratedColumn<String> major = GeneratedColumn<String>(
      'major', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, fullName, studentId, major, avatarUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<StudentProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    }
    if (data.containsKey('major')) {
      context.handle(
          _majorMeta, major.isAcceptableOrUnknown(data['major']!, _majorMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id']),
      major: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}major']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
    );
  }

  @override
  $StudentProfilesTable createAlias(String alias) {
    return $StudentProfilesTable(attachedDatabase, alias);
  }
}

class StudentProfile extends DataClass implements Insertable<StudentProfile> {
  final int id;
  final int userId;
  final String fullName;
  final String? studentId;
  final String? major;
  final String? avatarUrl;
  const StudentProfile(
      {required this.id,
      required this.userId,
      required this.fullName,
      this.studentId,
      this.major,
      this.avatarUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<String>(studentId);
    }
    if (!nullToAbsent || major != null) {
      map['major'] = Variable<String>(major);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  StudentProfilesCompanion toCompanion(bool nullToAbsent) {
    return StudentProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      fullName: Value(fullName),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      major:
          major == null && nullToAbsent ? const Value.absent() : Value(major),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentProfile(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      studentId: serializer.fromJson<String?>(json['studentId']),
      major: serializer.fromJson<String?>(json['major']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'fullName': serializer.toJson<String>(fullName),
      'studentId': serializer.toJson<String?>(studentId),
      'major': serializer.toJson<String?>(major),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  StudentProfile copyWith(
          {int? id,
          int? userId,
          String? fullName,
          Value<String?> studentId = const Value.absent(),
          Value<String?> major = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent()}) =>
      StudentProfile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        fullName: fullName ?? this.fullName,
        studentId: studentId.present ? studentId.value : this.studentId,
        major: major.present ? major.value : this.major,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
      );
  StudentProfile copyWithCompanion(StudentProfilesCompanion data) {
    return StudentProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      major: data.major.present ? data.major.value : this.major,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('studentId: $studentId, ')
          ..write('major: $major, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, fullName, studentId, major, avatarUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.fullName == this.fullName &&
          other.studentId == this.studentId &&
          other.major == this.major &&
          other.avatarUrl == this.avatarUrl);
}

class StudentProfilesCompanion extends UpdateCompanion<StudentProfile> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> fullName;
  final Value<String?> studentId;
  final Value<String?> major;
  final Value<String?> avatarUrl;
  const StudentProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.studentId = const Value.absent(),
    this.major = const Value.absent(),
    this.avatarUrl = const Value.absent(),
  });
  StudentProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String fullName,
    this.studentId = const Value.absent(),
    this.major = const Value.absent(),
    this.avatarUrl = const Value.absent(),
  })  : userId = Value(userId),
        fullName = Value(fullName);
  static Insertable<StudentProfile> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? fullName,
    Expression<String>? studentId,
    Expression<String>? major,
    Expression<String>? avatarUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (studentId != null) 'student_id': studentId,
      if (major != null) 'major': major,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }

  StudentProfilesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? fullName,
      Value<String?>? studentId,
      Value<String?>? major,
      Value<String?>? avatarUrl}) {
    return StudentProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (major.present) {
      map['major'] = Variable<String>(major.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('studentId: $studentId, ')
          ..write('major: $major, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
      'teacher_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creditsMeta =
      const VerificationMeta('credits');
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
      'credits', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, teacherId, name, code, credits, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('credits')) {
      context.handle(_creditsMeta,
          credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}teacher_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code']),
      credits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credits'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final int teacherId;
  final String name;
  final String? code;
  final int credits;
  final bool isDeleted;
  const Subject(
      {required this.id,
      required this.teacherId,
      required this.name,
      this.code,
      required this.credits,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['teacher_id'] = Variable<int>(teacherId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['credits'] = Variable<int>(credits);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      teacherId: Value(teacherId),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      credits: Value(credits),
      isDeleted: Value(isDeleted),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      teacherId: serializer.fromJson<int>(json['teacherId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      credits: serializer.fromJson<int>(json['credits']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'teacherId': serializer.toJson<int>(teacherId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'credits': serializer.toJson<int>(credits),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Subject copyWith(
          {int? id,
          int? teacherId,
          String? name,
          Value<String?> code = const Value.absent(),
          int? credits,
          bool? isDeleted}) =>
      Subject(
        id: id ?? this.id,
        teacherId: teacherId ?? this.teacherId,
        name: name ?? this.name,
        code: code.present ? code.value : this.code,
        credits: credits ?? this.credits,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      credits: data.credits.present ? data.credits.value : this.credits,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('teacherId: $teacherId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('credits: $credits, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, teacherId, name, code, credits, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.teacherId == this.teacherId &&
          other.name == this.name &&
          other.code == this.code &&
          other.credits == this.credits &&
          other.isDeleted == this.isDeleted);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<int> teacherId;
  final Value<String> name;
  final Value<String?> code;
  final Value<int> credits;
  final Value<bool> isDeleted;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.credits = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required int teacherId,
    required String name,
    this.code = const Value.absent(),
    this.credits = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : teacherId = Value(teacherId),
        name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<int>? teacherId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? credits,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teacherId != null) 'teacher_id': teacherId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (credits != null) 'credits': credits,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id,
      Value<int>? teacherId,
      Value<String>? name,
      Value<String?>? code,
      Value<int>? credits,
      Value<bool>? isDeleted}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('teacherId: $teacherId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('credits: $credits, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $ClassesTable extends Classes with TableInfo<$ClassesTable, ClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subjects (id)'));
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _classCodeMeta =
      const VerificationMeta('classCode');
  @override
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
      'class_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
      'teacher_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, subjectId, className, classCode, teacherId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(Insertable<ClassesData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('class_code')) {
      context.handle(_classCodeMeta,
          classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta));
    } else if (isInserting) {
      context.missing(_classCodeMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id']),
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name'])!,
      classCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_code'])!,
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}teacher_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClassesData extends DataClass implements Insertable<ClassesData> {
  final int id;
  final int? subjectId;
  final String className;
  final String classCode;
  final int teacherId;
  final DateTime createdAt;
  const ClassesData(
      {required this.id,
      this.subjectId,
      required this.className,
      required this.classCode,
      required this.teacherId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    map['class_name'] = Variable<String>(className);
    map['class_code'] = Variable<String>(classCode);
    map['teacher_id'] = Variable<int>(teacherId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      className: Value(className),
      classCode: Value(classCode),
      teacherId: Value(teacherId),
      createdAt: Value(createdAt),
    );
  }

  factory ClassesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassesData(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      className: serializer.fromJson<String>(json['className']),
      classCode: serializer.fromJson<String>(json['classCode']),
      teacherId: serializer.fromJson<int>(json['teacherId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int?>(subjectId),
      'className': serializer.toJson<String>(className),
      'classCode': serializer.toJson<String>(classCode),
      'teacherId': serializer.toJson<int>(teacherId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClassesData copyWith(
          {int? id,
          Value<int?> subjectId = const Value.absent(),
          String? className,
          String? classCode,
          int? teacherId,
          DateTime? createdAt}) =>
      ClassesData(
        id: id ?? this.id,
        subjectId: subjectId.present ? subjectId.value : this.subjectId,
        className: className ?? this.className,
        classCode: classCode ?? this.classCode,
        teacherId: teacherId ?? this.teacherId,
        createdAt: createdAt ?? this.createdAt,
      );
  ClassesData copyWithCompanion(ClassesCompanion data) {
    return ClassesData(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      className: data.className.present ? data.className.value : this.className,
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassesData(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('className: $className, ')
          ..write('classCode: $classCode, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subjectId, className, classCode, teacherId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassesData &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.className == this.className &&
          other.classCode == this.classCode &&
          other.teacherId == this.teacherId &&
          other.createdAt == this.createdAt);
}

class ClassesCompanion extends UpdateCompanion<ClassesData> {
  final Value<int> id;
  final Value<int?> subjectId;
  final Value<String> className;
  final Value<String> classCode;
  final Value<int> teacherId;
  final Value<DateTime> createdAt;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.className = const Value.absent(),
    this.classCode = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClassesCompanion.insert({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    required String className,
    required String classCode,
    required int teacherId,
    required DateTime createdAt,
  })  : className = Value(className),
        classCode = Value(classCode),
        teacherId = Value(teacherId),
        createdAt = Value(createdAt);
  static Insertable<ClassesData> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? className,
    Expression<String>? classCode,
    Expression<int>? teacherId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (className != null) 'class_name': className,
      if (classCode != null) 'class_code': classCode,
      if (teacherId != null) 'teacher_id': teacherId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClassesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? subjectId,
      Value<String>? className,
      Value<String>? classCode,
      Value<int>? teacherId,
      Value<DateTime>? createdAt}) {
    return ClassesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      className: className ?? this.className,
      classCode: classCode ?? this.classCode,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('className: $className, ')
          ..write('classCode: $classCode, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES classes (id)'));
  static const VerificationMeta _subjectNameMeta =
      const VerificationMeta('subjectName');
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
      'subject_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notificationMinutesMeta =
      const VerificationMeta('notificationMinutes');
  @override
  late final GeneratedColumn<int> notificationMinutes = GeneratedColumn<int>(
      'notification_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentAbsencesMeta =
      const VerificationMeta('currentAbsences');
  @override
  late final GeneratedColumn<int> currentAbsences = GeneratedColumn<int>(
      'current_absences', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _midtermScoreMeta =
      const VerificationMeta('midtermScore');
  @override
  late final GeneratedColumn<double> midtermScore = GeneratedColumn<double>(
      'midterm_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _finalScoreMeta =
      const VerificationMeta('finalScore');
  @override
  late final GeneratedColumn<double> finalScore = GeneratedColumn<double>(
      'final_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _examScoreMeta =
      const VerificationMeta('examScore');
  @override
  late final GeneratedColumn<double> examScore = GeneratedColumn<double>(
      'exam_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _targetScoreMeta =
      const VerificationMeta('targetScore');
  @override
  late final GeneratedColumn<double> targetScore = GeneratedColumn<double>(
      'target_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(4.0));
  static const VerificationMeta _creditsMeta =
      const VerificationMeta('credits');
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
      'credits', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _maxAbsencesMeta =
      const VerificationMeta('maxAbsences');
  @override
  late final GeneratedColumn<int> maxAbsences = GeneratedColumn<int>(
      'max_absences', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(6));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('classSession'));
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('offline'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        classId,
        subjectName,
        room,
        startTime,
        endTime,
        note,
        imagePath,
        notificationMinutes,
        currentAbsences,
        midtermScore,
        finalScore,
        examScore,
        targetScore,
        credits,
        maxAbsences,
        type,
        format
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    }
    if (data.containsKey('subject_name')) {
      context.handle(
          _subjectNameMeta,
          subjectName.isAcceptableOrUnknown(
              data['subject_name']!, _subjectNameMeta));
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('notification_minutes')) {
      context.handle(
          _notificationMinutesMeta,
          notificationMinutes.isAcceptableOrUnknown(
              data['notification_minutes']!, _notificationMinutesMeta));
    }
    if (data.containsKey('current_absences')) {
      context.handle(
          _currentAbsencesMeta,
          currentAbsences.isAcceptableOrUnknown(
              data['current_absences']!, _currentAbsencesMeta));
    }
    if (data.containsKey('midterm_score')) {
      context.handle(
          _midtermScoreMeta,
          midtermScore.isAcceptableOrUnknown(
              data['midterm_score']!, _midtermScoreMeta));
    }
    if (data.containsKey('final_score')) {
      context.handle(
          _finalScoreMeta,
          finalScore.isAcceptableOrUnknown(
              data['final_score']!, _finalScoreMeta));
    }
    if (data.containsKey('exam_score')) {
      context.handle(_examScoreMeta,
          examScore.isAcceptableOrUnknown(data['exam_score']!, _examScoreMeta));
    }
    if (data.containsKey('target_score')) {
      context.handle(
          _targetScoreMeta,
          targetScore.isAcceptableOrUnknown(
              data['target_score']!, _targetScoreMeta));
    }
    if (data.containsKey('credits')) {
      context.handle(_creditsMeta,
          credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta));
    }
    if (data.containsKey('max_absences')) {
      context.handle(
          _maxAbsencesMeta,
          maxAbsences.isAcceptableOrUnknown(
              data['max_absences']!, _maxAbsencesMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id']),
      subjectName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_name'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      notificationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}notification_minutes']),
      currentAbsences: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_absences'])!,
      midtermScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}midterm_score']),
      finalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_score']),
      examScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exam_score']),
      targetScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_score'])!,
      credits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credits'])!,
      maxAbsences: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_absences'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final int userId;
  final int? classId;
  final String subjectName;
  final String? room;
  final DateTime startTime;
  final DateTime endTime;
  final String? note;
  final String? imagePath;
  final int? notificationMinutes;
  final int currentAbsences;
  final double? midtermScore;
  final double? finalScore;
  final double? examScore;
  final double targetScore;
  final int credits;
  final int maxAbsences;
  final String type;
  final String format;
  const Schedule(
      {required this.id,
      required this.userId,
      this.classId,
      required this.subjectName,
      this.room,
      required this.startTime,
      required this.endTime,
      this.note,
      this.imagePath,
      this.notificationMinutes,
      required this.currentAbsences,
      this.midtermScore,
      this.finalScore,
      this.examScore,
      required this.targetScore,
      required this.credits,
      required this.maxAbsences,
      required this.type,
      required this.format});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<int>(classId);
    }
    map['subject_name'] = Variable<String>(subjectName);
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || notificationMinutes != null) {
      map['notification_minutes'] = Variable<int>(notificationMinutes);
    }
    map['current_absences'] = Variable<int>(currentAbsences);
    if (!nullToAbsent || midtermScore != null) {
      map['midterm_score'] = Variable<double>(midtermScore);
    }
    if (!nullToAbsent || finalScore != null) {
      map['final_score'] = Variable<double>(finalScore);
    }
    if (!nullToAbsent || examScore != null) {
      map['exam_score'] = Variable<double>(examScore);
    }
    map['target_score'] = Variable<double>(targetScore);
    map['credits'] = Variable<int>(credits);
    map['max_absences'] = Variable<int>(maxAbsences);
    map['type'] = Variable<String>(type);
    map['format'] = Variable<String>(format);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      userId: Value(userId),
      classId: classId == null && nullToAbsent
          ? const Value.absent()
          : Value(classId),
      subjectName: Value(subjectName),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      startTime: Value(startTime),
      endTime: Value(endTime),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      notificationMinutes: notificationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationMinutes),
      currentAbsences: Value(currentAbsences),
      midtermScore: midtermScore == null && nullToAbsent
          ? const Value.absent()
          : Value(midtermScore),
      finalScore: finalScore == null && nullToAbsent
          ? const Value.absent()
          : Value(finalScore),
      examScore: examScore == null && nullToAbsent
          ? const Value.absent()
          : Value(examScore),
      targetScore: Value(targetScore),
      credits: Value(credits),
      maxAbsences: Value(maxAbsences),
      type: Value(type),
      format: Value(format),
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      classId: serializer.fromJson<int?>(json['classId']),
      subjectName: serializer.fromJson<String>(json['subjectName']),
      room: serializer.fromJson<String?>(json['room']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      note: serializer.fromJson<String?>(json['note']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      notificationMinutes:
          serializer.fromJson<int?>(json['notificationMinutes']),
      currentAbsences: serializer.fromJson<int>(json['currentAbsences']),
      midtermScore: serializer.fromJson<double?>(json['midtermScore']),
      finalScore: serializer.fromJson<double?>(json['finalScore']),
      examScore: serializer.fromJson<double?>(json['examScore']),
      targetScore: serializer.fromJson<double>(json['targetScore']),
      credits: serializer.fromJson<int>(json['credits']),
      maxAbsences: serializer.fromJson<int>(json['maxAbsences']),
      type: serializer.fromJson<String>(json['type']),
      format: serializer.fromJson<String>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'classId': serializer.toJson<int?>(classId),
      'subjectName': serializer.toJson<String>(subjectName),
      'room': serializer.toJson<String?>(room),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'note': serializer.toJson<String?>(note),
      'imagePath': serializer.toJson<String?>(imagePath),
      'notificationMinutes': serializer.toJson<int?>(notificationMinutes),
      'currentAbsences': serializer.toJson<int>(currentAbsences),
      'midtermScore': serializer.toJson<double?>(midtermScore),
      'finalScore': serializer.toJson<double?>(finalScore),
      'examScore': serializer.toJson<double?>(examScore),
      'targetScore': serializer.toJson<double>(targetScore),
      'credits': serializer.toJson<int>(credits),
      'maxAbsences': serializer.toJson<int>(maxAbsences),
      'type': serializer.toJson<String>(type),
      'format': serializer.toJson<String>(format),
    };
  }

  Schedule copyWith(
          {int? id,
          int? userId,
          Value<int?> classId = const Value.absent(),
          String? subjectName,
          Value<String?> room = const Value.absent(),
          DateTime? startTime,
          DateTime? endTime,
          Value<String?> note = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<int?> notificationMinutes = const Value.absent(),
          int? currentAbsences,
          Value<double?> midtermScore = const Value.absent(),
          Value<double?> finalScore = const Value.absent(),
          Value<double?> examScore = const Value.absent(),
          double? targetScore,
          int? credits,
          int? maxAbsences,
          String? type,
          String? format}) =>
      Schedule(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        classId: classId.present ? classId.value : this.classId,
        subjectName: subjectName ?? this.subjectName,
        room: room.present ? room.value : this.room,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        note: note.present ? note.value : this.note,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        notificationMinutes: notificationMinutes.present
            ? notificationMinutes.value
            : this.notificationMinutes,
        currentAbsences: currentAbsences ?? this.currentAbsences,
        midtermScore:
            midtermScore.present ? midtermScore.value : this.midtermScore,
        finalScore: finalScore.present ? finalScore.value : this.finalScore,
        examScore: examScore.present ? examScore.value : this.examScore,
        targetScore: targetScore ?? this.targetScore,
        credits: credits ?? this.credits,
        maxAbsences: maxAbsences ?? this.maxAbsences,
        type: type ?? this.type,
        format: format ?? this.format,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      classId: data.classId.present ? data.classId.value : this.classId,
      subjectName:
          data.subjectName.present ? data.subjectName.value : this.subjectName,
      room: data.room.present ? data.room.value : this.room,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      note: data.note.present ? data.note.value : this.note,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      notificationMinutes: data.notificationMinutes.present
          ? data.notificationMinutes.value
          : this.notificationMinutes,
      currentAbsences: data.currentAbsences.present
          ? data.currentAbsences.value
          : this.currentAbsences,
      midtermScore: data.midtermScore.present
          ? data.midtermScore.value
          : this.midtermScore,
      finalScore:
          data.finalScore.present ? data.finalScore.value : this.finalScore,
      examScore: data.examScore.present ? data.examScore.value : this.examScore,
      targetScore:
          data.targetScore.present ? data.targetScore.value : this.targetScore,
      credits: data.credits.present ? data.credits.value : this.credits,
      maxAbsences:
          data.maxAbsences.present ? data.maxAbsences.value : this.maxAbsences,
      type: data.type.present ? data.type.value : this.type,
      format: data.format.present ? data.format.value : this.format,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('classId: $classId, ')
          ..write('subjectName: $subjectName, ')
          ..write('room: $room, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('note: $note, ')
          ..write('imagePath: $imagePath, ')
          ..write('notificationMinutes: $notificationMinutes, ')
          ..write('currentAbsences: $currentAbsences, ')
          ..write('midtermScore: $midtermScore, ')
          ..write('finalScore: $finalScore, ')
          ..write('examScore: $examScore, ')
          ..write('targetScore: $targetScore, ')
          ..write('credits: $credits, ')
          ..write('maxAbsences: $maxAbsences, ')
          ..write('type: $type, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      classId,
      subjectName,
      room,
      startTime,
      endTime,
      note,
      imagePath,
      notificationMinutes,
      currentAbsences,
      midtermScore,
      finalScore,
      examScore,
      targetScore,
      credits,
      maxAbsences,
      type,
      format);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.classId == this.classId &&
          other.subjectName == this.subjectName &&
          other.room == this.room &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.note == this.note &&
          other.imagePath == this.imagePath &&
          other.notificationMinutes == this.notificationMinutes &&
          other.currentAbsences == this.currentAbsences &&
          other.midtermScore == this.midtermScore &&
          other.finalScore == this.finalScore &&
          other.examScore == this.examScore &&
          other.targetScore == this.targetScore &&
          other.credits == this.credits &&
          other.maxAbsences == this.maxAbsences &&
          other.type == this.type &&
          other.format == this.format);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int?> classId;
  final Value<String> subjectName;
  final Value<String?> room;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String?> note;
  final Value<String?> imagePath;
  final Value<int?> notificationMinutes;
  final Value<int> currentAbsences;
  final Value<double?> midtermScore;
  final Value<double?> finalScore;
  final Value<double?> examScore;
  final Value<double> targetScore;
  final Value<int> credits;
  final Value<int> maxAbsences;
  final Value<String> type;
  final Value<String> format;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.classId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.room = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.note = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.notificationMinutes = const Value.absent(),
    this.currentAbsences = const Value.absent(),
    this.midtermScore = const Value.absent(),
    this.finalScore = const Value.absent(),
    this.examScore = const Value.absent(),
    this.targetScore = const Value.absent(),
    this.credits = const Value.absent(),
    this.maxAbsences = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.classId = const Value.absent(),
    required String subjectName,
    this.room = const Value.absent(),
    required DateTime startTime,
    required DateTime endTime,
    this.note = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.notificationMinutes = const Value.absent(),
    this.currentAbsences = const Value.absent(),
    this.midtermScore = const Value.absent(),
    this.finalScore = const Value.absent(),
    this.examScore = const Value.absent(),
    this.targetScore = const Value.absent(),
    this.credits = const Value.absent(),
    this.maxAbsences = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
  })  : userId = Value(userId),
        subjectName = Value(subjectName),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? classId,
    Expression<String>? subjectName,
    Expression<String>? room,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? note,
    Expression<String>? imagePath,
    Expression<int>? notificationMinutes,
    Expression<int>? currentAbsences,
    Expression<double>? midtermScore,
    Expression<double>? finalScore,
    Expression<double>? examScore,
    Expression<double>? targetScore,
    Expression<int>? credits,
    Expression<int>? maxAbsences,
    Expression<String>? type,
    Expression<String>? format,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (classId != null) 'class_id': classId,
      if (subjectName != null) 'subject_name': subjectName,
      if (room != null) 'room': room,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (note != null) 'note': note,
      if (imagePath != null) 'image_path': imagePath,
      if (notificationMinutes != null)
        'notification_minutes': notificationMinutes,
      if (currentAbsences != null) 'current_absences': currentAbsences,
      if (midtermScore != null) 'midterm_score': midtermScore,
      if (finalScore != null) 'final_score': finalScore,
      if (examScore != null) 'exam_score': examScore,
      if (targetScore != null) 'target_score': targetScore,
      if (credits != null) 'credits': credits,
      if (maxAbsences != null) 'max_absences': maxAbsences,
      if (type != null) 'type': type,
      if (format != null) 'format': format,
    });
  }

  SchedulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int?>? classId,
      Value<String>? subjectName,
      Value<String?>? room,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<String?>? note,
      Value<String?>? imagePath,
      Value<int?>? notificationMinutes,
      Value<int>? currentAbsences,
      Value<double?>? midtermScore,
      Value<double?>? finalScore,
      Value<double?>? examScore,
      Value<double>? targetScore,
      Value<int>? credits,
      Value<int>? maxAbsences,
      Value<String>? type,
      Value<String>? format}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      subjectName: subjectName ?? this.subjectName,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      notificationMinutes: notificationMinutes ?? this.notificationMinutes,
      currentAbsences: currentAbsences ?? this.currentAbsences,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      examScore: examScore ?? this.examScore,
      targetScore: targetScore ?? this.targetScore,
      credits: credits ?? this.credits,
      maxAbsences: maxAbsences ?? this.maxAbsences,
      type: type ?? this.type,
      format: format ?? this.format,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (notificationMinutes.present) {
      map['notification_minutes'] = Variable<int>(notificationMinutes.value);
    }
    if (currentAbsences.present) {
      map['current_absences'] = Variable<int>(currentAbsences.value);
    }
    if (midtermScore.present) {
      map['midterm_score'] = Variable<double>(midtermScore.value);
    }
    if (finalScore.present) {
      map['final_score'] = Variable<double>(finalScore.value);
    }
    if (examScore.present) {
      map['exam_score'] = Variable<double>(examScore.value);
    }
    if (targetScore.present) {
      map['target_score'] = Variable<double>(targetScore.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (maxAbsences.present) {
      map['max_absences'] = Variable<int>(maxAbsences.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('classId: $classId, ')
          ..write('subjectName: $subjectName, ')
          ..write('room: $room, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('note: $note, ')
          ..write('imagePath: $imagePath, ')
          ..write('notificationMinutes: $notificationMinutes, ')
          ..write('currentAbsences: $currentAbsences, ')
          ..write('midtermScore: $midtermScore, ')
          ..write('finalScore: $finalScore, ')
          ..write('examScore: $examScore, ')
          ..write('targetScore: $targetScore, ')
          ..write('credits: $credits, ')
          ..write('maxAbsences: $maxAbsences, ')
          ..write('type: $type, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, Assignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES classes (id)'));
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
      'teacher_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rewardPointsMeta =
      const VerificationMeta('rewardPoints');
  @override
  late final GeneratedColumn<int> rewardPoints = GeneratedColumn<int>(
      'reward_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        classId,
        teacherId,
        title,
        description,
        dueDate,
        rewardPoints,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(Insertable<Assignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('reward_points')) {
      context.handle(
          _rewardPointsMeta,
          rewardPoints.isAcceptableOrUnknown(
              data['reward_points']!, _rewardPointsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id'])!,
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}teacher_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      rewardPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reward_points'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class Assignment extends DataClass implements Insertable<Assignment> {
  final int id;
  final int classId;
  final int teacherId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int rewardPoints;
  final DateTime createdAt;
  const Assignment(
      {required this.id,
      required this.classId,
      required this.teacherId,
      required this.title,
      this.description,
      required this.dueDate,
      required this.rewardPoints,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['teacher_id'] = Variable<int>(teacherId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['reward_points'] = Variable<int>(rewardPoints);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      classId: Value(classId),
      teacherId: Value(teacherId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: Value(dueDate),
      rewardPoints: Value(rewardPoints),
      createdAt: Value(createdAt),
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assignment(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      teacherId: serializer.fromJson<int>(json['teacherId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      rewardPoints: serializer.fromJson<int>(json['rewardPoints']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'teacherId': serializer.toJson<int>(teacherId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'rewardPoints': serializer.toJson<int>(rewardPoints),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Assignment copyWith(
          {int? id,
          int? classId,
          int? teacherId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? dueDate,
          int? rewardPoints,
          DateTime? createdAt}) =>
      Assignment(
        id: id ?? this.id,
        classId: classId ?? this.classId,
        teacherId: teacherId ?? this.teacherId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        dueDate: dueDate ?? this.dueDate,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        createdAt: createdAt ?? this.createdAt,
      );
  Assignment copyWithCompanion(AssignmentsCompanion data) {
    return Assignment(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      rewardPoints: data.rewardPoints.present
          ? data.rewardPoints.value
          : this.rewardPoints,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assignment(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('teacherId: $teacherId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('rewardPoints: $rewardPoints, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, teacherId, title, description,
      dueDate, rewardPoints, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assignment &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.teacherId == this.teacherId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.rewardPoints == this.rewardPoints &&
          other.createdAt == this.createdAt);
}

class AssignmentsCompanion extends UpdateCompanion<Assignment> {
  final Value<int> id;
  final Value<int> classId;
  final Value<int> teacherId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> dueDate;
  final Value<int> rewardPoints;
  final Value<DateTime> createdAt;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.rewardPoints = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required int teacherId,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueDate,
    this.rewardPoints = const Value.absent(),
    required DateTime createdAt,
  })  : classId = Value(classId),
        teacherId = Value(teacherId),
        title = Value(title),
        dueDate = Value(dueDate),
        createdAt = Value(createdAt);
  static Insertable<Assignment> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<int>? teacherId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<int>? rewardPoints,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (rewardPoints != null) 'reward_points': rewardPoints,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssignmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? classId,
      Value<int>? teacherId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? dueDate,
      Value<int>? rewardPoints,
      Value<DateTime>? createdAt}) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (rewardPoints.present) {
      map['reward_points'] = Variable<int>(rewardPoints.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('teacherId: $teacherId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('rewardPoints: $rewardPoints, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StudentAssignmentsTable extends StudentAssignments
    with TableInfo<$StudentAssignmentsTable, StudentAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<int> assignmentId = GeneratedColumn<int>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES assignments (id)'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rewardClaimedMeta =
      const VerificationMeta('rewardClaimed');
  @override
  late final GeneratedColumn<bool> rewardClaimed = GeneratedColumn<bool>(
      'reward_claimed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, assignmentId, studentId, isCompleted, completedAt, rewardClaimed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_assignments';
  @override
  VerificationContext validateIntegrity(Insertable<StudentAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('reward_claimed')) {
      context.handle(
          _rewardClaimedMeta,
          rewardClaimed.isAcceptableOrUnknown(
              data['reward_claimed']!, _rewardClaimedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentAssignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assignment_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      rewardClaimed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reward_claimed'])!,
    );
  }

  @override
  $StudentAssignmentsTable createAlias(String alias) {
    return $StudentAssignmentsTable(attachedDatabase, alias);
  }
}

class StudentAssignment extends DataClass
    implements Insertable<StudentAssignment> {
  final int id;
  final int assignmentId;
  final int studentId;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool rewardClaimed;
  const StudentAssignment(
      {required this.id,
      required this.assignmentId,
      required this.studentId,
      required this.isCompleted,
      this.completedAt,
      required this.rewardClaimed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['assignment_id'] = Variable<int>(assignmentId);
    map['student_id'] = Variable<int>(studentId);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['reward_claimed'] = Variable<bool>(rewardClaimed);
    return map;
  }

  StudentAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return StudentAssignmentsCompanion(
      id: Value(id),
      assignmentId: Value(assignmentId),
      studentId: Value(studentId),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      rewardClaimed: Value(rewardClaimed),
    );
  }

  factory StudentAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentAssignment(
      id: serializer.fromJson<int>(json['id']),
      assignmentId: serializer.fromJson<int>(json['assignmentId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      rewardClaimed: serializer.fromJson<bool>(json['rewardClaimed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assignmentId': serializer.toJson<int>(assignmentId),
      'studentId': serializer.toJson<int>(studentId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'rewardClaimed': serializer.toJson<bool>(rewardClaimed),
    };
  }

  StudentAssignment copyWith(
          {int? id,
          int? assignmentId,
          int? studentId,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          bool? rewardClaimed}) =>
      StudentAssignment(
        id: id ?? this.id,
        assignmentId: assignmentId ?? this.assignmentId,
        studentId: studentId ?? this.studentId,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      );
  StudentAssignment copyWithCompanion(StudentAssignmentsCompanion data) {
    return StudentAssignment(
      id: data.id.present ? data.id.value : this.id,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      rewardClaimed: data.rewardClaimed.present
          ? data.rewardClaimed.value
          : this.rewardClaimed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentAssignment(')
          ..write('id: $id, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('studentId: $studentId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rewardClaimed: $rewardClaimed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, assignmentId, studentId, isCompleted, completedAt, rewardClaimed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentAssignment &&
          other.id == this.id &&
          other.assignmentId == this.assignmentId &&
          other.studentId == this.studentId &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.rewardClaimed == this.rewardClaimed);
}

class StudentAssignmentsCompanion extends UpdateCompanion<StudentAssignment> {
  final Value<int> id;
  final Value<int> assignmentId;
  final Value<int> studentId;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> rewardClaimed;
  const StudentAssignmentsCompanion({
    this.id = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
  });
  StudentAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int assignmentId,
    required int studentId,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
  })  : assignmentId = Value(assignmentId),
        studentId = Value(studentId);
  static Insertable<StudentAssignment> custom({
    Expression<int>? id,
    Expression<int>? assignmentId,
    Expression<int>? studentId,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? rewardClaimed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (studentId != null) 'student_id': studentId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (rewardClaimed != null) 'reward_claimed': rewardClaimed,
    });
  }

  StudentAssignmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? assignmentId,
      Value<int>? studentId,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<bool>? rewardClaimed}) {
    return StudentAssignmentsCompanion(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<int>(assignmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rewardClaimed.present) {
      map['reward_claimed'] = Variable<bool>(rewardClaimed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('studentId: $studentId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rewardClaimed: $rewardClaimed')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _actionUrlMeta =
      const VerificationMeta('actionUrl');
  @override
  late final GeneratedColumn<String> actionUrl = GeneratedColumn<String>(
      'action_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedIdMeta =
      const VerificationMeta('relatedId');
  @override
  late final GeneratedColumn<int> relatedId = GeneratedColumn<int>(
      'related_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _relatedTypeMeta =
      const VerificationMeta('relatedType');
  @override
  late final GeneratedColumn<String> relatedType = GeneratedColumn<String>(
      'related_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        type,
        title,
        message,
        isRead,
        actionUrl,
        relatedId,
        relatedType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<Notification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('action_url')) {
      context.handle(_actionUrlMeta,
          actionUrl.isAcceptableOrUnknown(data['action_url']!, _actionUrlMeta));
    }
    if (data.containsKey('related_id')) {
      context.handle(_relatedIdMeta,
          relatedId.isAcceptableOrUnknown(data['related_id']!, _relatedIdMeta));
    }
    if (data.containsKey('related_type')) {
      context.handle(
          _relatedTypeMeta,
          relatedType.isAcceptableOrUnknown(
              data['related_type']!, _relatedTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      actionUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_url']),
      relatedId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}related_id']),
      relatedType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}related_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionUrl;
  final int? relatedId;
  final String? relatedType;
  final DateTime createdAt;
  const Notification(
      {required this.id,
      required this.userId,
      required this.type,
      required this.title,
      required this.message,
      required this.isRead,
      this.actionUrl,
      this.relatedId,
      this.relatedType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || actionUrl != null) {
      map['action_url'] = Variable<String>(actionUrl);
    }
    if (!nullToAbsent || relatedId != null) {
      map['related_id'] = Variable<int>(relatedId);
    }
    if (!nullToAbsent || relatedType != null) {
      map['related_type'] = Variable<String>(relatedType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      title: Value(title),
      message: Value(message),
      isRead: Value(isRead),
      actionUrl: actionUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(actionUrl),
      relatedId: relatedId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedId),
      relatedType: relatedType == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedType),
      createdAt: Value(createdAt),
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      actionUrl: serializer.fromJson<String?>(json['actionUrl']),
      relatedId: serializer.fromJson<int?>(json['relatedId']),
      relatedType: serializer.fromJson<String?>(json['relatedType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'isRead': serializer.toJson<bool>(isRead),
      'actionUrl': serializer.toJson<String?>(actionUrl),
      'relatedId': serializer.toJson<int?>(relatedId),
      'relatedType': serializer.toJson<String?>(relatedType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notification copyWith(
          {int? id,
          int? userId,
          String? type,
          String? title,
          String? message,
          bool? isRead,
          Value<String?> actionUrl = const Value.absent(),
          Value<int?> relatedId = const Value.absent(),
          Value<String?> relatedType = const Value.absent(),
          DateTime? createdAt}) =>
      Notification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        isRead: isRead ?? this.isRead,
        actionUrl: actionUrl.present ? actionUrl.value : this.actionUrl,
        relatedId: relatedId.present ? relatedId.value : this.relatedId,
        relatedType: relatedType.present ? relatedType.value : this.relatedType,
        createdAt: createdAt ?? this.createdAt,
      );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      actionUrl: data.actionUrl.present ? data.actionUrl.value : this.actionUrl,
      relatedId: data.relatedId.present ? data.relatedId.value : this.relatedId,
      relatedType:
          data.relatedType.present ? data.relatedType.value : this.relatedType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('isRead: $isRead, ')
          ..write('actionUrl: $actionUrl, ')
          ..write('relatedId: $relatedId, ')
          ..write('relatedType: $relatedType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, type, title, message, isRead,
      actionUrl, relatedId, relatedType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.message == this.message &&
          other.isRead == this.isRead &&
          other.actionUrl == this.actionUrl &&
          other.relatedId == this.relatedId &&
          other.relatedType == this.relatedType &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> message;
  final Value<bool> isRead;
  final Value<String?> actionUrl;
  final Value<int?> relatedId;
  final Value<String?> relatedType;
  final Value<DateTime> createdAt;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.isRead = const Value.absent(),
    this.actionUrl = const Value.absent(),
    this.relatedId = const Value.absent(),
    this.relatedType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String type,
    required String title,
    required String message,
    this.isRead = const Value.absent(),
    this.actionUrl = const Value.absent(),
    this.relatedId = const Value.absent(),
    this.relatedType = const Value.absent(),
    required DateTime createdAt,
  })  : userId = Value(userId),
        type = Value(type),
        title = Value(title),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<Notification> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? message,
    Expression<bool>? isRead,
    Expression<String>? actionUrl,
    Expression<int>? relatedId,
    Expression<String>? relatedType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (isRead != null) 'is_read': isRead,
      if (actionUrl != null) 'action_url': actionUrl,
      if (relatedId != null) 'related_id': relatedId,
      if (relatedType != null) 'related_type': relatedType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? message,
      Value<bool>? isRead,
      Value<String?>? actionUrl,
      Value<int?>? relatedId,
      Value<String?>? relatedType,
      Value<DateTime>? createdAt}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (actionUrl.present) {
      map['action_url'] = Variable<String>(actionUrl.value);
    }
    if (relatedId.present) {
      map['related_id'] = Variable<int>(relatedId.value);
    }
    if (relatedType.present) {
      map['related_type'] = Variable<String>(relatedType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('isRead: $isRead, ')
          ..write('actionUrl: $actionUrl, ')
          ..write('relatedId: $relatedId, ')
          ..write('relatedType: $relatedType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubmissionsTable extends Submissions
    with TableInfo<$SubmissionsTable, Submission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<int> assignmentId = GeneratedColumn<int>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES assignments (id)'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _fileUrlMeta =
      const VerificationMeta('fileUrl');
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
      'file_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _linkUrlMeta =
      const VerificationMeta('linkUrl');
  @override
  late final GeneratedColumn<String> linkUrl = GeneratedColumn<String>(
      'link_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isLateMeta = const VerificationMeta('isLate');
  @override
  late final GeneratedColumn<bool> isLate = GeneratedColumn<bool>(
      'is_late', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<double> grade = GeneratedColumn<double>(
      'grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _maxGradeMeta =
      const VerificationMeta('maxGrade');
  @override
  late final GeneratedColumn<double> maxGrade = GeneratedColumn<double>(
      'max_grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _feedbackMeta =
      const VerificationMeta('feedback');
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
      'feedback', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gradedAtMeta =
      const VerificationMeta('gradedAt');
  @override
  late final GeneratedColumn<DateTime> gradedAt = GeneratedColumn<DateTime>(
      'graded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _gradedByMeta =
      const VerificationMeta('gradedBy');
  @override
  late final GeneratedColumn<int> gradedBy = GeneratedColumn<int>(
      'graded_by', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _previousVersionIdMeta =
      const VerificationMeta('previousVersionId');
  @override
  late final GeneratedColumn<int> previousVersionId = GeneratedColumn<int>(
      'previous_version_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES submissions (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assignmentId,
        studentId,
        fileUrl,
        fileName,
        fileSize,
        linkUrl,
        textContent,
        submittedAt,
        isLate,
        status,
        grade,
        maxGrade,
        feedback,
        gradedAt,
        gradedBy,
        version,
        previousVersionId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submissions';
  @override
  VerificationContext validateIntegrity(Insertable<Submission> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('file_url')) {
      context.handle(_fileUrlMeta,
          fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('link_url')) {
      context.handle(_linkUrlMeta,
          linkUrl.isAcceptableOrUnknown(data['link_url']!, _linkUrlMeta));
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
    }
    if (data.containsKey('is_late')) {
      context.handle(_isLateMeta,
          isLate.isAcceptableOrUnknown(data['is_late']!, _isLateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('max_grade')) {
      context.handle(_maxGradeMeta,
          maxGrade.isAcceptableOrUnknown(data['max_grade']!, _maxGradeMeta));
    }
    if (data.containsKey('feedback')) {
      context.handle(_feedbackMeta,
          feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta));
    }
    if (data.containsKey('graded_at')) {
      context.handle(_gradedAtMeta,
          gradedAt.isAcceptableOrUnknown(data['graded_at']!, _gradedAtMeta));
    }
    if (data.containsKey('graded_by')) {
      context.handle(_gradedByMeta,
          gradedBy.isAcceptableOrUnknown(data['graded_by']!, _gradedByMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('previous_version_id')) {
      context.handle(
          _previousVersionIdMeta,
          previousVersionId.isAcceptableOrUnknown(
              data['previous_version_id']!, _previousVersionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submission(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assignment_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      fileUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_url']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      linkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_url']),
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content']),
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at'])!,
      isLate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_late'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grade']),
      maxGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_grade']),
      feedback: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feedback']),
      gradedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}graded_at']),
      gradedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}graded_by']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      previousVersionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}previous_version_id']),
    );
  }

  @override
  $SubmissionsTable createAlias(String alias) {
    return $SubmissionsTable(attachedDatabase, alias);
  }
}

class Submission extends DataClass implements Insertable<Submission> {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? linkUrl;
  final String? textContent;
  final DateTime submittedAt;
  final bool isLate;
  final String status;
  final double? grade;
  final double? maxGrade;
  final String? feedback;
  final DateTime? gradedAt;
  final int? gradedBy;
  final int version;
  final int? previousVersionId;
  const Submission(
      {required this.id,
      required this.assignmentId,
      required this.studentId,
      this.fileUrl,
      this.fileName,
      this.fileSize,
      this.linkUrl,
      this.textContent,
      required this.submittedAt,
      required this.isLate,
      required this.status,
      this.grade,
      this.maxGrade,
      this.feedback,
      this.gradedAt,
      this.gradedBy,
      required this.version,
      this.previousVersionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['assignment_id'] = Variable<int>(assignmentId);
    map['student_id'] = Variable<int>(studentId);
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || linkUrl != null) {
      map['link_url'] = Variable<String>(linkUrl);
    }
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    map['is_late'] = Variable<bool>(isLate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<double>(grade);
    }
    if (!nullToAbsent || maxGrade != null) {
      map['max_grade'] = Variable<double>(maxGrade);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    if (!nullToAbsent || gradedAt != null) {
      map['graded_at'] = Variable<DateTime>(gradedAt);
    }
    if (!nullToAbsent || gradedBy != null) {
      map['graded_by'] = Variable<int>(gradedBy);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || previousVersionId != null) {
      map['previous_version_id'] = Variable<int>(previousVersionId);
    }
    return map;
  }

  SubmissionsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionsCompanion(
      id: Value(id),
      assignmentId: Value(assignmentId),
      studentId: Value(studentId),
      fileUrl: fileUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fileUrl),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      linkUrl: linkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(linkUrl),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      submittedAt: Value(submittedAt),
      isLate: Value(isLate),
      status: Value(status),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      maxGrade: maxGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(maxGrade),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      gradedAt: gradedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(gradedAt),
      gradedBy: gradedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(gradedBy),
      version: Value(version),
      previousVersionId: previousVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersionId),
    );
  }

  factory Submission.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submission(
      id: serializer.fromJson<int>(json['id']),
      assignmentId: serializer.fromJson<int>(json['assignmentId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      linkUrl: serializer.fromJson<String?>(json['linkUrl']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      isLate: serializer.fromJson<bool>(json['isLate']),
      status: serializer.fromJson<String>(json['status']),
      grade: serializer.fromJson<double?>(json['grade']),
      maxGrade: serializer.fromJson<double?>(json['maxGrade']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      gradedAt: serializer.fromJson<DateTime?>(json['gradedAt']),
      gradedBy: serializer.fromJson<int?>(json['gradedBy']),
      version: serializer.fromJson<int>(json['version']),
      previousVersionId: serializer.fromJson<int?>(json['previousVersionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assignmentId': serializer.toJson<int>(assignmentId),
      'studentId': serializer.toJson<int>(studentId),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'fileName': serializer.toJson<String?>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'linkUrl': serializer.toJson<String?>(linkUrl),
      'textContent': serializer.toJson<String?>(textContent),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'isLate': serializer.toJson<bool>(isLate),
      'status': serializer.toJson<String>(status),
      'grade': serializer.toJson<double?>(grade),
      'maxGrade': serializer.toJson<double?>(maxGrade),
      'feedback': serializer.toJson<String?>(feedback),
      'gradedAt': serializer.toJson<DateTime?>(gradedAt),
      'gradedBy': serializer.toJson<int?>(gradedBy),
      'version': serializer.toJson<int>(version),
      'previousVersionId': serializer.toJson<int?>(previousVersionId),
    };
  }

  Submission copyWith(
          {int? id,
          int? assignmentId,
          int? studentId,
          Value<String?> fileUrl = const Value.absent(),
          Value<String?> fileName = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          Value<String?> linkUrl = const Value.absent(),
          Value<String?> textContent = const Value.absent(),
          DateTime? submittedAt,
          bool? isLate,
          String? status,
          Value<double?> grade = const Value.absent(),
          Value<double?> maxGrade = const Value.absent(),
          Value<String?> feedback = const Value.absent(),
          Value<DateTime?> gradedAt = const Value.absent(),
          Value<int?> gradedBy = const Value.absent(),
          int? version,
          Value<int?> previousVersionId = const Value.absent()}) =>
      Submission(
        id: id ?? this.id,
        assignmentId: assignmentId ?? this.assignmentId,
        studentId: studentId ?? this.studentId,
        fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
        fileName: fileName.present ? fileName.value : this.fileName,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        linkUrl: linkUrl.present ? linkUrl.value : this.linkUrl,
        textContent: textContent.present ? textContent.value : this.textContent,
        submittedAt: submittedAt ?? this.submittedAt,
        isLate: isLate ?? this.isLate,
        status: status ?? this.status,
        grade: grade.present ? grade.value : this.grade,
        maxGrade: maxGrade.present ? maxGrade.value : this.maxGrade,
        feedback: feedback.present ? feedback.value : this.feedback,
        gradedAt: gradedAt.present ? gradedAt.value : this.gradedAt,
        gradedBy: gradedBy.present ? gradedBy.value : this.gradedBy,
        version: version ?? this.version,
        previousVersionId: previousVersionId.present
            ? previousVersionId.value
            : this.previousVersionId,
      );
  Submission copyWithCompanion(SubmissionsCompanion data) {
    return Submission(
      id: data.id.present ? data.id.value : this.id,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      linkUrl: data.linkUrl.present ? data.linkUrl.value : this.linkUrl,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
      isLate: data.isLate.present ? data.isLate.value : this.isLate,
      status: data.status.present ? data.status.value : this.status,
      grade: data.grade.present ? data.grade.value : this.grade,
      maxGrade: data.maxGrade.present ? data.maxGrade.value : this.maxGrade,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      gradedAt: data.gradedAt.present ? data.gradedAt.value : this.gradedAt,
      gradedBy: data.gradedBy.present ? data.gradedBy.value : this.gradedBy,
      version: data.version.present ? data.version.value : this.version,
      previousVersionId: data.previousVersionId.present
          ? data.previousVersionId.value
          : this.previousVersionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submission(')
          ..write('id: $id, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('studentId: $studentId, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('linkUrl: $linkUrl, ')
          ..write('textContent: $textContent, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('isLate: $isLate, ')
          ..write('status: $status, ')
          ..write('grade: $grade, ')
          ..write('maxGrade: $maxGrade, ')
          ..write('feedback: $feedback, ')
          ..write('gradedAt: $gradedAt, ')
          ..write('gradedBy: $gradedBy, ')
          ..write('version: $version, ')
          ..write('previousVersionId: $previousVersionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      assignmentId,
      studentId,
      fileUrl,
      fileName,
      fileSize,
      linkUrl,
      textContent,
      submittedAt,
      isLate,
      status,
      grade,
      maxGrade,
      feedback,
      gradedAt,
      gradedBy,
      version,
      previousVersionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submission &&
          other.id == this.id &&
          other.assignmentId == this.assignmentId &&
          other.studentId == this.studentId &&
          other.fileUrl == this.fileUrl &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.linkUrl == this.linkUrl &&
          other.textContent == this.textContent &&
          other.submittedAt == this.submittedAt &&
          other.isLate == this.isLate &&
          other.status == this.status &&
          other.grade == this.grade &&
          other.maxGrade == this.maxGrade &&
          other.feedback == this.feedback &&
          other.gradedAt == this.gradedAt &&
          other.gradedBy == this.gradedBy &&
          other.version == this.version &&
          other.previousVersionId == this.previousVersionId);
}

class SubmissionsCompanion extends UpdateCompanion<Submission> {
  final Value<int> id;
  final Value<int> assignmentId;
  final Value<int> studentId;
  final Value<String?> fileUrl;
  final Value<String?> fileName;
  final Value<int?> fileSize;
  final Value<String?> linkUrl;
  final Value<String?> textContent;
  final Value<DateTime> submittedAt;
  final Value<bool> isLate;
  final Value<String> status;
  final Value<double?> grade;
  final Value<double?> maxGrade;
  final Value<String?> feedback;
  final Value<DateTime?> gradedAt;
  final Value<int?> gradedBy;
  final Value<int> version;
  final Value<int?> previousVersionId;
  const SubmissionsCompanion({
    this.id = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.linkUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.isLate = const Value.absent(),
    this.status = const Value.absent(),
    this.grade = const Value.absent(),
    this.maxGrade = const Value.absent(),
    this.feedback = const Value.absent(),
    this.gradedAt = const Value.absent(),
    this.gradedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.previousVersionId = const Value.absent(),
  });
  SubmissionsCompanion.insert({
    this.id = const Value.absent(),
    required int assignmentId,
    required int studentId,
    this.fileUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.linkUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    required DateTime submittedAt,
    this.isLate = const Value.absent(),
    required String status,
    this.grade = const Value.absent(),
    this.maxGrade = const Value.absent(),
    this.feedback = const Value.absent(),
    this.gradedAt = const Value.absent(),
    this.gradedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.previousVersionId = const Value.absent(),
  })  : assignmentId = Value(assignmentId),
        studentId = Value(studentId),
        submittedAt = Value(submittedAt),
        status = Value(status);
  static Insertable<Submission> custom({
    Expression<int>? id,
    Expression<int>? assignmentId,
    Expression<int>? studentId,
    Expression<String>? fileUrl,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? linkUrl,
    Expression<String>? textContent,
    Expression<DateTime>? submittedAt,
    Expression<bool>? isLate,
    Expression<String>? status,
    Expression<double>? grade,
    Expression<double>? maxGrade,
    Expression<String>? feedback,
    Expression<DateTime>? gradedAt,
    Expression<int>? gradedBy,
    Expression<int>? version,
    Expression<int>? previousVersionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (studentId != null) 'student_id': studentId,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (linkUrl != null) 'link_url': linkUrl,
      if (textContent != null) 'text_content': textContent,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (isLate != null) 'is_late': isLate,
      if (status != null) 'status': status,
      if (grade != null) 'grade': grade,
      if (maxGrade != null) 'max_grade': maxGrade,
      if (feedback != null) 'feedback': feedback,
      if (gradedAt != null) 'graded_at': gradedAt,
      if (gradedBy != null) 'graded_by': gradedBy,
      if (version != null) 'version': version,
      if (previousVersionId != null) 'previous_version_id': previousVersionId,
    });
  }

  SubmissionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? assignmentId,
      Value<int>? studentId,
      Value<String?>? fileUrl,
      Value<String?>? fileName,
      Value<int?>? fileSize,
      Value<String?>? linkUrl,
      Value<String?>? textContent,
      Value<DateTime>? submittedAt,
      Value<bool>? isLate,
      Value<String>? status,
      Value<double?>? grade,
      Value<double?>? maxGrade,
      Value<String?>? feedback,
      Value<DateTime?>? gradedAt,
      Value<int?>? gradedBy,
      Value<int>? version,
      Value<int?>? previousVersionId}) {
    return SubmissionsCompanion(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      linkUrl: linkUrl ?? this.linkUrl,
      textContent: textContent ?? this.textContent,
      submittedAt: submittedAt ?? this.submittedAt,
      isLate: isLate ?? this.isLate,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
      gradedBy: gradedBy ?? this.gradedBy,
      version: version ?? this.version,
      previousVersionId: previousVersionId ?? this.previousVersionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<int>(assignmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (linkUrl.present) {
      map['link_url'] = Variable<String>(linkUrl.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (isLate.present) {
      map['is_late'] = Variable<bool>(isLate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (grade.present) {
      map['grade'] = Variable<double>(grade.value);
    }
    if (maxGrade.present) {
      map['max_grade'] = Variable<double>(maxGrade.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (gradedAt.present) {
      map['graded_at'] = Variable<DateTime>(gradedAt.value);
    }
    if (gradedBy.present) {
      map['graded_by'] = Variable<int>(gradedBy.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (previousVersionId.present) {
      map['previous_version_id'] = Variable<int>(previousVersionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('studentId: $studentId, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('linkUrl: $linkUrl, ')
          ..write('textContent: $textContent, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('isLate: $isLate, ')
          ..write('status: $status, ')
          ..write('grade: $grade, ')
          ..write('maxGrade: $maxGrade, ')
          ..write('feedback: $feedback, ')
          ..write('gradedAt: $gradedAt, ')
          ..write('gradedBy: $gradedBy, ')
          ..write('version: $version, ')
          ..write('previousVersionId: $previousVersionId')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES classes (id)'));
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
      'schedule_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES schedules (id)'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _markedByMeta =
      const VerificationMeta('markedBy');
  @override
  late final GeneratedColumn<int> markedBy = GeneratedColumn<int>(
      'marked_by', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _markedAtMeta =
      const VerificationMeta('markedAt');
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
      'marked_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        classId,
        scheduleId,
        studentId,
        date,
        status,
        note,
        markedBy,
        markedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(Insertable<Attendance> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('marked_by')) {
      context.handle(_markedByMeta,
          markedBy.isAcceptableOrUnknown(data['marked_by']!, _markedByMeta));
    } else if (isInserting) {
      context.missing(_markedByMeta);
    }
    if (data.containsKey('marked_at')) {
      context.handle(_markedAtMeta,
          markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta));
    } else if (isInserting) {
      context.missing(_markedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id'])!,
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_id']),
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      markedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}marked_by'])!,
      markedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}marked_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final int id;
  final int classId;
  final int? scheduleId;
  final int studentId;
  final DateTime date;
  final String status;
  final String? note;
  final int markedBy;
  final DateTime markedAt;
  final DateTime? updatedAt;
  const Attendance(
      {required this.id,
      required this.classId,
      this.scheduleId,
      required this.studentId,
      required this.date,
      required this.status,
      this.note,
      required this.markedBy,
      required this.markedAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    map['student_id'] = Variable<int>(studentId);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['marked_by'] = Variable<int>(markedBy);
    map['marked_at'] = Variable<DateTime>(markedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      classId: Value(classId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      studentId: Value(studentId),
      date: Value(date),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      markedBy: Value(markedBy),
      markedAt: Value(markedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Attendance.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      markedBy: serializer.fromJson<int>(json['markedBy']),
      markedAt: serializer.fromJson<DateTime>(json['markedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'studentId': serializer.toJson<int>(studentId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'markedBy': serializer.toJson<int>(markedBy),
      'markedAt': serializer.toJson<DateTime>(markedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Attendance copyWith(
          {int? id,
          int? classId,
          Value<int?> scheduleId = const Value.absent(),
          int? studentId,
          DateTime? date,
          String? status,
          Value<String?> note = const Value.absent(),
          int? markedBy,
          DateTime? markedAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Attendance(
        id: id ?? this.id,
        classId: classId ?? this.classId,
        scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
        studentId: studentId ?? this.studentId,
        date: date ?? this.date,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
        markedBy: markedBy ?? this.markedBy,
        markedAt: markedAt ?? this.markedAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      markedBy: data.markedBy.present ? data.markedBy.value : this.markedBy,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedAt: $markedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, scheduleId, studentId, date,
      status, note, markedBy, markedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.scheduleId == this.scheduleId &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.status == this.status &&
          other.note == this.note &&
          other.markedBy == this.markedBy &&
          other.markedAt == this.markedAt &&
          other.updatedAt == this.updatedAt);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<int> id;
  final Value<int> classId;
  final Value<int?> scheduleId;
  final Value<int> studentId;
  final Value<DateTime> date;
  final Value<String> status;
  final Value<String?> note;
  final Value<int> markedBy;
  final Value<DateTime> markedAt;
  final Value<DateTime?> updatedAt;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.markedBy = const Value.absent(),
    this.markedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AttendancesCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    this.scheduleId = const Value.absent(),
    required int studentId,
    required DateTime date,
    required String status,
    this.note = const Value.absent(),
    required int markedBy,
    required DateTime markedAt,
    this.updatedAt = const Value.absent(),
  })  : classId = Value(classId),
        studentId = Value(studentId),
        date = Value(date),
        status = Value(status),
        markedBy = Value(markedBy),
        markedAt = Value(markedAt);
  static Insertable<Attendance> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<int>? scheduleId,
    Expression<int>? studentId,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? note,
    Expression<int>? markedBy,
    Expression<DateTime>? markedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (markedBy != null) 'marked_by': markedBy,
      if (markedAt != null) 'marked_at': markedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AttendancesCompanion copyWith(
      {Value<int>? id,
      Value<int>? classId,
      Value<int?>? scheduleId,
      Value<int>? studentId,
      Value<DateTime>? date,
      Value<String>? status,
      Value<String?>? note,
      Value<int>? markedBy,
      Value<DateTime>? markedAt,
      Value<DateTime?>? updatedAt}) {
    return AttendancesCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      scheduleId: scheduleId ?? this.scheduleId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (markedBy.present) {
      map['marked_by'] = Variable<int>(markedBy.value);
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedAt: $markedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, title, description, dueDate, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  const Task(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.dueDate,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: Value(dueDate),
      isCompleted: Value(isCompleted),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Task copyWith(
          {int? id,
          int? userId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? dueDate,
          bool? isCompleted}) =>
      Task(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, description, dueDate, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.isCompleted == this.isCompleted);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> dueDate;
  final Value<bool> isCompleted;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueDate,
    this.isCompleted = const Value.absent(),
  })  : userId = Value(userId),
        title = Value(title),
        dueDate = Value(dueDate);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? dueDate,
      Value<bool>? isCompleted}) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $StudentProfilesTable studentProfiles =
      $StudentProfilesTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $StudentAssignmentsTable studentAssignments =
      $StudentAssignmentsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $SubmissionsTable submissions = $SubmissionsTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        studentProfiles,
        subjects,
        classes,
        schedules,
        assignments,
        studentAssignments,
        notifications,
        submissions,
        attendances,
        tasks
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String email,
  required String passwordHash,
  Value<String?> fullName,
  Value<String?> resetToken,
  Value<int> role,
  Value<DateTime?> resetTokenExpiry,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> email,
  Value<String> passwordHash,
  Value<String?> fullName,
  Value<String?> resetToken,
  Value<int> role,
  Value<DateTime?> resetTokenExpiry,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudentProfilesTable, List<StudentProfile>>
      _studentProfilesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.studentProfiles,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.studentProfiles.userId));

  $$StudentProfilesTableProcessedTableManager get studentProfilesRefs {
    final manager =
        $$StudentProfilesTableTableManager($_db, $_db.studentProfiles)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_studentProfilesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubjectsTable, List<Subject>> _subjectsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subjects,
          aliasName: $_aliasNameGenerator(db.users.id, db.subjects.teacherId));

  $$SubjectsTableProcessedTableManager get subjectsRefs {
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.teacherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subjectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClassesTable, List<ClassesData>>
      _classesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.classes,
          aliasName: $_aliasNameGenerator(db.users.id, db.classes.teacherId));

  $$ClassesTableProcessedTableManager get classesRefs {
    final manager = $$ClassesTableTableManager($_db, $_db.classes)
        .filter((f) => f.teacherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_classesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
      _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.schedules,
          aliasName: $_aliasNameGenerator(db.users.id, db.schedules.userId));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssignmentsTable, List<Assignment>>
      _assignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignments,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.assignments.teacherId));

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.teacherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StudentAssignmentsTable, List<StudentAssignment>>
      _studentAssignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.studentAssignments,
              aliasName: $_aliasNameGenerator(
                  db.users.id, db.studentAssignments.studentId));

  $$StudentAssignmentsTableProcessedTableManager get studentAssignmentsRefs {
    final manager =
        $$StudentAssignmentsTableTableManager($_db, $_db.studentAssignments)
            .filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_studentAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotificationsTable, List<Notification>>
      _notificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.notifications,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.notifications.userId));

  $$NotificationsTableProcessedTableManager get notificationsRefs {
    final manager = $$NotificationsTableTableManager($_db, $_db.notifications)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubmissionsTable, List<Submission>>
      _submissionsStudentTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.submissions,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.submissions.studentId));

  $$SubmissionsTableProcessedTableManager get submissionsStudent {
    final manager = $$SubmissionsTableTableManager($_db, $_db.submissions)
        .filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_submissionsStudentTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubmissionsTable, List<Submission>>
      _submissionsGraderTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.submissions,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.submissions.gradedBy));

  $$SubmissionsTableProcessedTableManager get submissionsGrader {
    final manager = $$SubmissionsTableTableManager($_db, $_db.submissions)
        .filter((f) => f.gradedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_submissionsGraderTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
      _attendancesStudentTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attendances,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.attendances.studentId));

  $$AttendancesTableProcessedTableManager get attendancesStudent {
    final manager = $$AttendancesTableTableManager($_db, $_db.attendances)
        .filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesStudentTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
      _attendancesMarkerTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attendances,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.attendances.markedBy));

  $$AttendancesTableProcessedTableManager get attendancesMarker {
    final manager = $$AttendancesTableTableManager($_db, $_db.attendances)
        .filter((f) => f.markedBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesMarkerTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.users.id, db.tasks.userId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resetToken => $composableBuilder(
      column: $table.resetToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resetTokenExpiry => $composableBuilder(
      column: $table.resetTokenExpiry,
      builder: (column) => ColumnFilters(column));

  Expression<bool> studentProfilesRefs(
      Expression<bool> Function($$StudentProfilesTableFilterComposer f) f) {
    final $$StudentProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studentProfiles,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentProfilesTableFilterComposer(
              $db: $db,
              $table: $db.studentProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subjectsRefs(
      Expression<bool> Function($$SubjectsTableFilterComposer f) f) {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> classesRefs(
      Expression<bool> Function($$ClassesTableFilterComposer f) f) {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableFilterComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> assignmentsRefs(
      Expression<bool> Function($$AssignmentsTableFilterComposer f) f) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> studentAssignmentsRefs(
      Expression<bool> Function($$StudentAssignmentsTableFilterComposer f) f) {
    final $$StudentAssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studentAssignments,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentAssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.studentAssignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notificationsRefs(
      Expression<bool> Function($$NotificationsTableFilterComposer f) f) {
    final $$NotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notifications,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationsTableFilterComposer(
              $db: $db,
              $table: $db.notifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> submissionsStudent(
      Expression<bool> Function($$SubmissionsTableFilterComposer f) f) {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableFilterComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> submissionsGrader(
      Expression<bool> Function($$SubmissionsTableFilterComposer f) f) {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.gradedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableFilterComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attendancesStudent(
      Expression<bool> Function($$AttendancesTableFilterComposer f) f) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableFilterComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attendancesMarker(
      Expression<bool> Function($$AttendancesTableFilterComposer f) f) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.markedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableFilterComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resetToken => $composableBuilder(
      column: $table.resetToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resetTokenExpiry => $composableBuilder(
      column: $table.resetTokenExpiry,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get resetToken => $composableBuilder(
      column: $table.resetToken, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get resetTokenExpiry => $composableBuilder(
      column: $table.resetTokenExpiry, builder: (column) => column);

  Expression<T> studentProfilesRefs<T extends Object>(
      Expression<T> Function($$StudentProfilesTableAnnotationComposer a) f) {
    final $$StudentProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studentProfiles,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.studentProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subjectsRefs<T extends Object>(
      Expression<T> Function($$SubjectsTableAnnotationComposer a) f) {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> classesRefs<T extends Object>(
      Expression<T> Function($$ClassesTableAnnotationComposer a) f) {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> assignmentsRefs<T extends Object>(
      Expression<T> Function($$AssignmentsTableAnnotationComposer a) f) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.teacherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> studentAssignmentsRefs<T extends Object>(
      Expression<T> Function($$StudentAssignmentsTableAnnotationComposer a) f) {
    final $$StudentAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.studentAssignments,
            getReferencedColumn: (t) => t.studentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StudentAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.studentAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> notificationsRefs<T extends Object>(
      Expression<T> Function($$NotificationsTableAnnotationComposer a) f) {
    final $$NotificationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notifications,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationsTableAnnotationComposer(
              $db: $db,
              $table: $db.notifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> submissionsStudent<T extends Object>(
      Expression<T> Function($$SubmissionsTableAnnotationComposer a) f) {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableAnnotationComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> submissionsGrader<T extends Object>(
      Expression<T> Function($$SubmissionsTableAnnotationComposer a) f) {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.gradedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableAnnotationComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attendancesStudent<T extends Object>(
      Expression<T> Function($$AttendancesTableAnnotationComposer a) f) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableAnnotationComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attendancesMarker<T extends Object>(
      Expression<T> Function($$AttendancesTableAnnotationComposer a) f) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.markedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableAnnotationComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool studentProfilesRefs,
        bool subjectsRefs,
        bool classesRefs,
        bool schedulesRefs,
        bool assignmentsRefs,
        bool studentAssignmentsRefs,
        bool notificationsRefs,
        bool submissionsStudent,
        bool submissionsGrader,
        bool attendancesStudent,
        bool attendancesMarker,
        bool tasksRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String?> fullName = const Value.absent(),
            Value<String?> resetToken = const Value.absent(),
            Value<int> role = const Value.absent(),
            Value<DateTime?> resetTokenExpiry = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            passwordHash: passwordHash,
            fullName: fullName,
            resetToken: resetToken,
            role: role,
            resetTokenExpiry: resetTokenExpiry,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String email,
            required String passwordHash,
            Value<String?> fullName = const Value.absent(),
            Value<String?> resetToken = const Value.absent(),
            Value<int> role = const Value.absent(),
            Value<DateTime?> resetTokenExpiry = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            passwordHash: passwordHash,
            fullName: fullName,
            resetToken: resetToken,
            role: role,
            resetTokenExpiry: resetTokenExpiry,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {studentProfilesRefs = false,
              subjectsRefs = false,
              classesRefs = false,
              schedulesRefs = false,
              assignmentsRefs = false,
              studentAssignmentsRefs = false,
              notificationsRefs = false,
              submissionsStudent = false,
              submissionsGrader = false,
              attendancesStudent = false,
              attendancesMarker = false,
              tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studentProfilesRefs) db.studentProfiles,
                if (subjectsRefs) db.subjects,
                if (classesRefs) db.classes,
                if (schedulesRefs) db.schedules,
                if (assignmentsRefs) db.assignments,
                if (studentAssignmentsRefs) db.studentAssignments,
                if (notificationsRefs) db.notifications,
                if (submissionsStudent) db.submissions,
                if (submissionsGrader) db.submissions,
                if (attendancesStudent) db.attendances,
                if (attendancesMarker) db.attendances,
                if (tasksRefs) db.tasks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studentProfilesRefs)
                    await $_getPrefetchedData<User, $UsersTable,
                            StudentProfile>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._studentProfilesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .studentProfilesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (subjectsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Subject>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._subjectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).subjectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.teacherId == item.id),
                        typedResults: items),
                  if (classesRefs)
                    await $_getPrefetchedData<User, $UsersTable, ClassesData>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._classesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).classesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.teacherId == item.id),
                        typedResults: items),
                  if (schedulesRefs)
                    await $_getPrefetchedData<User, $UsersTable, Schedule>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).schedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (assignmentsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Assignment>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._assignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .assignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.teacherId == item.id),
                        typedResults: items),
                  if (studentAssignmentsRefs)
                    await $_getPrefetchedData<User, $UsersTable,
                            StudentAssignment>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._studentAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .studentAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items),
                  if (notificationsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Notification>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._notificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .notificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (submissionsStudent)
                    await $_getPrefetchedData<User, $UsersTable, Submission>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._submissionsStudentTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .submissionsStudent,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items),
                  if (submissionsGrader)
                    await $_getPrefetchedData<User, $UsersTable, Submission>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._submissionsGraderTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .submissionsGrader,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gradedBy == item.id),
                        typedResults: items),
                  if (attendancesStudent)
                    await $_getPrefetchedData<User, $UsersTable, Attendance>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._attendancesStudentTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .attendancesStudent,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items),
                  if (attendancesMarker)
                    await $_getPrefetchedData<User, $UsersTable, Attendance>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._attendancesMarkerTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .attendancesMarker,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.markedBy == item.id),
                        typedResults: items),
                  if (tasksRefs)
                    await $_getPrefetchedData<User, $UsersTable, Task>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool studentProfilesRefs,
        bool subjectsRefs,
        bool classesRefs,
        bool schedulesRefs,
        bool assignmentsRefs,
        bool studentAssignmentsRefs,
        bool notificationsRefs,
        bool submissionsStudent,
        bool submissionsGrader,
        bool attendancesStudent,
        bool attendancesMarker,
        bool tasksRefs})>;
typedef $$StudentProfilesTableCreateCompanionBuilder = StudentProfilesCompanion
    Function({
  Value<int> id,
  required int userId,
  required String fullName,
  Value<String?> studentId,
  Value<String?> major,
  Value<String?> avatarUrl,
});
typedef $$StudentProfilesTableUpdateCompanionBuilder = StudentProfilesCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> fullName,
  Value<String?> studentId,
  Value<String?> major,
  Value<String?> avatarUrl,
});

final class $$StudentProfilesTableReferences extends BaseReferences<
    _$AppDatabase, $StudentProfilesTable, StudentProfile> {
  $$StudentProfilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.studentProfiles.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StudentProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $StudentProfilesTable> {
  $$StudentProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get major => $composableBuilder(
      column: $table.major, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentProfilesTable> {
  $$StudentProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get major => $composableBuilder(
      column: $table.major, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentProfilesTable> {
  $$StudentProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get major =>
      $composableBuilder(column: $table.major, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentProfilesTable,
    StudentProfile,
    $$StudentProfilesTableFilterComposer,
    $$StudentProfilesTableOrderingComposer,
    $$StudentProfilesTableAnnotationComposer,
    $$StudentProfilesTableCreateCompanionBuilder,
    $$StudentProfilesTableUpdateCompanionBuilder,
    (StudentProfile, $$StudentProfilesTableReferences),
    StudentProfile,
    PrefetchHooks Function({bool userId})> {
  $$StudentProfilesTableTableManager(
      _$AppDatabase db, $StudentProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> studentId = const Value.absent(),
            Value<String?> major = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
          }) =>
              StudentProfilesCompanion(
            id: id,
            userId: userId,
            fullName: fullName,
            studentId: studentId,
            major: major,
            avatarUrl: avatarUrl,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String fullName,
            Value<String?> studentId = const Value.absent(),
            Value<String?> major = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
          }) =>
              StudentProfilesCompanion.insert(
            id: id,
            userId: userId,
            fullName: fullName,
            studentId: studentId,
            major: major,
            avatarUrl: avatarUrl,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StudentProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$StudentProfilesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$StudentProfilesTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StudentProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentProfilesTable,
    StudentProfile,
    $$StudentProfilesTableFilterComposer,
    $$StudentProfilesTableOrderingComposer,
    $$StudentProfilesTableAnnotationComposer,
    $$StudentProfilesTableCreateCompanionBuilder,
    $$StudentProfilesTableUpdateCompanionBuilder,
    (StudentProfile, $$StudentProfilesTableReferences),
    StudentProfile,
    PrefetchHooks Function({bool userId})>;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required int teacherId,
  required String name,
  Value<String?> code,
  Value<int> credits,
  Value<bool> isDeleted,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<int> teacherId,
  Value<String> name,
  Value<String?> code,
  Value<int> credits,
  Value<bool> isDeleted,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _teacherIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.subjects.teacherId, db.users.id));

  $$UsersTableProcessedTableManager get teacherId {
    final $_column = $_itemColumn<int>('teacher_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClassesTable, List<ClassesData>>
      _classesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.classes,
              aliasName:
                  $_aliasNameGenerator(db.subjects.id, db.classes.subjectId));

  $$ClassesTableProcessedTableManager get classesRefs {
    final manager = $$ClassesTableTableManager($_db, $_db.classes)
        .filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_classesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get teacherId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> classesRefs(
      Expression<bool> Function($$ClassesTableFilterComposer f) f) {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableFilterComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get teacherId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$UsersTableAnnotationComposer get teacherId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> classesRefs<T extends Object>(
      Expression<T> Function($$ClassesTableAnnotationComposer a) f) {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool teacherId, bool classesRefs})> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> teacherId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            teacherId: teacherId,
            name: name,
            code: code,
            credits: credits,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int teacherId,
            required String name,
            Value<String?> code = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            teacherId: teacherId,
            name: name,
            code: code,
            credits: credits,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({teacherId = false, classesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (classesRefs) db.classes],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (teacherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.teacherId,
                    referencedTable:
                        $$SubjectsTableReferences._teacherIdTable(db),
                    referencedColumn:
                        $$SubjectsTableReferences._teacherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (classesRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable,
                            ClassesData>(
                        currentTable: table,
                        referencedTable:
                            $$SubjectsTableReferences._classesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubjectsTableReferences(db, table, p0)
                                .classesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subjectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool teacherId, bool classesRefs})>;
typedef $$ClassesTableCreateCompanionBuilder = ClassesCompanion Function({
  Value<int> id,
  Value<int?> subjectId,
  required String className,
  required String classCode,
  required int teacherId,
  required DateTime createdAt,
});
typedef $$ClassesTableUpdateCompanionBuilder = ClassesCompanion Function({
  Value<int> id,
  Value<int?> subjectId,
  Value<String> className,
  Value<String> classCode,
  Value<int> teacherId,
  Value<DateTime> createdAt,
});

final class $$ClassesTableReferences
    extends BaseReferences<_$AppDatabase, $ClassesTable, ClassesData> {
  $$ClassesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) => db.subjects
      .createAlias($_aliasNameGenerator(db.classes.subjectId, db.subjects.id));

  $$SubjectsTableProcessedTableManager? get subjectId {
    final $_column = $_itemColumn<int>('subject_id');
    if ($_column == null) return null;
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _teacherIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.classes.teacherId, db.users.id));

  $$UsersTableProcessedTableManager get teacherId {
    final $_column = $_itemColumn<int>('teacher_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
      _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.schedules,
          aliasName: $_aliasNameGenerator(db.classes.id, db.schedules.classId));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssignmentsTable, List<Assignment>>
      _assignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignments,
              aliasName:
                  $_aliasNameGenerator(db.classes.id, db.assignments.classId));

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
      _attendancesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attendances,
              aliasName:
                  $_aliasNameGenerator(db.classes.id, db.attendances.classId));

  $$AttendancesTableProcessedTableManager get attendancesRefs {
    final manager = $$AttendancesTableTableManager($_db, $_db.attendances)
        .filter((f) => f.classId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get classCode => $composableBuilder(
      column: $table.classCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get teacherId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> assignmentsRefs(
      Expression<bool> Function($$AssignmentsTableFilterComposer f) f) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attendancesRefs(
      Expression<bool> Function($$AttendancesTableFilterComposer f) f) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableFilterComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get classCode => $composableBuilder(
      column: $table.classCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableOrderingComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get teacherId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get teacherId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> assignmentsRefs<T extends Object>(
      Expression<T> Function($$AssignmentsTableAnnotationComposer a) f) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attendancesRefs<T extends Object>(
      Expression<T> Function($$AttendancesTableAnnotationComposer a) f) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.classId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableAnnotationComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClassesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassesTable,
    ClassesData,
    $$ClassesTableFilterComposer,
    $$ClassesTableOrderingComposer,
    $$ClassesTableAnnotationComposer,
    $$ClassesTableCreateCompanionBuilder,
    $$ClassesTableUpdateCompanionBuilder,
    (ClassesData, $$ClassesTableReferences),
    ClassesData,
    PrefetchHooks Function(
        {bool subjectId,
        bool teacherId,
        bool schedulesRefs,
        bool assignmentsRefs,
        bool attendancesRefs})> {
  $$ClassesTableTableManager(_$AppDatabase db, $ClassesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> subjectId = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<String> classCode = const Value.absent(),
            Value<int> teacherId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClassesCompanion(
            id: id,
            subjectId: subjectId,
            className: className,
            classCode: classCode,
            teacherId: teacherId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> subjectId = const Value.absent(),
            required String className,
            required String classCode,
            required int teacherId,
            required DateTime createdAt,
          }) =>
              ClassesCompanion.insert(
            id: id,
            subjectId: subjectId,
            className: className,
            classCode: classCode,
            teacherId: teacherId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClassesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {subjectId = false,
              teacherId = false,
              schedulesRefs = false,
              assignmentsRefs = false,
              attendancesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (schedulesRefs) db.schedules,
                if (assignmentsRefs) db.assignments,
                if (attendancesRefs) db.attendances
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (subjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subjectId,
                    referencedTable:
                        $$ClassesTableReferences._subjectIdTable(db),
                    referencedColumn:
                        $$ClassesTableReferences._subjectIdTable(db).id,
                  ) as T;
                }
                if (teacherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.teacherId,
                    referencedTable:
                        $$ClassesTableReferences._teacherIdTable(db),
                    referencedColumn:
                        $$ClassesTableReferences._teacherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (schedulesRefs)
                    await $_getPrefetchedData<ClassesData, $ClassesTable,
                            Schedule>(
                        currentTable: table,
                        referencedTable:
                            $$ClassesTableReferences._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClassesTableReferences(db, table, p0)
                                .schedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.classId == item.id),
                        typedResults: items),
                  if (assignmentsRefs)
                    await $_getPrefetchedData<ClassesData, $ClassesTable,
                            Assignment>(
                        currentTable: table,
                        referencedTable:
                            $$ClassesTableReferences._assignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClassesTableReferences(db, table, p0)
                                .assignmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.classId == item.id),
                        typedResults: items),
                  if (attendancesRefs)
                    await $_getPrefetchedData<ClassesData, $ClassesTable,
                            Attendance>(
                        currentTable: table,
                        referencedTable:
                            $$ClassesTableReferences._attendancesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClassesTableReferences(db, table, p0)
                                .attendancesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.classId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClassesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassesTable,
    ClassesData,
    $$ClassesTableFilterComposer,
    $$ClassesTableOrderingComposer,
    $$ClassesTableAnnotationComposer,
    $$ClassesTableCreateCompanionBuilder,
    $$ClassesTableUpdateCompanionBuilder,
    (ClassesData, $$ClassesTableReferences),
    ClassesData,
    PrefetchHooks Function(
        {bool subjectId,
        bool teacherId,
        bool schedulesRefs,
        bool assignmentsRefs,
        bool attendancesRefs})>;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required int userId,
  Value<int?> classId,
  required String subjectName,
  Value<String?> room,
  required DateTime startTime,
  required DateTime endTime,
  Value<String?> note,
  Value<String?> imagePath,
  Value<int?> notificationMinutes,
  Value<int> currentAbsences,
  Value<double?> midtermScore,
  Value<double?> finalScore,
  Value<double?> examScore,
  Value<double> targetScore,
  Value<int> credits,
  Value<int> maxAbsences,
  Value<String> type,
  Value<String> format,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<int?> classId,
  Value<String> subjectName,
  Value<String?> room,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<String?> note,
  Value<String?> imagePath,
  Value<int?> notificationMinutes,
  Value<int> currentAbsences,
  Value<double?> midtermScore,
  Value<double?> finalScore,
  Value<double?> examScore,
  Value<double> targetScore,
  Value<int> credits,
  Value<int> maxAbsences,
  Value<String> type,
  Value<String> format,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.schedules.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClassesTable _classIdTable(_$AppDatabase db) => db.classes
      .createAlias($_aliasNameGenerator(db.schedules.classId, db.classes.id));

  $$ClassesTableProcessedTableManager? get classId {
    final $_column = $_itemColumn<int>('class_id');
    if ($_column == null) return null;
    final manager = $$ClassesTableTableManager($_db, $_db.classes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
      _attendancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.attendances,
          aliasName:
              $_aliasNameGenerator(db.schedules.id, db.attendances.scheduleId));

  $$AttendancesTableProcessedTableManager get attendancesRefs {
    final manager = $$AttendancesTableTableManager($_db, $_db.attendances)
        .filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationMinutes => $composableBuilder(
      column: $table.notificationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentAbsences => $composableBuilder(
      column: $table.currentAbsences,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get midtermScore => $composableBuilder(
      column: $table.midtermScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get examScore => $composableBuilder(
      column: $table.examScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableFilterComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> attendancesRefs(
      Expression<bool> Function($$AttendancesTableFilterComposer f) f) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.scheduleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableFilterComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationMinutes => $composableBuilder(
      column: $table.notificationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentAbsences => $composableBuilder(
      column: $table.currentAbsences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get midtermScore => $composableBuilder(
      column: $table.midtermScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get examScore => $composableBuilder(
      column: $table.examScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableOrderingComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get notificationMinutes => $composableBuilder(
      column: $table.notificationMinutes, builder: (column) => column);

  GeneratedColumn<int> get currentAbsences => $composableBuilder(
      column: $table.currentAbsences, builder: (column) => column);

  GeneratedColumn<double> get midtermScore => $composableBuilder(
      column: $table.midtermScore, builder: (column) => column);

  GeneratedColumn<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => column);

  GeneratedColumn<double> get examScore =>
      $composableBuilder(column: $table.examScore, builder: (column) => column);

  GeneratedColumn<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => column);

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> attendancesRefs<T extends Object>(
      Expression<T> Function($$AttendancesTableAnnotationComposer a) f) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendances,
        getReferencedColumn: (t) => t.scheduleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendancesTableAnnotationComposer(
              $db: $db,
              $table: $db.attendances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool userId, bool classId, bool attendancesRefs})> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int?> classId = const Value.absent(),
            Value<String> subjectName = const Value.absent(),
            Value<String?> room = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int?> notificationMinutes = const Value.absent(),
            Value<int> currentAbsences = const Value.absent(),
            Value<double?> midtermScore = const Value.absent(),
            Value<double?> finalScore = const Value.absent(),
            Value<double?> examScore = const Value.absent(),
            Value<double> targetScore = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<int> maxAbsences = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> format = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            userId: userId,
            classId: classId,
            subjectName: subjectName,
            room: room,
            startTime: startTime,
            endTime: endTime,
            note: note,
            imagePath: imagePath,
            notificationMinutes: notificationMinutes,
            currentAbsences: currentAbsences,
            midtermScore: midtermScore,
            finalScore: finalScore,
            examScore: examScore,
            targetScore: targetScore,
            credits: credits,
            maxAbsences: maxAbsences,
            type: type,
            format: format,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            Value<int?> classId = const Value.absent(),
            required String subjectName,
            Value<String?> room = const Value.absent(),
            required DateTime startTime,
            required DateTime endTime,
            Value<String?> note = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int?> notificationMinutes = const Value.absent(),
            Value<int> currentAbsences = const Value.absent(),
            Value<double?> midtermScore = const Value.absent(),
            Value<double?> finalScore = const Value.absent(),
            Value<double?> examScore = const Value.absent(),
            Value<double> targetScore = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<int> maxAbsences = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> format = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            userId: userId,
            classId: classId,
            subjectName: subjectName,
            room: room,
            startTime: startTime,
            endTime: endTime,
            note: note,
            imagePath: imagePath,
            notificationMinutes: notificationMinutes,
            currentAbsences: currentAbsences,
            midtermScore: midtermScore,
            finalScore: finalScore,
            examScore: examScore,
            targetScore: targetScore,
            credits: credits,
            maxAbsences: maxAbsences,
            type: type,
            format: format,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false, classId = false, attendancesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attendancesRefs) db.attendances],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$SchedulesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (classId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.classId,
                    referencedTable:
                        $$SchedulesTableReferences._classIdTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._classIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendancesRefs)
                    await $_getPrefetchedData<Schedule, $SchedulesTable,
                            Attendance>(
                        currentTable: table,
                        referencedTable: $$SchedulesTableReferences
                            ._attendancesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SchedulesTableReferences(db, table, p0)
                                .attendancesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool userId, bool classId, bool attendancesRefs})>;
typedef $$AssignmentsTableCreateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<int> id,
  required int classId,
  required int teacherId,
  required String title,
  Value<String?> description,
  required DateTime dueDate,
  Value<int> rewardPoints,
  required DateTime createdAt,
});
typedef $$AssignmentsTableUpdateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<int> id,
  Value<int> classId,
  Value<int> teacherId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> dueDate,
  Value<int> rewardPoints,
  Value<DateTime> createdAt,
});

final class $$AssignmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment> {
  $$AssignmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) => db.classes
      .createAlias($_aliasNameGenerator(db.assignments.classId, db.classes.id));

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager($_db, $_db.classes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _teacherIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.assignments.teacherId, db.users.id));

  $$UsersTableProcessedTableManager get teacherId {
    final $_column = $_itemColumn<int>('teacher_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$StudentAssignmentsTable, List<StudentAssignment>>
      _studentAssignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.studentAssignments,
              aliasName: $_aliasNameGenerator(
                  db.assignments.id, db.studentAssignments.assignmentId));

  $$StudentAssignmentsTableProcessedTableManager get studentAssignmentsRefs {
    final manager = $$StudentAssignmentsTableTableManager(
            $_db, $_db.studentAssignments)
        .filter((f) => f.assignmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_studentAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubmissionsTable, List<Submission>>
      _submissionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.submissions,
              aliasName: $_aliasNameGenerator(
                  db.assignments.id, db.submissions.assignmentId));

  $$SubmissionsTableProcessedTableManager get submissionsRefs {
    final manager = $$SubmissionsTableTableManager($_db, $_db.submissions)
        .filter((f) => f.assignmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_submissionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rewardPoints => $composableBuilder(
      column: $table.rewardPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableFilterComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get teacherId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> studentAssignmentsRefs(
      Expression<bool> Function($$StudentAssignmentsTableFilterComposer f) f) {
    final $$StudentAssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studentAssignments,
        getReferencedColumn: (t) => t.assignmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentAssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.studentAssignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> submissionsRefs(
      Expression<bool> Function($$SubmissionsTableFilterComposer f) f) {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.assignmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableFilterComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rewardPoints => $composableBuilder(
      column: $table.rewardPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableOrderingComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get teacherId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get rewardPoints => $composableBuilder(
      column: $table.rewardPoints, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get teacherId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.teacherId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> studentAssignmentsRefs<T extends Object>(
      Expression<T> Function($$StudentAssignmentsTableAnnotationComposer a) f) {
    final $$StudentAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.studentAssignments,
            getReferencedColumn: (t) => t.assignmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StudentAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.studentAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> submissionsRefs<T extends Object>(
      Expression<T> Function($$SubmissionsTableAnnotationComposer a) f) {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.assignmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableAnnotationComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, $$AssignmentsTableReferences),
    Assignment,
    PrefetchHooks Function(
        {bool classId,
        bool teacherId,
        bool studentAssignmentsRefs,
        bool submissionsRefs})> {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> classId = const Value.absent(),
            Value<int> teacherId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<int> rewardPoints = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AssignmentsCompanion(
            id: id,
            classId: classId,
            teacherId: teacherId,
            title: title,
            description: description,
            dueDate: dueDate,
            rewardPoints: rewardPoints,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int classId,
            required int teacherId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime dueDate,
            Value<int> rewardPoints = const Value.absent(),
            required DateTime createdAt,
          }) =>
              AssignmentsCompanion.insert(
            id: id,
            classId: classId,
            teacherId: teacherId,
            title: title,
            description: description,
            dueDate: dueDate,
            rewardPoints: rewardPoints,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {classId = false,
              teacherId = false,
              studentAssignmentsRefs = false,
              submissionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studentAssignmentsRefs) db.studentAssignments,
                if (submissionsRefs) db.submissions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (classId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.classId,
                    referencedTable:
                        $$AssignmentsTableReferences._classIdTable(db),
                    referencedColumn:
                        $$AssignmentsTableReferences._classIdTable(db).id,
                  ) as T;
                }
                if (teacherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.teacherId,
                    referencedTable:
                        $$AssignmentsTableReferences._teacherIdTable(db),
                    referencedColumn:
                        $$AssignmentsTableReferences._teacherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studentAssignmentsRefs)
                    await $_getPrefetchedData<Assignment, $AssignmentsTable,
                            StudentAssignment>(
                        currentTable: table,
                        referencedTable: $$AssignmentsTableReferences
                            ._studentAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AssignmentsTableReferences(db, table, p0)
                                .studentAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.assignmentId == item.id),
                        typedResults: items),
                  if (submissionsRefs)
                    await $_getPrefetchedData<Assignment, $AssignmentsTable,
                            Submission>(
                        currentTable: table,
                        referencedTable: $$AssignmentsTableReferences
                            ._submissionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AssignmentsTableReferences(db, table, p0)
                                .submissionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.assignmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, $$AssignmentsTableReferences),
    Assignment,
    PrefetchHooks Function(
        {bool classId,
        bool teacherId,
        bool studentAssignmentsRefs,
        bool submissionsRefs})>;
typedef $$StudentAssignmentsTableCreateCompanionBuilder
    = StudentAssignmentsCompanion Function({
  Value<int> id,
  required int assignmentId,
  required int studentId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> rewardClaimed,
});
typedef $$StudentAssignmentsTableUpdateCompanionBuilder
    = StudentAssignmentsCompanion Function({
  Value<int> id,
  Value<int> assignmentId,
  Value<int> studentId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> rewardClaimed,
});

final class $$StudentAssignmentsTableReferences extends BaseReferences<
    _$AppDatabase, $StudentAssignmentsTable, StudentAssignment> {
  $$StudentAssignmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AssignmentsTable _assignmentIdTable(_$AppDatabase db) =>
      db.assignments.createAlias($_aliasNameGenerator(
          db.studentAssignments.assignmentId, db.assignments.id));

  $$AssignmentsTableProcessedTableManager get assignmentId {
    final $_column = $_itemColumn<int>('assignment_id')!;

    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assignmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _studentIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.studentAssignments.studentId, db.users.id));

  $$UsersTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StudentAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rewardClaimed => $composableBuilder(
      column: $table.rewardClaimed, builder: (column) => ColumnFilters(column));

  $$AssignmentsTableFilterComposer get assignmentId {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get studentId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rewardClaimed => $composableBuilder(
      column: $table.rewardClaimed,
      builder: (column) => ColumnOrderings(column));

  $$AssignmentsTableOrderingComposer get assignmentId {
    final $$AssignmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableOrderingComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get studentId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get rewardClaimed => $composableBuilder(
      column: $table.rewardClaimed, builder: (column) => column);

  $$AssignmentsTableAnnotationComposer get assignmentId {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get studentId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentAssignmentsTable,
    StudentAssignment,
    $$StudentAssignmentsTableFilterComposer,
    $$StudentAssignmentsTableOrderingComposer,
    $$StudentAssignmentsTableAnnotationComposer,
    $$StudentAssignmentsTableCreateCompanionBuilder,
    $$StudentAssignmentsTableUpdateCompanionBuilder,
    (StudentAssignment, $$StudentAssignmentsTableReferences),
    StudentAssignment,
    PrefetchHooks Function({bool assignmentId, bool studentId})> {
  $$StudentAssignmentsTableTableManager(
      _$AppDatabase db, $StudentAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> assignmentId = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> rewardClaimed = const Value.absent(),
          }) =>
              StudentAssignmentsCompanion(
            id: id,
            assignmentId: assignmentId,
            studentId: studentId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            rewardClaimed: rewardClaimed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int assignmentId,
            required int studentId,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> rewardClaimed = const Value.absent(),
          }) =>
              StudentAssignmentsCompanion.insert(
            id: id,
            assignmentId: assignmentId,
            studentId: studentId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            rewardClaimed: rewardClaimed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StudentAssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({assignmentId = false, studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (assignmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.assignmentId,
                    referencedTable: $$StudentAssignmentsTableReferences
                        ._assignmentIdTable(db),
                    referencedColumn: $$StudentAssignmentsTableReferences
                        ._assignmentIdTable(db)
                        .id,
                  ) as T;
                }
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$StudentAssignmentsTableReferences._studentIdTable(db),
                    referencedColumn: $$StudentAssignmentsTableReferences
                        ._studentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StudentAssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentAssignmentsTable,
    StudentAssignment,
    $$StudentAssignmentsTableFilterComposer,
    $$StudentAssignmentsTableOrderingComposer,
    $$StudentAssignmentsTableAnnotationComposer,
    $$StudentAssignmentsTableCreateCompanionBuilder,
    $$StudentAssignmentsTableUpdateCompanionBuilder,
    (StudentAssignment, $$StudentAssignmentsTableReferences),
    StudentAssignment,
    PrefetchHooks Function({bool assignmentId, bool studentId})>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  Value<int> id,
  required int userId,
  required String type,
  required String title,
  required String message,
  Value<bool> isRead,
  Value<String?> actionUrl,
  Value<int?> relatedId,
  Value<String?> relatedType,
  required DateTime createdAt,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> type,
  Value<String> title,
  Value<String> message,
  Value<bool> isRead,
  Value<String?> actionUrl,
  Value<int?> relatedId,
  Value<String?> relatedType,
  Value<DateTime> createdAt,
});

final class $$NotificationsTableReferences
    extends BaseReferences<_$AppDatabase, $NotificationsTable, Notification> {
  $$NotificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.notifications.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionUrl => $composableBuilder(
      column: $table.actionUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get relatedId => $composableBuilder(
      column: $table.relatedId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedType => $composableBuilder(
      column: $table.relatedType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionUrl => $composableBuilder(
      column: $table.actionUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get relatedId => $composableBuilder(
      column: $table.relatedId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedType => $composableBuilder(
      column: $table.relatedType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get actionUrl =>
      $composableBuilder(column: $table.actionUrl, builder: (column) => column);

  GeneratedColumn<int> get relatedId =>
      $composableBuilder(column: $table.relatedId, builder: (column) => column);

  GeneratedColumn<String> get relatedType => $composableBuilder(
      column: $table.relatedType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (Notification, $$NotificationsTableReferences),
    Notification,
    PrefetchHooks Function({bool userId})> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String?> actionUrl = const Value.absent(),
            Value<int?> relatedId = const Value.absent(),
            Value<String?> relatedType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            userId: userId,
            type: type,
            title: title,
            message: message,
            isRead: isRead,
            actionUrl: actionUrl,
            relatedId: relatedId,
            relatedType: relatedType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String type,
            required String title,
            required String message,
            Value<bool> isRead = const Value.absent(),
            Value<String?> actionUrl = const Value.absent(),
            Value<int?> relatedId = const Value.absent(),
            Value<String?> relatedType = const Value.absent(),
            required DateTime createdAt,
          }) =>
              NotificationsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            title: title,
            message: message,
            isRead: isRead,
            actionUrl: actionUrl,
            relatedId: relatedId,
            relatedType: relatedType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NotificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$NotificationsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$NotificationsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (Notification, $$NotificationsTableReferences),
    Notification,
    PrefetchHooks Function({bool userId})>;
typedef $$SubmissionsTableCreateCompanionBuilder = SubmissionsCompanion
    Function({
  Value<int> id,
  required int assignmentId,
  required int studentId,
  Value<String?> fileUrl,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<String?> linkUrl,
  Value<String?> textContent,
  required DateTime submittedAt,
  Value<bool> isLate,
  required String status,
  Value<double?> grade,
  Value<double?> maxGrade,
  Value<String?> feedback,
  Value<DateTime?> gradedAt,
  Value<int?> gradedBy,
  Value<int> version,
  Value<int?> previousVersionId,
});
typedef $$SubmissionsTableUpdateCompanionBuilder = SubmissionsCompanion
    Function({
  Value<int> id,
  Value<int> assignmentId,
  Value<int> studentId,
  Value<String?> fileUrl,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<String?> linkUrl,
  Value<String?> textContent,
  Value<DateTime> submittedAt,
  Value<bool> isLate,
  Value<String> status,
  Value<double?> grade,
  Value<double?> maxGrade,
  Value<String?> feedback,
  Value<DateTime?> gradedAt,
  Value<int?> gradedBy,
  Value<int> version,
  Value<int?> previousVersionId,
});

final class $$SubmissionsTableReferences
    extends BaseReferences<_$AppDatabase, $SubmissionsTable, Submission> {
  $$SubmissionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssignmentsTable _assignmentIdTable(_$AppDatabase db) =>
      db.assignments.createAlias(
          $_aliasNameGenerator(db.submissions.assignmentId, db.assignments.id));

  $$AssignmentsTableProcessedTableManager get assignmentId {
    final $_column = $_itemColumn<int>('assignment_id')!;

    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assignmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _studentIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.submissions.studentId, db.users.id));

  $$UsersTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _gradedByTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.submissions.gradedBy, db.users.id));

  $$UsersTableProcessedTableManager? get gradedBy {
    final $_column = $_itemColumn<int>('graded_by');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gradedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubmissionsTable _previousVersionIdTable(_$AppDatabase db) =>
      db.submissions.createAlias($_aliasNameGenerator(
          db.submissions.previousVersionId, db.submissions.id));

  $$SubmissionsTableProcessedTableManager? get previousVersionId {
    final $_column = $_itemColumn<int>('previous_version_id');
    if ($_column == null) return null;
    final manager = $$SubmissionsTableTableManager($_db, $_db.submissions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_previousVersionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkUrl => $composableBuilder(
      column: $table.linkUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLate => $composableBuilder(
      column: $table.isLate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxGrade => $composableBuilder(
      column: $table.maxGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedback => $composableBuilder(
      column: $table.feedback, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get gradedAt => $composableBuilder(
      column: $table.gradedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$AssignmentsTableFilterComposer get assignmentId {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get studentId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get gradedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gradedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubmissionsTableFilterComposer get previousVersionId {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.previousVersionId,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableFilterComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkUrl => $composableBuilder(
      column: $table.linkUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLate => $composableBuilder(
      column: $table.isLate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxGrade => $composableBuilder(
      column: $table.maxGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedback => $composableBuilder(
      column: $table.feedback, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get gradedAt => $composableBuilder(
      column: $table.gradedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$AssignmentsTableOrderingComposer get assignmentId {
    final $$AssignmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableOrderingComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get studentId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get gradedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gradedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubmissionsTableOrderingComposer get previousVersionId {
    final $$SubmissionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.previousVersionId,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableOrderingComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get linkUrl =>
      $composableBuilder(column: $table.linkUrl, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);

  GeneratedColumn<bool> get isLate =>
      $composableBuilder(column: $table.isLate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<double> get maxGrade =>
      $composableBuilder(column: $table.maxGrade, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<DateTime> get gradedAt =>
      $composableBuilder(column: $table.gradedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$AssignmentsTableAnnotationComposer get assignmentId {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get studentId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get gradedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gradedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubmissionsTableAnnotationComposer get previousVersionId {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.previousVersionId,
        referencedTable: $db.submissions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubmissionsTableAnnotationComposer(
              $db: $db,
              $table: $db.submissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubmissionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubmissionsTable,
    Submission,
    $$SubmissionsTableFilterComposer,
    $$SubmissionsTableOrderingComposer,
    $$SubmissionsTableAnnotationComposer,
    $$SubmissionsTableCreateCompanionBuilder,
    $$SubmissionsTableUpdateCompanionBuilder,
    (Submission, $$SubmissionsTableReferences),
    Submission,
    PrefetchHooks Function(
        {bool assignmentId,
        bool studentId,
        bool gradedBy,
        bool previousVersionId})> {
  $$SubmissionsTableTableManager(_$AppDatabase db, $SubmissionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> assignmentId = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<String?> fileUrl = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> linkUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<DateTime> submittedAt = const Value.absent(),
            Value<bool> isLate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> grade = const Value.absent(),
            Value<double?> maxGrade = const Value.absent(),
            Value<String?> feedback = const Value.absent(),
            Value<DateTime?> gradedAt = const Value.absent(),
            Value<int?> gradedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int?> previousVersionId = const Value.absent(),
          }) =>
              SubmissionsCompanion(
            id: id,
            assignmentId: assignmentId,
            studentId: studentId,
            fileUrl: fileUrl,
            fileName: fileName,
            fileSize: fileSize,
            linkUrl: linkUrl,
            textContent: textContent,
            submittedAt: submittedAt,
            isLate: isLate,
            status: status,
            grade: grade,
            maxGrade: maxGrade,
            feedback: feedback,
            gradedAt: gradedAt,
            gradedBy: gradedBy,
            version: version,
            previousVersionId: previousVersionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int assignmentId,
            required int studentId,
            Value<String?> fileUrl = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> linkUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            required DateTime submittedAt,
            Value<bool> isLate = const Value.absent(),
            required String status,
            Value<double?> grade = const Value.absent(),
            Value<double?> maxGrade = const Value.absent(),
            Value<String?> feedback = const Value.absent(),
            Value<DateTime?> gradedAt = const Value.absent(),
            Value<int?> gradedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int?> previousVersionId = const Value.absent(),
          }) =>
              SubmissionsCompanion.insert(
            id: id,
            assignmentId: assignmentId,
            studentId: studentId,
            fileUrl: fileUrl,
            fileName: fileName,
            fileSize: fileSize,
            linkUrl: linkUrl,
            textContent: textContent,
            submittedAt: submittedAt,
            isLate: isLate,
            status: status,
            grade: grade,
            maxGrade: maxGrade,
            feedback: feedback,
            gradedAt: gradedAt,
            gradedBy: gradedBy,
            version: version,
            previousVersionId: previousVersionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubmissionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {assignmentId = false,
              studentId = false,
              gradedBy = false,
              previousVersionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (assignmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.assignmentId,
                    referencedTable:
                        $$SubmissionsTableReferences._assignmentIdTable(db),
                    referencedColumn:
                        $$SubmissionsTableReferences._assignmentIdTable(db).id,
                  ) as T;
                }
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$SubmissionsTableReferences._studentIdTable(db),
                    referencedColumn:
                        $$SubmissionsTableReferences._studentIdTable(db).id,
                  ) as T;
                }
                if (gradedBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gradedBy,
                    referencedTable:
                        $$SubmissionsTableReferences._gradedByTable(db),
                    referencedColumn:
                        $$SubmissionsTableReferences._gradedByTable(db).id,
                  ) as T;
                }
                if (previousVersionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.previousVersionId,
                    referencedTable: $$SubmissionsTableReferences
                        ._previousVersionIdTable(db),
                    referencedColumn: $$SubmissionsTableReferences
                        ._previousVersionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SubmissionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubmissionsTable,
    Submission,
    $$SubmissionsTableFilterComposer,
    $$SubmissionsTableOrderingComposer,
    $$SubmissionsTableAnnotationComposer,
    $$SubmissionsTableCreateCompanionBuilder,
    $$SubmissionsTableUpdateCompanionBuilder,
    (Submission, $$SubmissionsTableReferences),
    Submission,
    PrefetchHooks Function(
        {bool assignmentId,
        bool studentId,
        bool gradedBy,
        bool previousVersionId})>;
typedef $$AttendancesTableCreateCompanionBuilder = AttendancesCompanion
    Function({
  Value<int> id,
  required int classId,
  Value<int?> scheduleId,
  required int studentId,
  required DateTime date,
  required String status,
  Value<String?> note,
  required int markedBy,
  required DateTime markedAt,
  Value<DateTime?> updatedAt,
});
typedef $$AttendancesTableUpdateCompanionBuilder = AttendancesCompanion
    Function({
  Value<int> id,
  Value<int> classId,
  Value<int?> scheduleId,
  Value<int> studentId,
  Value<DateTime> date,
  Value<String> status,
  Value<String?> note,
  Value<int> markedBy,
  Value<DateTime> markedAt,
  Value<DateTime?> updatedAt,
});

final class $$AttendancesTableReferences
    extends BaseReferences<_$AppDatabase, $AttendancesTable, Attendance> {
  $$AttendancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClassesTable _classIdTable(_$AppDatabase db) => db.classes
      .createAlias($_aliasNameGenerator(db.attendances.classId, db.classes.id));

  $$ClassesTableProcessedTableManager get classId {
    final $_column = $_itemColumn<int>('class_id')!;

    final manager = $$ClassesTableTableManager($_db, $_db.classes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_classIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias(
          $_aliasNameGenerator(db.attendances.scheduleId, db.schedules.id));

  $$SchedulesTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id');
    if ($_column == null) return null;
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _studentIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.attendances.studentId, db.users.id));

  $$UsersTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _markedByTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.attendances.markedBy, db.users.id));

  $$UsersTableProcessedTableManager get markedBy {
    final $_column = $_itemColumn<int>('marked_by')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_markedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get markedAt => $composableBuilder(
      column: $table.markedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ClassesTableFilterComposer get classId {
    final $$ClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableFilterComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get studentId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get markedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.markedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get markedAt => $composableBuilder(
      column: $table.markedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ClassesTableOrderingComposer get classId {
    final $$ClassesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableOrderingComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableOrderingComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get studentId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get markedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.markedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ClassesTableAnnotationComposer get classId {
    final $$ClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.classId,
        referencedTable: $db.classes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.classes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get studentId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get markedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.markedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, $$AttendancesTableReferences),
    Attendance,
    PrefetchHooks Function(
        {bool classId, bool scheduleId, bool studentId, bool markedBy})> {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> classId = const Value.absent(),
            Value<int?> scheduleId = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> markedBy = const Value.absent(),
            Value<DateTime> markedAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AttendancesCompanion(
            id: id,
            classId: classId,
            scheduleId: scheduleId,
            studentId: studentId,
            date: date,
            status: status,
            note: note,
            markedBy: markedBy,
            markedAt: markedAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int classId,
            Value<int?> scheduleId = const Value.absent(),
            required int studentId,
            required DateTime date,
            required String status,
            Value<String?> note = const Value.absent(),
            required int markedBy,
            required DateTime markedAt,
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              AttendancesCompanion.insert(
            id: id,
            classId: classId,
            scheduleId: scheduleId,
            studentId: studentId,
            date: date,
            status: status,
            note: note,
            markedBy: markedBy,
            markedAt: markedAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttendancesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {classId = false,
              scheduleId = false,
              studentId = false,
              markedBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (classId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.classId,
                    referencedTable:
                        $$AttendancesTableReferences._classIdTable(db),
                    referencedColumn:
                        $$AttendancesTableReferences._classIdTable(db).id,
                  ) as T;
                }
                if (scheduleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduleId,
                    referencedTable:
                        $$AttendancesTableReferences._scheduleIdTable(db),
                    referencedColumn:
                        $$AttendancesTableReferences._scheduleIdTable(db).id,
                  ) as T;
                }
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$AttendancesTableReferences._studentIdTable(db),
                    referencedColumn:
                        $$AttendancesTableReferences._studentIdTable(db).id,
                  ) as T;
                }
                if (markedBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.markedBy,
                    referencedTable:
                        $$AttendancesTableReferences._markedByTable(db),
                    referencedColumn:
                        $$AttendancesTableReferences._markedByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttendancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, $$AttendancesTableReferences),
    Attendance,
    PrefetchHooks Function(
        {bool classId, bool scheduleId, bool studentId, bool markedBy})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required int userId,
  required String title,
  Value<String?> description,
  required DateTime dueDate,
  Value<bool> isCompleted,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> dueDate,
  Value<bool> isCompleted,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(db.tasks.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool userId})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            isCompleted: isCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime dueDate,
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            isCompleted: isCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$TasksTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$StudentProfilesTableTableManager get studentProfiles =>
      $$StudentProfilesTableTableManager(_db, _db.studentProfiles);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$StudentAssignmentsTableTableManager get studentAssignments =>
      $$StudentAssignmentsTableTableManager(_db, _db.studentAssignments);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$SubmissionsTableTableManager get submissions =>
      $$SubmissionsTableTableManager(_db, _db.submissions);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
