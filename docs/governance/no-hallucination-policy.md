# No-Hallucination Policy (Phase 0)

## Non-negotiable constraints
1. **No invented Quran/juristic rules.**
   - Tajweed/Makharij/Sifaat explanations must come from ingested, approved scholar sources.
2. **Provenance is required for any claim.**
   - If a response would require rule facts or corrective rationales, the system must reference `referenceSpanIds` with `ingestion_status = complete`.
3. **Refusal mode**
   - If required source spans are missing/partial, the AI responds with:
     - "This topic needs ingestion from an approved scholar source before I can explain it."

## Allowed outputs when sources are missing
- Generic learning guidance that does **not** assert rule facts.
- Practice instructions that do not claim correctness of tajweed rules.

## Implementation notes
- Retrieval service must enforce provenance gating.
- Prompting strategy must refuse to synthesize rule explanations.

