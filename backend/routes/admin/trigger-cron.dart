import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/cron_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final job = params['job'];

  if (job == null || job.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Missing job parameter',
        'available': [
          'morning_digest',
          'midday_reminder',
          'afternoon_reminder',
          'urgent_reminder',
          'finalize_attendance',
        ],
      },
    );
  }

  try {
    final db = context.read<AppDatabase>();
    final cron = CronService(db);
    await cron.triggerJob(job);

    return Response.json(body: {
      'message': 'Job "$job" completed successfully',
      'timestamp': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Job failed: $e'},
    );
  }
}
