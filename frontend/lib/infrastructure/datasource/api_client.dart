import 'package:dio/dio.dart';
import 'package:frontend/config/constants/environment.dart';

/// Cliente HTTP centralizado para consumir la API de TandaPlus.
///
/// Envuelve una instancia de `Dio` y registra un interceptor placeholder
/// que en el Sprint 3 inyectara el JWT en el header `Authorization`.
class ApiClient {
  /// Crea el cliente configurando la URL base desde el entorno.
  ApiClient() : _dio = Dio(BaseOptions(baseUrl: Environment.apiBaseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO(USER1FR0): inyectar JWT desde AuthNotifier (Sprint 3).
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  /// Instancia interna de `Dio` para uso de repositorios.
  Dio get dio => _dio;
}
