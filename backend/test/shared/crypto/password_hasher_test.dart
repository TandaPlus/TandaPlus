import 'package:backend/src/shared/crypto/password_hasher.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordHasher', () {
    const hasher = PasswordHasher();

    test('genera un hash distinto para la misma contrasena', () {
      const password = 'contrasena-super-segura-123';
      final hashA = hasher.hash(password);
      final hashB = hasher.hash(password);
      expect(hashA, isNot(equals(hashB)));
    });

    test('el hash generado tiene formato PHC de argon2id', () {
      final result = hasher.hash('contrasena-123');
      expect(result, startsWith(r'$argon2id$'));
    });

    test('verify regresa true con la contrasena correcta', () {
      const password = 'otra-contrasena-valida';
      final hashed = hasher.hash(password);
      expect(hasher.verify(password, hashed), isTrue);
    });

    test('verify regresa false con la contrasena incorrecta', () {
      const password = 'password-correcto';
      final hashed = hasher.hash(password);
      expect(hasher.verify('password-incorrecto', hashed), isFalse);
    });

    test('verify regresa false con un hash con formato invalido', () {
      final result = hasher.verify('cualquier-password', 'no-es-un-phc');
      expect(result, isFalse);
    });
  });
}
