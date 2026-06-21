# Phase 3 — Database Schema (AI Teacher Memory + Pronunciation Correction)

## Invariants
- Scholar-grounded content in AI responses must be backed by `reference_spans` where `ingestion_status = 'complete'`.
- Pronunciation correction rationales must reference stored scholar sources.

## Existing base schema (already present)
From `db/schema/schema.sql`:
- Curriculum & lessons: `curriculum_levels`, `curriculum_units`, `lessons`
- Scholar provenance: `scholars`, `scholar_works`, `reference_spans`, *_sources_map
- Student attempts: `student_attempts`, `student_attempt_scores`
- Assessment sessions: `assessment_sessions`, `audio_submissions`
- Interview/session placement: `ai_interview_sessions`, `quran_assessment_results`

## Phase 3 additions (proposed)

### 1) Student learning memory (topic-level)
**Table:** `student_learning_memory`
- `student_id` (FK)
- `topic` (e.g., makharij:duad, ghunnah, qalqalah)
- `mistake` (structured text or json)
- `correction` (structured text or json)
- `progress_score` (0..1 or 0..100)
- `last_practice` timestamp
- `updated_at`

### 2) Pronunciation diagnostics (what went wrong)
**Table:** `pronunciation_diagnostics`
- `id`
- `student_id`
- `attempt_id` (FK to student_attempts) or `audio_processing_job_id`
- `target_letter` (Arabic char)
- `diagnostic_class` enum: makharij | sifaat | tajweed
- `diagnostic_signals_json` (normalized phoneme distances, confidence)
- `ranked_hypotheses_json`
- `created_at`

### 3) Pronunciation corrections (what the AI proposed)
**Table:** `pronunciation_corrections`
- `id`
- `diagnostic_id` (FK)
- `correction_plan_json` (what to practice and in what order)
- `feedback_rationale` (must cite reference spans)
- `applied_at` timestamp
- `outcome_json` (did it improve?)
- `created_at`

### 4) AI teacher sessions (stateful conversation/lesson flows)
**Table:** `ai_teacher_sessions`
- `id`
- `student_id`
- `status` enum: created | in_progress | completed | cancelled
- `mode` enum: child | adult | advanced
- `current_activity_payload_json`
- `created_at`, `updated_at`

### 5) AI recommendations cache (next activities)
**Table:** `ai_teacher_recommendations`
- `id`
- `session_id` FK
- `start_date`, `end_date`
- `daily_plan_json`
- `citations_json` (optional denormalized list)
- `created_at`

### 6) Letter pronunciation targets (optional normalization)
If you want explicit letter drills independent of lessons:
**Table:** `letter_pronunciation_targets`
- `letter_id` (FK)
- `makharij_points_json` (or join table)
- `sifaat_attributes_json`
- `common_mistakes_json`
- `correct_audio_media_id`
- `practice_words_json` (words that include the letter)

## Phase 3 indexes (for million-student scaling)
- `student_learning_memory(student_id, topic)`
- `pronunciation_diagnostics(student_id, created_at)`
- `ai_teacher_sessions(student_id, status)`
- `ai_teacher_recommendations(session_id, start_date)`

## Implementation note
Prefer reading scholar-grounded lesson content from `lessons.explanation.scholarGrounded` fields, and use *_sources_map + `reference_spans` for citations/provenance gating.

