import 'package:flutter/material.dart';

/// Pantalla temporal de inicio.
///
/// Sirve para validar que el arranque del proyecto (dotenv, Riverpod,
/// go_router y el tema) funciona correctamente antes de agregar
/// funcionalidad real en sprints posteriores.
class HomeScreen extends StatelessWidget {
  /// Crea la pantalla de inicio placeholder.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'TandaPlus',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
