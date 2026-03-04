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
    final teachersList = body['teachers'] as List<dynamic>?;

    if (teachersList != null && teachersList.isNotEmpty) {
      return _handleTeachersJson(db, teachersList);
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
          'error': 'Vui lòng cung cấp teachers, csvContent hoặc xlsxBase64'
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
      final nameLower = d.name.toLowerCase().trim();
      deptMapByName[nameLower] = d.id;
      if (nameLower.startsWith('khoa ')) {
        deptMapByName[nameLower.substring(5).trim()] = d.id;
      }
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
            'Dòng ${i + 1}: Thiếu dữ liệu (cần ít nhất: MaGV, HoTen, Email)');
        continue;
      }

      final teacherCode = parts[0].trim();
      final fullName = parts[1].trim();
      final email = parts[2].trim();
      final department = parts.length >= 4 ? parts[3].trim() : null;

      if (teacherCode.isEmpty || fullName.isEmpty || email.isEmpty) {
        errors.add('Dòng ${i + 1}: MaGV, HoTen hoặc Email trống');
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

      final existing = await (db.select(db.users)
            ..where((t) => t.email.equals(email)))
          .getSingleOrNull();

      if (existing != null) {
        final password = '$teacherCode@123';
        final newHash = BCrypt.hashpw(password, BCrypt.gensalt());
        await (db.update(db.users)..where((t) => t.id.equals(existing.id)))
            .write(UsersCompanion(
          role: Value(1),
          fullName: Value(fullName),
          passwordHash: Value(newHash),
          resetToken: Value(teacherCode),
          departmentId:
              departmentId != null ? Value(departmentId) : const Value.absent(),
        ));
        skipped++;
        results.add({
          'teacherCode': teacherCode,
          'email': email,
          'status': 'updated',
        });
        continue;
      }

      final password = '$teacherCode@123';
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final user = await db.into(db.users).insertReturning(
            UsersCompanion.insert(
              email: email,
              passwordHash: hashedPassword,
            ),
          );

      await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
        UsersCompanion(
          role: Value(1),
          fullName: Value(fullName),
          resetToken: Value(teacherCode),
          departmentId:
              departmentId != null ? Value(departmentId) : const Value.absent(),
        ),
      );

      created++;
      results.add({
        'teacherCode': teacherCode,
        'email': email,
        'fullName': fullName,
        'department': department,
        'departmentId': departmentId,
        'password': password,
        'status': 'created',
      });
    }

    return Response.json(
      body: {
        'success': true,
        'message': 'Import hoàn tất: $created tạo mới, $skipped cập nhật',
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
        (lowerLine.contains('mã gv') ||
            lowerLine.contains('magv') ||
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
          firstCell.contains('magv') ||
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

Future<Response> _handleTeachersJson(
  AppDatabase db,
  List<dynamic> teachersList,
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

  for (int i = 0; i < teachersList.length; i++) {
    final t = teachersList[i] as Map<String, dynamic>;
    final teacherId = (t['teacherId'] as String?)?.trim() ?? '';
    final fullName = (t['fullName'] as String?)?.trim() ?? '';
    final email = (t['email'] as String?)?.trim() ?? '';
    final department = (t['department'] as String?)?.trim() ?? '';
    final password = (t['password'] as String?)?.trim() ?? '';

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
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (existing != null) {
      final newHash = BCrypt.hashpw(
          password.isNotEmpty ? password : 'Teacher@123', BCrypt.gensalt());
      await (db.update(db.users)..where((u) => u.id.equals(existing.id)))
          .write(UsersCompanion(
        role: Value(1),
        fullName: Value(fullName),
        passwordHash: Value(newHash),
        resetToken:
            teacherId.isNotEmpty ? Value(teacherId) : const Value.absent(),
        departmentId:
            departmentId != null ? Value(departmentId) : const Value.absent(),
      ));
      skipped++;
      results.add({'email': email, 'status': 'updated'});
      continue;
    }

    final hashedPassword = BCrypt.hashpw(
        password.isNotEmpty ? password : 'Teacher@123', BCrypt.gensalt());
    final user = await db.into(db.users).insertReturning(
          UsersCompanion.insert(
            email: email,
            passwordHash: hashedPassword,
          ),
        );

    await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(
        role: Value(1),
        fullName: Value(fullName),
        resetToken:
            teacherId.isNotEmpty ? Value(teacherId) : const Value.absent(),
        departmentId:
            departmentId != null ? Value(departmentId) : const Value.absent(),
      ),
    );

    created++;
    results.add({
      'teacherId': teacherId,
      'email': email,
      'fullName': fullName,
      'department': department,
      'password': password,
      'status': 'created',
    });
  }

  return Response.json(
    body: {
      'success': true,
      'message': 'Import hoàn tất: $created tạo mới, $skipped cập nhật',
      'created': created,
      'skipped': skipped,
      'errors': errors,
      'details': results,
    },
  );
}
