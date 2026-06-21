# Phase 0 — Quran Education KB Foundation (TODO)

## 1) Confirm Phase 0 Architecture Deliverables
- [x] Define AI Teacher + Curriculum Graph architecture (KB-first)
- [x] Define “no rule invention” approach: all explanations must be sourced from ingested scholar references

## 2) Create KB Artifacts (files)
- [x] Create `kb/curriculum/curriculum-hierarchy.json`
- [x] Create `kb/lessons/lesson-template.json`
- [x] Create `kb/scholar/reference-model.json`

- [x] Create Tajweed rule skeletons:
  - [x] `kb/tajweed/rules/by-topic/madd.json`
  - [x] `kb/tajweed/rules/by-topic/ghunnah.json`
  - [x] `kb/tajweed/rules/by-topic/qalqalah.json`
  - [x] `kb/tajweed/rules/by-topic/ikhfa.json`
  - [x] `kb/tajweed/rules/by-topic/idgham.json`
  - [x] `kb/tajweed/rules/by-topic/iqlab.json`
  - [x] `kb/tajweed/rules/by-topic/izhar.json`
  - [x] `kb/tajweed/rules/by-topic/stopping-starting.json`
- [x] Create one sample lesson (structure-first):
  - [x] `kb/lessons/by-id/L-0301-duad-pronunciation.json`


## 3) Database Design Deliverables
- [x] Create `db/schema/schema.sql` (core schema + provenance fields)
- [x] Create `db/schema/erd-notes.md`

## 4) AI Teacher Preparation Docs
- [x] Create `services/ai-teacher/contracts/request.schema.json`
- [x] Create `services/ai-teacher/contracts/response.schema.json`
- [x] Create `services/ai-teacher/prompt-strategies/explain-from-sources.md`
- [x] Create `services/ai-teacher/retrieval/retrieval-contract.md`

## 5) Governance Docs
- [x] Create `docs/governance/no-hallucination-policy.md`
- [x] Create `docs/governance/provenance-required-fields.md`
- [x] Create `docs/methodology/ingestion-format-spec.md`

## 6) Phase 1 Compatibility Notes
- [x] Create `docs/phase-planning/phase0-architecture.md`
- [x] Create `docs/phase-planning/phase1-integration-notes.md

## 7) Validate
- [ ] Run a basic JSON validation pass (optional)
- [ ] Ensure every sample lesson/rule includes `sourceRequirement` and `provenance` placeholders

