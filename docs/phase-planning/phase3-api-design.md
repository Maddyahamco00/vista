# Phase 3 — API Design (AI Teacher + Correction)

## Constraints
- Responses must include provenance/citations when scholar-grounded content is produced.
- If ingestion is missing/partial, the system must refuse/defers scholar-grounded claims.

## Suggested endpoints (NestJS)

### 1) Create/continue an AI teacher session
`POST /ai-teacher/session`
- body:
  - studentId
  - mode (child|adult|advanced)
  - optional lastActivityId
- returns:
  - sessionId

### 2) Generate next lesson/activity
`POST /ai-teacher/lesson/next`
- body:
  - studentId
  - targetSkill
  - optional context: lessonId | letter | ruleTopic | surahNumber/ayahNumber
- returns:
  - lesson flow payload
  - practice prompt
  - assessment rubric
  - correctRecitation segments
  - citations + provenance

### 3) Pronunciation correction
`POST /ai-teacher/pronunciation/correct`
- body:
  - studentId
  - attemptId OR audioProcessingJobId
  - optional context: letter | ruleTopic | surah/ayah
- returns:
  - diagnostic summary
  - scholar-grounded correction guidance (or deferral if missing provenance)
  - practice drill steps
  - citations + provenance

### 4) Persist attempt feedback (if separate)
`POST /ai-teacher/attempt/submit`
- body:
  - studentId
  - attempt payload (audio url + signals)
- returns:
  - attemptId

### 5) Student progress for dashboard
`GET /ai-teacher/progress/:studentId`
- returns:
  - topic mastery overview
  - last corrections outcomes
  - recommended next activity

### 6) Admin dashboard analytics
`GET /admin/teacher/analytics`
- query: date range, topic filters
- returns:
  - common mistakes distribution
  - lesson effectiveness metrics

## Response schema alignment
Use or version the existing:
- `services/ai-teacher/contracts/response.schema.json`

Ensure:
- `scholarGroundedExplanation` only populated when `provenance.status` indicates complete/partial properly
- `citations` correspond to used `referenceSpanIds`

