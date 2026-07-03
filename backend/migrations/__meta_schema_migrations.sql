-- Meta migracion: crea la tabla de tracking de migraciones aplicadas.
-- Este archivo se ejecuta siempre al inicio del runner (idempotente).

CREATE TABLE IF NOT EXISTS schema_migrations (
  id INTEGER PRIMARY KEY,
  filename TEXT NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);