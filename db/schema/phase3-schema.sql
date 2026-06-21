-- Phase 3 — AI Teacher Memory + Pronunciation Correction Engine
-- Target: extend Phase 0/1 schema without breaking existing tables.

BEGIN;

-- -----------------------------
-- Student learning memory
-- -----------------------------
CREATE TABLE IF NOT EXISTS student_learning_memory (
  student_id     TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  topic          TEXT NOT NULL,

  -- Store structured mistake + correction info.
  -- Example shape:
  -- { "letter": "ض", "makharij": {...}, "sifaat": {...}, "examples": [...] }
  mistakes_json  JSONB NOT NULL DEFAULT '{}'::JSONB,
  correction_json JSONB NOT NULL DEFAULT '{}'::JSONB,

  -- progress_score is normalized 0..1 for topic mastery.
  progress_score NUMERIC NOT NULL DEFAULT 0 CHECK (progress_score >= 0 AND progress_score <= 1),

  last_practice  TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT NOW(),

  PRIMARY KEY(student_id, topic)
);

CREATE INDEX IF NOT EXISTS idx_slm_student_topic ON student_learning_memory(student_id, topic);
CREATE INDEX IF NOT EXISTS idx_slm_student_last_practice ON student_learning_memory(student_id, last_practice);

-- -----------------------------
-- Pronunciation diagnostics
-- -----------------------------
CREATE TYPE pronunciation_diagnostic_class AS ENUM ('makharij','sifaat','tajweed','unknown');

CREATE TABLE IF NOT EXISTS pronunciation_diagnostics (
  id                TEXT PRIMARY KEY,
  student_id       TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  attempt_id       TEXT REFERENCES student_attempts(id) ON DELETE SET NULL,
  audio_job_id     TEXT REFERENCES audio_processing_jobs(id) ON DELETE SET NULL,

  target_letter    TEXT,
  diagnostic_class pronunciation_diagnostic_class NOT NULL DEFAULT 'unknown',

  diagnostic_signals_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  ranked_hypotheses_json  JSONB NOT NULL DEFAULT '[]'::JSONB,

  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pr_diag_student_created ON pronunciation_diagnostics(student_id, created_at);
CREATE INDEX IF NOT EXISTS idx_pr_diag_attempt ON pronunciation_diagnostics(attempt_id);

-- -----------------------------
-- Pronunciation corrections
-- -----------------------------
CREATE TABLE IF NOT EXISTS pronunciation_corrections (
  id                     TEXT PRIMARY KEY,
  diagnostic_id          TEXT NOT NULL REFERENCES pronunciation_diagnostics(id) ON DELETE CASCADE,

  -- Correction plan presented to student.
  -- Example shape: { "steps": [ ... ], "drill": {...}, "targetSegments": [...] }
  correction_plan_json  JSONB NOT NULL DEFAULT '{}'::JSONB,

  -- Must cite reference spans via governance in app layer.
  -- Store any attached citation identifiers for audit.
  citations_json         JSONB NOT NULL DEFAULT '[]'::JSONB,

  -- Free-text rationale derived only from scholar-grounded KB payload.
  feedback_rationale    TEXT,

  applied_at             TIMESTAMP,
  outcome_json          JSONB NOT NULL DEFAULT '{}'::JSONB,

  created_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pr_corr_diagnostic ON pronunciation_corrections(diagnostic_id, created_at);

-- -----------------------------
-- AI teacher sessions
-- -----------------------------
CREATE TYPE ai_teacher_mode AS ENUM ('child','adult','advanced');
CREATE TYPE ai_teacher_session_status AS ENUM ('created','in_progress','completed','cancelled');

CREATE TABLE IF NOT EXISTS ai_teacher_sessions (
  id          TEXT PRIMARY KEY,
  student_id  TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  status      ai_teacher_session_status NOT NULL DEFAULT 'created',
  mode        ai_teacher_mode NOT NULL DEFAULT 'adult',

  current_activity_payload_json JSONB NOT NULL DEFAULT '{}'::JSONB,

  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_teacher_sessions_student_status ON ai_teacher_sessions(student_id, status);

-- -----------------------------
-- AI recommendations cache (daily plan)
-- -----------------------------
CREATE TABLE IF NOT EXISTS ai_teacher_recommendations (
  id          TEXT PRIMARY KEY,
  session_id  TEXT NOT NULL REFERENCES ai_teacher_sessions(id) ON DELETE CASCADE,

  start_date  DATE NOT NULL,
  end_date    DATE,

  daily_plan_json JSONB NOT NULL DEFAULT '{}'::JSONB,

  -- Optional denormalized citations for UI display.
  citations_json  JSONB NOT NULL DEFAULT '[]'::JSONB,

  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_teacher_reco_session_dates ON ai_teacher_recommendations(session_id, start_date);

-- -----------------------------
-- Optional: letter pronunciation targets
-- -----------------------------
-- This normalizes drills for a single Arabic letter target.
-- It is optional; can be replaced by lesson-driven drills.
CREATE TABLE IF NOT EXISTS letter_pronunciation_targets (
  id                TEXT PRIMARY KEY,
  letter_id         TEXT REFERENCES letters(id) ON DELETE SET NULL,
  target_letter    TEXT,

  makharij_points_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  sifaat_attributes_json JSONB NOT NULL DEFAULT '{}'::JSONB,

  common_mistakes_json JSONB NOT NULL DEFAULT '[]'::JSONB,

  -- Media ids can be linked later; store optional.
  correct_audio_media_id TEXT REFERENCES media_assets(id) ON DELETE SET NULL,

  practice_words_json JSONB NOT NULL DEFAULT '[]'::JSONB,

  created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lpt_letter ON letter_pronunciation_targets(target_letter);

COMMIT;

