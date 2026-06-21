# Phase 2 — AI Interview Agent + Quran Assessment Engine (TODO)

## 1) Confirm scope
- [x] No AI Teacher (scholar explanation) yet.
- [x] Build admission/placement via interview + audio assessment.
- [x] Scalable design for future subjects.

## 2) Database (schema.sql)
- [ ] Add interview session tables (fully separate):
  - [ ] ai_interview_sessions
  - [ ] ai_interview_turns
- [ ] Add assessment aggregation/result tables:
  - [ ] quran_assessment_results (category scores + overall)
  - [ ] placement_classifications (level + strengths/weaknesses/recs)
- [ ] Add audio pipeline tracking tables:
  - [ ] audio_processing_jobs
  - [ ] (optional) audio_alignment_segments
- [ ] Add reference comparison scaffolding for future scholar references:
  - [ ] recitation_reference_alignments
- [ ] Add necessary indexes + constraints.

## 3) NestJS backend (modules + endpoints)
- [ ] Create Placement/AI Interview module:
  - [ ] Start interview endpoint
  - [ ] Get next question endpoint / submit turn
  - [ ] Audio upload endpoint (creates audio_submissions + job)
  - [ ] Report endpoint (student + parent views)
- [ ] Admin review endpoint(s) (read-only first)
- [ ] RBAC guards (student/parent/admin)

## 4) Python microservice (assessment pipeline)
- [ ] Define service contracts (request/response JSON)
- [ ] Implement pipeline stages (stubs first):
  - [ ] Whisper transcription
  - [ ] Quran text normalization
  - [ ] Alignment (verse/phrase matching)
  - [ ] Pronunciation feature extraction (proxy metrics)
  - [ ] Tajweed feature scoring (rule-topic mapping)
  - [ ] Memorization scoring (missing words/recall proxy)
  - [ ] Reference comparison (stub + interface for future libraries)
  - [ ] Final scoring + per-category breakdown
  - [ ] Feedback generation (non-hallucination, rubric-only)

## 5) Scoring + classification implementation
- [ ] Implement weighted overall score from category scores
- [ ] Implement classification tiers + output model:
  - [ ] Beginner / Intermediate / Advanced / Excellent
  - [ ] strengths/weaknesses/recommendations
- [ ] Ensure deterministic scoring for reproducibility
- [ ] Unit tests for scoring weights + mapping

## 6) Prompt engineering design (for interview agent)
- [ ] Next-question selection logic (no scholar claims)
- [ ] Interview prompts templates:
  - [ ] Reading prompts
  - [ ] Tajweed prompts
  - [ ] Memorization prompts
- [ ] Feedback templates tied to rubric signals

## 7) Sequence diagrams
- [ ] Start interview sequence
- [ ] Audio processing + scoring sequence
- [ ] Report retrieval sequence

## 8) Integration checklist
- [ ] DB migrations / schema validation
- [ ] End-to-end smoke test:
  - [ ] start assessment
  - [ ] upload audio
  - [ ] retrieve report
- [ ] Admin dashboard read model wiring

