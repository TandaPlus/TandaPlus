// ignore_for_file: avoid_print
//
// Este archivo es un script CLI ejecutable; usar `print` para logs a stdout
// es apropiado (no es codigo de produccion de la app).
import 'dart:io';

import 'package:postgres/postgres.dart';

/// Runner de migraciones para PostgreSQL.
///
/// Lee `backend/migrations/*.sql` en orden numerico y aplica los que no
/// esten registrados en la tabla `schema_migrations`. Los archivos con
/// prefijo `_meta_` se ejecutan siempre (idempotentes) para asegurar que
/// la tabla de tracking exista antes de continuar.
///
/// Correr desde `backend/` con: `dart run tool/migrate.dart`.
Future<void> main() async {
  final databaseUrl =
      Platform.environment['DATABASE_URL'] ??
      'postgres://tandaplus:tandaplus@localhost:5432/tandaplus_dev';

  final connection = await _openConnection(databaseUrl);
  print('Conectado a Postgres.');

  try {
    await _runMetaMigrations(connection);
    final applied = await _fetchAppliedIds(connection);
    final pending = _listPendingMigrations(applied);

    if (pending.isEmpty) {
      print('Sin migraciones pendientes. Todo al dia.');
      return;
    }

    for (final migration in pending) {
      await _applyMigration(connection, migration);
    }
    print('Aplicadas ${pending.length} migracion(es).');
  } finally {
    await connection.close();
  }
}

Future<Connection> _openConnection(String databaseUrl) async {
  final uri = Uri.parse(databaseUrl);
  final userInfo = uri.userInfo.split(':');

  return Connection.open(
    Endpoint(
      host: uri.host,
      port: uri.port == 0 ? 5432 : uri.port,
      database: uri.pathSegments.first,
      username: userInfo.first,
      password: userInfo.length > 1 ? userInfo[1] : '',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}

Future<void> _runMetaMigrations(Connection connection) async {
  final metaFiles =
      _findMigrationFiles().where((f) => f.name.startsWith('_meta_')).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  for (final file in metaFiles) {
    final sql = file.readAsStringSync();
    await connection.execute(sql);
    print('Meta aplicada: ${file.name}');
  }
}

Future<Set<int>> _fetchAppliedIds(Connection connection) async {
  final result = await connection.execute('SELECT id FROM schema_migrations');
  return result.map((row) => row[0]! as int).toSet();
}

List<_Migration> _listPendingMigrations(Set<int> applied) {
  final all =
      _findMigrationFiles()
          .where((f) => !f.name.startsWith('_'))
          .map(_parseMigration)
          .whereType<_Migration>()
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  return all.where((m) => !applied.contains(m.id)).toList();
}

_Migration? _parseMigration(_MigrationFile file) {
  final match = RegExp(r'^(\d+)_(.+)\.sql$').firstMatch(file.name);
  if (match == null) return null;
  return _Migration(
    id: int.parse(match.group(1)!),
    filename: file.name,
    sql: file.readAsStringSync(),
  );
}

Future<void> _applyMigration(
  Connection connection,
  _Migration migration,
) async {
  await connection.runTx((tx) async {
    await tx.execute(migration.sql);
    await tx.execute(
      Sql.named(
        'INSERT INTO schema_migrations (id, filename) '
        'VALUES (@id, @filename)',
      ),
      parameters: {'id': migration.id, 'filename': migration.filename},
    );
  });
  print('Aplicada: ${migration.filename}');
}

List<_MigrationFile> _findMigrationFiles() {
  final dir = Directory('migrations');
  if (!dir.existsSync()) {
    throw StateError(
      'Directorio migrations/ no encontrado. Correr desde backend/.',
    );
  }
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .map(_MigrationFile.new)
      .toList();
}

class _MigrationFile {
  _MigrationFile(this._file);

  final File _file;

  String get name => _file.uri.pathSegments.last;

  String readAsStringSync() => _file.readAsStringSync();
}

class _Migration {
  _Migration({required this.id, required this.filename, required this.sql});

  final int id;
  final String filename;
  final String sql;
}
