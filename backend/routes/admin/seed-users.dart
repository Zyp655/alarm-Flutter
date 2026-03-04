import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:bcrypt/bcrypt.dart';
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
    final now = DateTime.now();
    final log = <String>[];

    final deptData = [
      {
        'name': 'Khoa Công nghệ Thông tin',
        'code': 'CNTT',
        'description': 'Ngành CNTT, Kỹ thuật phần mềm, Hệ thống thông tin'
      },
      {
        'name': 'Khoa Kinh tế',
        'code': 'KT',
        'description': 'Quản trị kinh doanh, Tài chính, Marketing'
      },
      {
        'name': 'Khoa Ngoại ngữ',
        'code': 'NN',
        'description': 'Ngôn ngữ Anh, Nhật, Hàn'
      },
    ];

    final deptIds = <String, int>{};
    for (final d in deptData) {
      final existing = await (db.select(db.departments)
            ..where((t) => t.code.equals(d['code']!)))
          .getSingleOrNull();
      if (existing != null) {
        deptIds[d['code']!] = existing.id;
        log.add('Khoa ${d['code']}: đã tồn tại (id=${existing.id})');
      } else {
        final row = await db.into(db.departments).insertReturning(
              DepartmentsCompanion.insert(
                name: d['name']!,
                code: d['code']!,
                description: Value(d['description']),
                createdAt: now,
              ),
            );
        deptIds[d['code']!] = row.id;
        log.add('Khoa ${d['code']}: tạo mới (id=${row.id})');
      }
    }

    final semData = [
      {'name': 'HK1 2025-2026', 'year': 2025, 'term': 1, 'isActive': true},
      {'name': 'HK2 2025-2026', 'year': 2025, 'term': 2, 'isActive': false},
    ];

    final semIds = <String, int>{};
    for (final s in semData) {
      final name = s['name'] as String;
      final existing = await (db.select(db.semesters)
            ..where((t) => t.name.equals(name)))
          .getSingleOrNull();
      if (existing != null) {
        semIds[name] = existing.id;
        log.add('Học kỳ $name: đã tồn tại');
      } else {
        final row = await db.into(db.semesters).insertReturning(
              SemestersCompanion.insert(
                name: name,
                year: s['year'] as int,
                term: s['term'] as int,
                startDate: DateTime(2025, s['term'] == 1 ? 9 : 2, 1),
                endDate: DateTime(2025, s['term'] == 1 ? 12 : 6, 30),
                isActive: Value(s['isActive'] as bool),
              ),
            );
        semIds[name] = row.id;
        log.add('Học kỳ $name: tạo mới (id=${row.id})');
      }
    }

    final activeSemId = semIds['HK1 2025-2026']!;

    final courseData = [
      {
        'name': 'Lập trình Java',
        'code': 'INT1340',
        'credits': 3,
        'dept': 'CNTT'
      },
      {
        'name': 'Cơ sở dữ liệu',
        'code': 'INT1341',
        'credits': 3,
        'dept': 'CNTT'
      },
      {
        'name': 'Mạng máy tính',
        'code': 'INT1342',
        'credits': 3,
        'dept': 'CNTT'
      },
      {
        'name': 'Trí tuệ nhân tạo',
        'code': 'INT1343',
        'credits': 3,
        'dept': 'CNTT'
      },
      {'name': 'Kinh tế vi mô', 'code': 'ECO1001', 'credits': 3, 'dept': 'KT'},
      {
        'name': 'Marketing căn bản',
        'code': 'MKT1001',
        'credits': 2,
        'dept': 'KT'
      },
      {
        'name': 'Tiếng Anh giao tiếp',
        'code': 'ENG1001',
        'credits': 2,
        'dept': 'NN'
      },
    ];

    final acIds = <String, int>{};
    for (final c in courseData) {
      final code = c['code'] as String;
      final existing = await (db.select(db.academicCourses)
            ..where((t) => t.code.equals(code)))
          .getSingleOrNull();
      if (existing != null) {
        acIds[code] = existing.id;
      } else {
        final row = await db.into(db.academicCourses).insertReturning(
              AcademicCoursesCompanion.insert(
                name: c['name'] as String,
                code: code,
                credits: Value(c['credits'] as int),
                departmentId: deptIds[c['dept'] as String]!,
                createdAt: now,
              ),
            );
        acIds[code] = row.id;
      }
    }
    log.add('Học phần: ${acIds.length} môn');

    final courseLessons = <String, List<Map<String, dynamic>>>{
      'INT1340': [
        {'title': 'Giới thiệu Java và JDK', 'type': 'video', 'dur': 45},
        {'title': 'Biến, kiểu dữ liệu và toán tử', 'type': 'video', 'dur': 50},
        {
          'title': 'Cấu trúc điều khiển (if/else, switch)',
          'type': 'video',
          'dur': 40
        },
        {
          'title': 'Vòng lặp for, while, do-while',
          'type': 'document',
          'dur': 30
        },
        {'title': 'OOP: Class, Object, Kế thừa', 'type': 'video', 'dur': 60},
        {'title': 'Bài tập thực hành Java', 'type': 'assignment', 'dur': 90},
      ],
      'INT1341': [
        {'title': 'Tổng quan Database & DBMS', 'type': 'video', 'dur': 40},
        {'title': 'SQL: CREATE, INSERT, SELECT', 'type': 'video', 'dur': 50},
        {'title': 'WHERE, JOIN, GROUP BY', 'type': 'video', 'dur': 55},
        {
          'title': 'Thiết kế cơ sở dữ liệu (ERD)',
          'type': 'document',
          'dur': 35
        },
        {'title': 'Bài tập SQL nâng cao', 'type': 'assignment', 'dur': 60},
      ],
      'INT1342': [
        {'title': 'Mô hình OSI và TCP/IP', 'type': 'video', 'dur': 45},
        {'title': 'Địa chỉ IP và Subnetting', 'type': 'video', 'dur': 50},
        {'title': 'Giao thức HTTP, DNS, DHCP', 'type': 'video', 'dur': 40},
        {'title': 'Bảo mật mạng cơ bản', 'type': 'document', 'dur': 30},
        {
          'title': 'Lab thực hành cấu hình mạng',
          'type': 'assignment',
          'dur': 90
        },
      ],
      'INT1343': [
        {
          'title': 'Giới thiệu AI và Machine Learning',
          'type': 'video',
          'dur': 50
        },
        {'title': 'Thuật toán tìm kiếm (BFS, DFS)', 'type': 'video', 'dur': 45},
        {'title': 'Mạng Neural cơ bản', 'type': 'video', 'dur': 60},
        {
          'title': 'Xử lý ngôn ngữ tự nhiên (NLP)',
          'type': 'document',
          'dur': 35
        },
        {'title': 'Đồ án: Chatbot AI', 'type': 'assignment', 'dur': 120},
      ],
      'ECO1001': [
        {'title': 'Cung - Cầu và thị trường', 'type': 'video', 'dur': 45},
        {
          'title': 'Lý thuyết hành vi người tiêu dùng',
          'type': 'video',
          'dur': 40
        },
        {'title': 'Chi phí sản xuất và lợi nhuận', 'type': 'video', 'dur': 50},
        {
          'title': 'Thị trường cạnh tranh hoàn hảo',
          'type': 'document',
          'dur': 30
        },
        {'title': 'Bài tập Kinh tế vi mô', 'type': 'assignment', 'dur': 60},
      ],
      'MKT1001': [
        {'title': 'Tổng quan Marketing', 'type': 'video', 'dur': 40},
        {'title': 'Phân tích thị trường và SWOT', 'type': 'video', 'dur': 45},
        {'title': 'Marketing Mix (4P)', 'type': 'video', 'dur': 50},
        {'title': 'Digital Marketing cơ bản', 'type': 'document', 'dur': 30},
      ],
      'ENG1001': [
        {
          'title': 'Giao tiếp hàng ngày (Greetings)',
          'type': 'video',
          'dur': 35
        },
        {
          'title': 'Ngữ pháp: Thì hiện tại & quá khứ',
          'type': 'video',
          'dur': 40
        },
        {
          'title': 'Kỹ năng nghe - Listening Practice',
          'type': 'video',
          'dur': 45
        },
        {'title': 'Viết email chuyên nghiệp', 'type': 'document', 'dur': 30},
      ],
    };

    int modulesCreated = 0;
    int lessonsCreated = 0;
    for (final entry in courseLessons.entries) {
      final academicCourseId = acIds[entry.key]!;
      final existingModules = await (db.select(db.modules)
            ..where((m) => m.academicCourseId.equals(academicCourseId)))
          .get();
      if (existingModules.isNotEmpty) continue;

      final moduleId = await db.into(db.modules).insert(
            ModulesCompanion.insert(
              academicCourseId: Value(academicCourseId),
              title: 'Nội dung chính',
              description: const Value('Bài giảng chính thức'),
              orderIndex: 0,
              createdAt: now,
            ),
          );
      modulesCreated++;

      for (var i = 0; i < entry.value.length; i++) {
        final lesson = entry.value[i];
        await db.into(db.lessons).insert(
              LessonsCompanion.insert(
                moduleId: moduleId,
                title: lesson['title'] as String,
                type: lesson['type'] as String,
                durationMinutes: Value(lesson['dur'] as int),
                isFreePreview: Value(i == 0),
                orderIndex: i,
                createdAt: now,
              ),
            );
        lessonsCreated++;
      }
    }
    log.add('Modules: $modulesCreated mới, Lessons: $lessonsCreated mới');

    final teacherData = [
      {
        'teacherCode': 'GV001',
        'fullName': 'TS. Nguyễn Văn Hùng',
        'email': 'gv001@lms.edu.vn',
        'dept': 'CNTT',
      },
      {
        'teacherCode': 'GV002',
        'fullName': 'ThS. Trần Thị Mai',
        'email': 'gv002@lms.edu.vn',
        'dept': 'CNTT',
      },
      {
        'teacherCode': 'GV003',
        'fullName': 'PGS. Lê Hoàng Nam',
        'email': 'gv003@lms.edu.vn',
        'dept': 'KT',
      },
      {
        'teacherCode': 'GV004',
        'fullName': 'TS. Phạm Minh Tuấn',
        'email': 'gv004@lms.edu.vn',
        'dept': 'NN',
      },
    ];

    int teachersCreated = 0;
    int teachersSkipped = 0;
    final userIds = <String, int>{};

    for (final t in teacherData) {
      final email = t['email']!;
      final teacherCode = t['teacherCode']!;
      final fullName = t['fullName']!;
      final deptCode = t['dept']!;
      final deptId = deptIds[deptCode];

      final existing = await (db.select(db.users)
            ..where((u) => u.email.equals(email)))
          .getSingleOrNull();

      if (existing != null) {
        userIds[email] = existing.id;
        await (db.update(db.users)..where((u) => u.id.equals(existing.id)))
            .write(UsersCompanion(
          role: const Value(1),
          fullName: Value(fullName),
          departmentId: Value(deptId),
        ));
        teachersSkipped++;
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

      await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
        UsersCompanion(
          role: const Value(1),
          fullName: Value(fullName),
          departmentId: Value(deptId),
        ),
      );

      userIds[email] = user.id;
      teachersCreated++;
    }
    log.add('Giảng viên: $teachersCreated tạo mới, $teachersSkipped cập nhật');

    final studentData = [
      {
        'studentId': '2021CNTT001',
        'fullName': 'Nguyễn Minh Đức',
        'studentClass': 'CNTT01-K2021',
        'dept': 'CNTT',
        'academicYear': '2021-2025',
      },
      {
        'studentId': '2021CNTT002',
        'fullName': 'Trần Thị Hương',
        'studentClass': 'CNTT01-K2021',
        'dept': 'CNTT',
        'academicYear': '2021-2025',
      },
      {
        'studentId': '2021CNTT003',
        'fullName': 'Phạm Quốc Bảo',
        'studentClass': 'CNTT02-K2021',
        'dept': 'CNTT',
        'academicYear': '2021-2025',
      },
      {
        'studentId': '2022CNTT001',
        'fullName': 'Hoàng Anh Tuấn',
        'studentClass': 'CNTT01-K2022',
        'dept': 'CNTT',
        'academicYear': '2022-2026',
      },
      {
        'studentId': '2021KT001',
        'fullName': 'Lê Thị Ngọc Ánh',
        'studentClass': 'QTKD01-K2021',
        'dept': 'KT',
        'academicYear': '2021-2025',
      },
      {
        'studentId': '2021KT002',
        'fullName': 'Võ Hoàng Phúc',
        'studentClass': 'QTKD01-K2021',
        'dept': 'KT',
        'academicYear': '2021-2025',
      },
      {
        'studentId': '2022NN001',
        'fullName': 'Nguyễn Thanh Hà',
        'studentClass': 'NN01-K2022',
        'dept': 'NN',
        'academicYear': '2022-2026',
      },
    ];

    int studentsCreated = 0;
    int studentsSkipped = 0;

    for (final s in studentData) {
      final maSV = s['studentId']!;
      final fullName = s['fullName']!;
      final className = s['studentClass']!;
      final deptCode = s['dept']!;
      final deptId = deptIds[deptCode];
      final academicYear = s['academicYear']!;
      final email = '$maSV@student.lms.edu.vn';

      final existing = await (db.select(db.users)
            ..where((u) => u.email.equals(email)))
          .getSingleOrNull();

      if (existing != null) {
        userIds[email] = existing.id;
        await (db.update(db.users)..where((u) => u.id.equals(existing.id)))
            .write(UsersCompanion(
          role: const Value(0),
          fullName: Value(fullName),
          departmentId: Value(deptId),
        ));
        studentsSkipped++;
        continue;
      }

      final password = '$maSV@123';
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final user = await db.into(db.users).insertReturning(
            UsersCompanion.insert(
              email: email,
              passwordHash: hashedPassword,
            ),
          );

      await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
        UsersCompanion(
          role: const Value(0),
          fullName: Value(fullName),
          departmentId: Value(deptId),
        ),
      );

      final existingProfile = await (db.select(db.studentProfiles)
            ..where((t) => t.userId.equals(user.id)))
          .getSingleOrNull();
      if (existingProfile == null) {
        await db.into(db.studentProfiles).insert(
              StudentProfilesCompanion.insert(
                userId: user.id,
                fullName: fullName,
                studentId: Value(maSV),
                departmentId: Value(deptId),
                studentClass: Value(className),
                academicYear: Value(academicYear),
              ),
            );
      }

      userIds[email] = user.id;
      studentsCreated++;
    }
    log.add('Sinh viên: $studentsCreated tạo mới, $studentsSkipped cập nhật');

    final gv01Id = userIds['gv001@lms.edu.vn']!;
    final gv02Id = userIds['gv002@lms.edu.vn']!;
    final gv03Id = userIds['gv003@lms.edu.vn']!;

    final classData = [
      {
        'code': 'INT1340.01',
        'courseCode': 'INT1340',
        'teacherId': gv01Id,
        'room': 'A301',
        'schedule': 'T2 (7:00-9:30)'
      },
      {
        'code': 'INT1341.01',
        'courseCode': 'INT1341',
        'teacherId': gv01Id,
        'room': 'A302',
        'schedule': 'T4 (7:00-9:30)'
      },
      {
        'code': 'INT1342.01',
        'courseCode': 'INT1342',
        'teacherId': gv02Id,
        'room': 'B201',
        'schedule': 'T3 (13:00-15:30)'
      },
      {
        'code': 'INT1343.01',
        'courseCode': 'INT1343',
        'teacherId': gv02Id,
        'room': 'B202',
        'schedule': 'T5 (13:00-15:30)'
      },
      {
        'code': 'ECO1001.01',
        'courseCode': 'ECO1001',
        'teacherId': gv03Id,
        'room': 'C101',
        'schedule': 'T2 (13:00-15:30)'
      },
      {
        'code': 'MKT1001.01',
        'courseCode': 'MKT1001',
        'teacherId': gv03Id,
        'room': 'C102',
        'schedule': 'T6 (7:00-9:30)'
      },
    ];

    final classIds = <String, int>{};
    for (final c in classData) {
      final code = c['code'] as String;
      final existing = await (db.select(db.courseClasses)
            ..where((t) => t.classCode.equals(code)))
          .getSingleOrNull();
      if (existing != null) {
        classIds[code] = existing.id;
      } else {
        final row = await db.into(db.courseClasses).insertReturning(
              CourseClassesCompanion.insert(
                academicCourseId: acIds[c['courseCode'] as String]!,
                semesterId: activeSemId,
                teacherId: Value(c['teacherId'] as int?),
                classCode: code,
                room: Value(c['room'] as String),
                schedule: Value(c['schedule'] as String),
                createdAt: now,
              ),
            );
        classIds[code] = row.id;
      }
    }
    log.add('Lớp HP: ${classData.length} lớp');

    final enrollData = [
      {
        'student': '2021CNTT001@student.lms.edu.vn',
        'classes': ['INT1340.01', 'INT1341.01', 'INT1342.01']
      },
      {
        'student': '2021CNTT002@student.lms.edu.vn',
        'classes': ['INT1340.01', 'INT1343.01']
      },
      {
        'student': '2021CNTT003@student.lms.edu.vn',
        'classes': ['INT1341.01', 'INT1342.01', 'INT1343.01']
      },
      {
        'student': '2022CNTT001@student.lms.edu.vn',
        'classes': ['INT1340.01', 'INT1341.01']
      },
      {
        'student': '2021KT001@student.lms.edu.vn',
        'classes': ['ECO1001.01', 'MKT1001.01']
      },
      {
        'student': '2021KT002@student.lms.edu.vn',
        'classes': ['ECO1001.01', 'MKT1001.01']
      },
    ];

    int enrolled = 0;
    for (final e in enrollData) {
      final studentId = userIds[e['student'] as String]!;
      for (final classCode in e['classes'] as List<String>) {
        final classId = classIds[classCode]!;
        final existing = await (db.select(db.courseClassEnrollments)
              ..where((t) =>
                  t.courseClassId.equals(classId) &
                  t.studentId.equals(studentId)))
            .getSingleOrNull();
        if (existing == null) {
          await db.into(db.courseClassEnrollments).insert(
                CourseClassEnrollmentsCompanion.insert(
                  courseClassId: classId,
                  studentId: studentId,
                  enrolledAt: now,
                ),
              );
          enrolled++;
        }
      }
    }
    log.add('Ghi danh: $enrolled bản ghi mới');

    return Response.json(
      body: {
        'success': true,
        'message':
            'Seed hoàn tất: $teachersCreated GV, $studentsCreated SV mới, $enrolled ghi danh',
        'teachersCreated': teachersCreated,
        'studentsCreated': studentsCreated,
        'enrolled': enrolled,
        'log': log,
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': '$e',
      }),
    );
  }
}
