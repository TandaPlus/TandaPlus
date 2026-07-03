import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso tipado a las variables de entorno cargadas desde `.env`.
///
/// El archivo `.env` debe cargarse en `main()` mediante `dotenv.load()`
/// antes de leer cualquier valor de esta clase.
class Environment {
  const Environment._();

  /// URL base del backend TandaPlus para peticiones HTTP y WebSocket.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
}
