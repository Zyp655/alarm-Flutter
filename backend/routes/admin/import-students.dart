import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:excel/excel.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final csvContent = body['csvContent'] as String?;
    final xlsxBase64 = body['xlsxBase64'] as String?;
    final studentsList = body['students'] as List<dynamic>?;

    if (studentsList != null && studentsList.isNotEmpty) {
      return _handleStudentsJson(db, studentsList);
    }

    final List<List<String>> rows;
    if (xlsxBase64 != null && xlsxBase64.isNotEmpty) {
      rows = _parseXlsx(xlsxBase64);
    } else if (csvContent != null && csvContent.trim().isNotEmpty) {
      rows = _parseCsv(csvContent);
    } else {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Vui lòng cung cấp students, csvContent hoặc xlsxBase64'
        },
      );
    }

    if (rows.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'File không có dữ liệu'},
      );
    }

    final allDepartments = await db.select(db.departments).get();
    final deptMapByName = <String, int>{};
    final deptMapByCode = <String, int>{};
    for (final d in allDepartments) {
      deptMapByName[d.name.toLowerCase().trim()] = d.id;
      deptMapByCode[d.code.toLowerCase().trim()] = d.id;
    }

    int created = 0;
    int skipped = 0;
    final errors = <String>[];
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < rows.length; i++) {
      final parts = rows[i];
      if (parts.length < 3) {
        errors.add(
            'Dòng ${i + 1}: Thiếu dữ liệu (cần ít nhất: MaSV, HoTen, Lop)');
        continue;
      }

      final studentId = parts[0].trim();
      final fullName = parts[1].trim();
      final className = parts[2].trim();
      final department = parts.length >= 4 ? parts[3].trim() : null;
      final academicYear = parts.length >= 5 ? parts[4].trim() : null;

      if (studentId.isEmpty || fullName.isEmpty) {
        errors.add('Dòng ${i + 1}: MaSV hoặc HoTen trống');
        continue;
      }

      int? departmentId;
      if (department != null && department.isNotEmpty) {
        departmentId = deptMapByName[department.toLowerCase()] ??
            deptMapByCode[department.toLowerCase()];
        if (departmentId == null) {
          errors.add(
              'Dòng ${i + 1}: Khoa "$department" không tồn tại trong hệ thống');
          continue;
        }
      }

      final email = '$studentId@student.lms.edu.vn';
      final password = '$studentId@123';

      final existing = await (db.select(db.users)
            ..where((t) => t.email.equals(email)))
          .getSingleOrNull();

      if (existing != null) {
        if (departmentId != null && existing.departmentId == null) {
          await (db.update(db.users)..where((t) => t.id.equals(existing.id)))
              .write(UsersCompanion(departmentId: Value(departmentId)));
        }

        final profile = await (db.select(db.studentProfiles)
              ..where((t) => t.userId.equals(existing.id)))
            .getSingleOrNull();
        if (profile != null) {
          await (db.update(db.studentProfiles)
                ..where((t) => t.id.equals(profile.id)))
              .write(StudentProfilesCompanion(
            studentClass: Value(className),
            departmentId: departmentId != null
                ? Value(departmentId)
                : const Value.absent(),
          ));
        }
        skipped++;
        results.add({'studentId': studentId, 'status': 'skipped (updated)'});
        continue;
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final user = await db.into(db.users).insertReturning(
            UsersCompanion.insert(
              email: email,
              passwordHash: hashedPassword,
            ),
          );

      await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
        UsersCompanion(
          role: Value(0),
          fullName: Value(fullName),
          departmentId:
              departmentId != null ? Value(departmentId) : const Value.absent(),
        ),
      );

      try {
        await db.into(db.studentProfiles).insert(
              StudentProfilesCompanion.insert(
                userId: user.id,
                fullName: fullName,
                studentId: Value(studentId),
                major: Value(department ?? className),
                departmentId: departmentId != null
                    ? Value(departmentId)
                    : const Value.absent(),
                studentClass: Value(className),
                academicYear: academicYear != null && academicYear.isNotEmpty
                    ? Value(academicYear)
                    : const Value.absent(),
              ),
            );
      } catch (_) {}

      created++;
      results.add({
        'studentId': studentId,
        'email': email,
        'fullName': fullName,
        'class': className,
        'department': department,
        'departmentId': departmentId,
        'password': '$studentId@123',
        'status': 'created',
      });
    }

    return Response.json(
      body: {
        'success': true,
        'message': 'Import hoàn tất: $created tạo mới, $skipped bỏ qua',
        'created': created,
        'skipped': skipped,
        'errors': errors,
        'details': results,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.',
      }),
    );
  }
}

List<List<String>> _parseCsv(String csvContent) {
  final lines = csvContent.trim().split('\n');
  final rows = <List<String>>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    final lowerLine = line.toLowerCase();
    if (i == 0 &&
        (lowerLine.contains('mã sv') ||
            lowerLine.contains('masv') ||
            lowerLine.contains('ho ten') ||
            lowerLine.contains('họ tên') ||
            lowerLine.contains('stt'))) {
      continue;
    }

    rows.add(line.split(',').map((p) => p.trim()).toList());
  }

  return rows;
}

List<List<String>> _parseXlsx(String base64Data) {
  final bytes = base64Decode(base64Data);
  final excel = Excel.decodeBytes(bytes);

  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName]!;
  final rows = <List<String>>[];

  for (int i = 0; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];

    if (i == 0) {
      final firstCell = row.firstOrNull?.value?.toString().toLowerCase() ?? '';
      if (firstCell.contains('mã') ||
          firstCell.contains('masv') ||
          firstCell.contains('stt')) {
        continue;
      }
    }

    final cells =
        row.map((cell) => cell?.value?.toString().trim() ?? '').toList();
    if (cells.every((c) => c.isEmpty)) continue;

    rows.add(cells);
  }

  return rows;
}

