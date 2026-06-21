-- Phase 0 — Quran Education KB Foundation (Schema)
-- Target: scalable KB + curriculum + provenance
-- Note: Phase 0 app code may not exist yet; this is the foundation schema.

BEGIN;

-- --- Curriculum levels ---
CREATE TABLE IF NOT EXISTS curriculum_levels (
  id                TEXT PRIMARY KEY,
  name              TEXT NOT NULL,
  description       TEXT,
  sort_order        INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS curriculum_units (
  id                TEXT PRIMARY KEY,
  level_id          TEXT NOT NULL REFERENCES curriculum_levels(id),
  name              TEXT NOT NULL,
  description       TEXT,
  sort_order        INTEGER NOT NULL
);

-- Optional: explicit curriculum prerequisite edges (graph)
CREATE TABLE IF NOT EXISTS curriculum_prerequisites (
  from_unit_id      TEXT NOT NULL REFERENCES curriculum_units(id),
  to_unit_id        TEXT NOT NULL REFERENCES curriculum_units(id),
  edge_type         TEXT NOT NULL DEFAULT 'prerequisite',
  PRIMARY KEY(from_unit_id, to_unit_id, edge_type)
);

-- --- Lessons ---
CREATE TABLE IF NOT EXISTS lessons (
  id                  TEXT PRIMARY KEY,
  unit_id             TEXT REFERENCES curriculum_units(id),
  lesson_title        TEXT NOT NULL,
  learning_objective  TEXT NOT NULL,

  -- Store scholar-grounded content (or pointers) as JSON/markdown
  explanation_simple   TEXT,
  explanation_payload  JSONB,

  difficulty_level     INTEGER DEFAULT 1,
  tags                  TEXT[] DEFAULT ARRAY[]::TEXT[],

  requires_provenance   BOOLEAN NOT NULL DEFAULT TRUE,
  provenance_status     TEXT NOT NULL DEFAULT 'missing', -- missing|partial|complete
  created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS lesson_prerequisites (
  lesson_id                 TEXT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  prerequisite_lesson_id   TEXT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  PRIMARY KEY (lesson_id, prerequisite_lesson_id)
);

CREATE TABLE IF NOT EXISTS lesson_exercises (
  id                TEXT PRIMARY KEY,
  lesson_id         TEXT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  exercise_type     TEXT NOT NULL,
  prompt            TEXT NOT NULL,
  steps             JSONB NOT NULL,
  student_output_format TEXT NOT NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS assessments (
  id                 TEXT PRIMARY KEY,
  lesson_id          TEXT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  method_type        TEXT NOT NULL,
  rubric_json        JSONB,
  pass_criteria_json JSONB,
  evaluation_notes   TEXT,
  created_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

-- --- Letters / phonetics mapping ---
CREATE TABLE IF NOT EXISTS letters (
  id            TEXT PRIMARY KEY,
  arabic_char   TEXT NOT NULL,
  letter_name   TEXT,
  base_form     TEXT,
  join_group    TEXT[] DEFAULT ARRAY[]::TEXT[]
);

CREATE TABLE IF NOT EXISTS makharij_points (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT
);

CREATE TABLE IF NOT EXISTS letter_makharij_map (
  letter_id     TEXT NOT NULL REFERENCES letters(id) ON DELETE CASCADE,
  makharij_id   TEXT NOT NULL REFERENCES makharij_points(id) ON DELETE CASCADE,
  PRIMARY KEY(letter_id, makharij_id)
);

-- Sifaat (attributes/traits)
CREATE TABLE IF NOT EXISTS sifaat_attributes (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT
);

CREATE TABLE IF NOT EXISTS letter_sifaat_map (
  letter_id     TEXT NOT NULL REFERENCES letters(id) ON DELETE CASCADE,
  sifaat_id     TEXT NOT NULL REFERENCES sifaat_attributes(id) ON DELETE CASCADE,
  PRIMARY KEY(letter_id, sifaat_id)
);

-- --- Tajweed rules ---
CREATE TABLE IF NOT EXISTS tajweed_rules (
  id              TEXT PRIMARY KEY,
  topic           TEXT NOT NULL,
  rule_name       TEXT NOT NULL,
  rule_description TEXT,
  description_payload JSONB,
  requires_provenance BOOLEAN NOT NULL DEFAULT TRUE,
  provenance_status TEXT NOT NULL DEFAULT 'missing'
);

CREATE TABLE IF NOT EXISTS tajweed_rule_applicability (
  id            TEXT PRIMARY KEY,
  rule_id       TEXT NOT NULL REFERENCES tajweed_rules(id) ON DELETE CASCADE,
  letter_id     TEXT REFERENCES letters(id) ON DELETE SET NULL,
  context_tag   TEXT,
  notes          TEXT
);

CREATE TABLE IF NOT EXISTS rule_examples (
  id                TEXT PRIMARY KEY,
  rule_id           TEXT NOT NULL REFERENCES tajweed_rules(id) ON DELETE CASCADE,
  example_text     TEXT,
  common_mistakes_json JSONB,
  correct_output_audio_ref_id TEXT
);

-- --- Reciters & examples ---
CREATE TABLE IF NOT EXISTS reciters (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  sort_name     TEXT,
  notes         TEXT
);

CREATE TABLE IF NOT EXISTS recitation_examples (
  id              TEXT PRIMARY KEY,
  reciter_id      TEXT NOT NULL REFERENCES reciters(id) ON DELETE CASCADE,
  surah_number    INTEGER NOT NULL,
  ayah_number     INTEGER NOT NULL,
  learning_purpose TEXT,
  example_text    TEXT
);

CREATE TABLE IF NOT EXISTS recitation_example_mistakes (
  id                     TEXT PRIMARY KEY,
  recitation_example_id  TEXT NOT NULL REFERENCES recitation_examples(id) ON DELETE CASCADE,
  mistake_type           TEXT NOT NULL,
  mistake_description    TEXT NOT NULL,
  correction_rationale   TEXT
);

-- --- Media registry ---
CREATE TABLE IF NOT EXISTS media_assets (
  id                TEXT PRIMARY KEY,
  kind              TEXT NOT NULL, -- audio|video
  provider         TEXT,
  storage_key_or_url TEXT NOT NULL,
  duration_ms      INTEGER,
  license_notes    TEXT
);

CREATE TABLE IF NOT EXISTS media_segments (
  id                TEXT PRIMARY KEY,
  media_id         TEXT NOT NULL REFERENCES media_assets(id) ON DELETE CASCADE,
  start_ms          INTEGER NOT NULL,
  end_ms            INTEGER NOT NULL,
  description       TEXT
);

-- --- Scholars & provenance ---
CREATE TABLE IF NOT EXISTS scholars (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  bio_short   TEXT,
  notes       TEXT
);

CREATE TABLE IF NOT EXISTS scholar_works (
  id           TEXT PRIMARY KEY,
  scholar_id   TEXT NOT NULL REFERENCES scholars(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  work_type    TEXT NOT NULL, -- book|qaida|course|lecture|guide
  edition      TEXT,
  publisher    TEXT,
  year         TEXT,
  notes        TEXT
);

CREATE TABLE IF NOT EXISTS reference_spans (
  id               TEXT PRIMARY KEY,
  work_id          TEXT NOT NULL REFERENCES scholar_works(id) ON DELETE CASCADE,
  location_type    TEXT NOT NULL, -- page|chapter|section|timestamp|verseRange
  location_value   TEXT NOT NULL,
  quote_text       TEXT,
  ingestion_status TEXT NOT NULL DEFAULT 'pending' -- pending|complete
);

-- Links from lessons/rules/media back to reference spans
CREATE TABLE IF NOT EXISTS lesson_sources_map (
  lesson_id          TEXT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  reference_span_id TEXT NOT NULL REFERENCES reference_spans(id) ON DELETE RESTRICT,
  PRIMARY KEY(lesson_id, reference_span_id)
);

CREATE TABLE IF NOT EXISTS rule_sources_map (
  rule_id            TEXT NOT NULL REFERENCES tajweed_rules(id) ON DELETE CASCADE,
  reference_span_id TEXT NOT NULL REFERENCES reference_spans(id) ON DELETE RESTRICT,
  PRIMARY KEY(rule_id, reference_span_id)
);

CREATE TABLE IF NOT EXISTS media_sources_map (
  media_asset_id    TEXT NOT NULL REFERENCES media_assets(id) ON DELETE CASCADE,
  reference_span_id TEXT NOT NULL REFERENCES reference_spans(id) ON DELETE RESTRICT,
  PRIMARY KEY(media_asset_id, reference_span_id)
);

-- -----------------------------
-- Phase 1 — Student platform
-- -----------------------------

-- --- Auth & RBAC ---
CREATE TYPE user_role AS ENUM ('student', 'parent', 'admin');

-- Ensure citext extension exists (email case-insensitive)
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  email         CITEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          user_role NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);


-- --- Student profile ---
-- learning goals: reading, tajweed, memorization, recitation
CREATE TYPE learning_goal AS ENUM (
  'quran_reading',
  'tajweed_improvement',
  'memorization',
  'recitation_improvement'
);

CREATE TYPE gender AS ENUM ('male', 'female', 'other');

CREATE TABLE IF NOT EXISTS student_profiles (
  student_id          TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  age                 INTEGER,
  gender              gender,
  country             TEXT,
  preferred_language  TEXT,
  current_level       TEXT,
  learning_goal       learning_goal NOT NULL,
  created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),

);

-- --- Parent ↔ Students ---
CREATE TABLE IF NOT EXISTS parents (
  parent_id  TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS parent_students (
  parent_id  TEXT NOT NULL REFERENCES parents(parent_id) ON DELETE CASCADE,
  student_id TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY(parent_id, student_id)
);

-- --- Courses abstraction (maps to lessons) ---
-- Phase 1 keeps Phase 0 `lessons` as the canonical lesson entity.
-- Courses provide a student-facing grouping.
CREATE TABLE IF NOT EXISTS courses (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  description TEXT,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Each course contains a set of lesson_ids (optionally ordered + level scoped)
CREATE TABLE IF NOT EXISTS course_lessons (
  course_id    TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id    TEXT NOT NULL REFERENCES lessons(id) ON DELETE RESTRICT,
  sort_order   INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(course_id, lesson_id)
);

-- Student progress per course
CREATE TABLE IF NOT EXISTS student_course_progress (
  student_id     TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  course_id      TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  progress_percent INTEGER NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  status         TEXT NOT NULL DEFAULT 'active', -- active|completed
  updated_at     TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY(student_id, course_id)
);

-- Completion per lesson
CREATE TABLE IF NOT EXISTS lesson_completion (
  student_id     TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  lesson_id      TEXT NOT NULL REFERENCES lessons(id) ON DELETE RESTRICT,
  status         TEXT NOT NULL DEFAULT 'not_started', -- not_started|in_progress|completed
  completed_at   TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY(student_id, lesson_id)
);

-- --- Assessment sessions (foundation) ---
CREATE TYPE assessment_status AS ENUM ('created', 'started', 'submitted', 'evaluated', 'cancelled');
CREATE TYPE assessment_type AS ENUM ('reading_test', 'tajweed_test', 'memorization_test');

CREATE TABLE IF NOT EXISTS assessment_sessions (
  id          TEXT PRIMARY KEY,
  student_id  TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  type        assessment_type NOT NULL,
  status      assessment_status NOT NULL DEFAULT 'created',
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- --- Audio recording foundation ---
CREATE TABLE IF NOT EXISTS audio_submissions (
  id                     TEXT PRIMARY KEY,
  student_id             TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  assessment_session_id TEXT NOT NULL REFERENCES assessment_sessions(id) ON DELETE CASCADE,
  audio_url             TEXT NOT NULL,
  duration_ms          INTEGER,
  created_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for scalability
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_student_course_progress_student ON student_course_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_student_course_progress_course ON student_course_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completion_student ON lesson_completion(student_id);
CREATE INDEX IF NOT EXISTS idx_assessment_sessions_student ON assessment_sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_audio_submissions_session ON audio_submissions(assessment_session_id);

-- Student attempts (Phase 1 evaluation storage; references are now real)
CREATE TABLE IF NOT EXISTS student_attempts (
  id                TEXT PRIMARY KEY,
  student_id       TEXT NOT NULL REFERENCES student_profiles(student_id) ON DELETE CASCADE,
  lesson_id         TEXT NOT NULL REFERENCES lessons(id) ON DELETE RESTRICT,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
  attempt_payload   JSONB
);

CREATE TABLE IF NOT EXISTS student_attempt_scores (
  id                TEXT PRIMARY KEY,
  student_attempt_id TEXT NOT NULL REFERENCES student_attempts(id) ON DELETE CASCADE,
  assessment_id     TEXT NOT NULL REFERENCES assessments(id) ON DELETE RESTRICT,
  score_value       NUMERIC,
  signals_json      JSONB,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMIT;


