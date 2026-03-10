import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _getSemesters(context);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getSemesters(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();

    final results = await db
        .customSelect(
          'SELECT id, name, year, term, start_date, end_date, is_active FROM semesters ORDER BY start_date DESC',
        )
        .get();

    final semesters = results
        .map((row) => {
              'id': row.data['id'],
              'name': row.data['name'],
              'year': row.data['year'],
              'term': row.data['term'],
              'startDate': row.data['start_date']?.toString(),
              'endDate': row.data['end_date']?.toString(),
              'isCurrent':
                  row.data['is_active'] == true || row.data['is_active'] == 1,
            })
        .toList();

    return Response.json(body: {'semesters': semesters});
  } catch (e) {
    return Response.json(
      body: {'error': 'Server error: $e'},
      statusCode: 500,
    );
  }
}
