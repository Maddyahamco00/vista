# Phase 3 ERD additions — AI Teacher Memory + Pronunciation Correction

## Scope
Adds entities required for:
- Student learning memory
- Pronunciation diagnostics + correction plans/outcomes
- AI teacher sessions + recommendation cache
- Optional letter pronunciation target normalization

Base tables remain in `db/schema/schema.sql`.

## Mermaid ERD (Phase 3)
```mermaid
erDiagram
  STUDENT_PROFILES {
    TEXT student_id PK
    TEXT current_level
  }

  STUDENT_LEARNING_MEMORY {
    TEXT student_id PK, FK student_profiles
    TEXT topic PK
    JSONB mistakes_json
    JSONB correction_json
    NUMERIC progress_score
    TIMESTAMP last_practice
  }

  STUDENT_ATTEMPTS {
    TEXT id PK
    TEXT student_id
  }

  PRONUNCIATION_DIAGNOSTICS {
    TEXT id PK
    TEXT student_id FK
    TEXT attempt_id FK
    TEXT target_letter
    TEXT diagnostic_class
    JSONB diagnostic_signals_json
  }

  PRONUNCIATION_CORRECTIONS {
    TEXT id PK
    TEXT diagnostic_id FK
    JSONB correction_plan_json
    JSONB citations_json
    TEXT feedback_rationale
    TIMESTAMP applied_at
    JSONB outcome_json
  }

  AI_TEACHER_SESSIONS {
    TEXT id PK
    TEXT student_id FK
    TEXT status
    TEXT mode
    JSONB current_activity_payload_json
  }

  AI_TEACHER_RECOMMENDATIONS {
    TEXT id PK
    TEXT session_id FK
    DATE start_date
    DATE end_date
    JSONB daily_plan_json
    JSONB citations_json
  }

  LETTER_PRONUNCIATION_TARGETS {
    TEXT id PK
    TEXT letter_id FK
    TEXT target_letter
    JSONB makharij_points_json
    JSONB sifaat_attributes_json
    JSONB common_mistakes_json
    TEXT correct_audio_media_id FK
    JSONB practice_words_json
  }

  STUDENT_PROFILES ||--o{ STUDENT_LEARNING_MEMORY : "student_id"
  STUDENT_ATTEMPTS ||--o{ PRONUNCIATION_DIAGNOSTICS : "attempt_id"
  STUDENT_PROFILES ||--o{ PRONUNCIATION_DIAGNOSTICS : "student_id"
  PRONUNCIATION_DIAGNOSTICS ||--o{ PRONUNCIATION_CORRECTIONS : "diagnostic_id"

  STUDENT_PROFILES ||--o{ AI_TEACHER_SESSIONS : "student_id"
  AI_TEACHER_SESSIONS ||--o{ AI_TEACHER_RECOMMENDATIONS : "session_id"

  LETTER_PRONUNCIATION_TARGETS }o--|| LETTERS : "letter_id"
```

## Implementation notes
- `student_learning_memory` is **topic-level** and should be updated after each practice/correction.
- `pronunciation_corrections.citations_json` should store the referenceSpanIds used in the final scholar-grounded guidance.
- For governance/no-hallucination: the application layer must ensure that any scholar-grounded text in `feedback_rationale` is derived from `reference_spans` with `ingestion_status='complete'`.

