import 'package:postgres/postgres.dart';

/// Singleton del pool de conexiones a PostgreSQL.
///
/// Aplicación explícita del patrón Singleton requerido por la rúbrica de la
/// Unidad III (Actividad 3, criterio #2) y documentado en el Word original
/// del proyecto, sección 5 (Patrones de Diseño).
///
/// Razón: una única instancia del pool por proceso evita agotar el límite
/// de conexiones del servidor y centraliza la configuración de la base de
/// datos. La primera llamada a [instance] inicializa la conexión; las
/// siguientes devuelven la misma referencia.
class PostgresPool {
  PostgresPool._({required this.connection});

  /// Conexión activa al pool de Postgres.
  final Connection connection;

  /// Instancia única del Singleton. Nullable porque se inicializa de forma
  /// perezosa en la primera llamada a [instance].
  static PostgresPool? _instance;

  /// Devuelve la instancia única del pool.
  ///
  /// La primera llamada parsea [databaseUrl] (formato
  /// `postgres://usuario:contraseña@host:puerto/base_de_datos`) y abre la
  /// conexión. Las siguientes llamadas devuelven la instancia ya creada
  /// sin reabrir nada.
  static Future<PostgresPool> instance(String databaseUrl) async {
    if (_instance != null) return _instance!;

    final uri = Uri.parse(databaseUrl);
    final userInfo = uri.userInfo.split(':');

    final connection = await Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.port == 0 ? 5432 : uri.port,
        database: uri.pathSegments.first,
        username: userInfo.first,
        password: userInfo.length > 1 ? userInfo[1] : '',
      ),
      settings: const ConnectionSettings(
        // TODO(Cristian-Oropeza): cambiar a SslMode.require al desplegar
        // a produccion (Sprint 5).}
      ),
    );

    _instance = PostgresPool._(connection: connection);
    return _instance!;
  }

  /// Cierra la conexión y libera la instancia. Usar solo en shutdown del
  /// servidor o en tests que necesiten reinicializar el Singleton.
  static Future<void> dispose() async {
    await _instance?.connection.close();
    _instance = null;
  }
}
