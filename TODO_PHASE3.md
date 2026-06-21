# TODO_PHASE3 — AI Teacher Agent + Scholar Reference System + Pronunciation Correction Engine

## 1. Phase 3 documentation set
- [x] Create `docs/phase-planning/phase3-ai-teacher-architecture.md` (AI Teacher Agent architecture diagram + module responsibilities)
- [x] Create `docs/phase-planning/phase3-scholar-reference-library.md` (Scholar reference library mapping + ingestion/provenance checklist)
- [x] Create `docs/phase-planning/phase3-database-schema.md` (Phase 3 tables + invariants)
- [x] Create `docs/phase-planning/phase3-ai-agent-workflow.md` (end-to-end workflow with provenance gate)
- [x] Create `docs/phase-planning/phase3-lesson-generation-logic.md` (recommendation + daily plan logic)
- [x] Create `docs/phase-planning/phase3-pronunciation-correction-flow.md` (Makharij/Sifaat/Tajweed diagnostic → correction)
- [x] Create `docs/phase-planning/phase3-api-design.md` (endpoints + request/response mapping)
- [x] Create `docs/phase-planning/phase3-frontend-components.md` (UI component list + states)
- [x] Create `docs/phase-planning/phase3-testing-strategy.md` (unit/contract/integration/governance/load tests)


## 2. Database schema additions
- [x] Create `db/schema/phase3-schema.sql` (student learning memory, pronunciation diagnostics/corrections, AI teacher sessions/recommendations, optional letter pronunciation targets)
- [x] Create/update `db/schema/phase3-erd.md` with Phase 3 ERD additions



## 3. AI Teacher contracts & retrieval/provenance enforcement
- [x] Review `services/ai-teacher/contracts/request.schema.json` + `response.schema.json`
- [x] Version/extend schemas if needed for Phase 3 (sessions, lesson flow, correction plan outputs)
- [x] Ensure provenance gate logic matches existing policies (no hallucination)


## 4. AI services implementation (scaffolding)
- [ ] Implement/define Teacher Orchestrator service contract (lesson routing + conversation routing)
- [ ] Implement Lesson Recommendation engine (reads from KB only)
- [ ] Implement Pronunciation Correction Engine (makharij/sifaat/tajweed routing)
- [ ] Implement provenance gatekeeper enforcement (block scholar-grounded claims if sources missing)

## 5. Frontend integration (scaffolding)
- [ ] Implement lesson flow UI screens (intro → demo → practice → feedback → next activity)
- [ ] Implement pronunciation correction UI (diagnostic labels + drill wizard)
- [ ] Implement learning mode selector (Child/Adult/Advanced styling only)
- [ ] Implement admin dashboard views for common mistakes + effectiveness

## 6. Migrations + validation
- [ ] Add DB migration instructions to README/TODO_PHASE3
- [ ] Run a migration/smoke test against local Postgres

## 7. Testing
- [ ] Add unit tests for recommendation + correction routing
- [ ] Add contract tests to validate response schema incl. citations/provenance
- [ ] Add governance tests: missing ingestion_status => refusal/deferral
- [ ] Add integration test: attempt submission → processing → feedback → memory update

## Done criteria (Phase 3)
- [ ] All deliverables documented (architecture, schemas, workflows, logic, API, frontend, implementation steps, testing strategy)
- [ ] Phase 3 DB schema exists (sql + ERD)
- [ ] API contracts updated to support Phase 3 outputs
- [ ] Provenance/no-hallucination enforcement is explicitly testable

