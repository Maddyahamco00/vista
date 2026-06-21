import { enforceProvenance, type ReferenceSpan } from '../provenance/provenance-gatekeeper';

export type CorrectionTarget = 'makharij' | 'sifaat' | 'tajweed';

export interface PronunciationCorrectionInput {
  studentId: string;
  attemptId?: string;
  mode: 'child' | 'adult' | 'advanced';
  context: {
    letter?: string;
    ruleTopic?: string;
    surahNumber?: number;
    ayahNumber?: number;
    targetRuleType?: CorrectionTarget;
  };
  /** If provided, orchestration should use this list to gate scholar-grounded claims. */
  requiredReferenceSpanIds?: string[];
  /** Retrieved spans keyed by referenceSpanId. */
  referenceSpansById?: Record<string, ReferenceSpan>;
}

export interface PronunciationCorrectionOutput {
  diagnostic: {
    target: CorrectionTarget;
    likelyErrorClass: string[];
  };
  correctionPlan: {
    mode: 'deferred' | 'guided';
    scholarGrounded: boolean;
    instructions: string[];
  };
  practice: {
    exerciseType: string;
    prompt: string;
    steps: string[];
  };
  assessment: {
    methodType: string;
    rubric: object;
  };
  citations: Array<{ workId: string; referenceSpanId: string }>;
  provenance: { status: 'complete' | 'partial' | 'missing'; reasonIfMissing?: string };
}

function routeTarget(input: PronunciationCorrectionInput): CorrectionTarget {
  return (input.context.targetRuleType ?? 'makharij') as CorrectionTarget;
}

/**
 * Pronunciation Correction Engine (Phase 3 scaffolding)
 * - Produces routing + generic drills.
 * - Scholar-grounded correction instructions are allowed only when provenance is complete.
 */
export async function correctPronunciation(
  input: PronunciationCorrectionInput
): Promise<PronunciationCorrectionOutput> {
  const target = routeTarget(input);

  // Placeholder diagnostic routing hypotheses.
  const likelyErrorClass =
    target === 'makharij'
      ? ['wrong articulation point', 'sound drift']
      : target === 'sifaat'
        ? ['missing/altered sound characteristic', 'quality mismatch']
        : ['rule/context mismatch', 'timing/stop mismatch'];

  const required = input.requiredReferenceSpanIds ?? [];
  const refById = input.referenceSpansById ?? {};

  if (required.length > 0) {
    const enforced = enforceProvenance(required, refById);

    if (!enforced.allowed) {
      return {
        diagnostic: { target, likelyErrorClass },
        correctionPlan: {
          mode: 'deferred',
          scholarGrounded: false,
          instructions: [
            'I can’t provide scholar-grounded corrective explanations yet because required reference spans are not fully ingested.',
            'Meanwhile, do generic fluency drills and re-record for another attempt.'
          ]
        },
        practice: {
          exerciseType: 'generic-practice',
          prompt: 'Generic drill: slow recitation + mimic the target sound quality.',
          steps: ['Recite slowly', 'Repeat 5 times', 'Record and self-compare']
        },
        assessment: { methodType: 'rubric', rubric: {} },
        citations: [],
        provenance: enforced.provenance
      };
    }

    const citations = required.map((referenceSpanId) => ({
      workId: refById[referenceSpanId]?.workId ?? 'unknown',
      referenceSpanId
    }));

    return {
      diagnostic: { target, likelyErrorClass },
      correctionPlan: {
        mode: 'guided',
        scholarGrounded: true,
        // Scaffolding only: do not invent rule facts; in real impl these come from KB.
        instructions: [
          'Use the stored scholar-referenced guidance from the retrieved KB payloads (not generated here).',
          'Follow the recommended drill steps for your target class.'
        ]
      },
      practice: {
        exerciseType: 'drill',
        prompt: 'Do a short targeted drill for your likely error class.',
        steps: ['Listen', 'Imitate', 'Record', 'Repeat with slightly faster tempo']
      },
      assessment: { methodType: 'rubric', rubric: {} },
      citations,
      provenance: enforced.provenance
    };
  }

  // No provenance requirement provided: return non-scholar generic guidance.
  return {
    diagnostic: { target, likelyErrorClass },
    correctionPlan: {
      mode: 'deferred',
      scholarGrounded: false,
      instructions: ['Provide ingested scholar reference spans to enable rule-grounded correction.']
    },
    practice: {
      exerciseType: 'generic-practice',
      prompt: 'Generic drill without rule facts.',
      steps: ['Slow recitation', 'Repetition', 'Record and compare']
    },
    assessment: { methodType: 'rubric', rubric: {} },
    citations: [],
    provenance: {
      status: 'missing',
      reasonIfMissing: 'No requiredReferenceSpanIds supplied for provenance gating.'
    }
  };
}

