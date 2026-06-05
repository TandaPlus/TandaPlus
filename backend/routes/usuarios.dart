import 'package:dart_frog/dart_frog.dart';

final List<Map<String, dynamic>> _baseDeDatosFalsa = [
  {'id': 1, 'nombre': 'Ana', 'activo': true},
  {'id': 2, 'nombre': 'Carlos', 'activo': false},
];

Future<Response> onRequest(RequestContext context) async {
  try {
    final activos = _baseDeDatosFalsa
        .where((u) => u['activo'] as bool)
        .toList();

    return Response.json(body: {'ok': true, 'data': activos});
  } catch (error) {
    return Response.json(
      statusCode: 500,
      body: {'ok': false, 'error': error.toString()},
    );
  }
}
