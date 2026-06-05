import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('ERROR: No se proporcionó archivo de mensaje.');
    exit(1);
  }

  final file = File(args[0]);
  final message = file.readAsStringSync().trim();

  final pattern = RegExp(
    r'^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,72}$',
  );

  if (!pattern.hasMatch(message)) {
    print('');
    print('ERROR: Mensaje de commit inválido.');
    print('Formato requerido: tipo(scope): descripción');
    print('Ejemplo: feat(auth): agregar login con JWT');
    print('Tipos válidos: feat fix docs style refactor test chore');
    print('');
    exit(1);
  }

  print('Mensaje de commit válido.');
  exit(0);
}
