# Phase 3 — Scholar Reference Library Design

## Requirement
The AI Teacher must use **verified educational references** and must not create new Quran explanations.

## Mapping to existing DB
Phase 3 Scholar Reference Library uses the following schema entities (already in `db/schema/schema.sql`):
- `scholars` (name, bio_short)
- `scholar_works` (title, work_type, edition, etc.)
- `reference_spans` (precise authority pointers + `ingestion_status`)
- `lesson_sources_map`, `rule_sources_map`, `media_sources_map` to connect KB lesson/rule/media to `reference_spans`

## Scholar Reference object (as requested)
```text
Scholar Reference:
- Name
- Field (Tajweed / Recitation / Makharij / Sifaat / etc.)
- Lesson category (e.g., Makharij al-Huruf, Ghunnah)
- Video/audio reference
- Explanation (stored only from approved ingestion)
- Tags

Store:
- Surah, Ayah (when applicable to recitation examples)
- Audio (correct recitation)
- Learning purpose
- Tajweed notes
```

## Provenance rules (non-negotiable)
When producing any scholar-grounded content, the system must:
1. Select candidate `referenceSpanIds`
2. Verify `reference_spans.ingestion_status = 'complete'` for every span used
3. Attach `citations` / `referenceSpanIds` in API responses
4. If ingestion is missing/partial:
   - do not generate rule facts
   - return deferral/ refusal message per `services/ai-teacher/prompt-strategies/explain-from-sources.md`

## Ingestion checklist (what must be provided by ingestion)
For each explanation/correction source used in AI output:
- `work_id` linking to an ingested `scholar_works`
- `location_type` and `location_value` (page/chapter/section/timestamp/verseRange)
- optional `quote_text` if allowed by your ingestion policy
- `referenceSpan.ingestion_status` = complete after curation

## Recommended tags taxonomy
- `topic`: makharij | sifaat | tajweed-rule | ghunnah | qalqalah | ikhfa | idgham | iqlab | izhar | stopping-starting
- `letter`: specific Arabic character(s) when applicable
- `context`: isolated-letter | word | verse | ruling-environment
- `reciter`: al-husary | al-minshawi | al-hudhaify | other

## Example: Tajweed — Ayman Suwaid (illustrative)
- Scholar: Ayman Suwaid
- Work: Tajweed methodology (to be filled during ingestion)
- Reference spans:
  - Makharij al-Huruf section
  - Sifaat al-Huruf characteristics section
- Links:
  - attach spans to relevant `tajweed_rules` and/or letter-pronunciation lessons via `rule_sources_map` and/or `lesson_sources_map`

(Implementation depends on your actual ingestion outputs and referenceSpanIds.)

