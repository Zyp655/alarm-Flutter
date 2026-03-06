import 'package:postgres/postgres.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: 'localhost',
      port: 5432,
      database: 'alarmm_db',
      username: 'postgres',
      password: '1234',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  await conn
      .execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT');
  print('Migration done: fcm_token column added');
  await conn.close();
}
