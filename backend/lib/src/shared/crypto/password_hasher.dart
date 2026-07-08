import 'dart:convert';

import 'package:hashlib/hashlib.dart';
import 'package:hashlib/random.dart';

/// Longitud de sal en bytes recomendada para Argon2id (16 bytes).
const int _defaultSaltLength = 16;

/// Costo de memoria en KiB (19 MiB), minimo recomendado por OWASP.
const int _defaultMemorySizeKB = 19456;

/// Numero de iteraciones (time cost) por defecto.
const int _defaultIterations = 2;

/// Grado de paralelismo por defecto.
const int _defaultParallelism = 1;

/// Longitud del hash derivado en bytes.
const int _defaultHashLength = 32;

/// Helper de hashing y verificacion de contrasenas con Argon2id.
///
/// Usa el paquete `hashlib` (implementacion pura Dart, sin dependencias
/// nativas) y devuelve el hash en formato estandar PHC, por ejemplo:
/// `$argon2id$v=19$m=19456,t=2,p=1$<salt>$<hash>`.
///
/// Parametros alineados con la recomendacion de OWASP para Argon2id:
/// memoryCost >= 19 MiB, timeCost >= 2, parallelism = 1.
class PasswordHasher {
  /// Crea un [PasswordHasher] con parametros Argon2id configurables.
  ///
  /// Los valores por defecto cumplen el minimo recomendado por OWASP.
  const PasswordHasher({
    int memorySizeKB = _defaultMemorySizeKB,
    int iterations = _defaultIterations,
    int parallelism = _defaultParallelism,
    int hashLength = _defaultHashLength,
    int saltLength = _defaultSaltLength,
  }) : _memorySizeKB = memorySizeKB,
       _iterations = iterations,
       _parallelism = parallelism,
       _hashLength = hashLength,
       _saltLength = saltLength;

  final int _memorySizeKB;
  final int _iterations;
  final int _parallelism;
  final int _hashLength;
  final int _saltLength;

  /// Genera un hash Argon2id en formato PHC a partir de [password].
  ///
  /// Cada llamada usa una sal aleatoria nueva, por lo que el resultado
  /// es distinto incluso para la misma contrasena.
  String hash(String password) {
    final salt = randomBytes(_saltLength);
    final argon2 = Argon2(
      memorySizeKB: _memorySizeKB,
      iterations: _iterations,
      parallelism: _parallelism,
      hashLength: _hashLength,
      salt: salt,
    );
    return argon2.encode(utf8.encode(password));
  }

  /// Verifica que [password] corresponda al [hash] PHC dado.
  ///
  /// Devuelve `false` si la contrasena no coincide o si [hash] no
  /// tiene un formato PHC valido de Argon2.
  bool verify(String password, String hash) {
    try {
      return argon2Verify(hash, utf8.encode(password));
    } on FormatException {
      return false;
    }
    // hashlib lanza ArgumentError (no Exception) cuando el string no
    // trae un hash valido (formato PHC malformado). Es una entrada
    // invalida esperada del helper, no un bug de programacion.
    // ignore: avoid_catching_errors
    on ArgumentError {
      return false;
    }
  }
}
