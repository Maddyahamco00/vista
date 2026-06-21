# Ingestion Format Spec (Phase 0)

This spec defines how approved scholar content must be prepared before it can be used in AI responses.

## 1) Source types
- Written: books/qaida/notes
- Audio/video: lesson recordings with timestamps

## 2) Required annotations
For each ingested item:
- `workId`
- `referenceSpanId`
- `locationType` (page|chapter|section|timestamp|verseRange)
- `locationValue`
- `ingestion_status` (complete)

## 3) Content fields
Ingested lesson payloads must include:
- `explanation.scholarGrounded.content`
- list of `scholarReferences` with `referenceSpanId`

Ingested tajweed rule payloads must include:
- `ruleDescription.provenance` or stored `referenceSpanIds` in DB maps

## 4) Governance
- No content without reference spans.
- If ingestion is partial, mark status as partial/missing and block AI claims.

