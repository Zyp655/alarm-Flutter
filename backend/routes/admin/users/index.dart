import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/helpers/pagination.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final pg = Pagination.fromQuery(params);
    final roleFilter = int.tryParse(params['role'] ?? '');
    final search = params['search']?.toLowerCase();
    final departmentId = int.tryParse(params['departmentId'] ?? '');
    final studentClass = params['studentClass'];

    var query = db.select(db.users);

    if (roleFilter != null) {
      query = query..where((t) => t.role.equals(roleFilter));
    }

    if (departmentId != null) {
      query = query..where((t) => t.departmentId.equals(departmentId));
    }

    var users = await query.get();

    if (search != null && search.isNotEmpty) {
      users = users
          .where(
            (u) =>
                u.email.toLowerCase().contains(search) ||
                (u.fullName?.toLowerCase().contains(search) ?? false),
          )
          .toList();
    }

    Set<int>? studentClassUserIds;
    if (studentClass != null && studentClass.isNotEmpty) {
      final profiles = await (db.select(db.studentProfiles)
            ..where((t) => t.studentClass.equals(studentClass)))
          .get();
      studentClassUserIds = profiles.map((p) => p.userId).toSet();
      users = users.where((u) => studentClassUserIds!.contains(u.id)).toList();
    }

    final total = users.length;

    final paginatedUsers = users.skip(pg.offset).take(pg.limit).toList();

    final userIds = paginatedUsers.map((u) => u.id).toSet();
    final profiles = await db.select(db.studentProfiles).get();
    final profileMap = <int, dynamic>{};
    for (final p in profiles) {
      if (userIds.contains(p.userId)) {
        profileMap[p.userId] = p;
      }
    }

    final departments = await db.select(db.departments).get();
    final deptNameMap = <int, String>{};
    for (final d in departments) {
      deptNameMap[d.id] = d.name;
    }

    final result = paginatedUsers.map(
      (u) {
        final profile = profileMap[u.id];
        return {
          'id': u.id,
          'email': u.email,
          'fullName': u.fullName,
          'role': u.role,
          'isBanned': u.isBanned,
          'departmentId': u.departmentId,
          'departmentName':
              u.departmentId != null ? deptNameMap[u.departmentId] : null,
          'studentClass': profile?.studentClass,
          'studentId': profile?.studentId,
        };
      },
    ).toList();

    return Response.json(body: pg.wrap(result, total: total, key: 'users'));
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
