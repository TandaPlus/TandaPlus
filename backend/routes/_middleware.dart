import 'dart:io';

import 'package:backend/src/infrastructure/database/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

/// Cadena de middleware aplicada a todas las rutas del backend.
Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(_postgresProvider());
}

/// Provider que inyecta el Singleton del pool de Postgres en cada request.
///
/// Los handlers acceden a la conexión con:
/// `final pool = await context.read<Future<PostgresPool>>();`
Middleware _postgresProvider() {
  return provider<Future<PostgresPool>>(
    (_) => PostgresPool.instance(
      Platform.environment['DATABASE_URL'] ??
          'postgres://tandaplus:tandaplus@localhost:5432/tandaplus_dev',
    ),
  );
}
