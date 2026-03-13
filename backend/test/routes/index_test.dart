import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('GET /', () {
    test('responds with a 200 and health status.', () async {
      final context = _MockRequestContext();
      final request = _MockRequest();
      final db = _MockAppDatabase();

      when(() => context.request).thenReturn(request);
      when(() => context.read<AppDatabase>()).thenReturn(db);

      final response = await route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
    });
  });
}
