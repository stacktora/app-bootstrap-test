-- docker/init.sql — runs once on first database boot (mounted into the container)
-- Add your schema + seed rows here. Safe to re-run via `make db-seed`.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email      TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO users (email) VALUES ('dev@example.com')
  ON CONFLICT (email) DO NOTHING;