Future<Response> _handleStudentsJson(
  AppDatabase db,
  List<dynamic> studentsList,
) async {
  int created = 0;
  int skipped = 0;
  final errors = <String>[];
  final results = <Map<String, dynamic>>[];

  final allDepartments = await db.select(db.departments).get();
  final deptMapByName = <String, int>{};
  final deptMapByCode = <String, int>{};
  for (final d in allDepartments) {
    final nameLower = d.name.toLowerCase().trim();
    deptMapByName[nameLower] = d.id;

    if (nameLower.startsWith('khoa ')) {
      deptMapByName[nameLower.substring(5).trim()] = d.id;
    }
    deptMapByCode[d.code.toLowerCase().trim()] = d.id;
  }

  for (int i = 0; i < studentsList.length; i++) {
    final s = studentsList[i] as Map<String, dynamic>;
    final studentId = (s['studentId'] as String?)?.trim() ?? '';
    final fullName = (s['fullName'] as String?)?.trim() ?? '';
    final email = (s['email'] as String?)?.trim() ?? '';
    final department = (s['department'] as String?)?.trim() ?? '';
    final academicYear = (s['academicYear'] as String?)?.trim() ?? '';
    final studentClass = (s['studentClass'] as String?)?.trim() ?? '';
    final password = (s['password'] as String?)?.trim() ?? '';

    if (fullName.isEmpty || email.isEmpty) {
      errors.add('Dòng ${i + 1}: Thiếu họ tên hoặc email');
      continue;
    }

    int? departmentId;
    if (department.isNotEmpty) {
      departmentId = deptMapByName[department.toLowerCase()] ??
          deptMapByCode[department.toLowerCase()];
      if (departmentId == null) {
        errors.add(
            'Dòng ${i + 1}: Khoa "$department" không tồn tại trong hệ thống');
        continue;
      }
    }

    final existing = await (db.select(db.users)
          ..where((t) => t.email.equals(email)))
        .getSingleOrNull();

    if (existing != null) {
      final hashedPw = BCrypt.hashpw(
          password.isNotEmpty ? password : 'Student@123', BCrypt.gensalt());
      await (db.update(db.users)..where((t) => t.id.equals(existing.id)))
          .write(UsersCompanion(
        passwordHash: Value(hashedPw),
        fullName: Value(fullName),
        departmentId:
            departmentId != null ? Value(departmentId) : const Value.absent(),
      ));

      final existingProfile = await (db.select(db.studentProfiles)
            ..where((t) => t.userId.equals(existing.id)))
          .getSingleOrNull();
      if (existingProfile == null) {
        try {
          await db.into(db.studentProfiles).insert(
                StudentProfilesCompanion.insert(
                  userId: existing.id,
                  fullName: fullName,
                  studentId: studentId.isNotEmpty
                      ? Value(studentId)
                      : const Value.absent(),
                  major: department.isNotEmpty
                      ? Value(department)
                      : const Value.absent(),
                  departmentId: departmentId != null
                      ? Value(departmentId)
                      : const Value.absent(),
                  studentClass: studentClass.isNotEmpty
                      ? Value(studentClass)
                      : const Value.absent(),
                  academicYear: academicYear.isNotEmpty
                      ? Value(academicYear)
                      : const Value.absent(),
                ),
              );
        } catch (_) {}
      } else {
        await (db.update(db.studentProfiles)
              ..where((t) => t.id.equals(existingProfile.id)))
            .write(StudentProfilesCompanion(
          fullName: Value(fullName),
          studentId:
              studentId.isNotEmpty ? Value(studentId) : const Value.absent(),
          departmentId:
              departmentId != null ? Value(departmentId) : const Value.absent(),
          studentClass: studentClass.isNotEmpty
              ? Value(studentClass)
              : const Value.absent(),
          academicYear: academicYear.isNotEmpty
              ? Value(academicYear)
              : const Value.absent(),
        ));
      }

      skipped++;
      results.add({'email': email, 'status': 'updated'});
      continue;
    }

    final hashedPassword = BCrypt.hashpw(
        password.isNotEmpty ? password : 'Student@123', BCrypt.gensalt());
    final user = await db.into(db.users).insertReturning(
          UsersCompanion.insert(
            email: email,
            passwordHash: hashedPassword,
          ),
        );

    await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
      UsersCompanion(
        role: Value(0),
        fullName: Value(fullName),
        departmentId:
            departmentId != null ? Value(departmentId) : const Value.absent(),
      ),
    );

    try {
      await db.into(db.studentProfiles).insert(
            StudentProfilesCompanion.insert(
              userId: user.id,
              fullName: fullName,
              studentId: studentId.isNotEmpty
                  ? Value(studentId)
                  : const Value.absent(),
              major: department.isNotEmpty
                  ? Value(department)
                  : const Value.absent(),
              departmentId: departmentId != null
                  ? Value(departmentId)
                  : const Value.absent(),
              academicYear: academicYear.isNotEmpty
                  ? Value(academicYear)
                  : const Value.absent(),
              studentClass: studentClass.isNotEmpty
                  ? Value(studentClass)
                  : const Value.absent(),
            ),
          );
    } catch (_) {}

    created++;
    results.add({
      'studentId': studentId,
      'email': email,
      'fullName': fullName,
      'department': department,
      'academicYear': academicYear,
      'password': password,
      'status': 'created',
    });
  }

  return Response.json(
    body: {
      'success': true,
      'message': 'Import hoàn tất: $created tạo mới, $skipped bỏ qua',
      'created': created,
      'skipped': skipped,
      'errors': errors,
      'details': results,
    },
  );
}
