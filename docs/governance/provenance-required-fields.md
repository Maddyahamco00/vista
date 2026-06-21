# Provenance Required Fields (Phase 0)

Any content used by the AI teacher must have a complete provenance chain.

## Required content types
- Lesson scholar-grounded explanation (`lesson.explanation.scholarGrounded.content`)
- Tajweed rule descriptions (`tajweed_rules.rule_description`)
- Common mistakes + correction rationale (when presented as corrective guidance)
- Media segments and examples (audio/video must be linked to reference spans)

## Required provenance artifacts
- `reference_spans` rows linked via:
  - `lesson_sources_map`
  - `rule_sources_map`
  - `media_sources_map`

## Validation rule (Phase 0)
Before assembling `scholarGroundedExplanation.content`:
- For every `referenceSpanId` used, enforce:
  - `reference_spans.ingestion_status == 'complete'`

If any fail:
- Do not use that candidate content in the response.
- Return refusal/deferral provenance status.

