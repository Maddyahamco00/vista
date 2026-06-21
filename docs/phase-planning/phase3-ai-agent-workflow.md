# Phase 3 — AI Agent Workflow (Provenance-first)

## Inputs
- student message/question (optional)
- current mode: child | adult | advanced
- student state:
  - current_level
  - weak areas
  - completed lessons
  - last attempts + scores
- request target:
  - `lessonId` OR `letter` OR `ruleTopic` OR `surahNumber/ayahNumber`

## Workflow

### Step 1 — Route the request
- If student asks about a letter/rule → pronunciation correction path
- Else → lesson recommendation path
- If conversation continues → combine with memory + last activity

### Step 2 — Update Student Profile Memory
- Read last attempts and scores
- Compute topic-level weak/strong signals
- Persist to `student_learning_memory`

### Step 3 — Retrieve KB candidates
- lesson candidates from curriculum prerequisites + student weak areas
- rule candidates by `ruleTopic`
- letter candidates by `letter`
- media examples by rule/letter/verse context

### Step 4 — Provenance Gatekeeper (mandatory)
For every candidate used in scholar-grounded explanation/correction:
- ensure all required `reference_spans` have `ingestion_status = complete`
- otherwise:
  - set response provenance status missing/partial
  - refuse scholar-grounded claims
  - provide generic practice steps that do not assert rule facts

### Step 5 — Construct lesson delivery
1. Introduction
   - derived from KB payload (`lessons.explanation.scholarGrounded`)
2. Scholar reference recommendation
   - cite reference spans
3. Demonstration
   - provide correct recitation segments
4. Student practice prompt
   - provide recording/upload instructions
5. AI feedback
   - rubric-based scoring + correction plan derived from stored references
6. Next activity
   - recommendation cached to DB

### Step 6 — Persist outcomes
- store diagnostic + correction outcomes
- update progress_score and last_practice

## Conversation policy
- No new explanations are invented.
- Answers must be composed only from:
  - lesson payloads
  - rule payloads
  - reference spans
- If the user asks “why am I wrong?” and needed sources are missing → deferral message + generic drill.

