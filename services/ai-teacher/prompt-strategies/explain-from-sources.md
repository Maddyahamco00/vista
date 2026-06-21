# Explain-from-sources (Phase 0)

Goal: prevent hallucination.

## Inputs
- retrievedLesson.explanation.simple
- retrievedLesson.explanation.scholarGrounded.content
- retrievedLesson.assessment rubric
- retrieved media example refs
- required `referenceSpanIds` with ingestionStatus=complete

## Response assembly rules
1. **simpleExplanation** must be derived from `explanation.simple` only.
2. **scholarGroundedExplanation.content** must be derived from stored KB text. No rule invention.
3. **citations** must include all `referenceSpanIds` used.
4. If any required source spans are missing or ingestionStatus != complete:
   - set `provenance.status = "missing"`
   - respond with a refusal/deferral message:
     - "This topic needs ingestion from an approved scholar source before I can explain it."
   - still provide a generic practice suggestion **only** if it does not assert rule facts.

## Output constraints
- Never output rules without provenance.
- Never claim “Ayman Suwaid says …” unless that workId + referenceSpanId is linked in KB.

