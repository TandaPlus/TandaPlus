-- Migration 001: schema inicial v1
-- Ver contexto.md seccion 6 (Modelo de datos) para el detalle.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tabla de usuarios. Email y nombre cifrados con pgcrypto (RNF-04).
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email BYTEA UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name BYTEA NOT NULL,
  role TEXT NOT NULL DEFAULT 'participant',
  reputation_score INTEGER NOT NULL DEFAULT 100,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL,
  CONSTRAINT ck_users_role CHECK (
    role IN ('organizer', 'participant', 'both')
  )
);

CREATE INDEX idx_users_email ON users (email);

-- Tabla de tandas. Creada por un organizador.
CREATE TABLE tandas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  join_code TEXT UNIQUE NOT NULL,
  participant_count INTEGER NOT NULL,
  periodicity TEXT NOT NULL DEFAULT 'weekly',
  contribution_amount_cents BIGINT NOT NULL,
  cutoff_time TIME NOT NULL,
  daily_fine_cents BIGINT NOT NULL DEFAULT 0,
  fine_strategy TEXT NOT NULL DEFAULT 'fixed',
  include_dead_number BOOLEAN NOT NULL DEFAULT FALSE,
  status TEXT NOT NULL DEFAULT 'draft',
  commission_rate NUMERIC(5,4) NOT NULL DEFAULT 0.05,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ NULL,
  completed_at TIMESTAMPTZ NULL,
  CONSTRAINT ck_tandas_periodicity CHECK (periodicity IN ('weekly')),
  CONSTRAINT ck_tandas_participants CHECK (
    participant_count BETWEEN 2 AND 50
  ),
  CONSTRAINT ck_tandas_contribution CHECK (contribution_amount_cents > 0),
  CONSTRAINT ck_tandas_fine_amount CHECK (daily_fine_cents >= 0),
  CONSTRAINT ck_tandas_fine_strategy CHECK (
    fine_strategy IN ('fixed', 'percentage')
  ),
  CONSTRAINT ck_tandas_status CHECK (
    status IN ('draft', 'active', 'completed')
  )
);

CREATE INDEX idx_tandas_organizer ON tandas (organizer_id);
CREATE INDEX idx_tandas_status ON tandas (status);

-- Participacion. Un usuario se une a una tanda con un turno asignado.
CREATE TABLE tanda_participants (
  tanda_id UUID NOT NULL REFERENCES tandas(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  turn_number INTEGER NOT NULL,
  payout_received BOOLEAN NOT NULL DEFAULT FALSE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (tanda_id, user_id),
  UNIQUE (tanda_id, turn_number)
);

CREATE INDEX idx_tanda_participants_user ON tanda_participants (user_id);

-- Pagos. Uno por participante por ciclo. Validados por el organizador.
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tanda_id UUID NOT NULL REFERENCES tandas(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  cycle_number INTEGER NOT NULL,
  validated_by UUID NULL REFERENCES users(id) ON DELETE SET NULL,
  validated_at TIMESTAMPTZ NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  UNIQUE (tanda_id, user_id, cycle_number),
  CONSTRAINT ck_payments_status CHECK (
    status IN ('pending', 'validated', 'overdue')
  )
);

CREATE INDEX idx_payments_tanda ON payments (tanda_id);
CREATE INDEX idx_payments_status ON payments (status);

-- Multas. Aplicadas por el scheduler al pasar la hora de corte.
CREATE TABLE fines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  amount_cents BIGINT NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ck_fines_amount CHECK (amount_cents > 0)
);

CREATE INDEX idx_fines_payment ON fines (payment_id);

-- Mensajes de chat por tanda.
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tanda_id UUID NOT NULL REFERENCES tandas(id) ON DELETE CASCADE,
  sender_id UUID NULL REFERENCES users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ck_messages_content_len CHECK (
    length(content) BETWEEN 1 AND 500
  )
);

CREATE INDEX idx_messages_tanda_created
  ON messages (tanda_id, created_at DESC);

-- Eventos de reputacion. Alimentan reputation_score de users.
CREATE TABLE reputation_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tanda_id UUID NULL REFERENCES tandas(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  points INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT ck_reputation_type CHECK (
    event_type IN ('on_time', 'late', 'cycle_completed')
  )
);

CREATE INDEX idx_reputation_events_user ON reputation_events (user_id);

-- Bitacoras de auditoria. LGPDPPSO: sin PII, solo IDs.
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID NULL REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_actor_created
  ON audit_logs (actor_id, created_at DESC);
CREATE INDEX idx_audit_logs_target
  ON audit_logs (target_type, target_id);