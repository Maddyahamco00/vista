# Phase 3 — Testing Strategy

## Test categories

### 1) Unit tests
- Lesson recommendation selection respects:
  - prerequisites
  - student weak areas
  - provenance availability
- Pronunciation correction routing:
  - makharij vs sifaat vs tajweed decision logic
- Memory update logic:
  - progress_score updates + last_practice timestamps

### 2) Contract tests (API schema)
- Validate responses against:
  - `services/ai-teacher/contracts/response.schema.json`
- Ensure required fields always exist:
  - `citations`
  - `provenance`
  - `practice` + `assessment`

### 3) Governance tests (critical)
- Scenario: required `reference_spans.ingestion_status != complete`
  - Expect:
    - `scholarGroundedExplanation` is refused/defers
    - `provenance.status` = missing/partial
    - no scholar-claim text is produced

### 4) Integration tests
- End-to-end:
  1. student submits attempt
  2. correction is generated
  3. practice is shown
  4. memory updated
  5. next lesson recommended

### 5) Performance & load tests
- Ensure recommendation generation and memory queries:
  - use proper indexes
  - do not require full-table scans

### 6) Regression suite
- Verify:
  - “No invented explanations” invariant
  - consistent citations mapping with retrieved KB payloads

