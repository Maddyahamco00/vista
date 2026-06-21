# Phase 1 Integration Notes (Student Platform + AI Interview Agent)

## Expected calls into Phase 0
The Phase 1 AI interview agent will call the AI Teacher contract:
- Use `targetSkill` and optional `context` (letter/ruleTopic/surah/ayah/lessonId)

## Retrieval + response
- Retrieval must load candidate lesson/rule/media objects
- Provenance gate is enforced before returning scholarGroundedExplanation

## Evaluation
- Student attempts are scored via Phase 1 assessment pipelines
- Rubrics live in the Phase 0 lessons table (Phase 0 schema already supports rubric_json)

## Storage
- Store pronunciation/text attempts in Phase 1 tables (`student_attempts`, `student_attempt_scores`)

