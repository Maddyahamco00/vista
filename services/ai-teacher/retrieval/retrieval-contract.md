# Retrieval Contract (Phase 0)

This document defines how the AI teacher retrieves KB content.

## 1) Determine retrieval targets
From request:
- If context.lessonId exists → retrieve lesson + its sources
- Else if context.letter exists → retrieve relevant letter lesson(s) + makharij/sifaat rule mappings
- Else if context.ruleTopic exists → retrieve tajweed rules for that topic
- If context.surahNumber & ayahNumber exist → retrieve recitation examples for those indices

## 2) Candidate retrieval
- Retrieve up to N lesson/rule/reciter candidates.
- Rank by:
  - exact match (lessonId, ruleTopic, letter)
  - unit/level proximity

## 3) Provenance gate (mandatory)
For each candidate used to generate scholarGroundedExplanation:
- Load all `lesson_sources_map` or `rule_sources_map` referenceSpans
- Verify `reference_spans.ingestion_status == 'complete'`
- If not complete:
  - do not use that content in responses
  - mark response provenance status accordingly

## 4) Assemble response
- simpleExplanation: from selected lesson payload
- scholarGroundedExplanation: from selected lesson/rule stored content
- correctRecitation: from selected media examples
- practice & assessment: from selected lesson
- citations: all used referenceSpanIds

## 5) Return
- Must conform to `response.schema.json`

