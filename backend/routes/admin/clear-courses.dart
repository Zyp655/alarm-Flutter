import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }

  try {
    final db = context.read<AppDatabase>();

    await db.customStatement('TRUNCATE TABLE courses CASCADE');
    await db.customStatement('TRUNCATE TABLE majors CASCADE');

    return Response.json(
      body: {
        'success': true,
        'message': 'Deleted all old LMS courses and related data (CASCADE)',
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
