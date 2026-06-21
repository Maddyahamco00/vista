# Phase 3 — Pronunciation Correction Flow

## Objective
Diagnose why a student’s recitation is wrong and provide correction guidance grounded in verified scholar references.

## Correction targets
- Makharij correction (articulation point)
- Sifaat correction (sound characteristics)
- Tajweed correction (rule/context mismatch)

## Inputs
- Student recording or attempt signals
- Context:
  - target letter (if known)
  - rule topic / surah+ayah (if known)
  - last diagnostic (if follow-up)
- Student memory weak areas

## Steps

### Step 1 — Identify likely target
- If request includes `context.letter`: use it
- Else infer from aligned transcript / assessment signals (Phase 2 outputs)

### Step 2 — Run diagnostic routing
- Produce a ranked hypothesis list:
  - makharij mismatch hypotheses
  - sifaat mismatch hypotheses
  - tajweed rule mismatch hypotheses (if applicable)

### Step 3 — Retrieve correction artifacts
- Fetch for the chosen hypothesis:
  - letter pronunciation target / common mistakes
  - relevant `tajweed_rules` record(s)
  - correct pronunciation media segments
  - practice exercise template(s)

### Step 4 — Provenance gate
If any required `referenceSpanIds` are missing/partial:
- do not output scholar-grounded corrective rationales
- return deferral/refusal behavior
- still allow generic drill suggestions

### Step 5 — Build correction response
- Short diagnosis summary (from stored signals)
- Correction instructions derived from KB payloads
- “Review this scholar-referenced explanation” section
- Practice drill steps and scoring rubric

### Step 6 — Store & measure outcome
- persist `pronunciation_diagnostics`
- persist `pronunciation_corrections`
- update `student_learning_memory.topic.progress_score`

## Teaching mode
- Child Mode uses simpler language + emojis
- Adult/Advanced can include more technical mapping, but only from stored references.

