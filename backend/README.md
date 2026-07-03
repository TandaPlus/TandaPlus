# backend

[![style: dart frog lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

An example application built with dart_frog

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT

## Migraciones

El schema vive en `migrations/` como archivos SQL numerados. Un runner en
Dart aplica solo las que no se han corrido, registrando cada una en la
tabla `schema_migrations`.

Requisitos: `DATABASE_URL` en el entorno o en `.env` (formato
`postgres://usuario:password@host:puerto/db`).

Aplicar todas las migraciones pendientes:

\`\`\`bash
cd backend
dart run tool/migrate.dart
\`\`\`

Salida esperada la primera vez sobre una BD limpia:

\`\`\`
Conectado a Postgres.
Meta aplicada: _meta_schema_migrations.sql
Aplicada: 001_init.sql
Aplicadas 1 migracion(es).
\`\`\`

Correrlo de nuevo con la BD ya migrada:

\`\`\`
Conectado a Postgres.
Meta aplicada: _meta_schema_migrations.sql
Sin migraciones pendientes. Todo al dia.
\`\`\`

Para agregar una nueva migracion, crea `migrations/002_lo_que_sea.sql` con
el prefijo numerico siguiente y correr el runner.