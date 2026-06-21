# ERD Notes (Phase 0)

This schema is designed to support a KB-first AI teacher:
- Curriculum hierarchy is represented via levels/units.
- Lessons contain student-facing explanation fields, but **only** scholar-grounded content should be marked complete.
- Tajweed rules and recitation examples are linked to **reference_spans** so the AI can cite provenance.

## Provenance enforcement strategy (Phase 0)
- `requires_provenance = true` in `lessons` and `tajweed_rules`.
- `provenance_status` is set to `missing|partial|complete`.
- Links to sources are stored in:
  - `lesson_sources_map`
  - `rule_sources_map`
  - `media_sources_map`

A retrieval/response builder (Phase 1/2) should refuse to generate scholar-claiming text if relevant sources have `reference_spans.ingestion_status != 'complete'`.

## Media segments
- Media segments support drills (timed excerpts) and mistake demonstrations.
- Recitation example mistakes can reference corrective rationale, but that rationale should be linked to `reference_spans` via ingestion.

## Phase 1 integration
- Student attempts are placeholders and store an `attempt_payload` JSON:
  - pronunciation recording path
  - recognized phoneme/score signals
  - rubric evaluation outputs

## Scalability notes
- Use a separate embedding index over:
  - rule_description payload
  - lesson explanation scholarGrounded content
  - reference span quote/paraphrase text (if allowed)
- Keep identifiers stable (`id` strings) for million-student operations.
