export type IngestionStatus = 'complete' | 'partial' | 'missing';

export interface ReferenceSpan {
  referenceSpanId: string;
  workId: string;
  ingestion_status: IngestionStatus;
}

export interface ProvenanceEnforcementResult {
  allowed: boolean;
  provenance: { status: 'complete' | 'partial' | 'missing'; reasonIfMissing?: string };
  missingReferenceSpanIds: string[];
  partialReferenceSpanIds: string[];
}

/**
 * Provenance Gatekeeper (Phase 3)
 *
 * Enforces no hallucination:
 * - If any required referenceSpan is not ingestion_status=complete → scholar-grounded content must be refused/defers.
 */
export function enforceProvenance(
  requiredReferenceSpanIds: string[],
  referenceSpansById: Record<string, ReferenceSpan>
): ProvenanceEnforcementResult {
  const missingReferenceSpanIds: string[] = [];
  const partialReferenceSpanIds: string[] = [];

  for (const id of requiredReferenceSpanIds) {
    const span = referenceSpansById[id];
    if (!span) {
      missingReferenceSpanIds.push(id);
      continue;
    }

    if (span.ingestion_status !== 'complete') {
      if (span.ingestion_status === 'missing') missingReferenceSpanIds.push(id);
      else partialReferenceSpanIds.push(id);
    }
  }

  if (missingReferenceSpanIds.length > 0) {
    return {
      allowed: false,
      provenance: {
        status: 'missing',
        reasonIfMissing:
          'This topic needs ingestion from an approved scholar source before I can explain it.'
      },
      missingReferenceSpanIds,
      partialReferenceSpanIds
    };
  }

  if (partialReferenceSpanIds.length > 0) {
    return {
      allowed: false,
      provenance: {
        status: 'partial',
        reasonIfMissing: 'Some required scholar reference spans are not fully ingested.'
      },
      missingReferenceSpanIds,
      partialReferenceSpanIds
    };
  }

  return {
    allowed: true,
    provenance: { status: 'complete' },
    missingReferenceSpanIds: [],
    partialReferenceSpanIds: []
  };
}

export function refusalForMissingProvenance() {
  return {
    simpleExplanation: 'This topic needs ingestion from an approved scholar source before I can explain it.',
    scholarGroundedExplanation: {
      content: '',
      sourceReferences: []
    },
    practice: {
      exerciseType: 'generic-practice',
      prompt: 'Let’s do a short drill to build fluency without asserting any specific rule facts.',
      steps: ['Slow recitation with repetition', 'Listen and mimic the target sound', 'Record again and compare']
    },
    assessment: {
      methodType: 'rubric',
      rubric: {},
      passCriteria: {}
    },
    citations: [],
    provenance: { status: 'missing', reasonIfMissing: 'Missing required reference spans.' }
  };
}

