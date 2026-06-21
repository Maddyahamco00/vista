# Phase 3 — AI Teacher Agent Architecture

## Goal
Personalized AI Quran teacher using **verified scholar references**. The AI is an assistant that never invents new religious explanations.

## High-level architecture (modules)
```mermaid
flowchart TB
  Student[Student UI / Recording] --> Orchestrator[AI Teacher Agent Orchestrator]

  Orchestrator --> Memory[Student Profile Memory]
  Memory --> Orchestrator

  Orchestrator --> LessonKB[Quran Knowledge Base (curriculum + lessons)]
  Orchestrator --> ScholarLib[Scholar Reference Library]

  Orchestrator --> ProvenanceGate[Provenance Gatekeeper]
  ProvenanceGate --> LessonRenderer[Lesson Delivery]
  ProvenanceGate --> CorrectionEngine[Pronunciation Correction Engine]

  LessonRenderer --> Practice[Student Practice]
  Practice --> Attempt[Attempt / Recording Submission]
  Attempt --> Memory

  CorrectionEngine --> ScholarLib
  CorrectionEngine --> Media[Audio/Video Demonstrations]
  Media --> Practice

  LessonRenderer --> NextActivity[Next Activity / Daily Recommendation]
  NextActivity --> Memory
```

## Component responsibilities

### 1) AI Teacher Agent Orchestrator
- Receives: student question / level / last attempt signals
- Decides routing:
  - lesson recommendation generation
  - pronunciation correction flow
  - conversation follow-up
- Calls retrieval with explicit targets (letter, ruleTopic, surah/ayah, lessonId)

### 2) Student Profile Memory (persistent)
Stores (and updates after each practice):
- current level & progression pace
- previous mistakes
- completed lessons
- weak areas (topic-level)
- learning speed (time-to-improvement signals)

### 3) Quran Knowledge Base (curriculum + lessons)
- Stores scholar-grounded lesson explanations and practice exercises
- Supplies **lesson payloads** only (the AI does not generate rule facts)

### 4) Scholar Reference Library (provenance-first)
- Stores:
  - scholars, works
  - precise reference spans
  - ingestion status
- All scholar-grounded explanation fragments and correction rationales must cite `referenceSpanIds` whose `ingestion_status = complete`.

### 5) Provenance Gatekeeper (mandatory)
- Enforces no-hallucination policy:
  - if required reference spans are missing/partial → refuse scholar-grounded claims
  - may still provide generic practice guidance that does not assert rule facts

### 6) Lesson Delivery
Lesson flow segments:
1. Introduction
2. Scholar reference recommendation (what to watch/read)
3. Demonstration (correct recitation segments)
4. Student practice prompt
5. AI Feedback (rubric + correction plan)
6. Next Activity

### 7) Pronunciation Correction Engine
- Diagnoses likely error class:
  - Makharij (articulation point)
  - Sifaat (sound characteristics)
  - Tajweed (rule-based context when relevant)
- Retrieves related letter/rule media and scholar-grounded guidance
- Produces correction plan + drill steps

## Teaching modes (personality layer)
- Child Mode: simpler language + emojis + encouraging prompts
- Adult Mode: standard terminology, more structured steps
- Advanced Mode: more technical description (still provenance-anchored)

Mode affects **presentation style only**, not correctness claims.

