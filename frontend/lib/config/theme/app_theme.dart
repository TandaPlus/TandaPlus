import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de la aplicacion basado en Material 3.
///
/// Usa como color semilla el emerald `#10B981` definido en el branding
/// del proyecto y la tipografia Inter cargada desde Google Fonts.
class AppTheme {
  const AppTheme._();

  /// Color semilla del esquema Material 3.
  static const Color seedColor = Color(0xFF10B981);

  /// Construye el tema claro de la aplicacion.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }
}
