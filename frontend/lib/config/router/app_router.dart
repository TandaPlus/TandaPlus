import 'package:frontend/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

/// Router principal de la aplicacion.
///
/// Define las rutas de nivel superior. Las pantallas de login y registro
/// son placeholders hasta el Sprint 3.
class AppRouter {
  const AppRouter._();

  /// Instancia unica del router configurada con las rutas base.
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}
