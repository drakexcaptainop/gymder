import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDirectory;
  late File database;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync('gymder_migrations_');
    database = File('${tempDirectory.path}/gymder.sqlite');
  });

  tearDown(() {
    tempDirectory.deleteSync(recursive: true);
  });

  test(
    'las migraciones y el seed crean una base íntegra sin bookings',
    () async {
      final root = Directory.current.path;
      final result = await Process.run('sqlite3', [
        database.path,
        '.read $root/migrations/0001_init_schema.sql',
        '.read $root/migrations/0002_triggers.sql',
        '.read $root/seed/seed.sql',
        'PRAGMA foreign_key_check;',
        "SELECT COUNT(*) FROM sqlite_master WHERE name LIKE '%booking%';",
        'SELECT COUNT(*) FROM reviews;',
        'SELECT COUNT(*) FROM notifications;',
      ]);

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect((result.stdout as String).trim().split('\n'), ['0', '1', '6']);
    },
  );

  test('ninguna migración conserva referencias a bookings', () {
    final migrationDirectory = Directory('migrations');
    final migrationFiles = migrationDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.sql'));

    for (final file in migrationFiles) {
      expect(
        file.readAsStringSync().toLowerCase(),
        isNot(contains('booking')),
        reason: file.path,
      );
    }
  });

  test('aceptar una solicitud abre chat, notifica y habilita reseña', () async {
    final root = Directory.current.path;
    final result = await Process.run('sqlite3', [
      database.path,
      '.read $root/migrations/0001_init_schema.sql',
      '.read $root/migrations/0002_triggers.sql',
      '.read $root/seed/seed.sql',
      "UPDATE contact_requests SET status = 'accepted', resolved_at = '2026-11-23T10:00:00.000Z' WHERE id = '50000000-0000-4000-8000-000000000002';",
      "SELECT COUNT(*) FROM conversations WHERE student_id = '10000000-0000-4000-8000-000000000006' AND coach_id = '20000000-0000-4000-8000-000000000002';",
      "SELECT COUNT(*) FROM notifications WHERE recipient_id = '10000000-0000-4000-8000-000000000006' AND notification_type = 'contact_request_resolved';",
      "INSERT INTO reviews (id, coach_id, student_id, rating) VALUES ('review-laura-ana', '20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000006', 4);",
      "SELECT COUNT(*) FROM notifications WHERE review_id = 'review-laura-ana' AND notification_type = 'review_created';",
    ]);

    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect((result.stdout as String).trim().split('\n'), ['1', '1', '1']);
  });

  test('la base rechaza mensajes largos y favoritos de coaches', () async {
    final root = Directory.current.path;
    final result = await Process.run('sqlite3', [
      database.path,
      '.bail on',
      '.read $root/migrations/0001_init_schema.sql',
      '.read $root/migrations/0002_triggers.sql',
      '.read $root/seed/seed.sql',
      "INSERT INTO messages (conversation_id, sender_id, body) VALUES ('60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', substr(replace(hex(zeroblob(1001)), '00', 'aa'), 1, 2001));",
    ]);

    expect(result.exitCode, isNot(0));
    expect('${result.stderr}', contains('CHECK constraint failed'));

    final roleResult = await Process.run('sqlite3', [
      database.path,
      '.bail on',
      "INSERT INTO favorites (profile_id, coach_id) VALUES ('10000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002');",
    ]);
    expect(roleResult.exitCode, isNot(0));
    expect('${roleResult.stderr}', contains('Only students'));
  });
}
