# TODO_PHASE3_IMPLEMENTATION

## Step 1 — Align lesson recommendation engine with response schema & add routing contract scaffolding
- [x] Review existing `services/ai-teacher/engines/lesson-recommendation.engine.ts` against `services/ai-teacher/contracts/response.schema.json`
- [x] Add missing exports/types for orchestrator + recommendation/citations/provenance

## Step 2 — Add provenance gatekeeper enforcement
- [x] Create `services/ai-teacher/provenance/provenance-gatekeeper.ts`
- [x] Implement `enforceProvenance(...)` that refuses scholar-grounded claims when reference spans ingestion_status != complete

## Step 3 — Add pronunciation correction engine scaffolding
- [x] Create `services/ai-teacher/engines/pronunciation-correction.engine.ts`
- [x] Implement makharij/sifaat/tajweed routing stubs
- [x] If provenance incomplete: return deferral/refusal + generic drills (no rule facts)

## Step 4 — Add teacher orchestrator service contract types
- [x] Create `services/ai-teacher/orchestrator/teacher-orchestrator.contract.ts`
- [x] Define request/response payload types for lesson routing & conversation routing

## Step 5 — Unit test stubs
- [x] Add `services/ai-teacher/__tests__/provenance-gatekeeper.test.ts`
- [x] Add `services/ai-teacher/__tests__/recommendation-routing.test.ts`

## Step 6 — Smoke check
- [ ] Run TypeScript compile/tests (if configured)


