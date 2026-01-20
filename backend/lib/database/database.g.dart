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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      clientDefault: () => false);
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
        targetScore,
        credits,
        maxAbsences
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
      targetScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_score'])!,
      credits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credits'])!,
      maxAbsences: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_absences'])!,
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
  final double targetScore;
  final int credits;
  final int maxAbsences;
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
      required this.targetScore,
      required this.credits,
      required this.maxAbsences});
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
    map['target_score'] = Variable<double>(targetScore);
    map['credits'] = Variable<int>(credits);
    map['max_absences'] = Variable<int>(maxAbsences);
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
      targetScore: Value(targetScore),
      credits: Value(credits),
      maxAbsences: Value(maxAbsences),
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
      targetScore: serializer.fromJson<double>(json['targetScore']),
      credits: serializer.fromJson<int>(json['credits']),
      maxAbsences: serializer.fromJson<int>(json['maxAbsences']),
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
      'targetScore': serializer.toJson<double>(targetScore),
      'credits': serializer.toJson<int>(credits),
      'maxAbsences': serializer.toJson<int>(maxAbsences),
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
          double? targetScore,
          int? credits,
          int? maxAbsences}) =>
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
        targetScore: targetScore ?? this.targetScore,
        credits: credits ?? this.credits,
        maxAbsences: maxAbsences ?? this.maxAbsences,
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
      targetScore:
          data.targetScore.present ? data.targetScore.value : this.targetScore,
      credits: data.credits.present ? data.credits.value : this.credits,
      maxAbsences:
          data.maxAbsences.present ? data.maxAbsences.value : this.maxAbsences,
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
          ..write('targetScore: $targetScore, ')
          ..write('credits: $credits, ')
          ..write('maxAbsences: $maxAbsences')
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
      targetScore,
      credits,
      maxAbsences);
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
          other.targetScore == this.targetScore &&
          other.credits == this.credits &&
          other.maxAbsences == this.maxAbsences);
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
  final Value<double> targetScore;
  final Value<int> credits;
  final Value<int> maxAbsences;
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
    this.targetScore = const Value.absent(),
    this.credits = const Value.absent(),
    this.maxAbsences = const Value.absent(),
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
    this.targetScore = const Value.absent(),
    this.credits = const Value.absent(),
    this.maxAbsences = const Value.absent(),
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
    Expression<double>? targetScore,
    Expression<int>? credits,
    Expression<int>? maxAbsences,
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
      if (targetScore != null) 'target_score': targetScore,
      if (credits != null) 'credits': credits,
      if (maxAbsences != null) 'max_absences': maxAbsences,
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
      Value<double>? targetScore,
      Value<int>? credits,
      Value<int>? maxAbsences}) {
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
      targetScore: targetScore ?? this.targetScore,
      credits: credits ?? this.credits,
      maxAbsences: maxAbsences ?? this.maxAbsences,
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
    if (targetScore.present) {
      map['target_score'] = Variable<double>(targetScore.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (maxAbsences.present) {
      map['max_absences'] = Variable<int>(maxAbsences.value);
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
          ..write('targetScore: $targetScore, ')
          ..write('credits: $credits, ')
          ..write('maxAbsences: $maxAbsences')
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
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
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
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reward_claimed" IN (0, 1))'),
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
        studentAssignments
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
        bool studentAssignmentsRefs})> {
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
              studentAssignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studentProfilesRefs) db.studentProfiles,
                if (subjectsRefs) db.subjects,
                if (classesRefs) db.classes,
                if (schedulesRefs) db.schedules,
                if (assignmentsRefs) db.assignments,
                if (studentAssignmentsRefs) db.studentAssignments
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
        bool studentAssignmentsRefs})>;
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
        bool assignmentsRefs})> {
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
              assignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (schedulesRefs) db.schedules,
                if (assignmentsRefs) db.assignments
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
        bool assignmentsRefs})>;
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
  Value<double> targetScore,
  Value<int> credits,
  Value<int> maxAbsences,
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
  Value<double> targetScore,
  Value<int> credits,
  Value<int> maxAbsences,
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

  ColumnFilters<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => column);

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<int> get maxAbsences => $composableBuilder(
      column: $table.maxAbsences, builder: (column) => column);

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
    PrefetchHooks Function({bool userId, bool classId})> {
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
            Value<double> targetScore = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<int> maxAbsences = const Value.absent(),
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
            targetScore: targetScore,
            credits: credits,
            maxAbsences: maxAbsences,
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
            Value<double> targetScore = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<int> maxAbsences = const Value.absent(),
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
            targetScore: targetScore,
            credits: credits,
            maxAbsences: maxAbsences,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false, classId = false}) {
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
                return [];
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
    PrefetchHooks Function({bool userId, bool classId})>;
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
        {bool classId, bool teacherId, bool studentAssignmentsRefs})> {
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
              studentAssignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studentAssignmentsRefs) db.studentAssignments
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
        {bool classId, bool teacherId, bool studentAssignmentsRefs})>;
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
}
