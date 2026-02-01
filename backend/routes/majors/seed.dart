import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

/// POST /majors/seed - Seed initial majors data
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();

    final majorsToSeed = [
      {
        'name': 'Công nghệ thông tin',
        'code': 'CNTT',
        'description':
            'Chuyên ngành về công nghệ thông tin, phần mềm và hệ thống máy tính',
        'iconUrl': null,
      },
    ];

    final List<Map<String, dynamic>> seeded = [];

    for (final majorData in majorsToSeed) {
      final existing = await (db.select(db.majors)
            ..where((m) => m.code.equals(majorData['code']!)))
          .getSingleOrNull();

      if (existing != null) {
        seeded.add({
          'id': existing.id,
          'name': existing.name,
          'code': existing.code,
          'status': 'already_exists',
        });
        continue;
      }

      final major = await db.into(db.majors).insertReturning(
            MajorsCompanion.insert(
              name: majorData['name']!,
              code: majorData['code']!,
              description: Value(majorData['description']),
              iconUrl: Value(majorData['iconUrl']),
              createdAt: DateTime.now(),
            ),
          );

      seeded.add({
        'id': major.id,
        'name': major.name,
        'code': major.code,
        'status': 'created',
      });
    }

    return Response.json(
      body: {
        'message': 'Seeding completed',
        'majors': seeded,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to seed majors: $e'},
    );
  }
}
