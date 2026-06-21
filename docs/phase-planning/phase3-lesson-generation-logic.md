# Phase 3 — Lesson Generation Logic

## Objective
Generate a personalized daily plan and lesson flow based on:
- student level
- weaknesses & common mistakes
- completed lessons
- learning speed

## Key constraint
Lesson explanations and correction rationales must come from stored scholar-grounded KB. Generation is limited to:
- selecting which KB items to show
- assembling the delivery flow
- choosing drill repetition counts
- applying teaching mode style

## Algorithm (high level)

### Inputs
- `student_learning_memory`:
  - topic → progress_score, last_practice
- `student_course_progress` + `lesson_completion`
- curriculum graph constraints:
  - prerequisites in `curriculum_prerequisites` and `lesson_prerequisites`
- available provenance:
  - only include candidates whose linked `reference_spans.ingestion_status = complete`

### Outputs
- `daily_plan_json` (Day 1..Day N)
- `next_activity_payload` (lessonId / letter/rule target / practice exercise)

## Scoring model (conceptual)
For each candidate topic T:
- `need(T) = (1 - mastery(T)) * weight(T)`
- `mastery(T)` derived from memory progress_score
- `weight(T)` derived from frequency/severity of past mistakes

Then choose next topics by:
- must satisfy prerequisites for T
- prefer topics with highest `need(T)`
- diversify across makharij/sifaat/tajweed + reading/fluency if student pace is slow

## Teaching modes
Mode affects only formatting:
- Child Mode: shorter steps, more repetition, emojis
- Adult Mode: standard terms (Makharij/Sifaat) explained by KB payload
- Advanced Mode: emphasizes technical mapping and more detailed drills

## Recommendation examples (format only)
- Day 1: Makharij of ض (lessonId or target letter)
- Day 2: Practice integration in short surah segment (recitation example reference)
- Day 3: Revision + mixed drills on weak subpoints

## Provenance-aware candidate filtering
- Any candidate whose rule/lesson explanation requires provenance that is missing/partial is excluded.
- If all candidates for a topic are excluded, provide only generic practice (no rule facts).

