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

-- Student attempts will be phase 1; placeholder future tables:
CREATE TABLE IF NOT EXISTS student_attempts (
  id                TEXT PRIMARY KEY,
  -- student_id will exist in Phase 1
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

