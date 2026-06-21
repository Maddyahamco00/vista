export type TeacherMode = 'child' | 'adult' | 'advanced';

export interface RecommendationInput {
  studentId: string;
  mode: TeacherMode;
  targetSkill: string;
  context: {
    lessonId?: string;
    letter?: string;
    ruleTopic?: string;
    surahNumber?: number;
    ayahNumber?: number;
  };
  studentWeakAreas?: Array<{ topic: string; weight: number; lastPractice?: string }>;
  completedLessonIds?: string[];
}

export interface KBLessonCandidate {
  lessonId: string;
  topic: string;
  targetSkill: string;
  prerequisites?: string[];
  provenanceComplete: boolean;
}

export interface RecommendationOutput {
  selectedLessonId: string;
  dailyPlanJson: unknown;
  nextActivityPayload: unknown;
  citations: Array<{ workId: string; referenceSpanId: string }>;
  provenance: { status: 'complete' | 'partial' | 'missing'; reasonIfMissing?: string };
}

/**
 * Lesson Recommendation engine (Phase 3 scaffolding)
 * - Reads candidates from KB (must be injected in real implementation)
 * - Enforces: only use provenanceComplete candidates
 * - Does NOT generate scholar-grounded content.
 */
export async function recommendLesson(
  input: RecommendationInput,
  getCandidatesFromKB: () => Promise<KBLessonCandidate[]>
): Promise<RecommendationOutput> {
  const candidates = await getCandidatesFromKB();

  // Provenance-aware filtering: only include complete candidates.
  const eligible = candidates.filter(
    (c) => c.provenanceComplete && (c.targetSkill === input.targetSkill)
  );

  // Exclude already completed lessons.
  const completed = new Set(input.completedLessonIds ?? []);
  const notCompleted = eligible.filter((c) => !completed.has(c.lessonId));

  // Prefer weak areas.
  const weak = new Map((input.studentWeakAreas ?? []).map((w) => [w.topic, w.weight]));

  notCompleted.sort((a, b) => {
    const wa = weak.get(a.topic) ?? 0;
    const wb = weak.get(b.topic) ?? 0;
    return wb - wa;
  });

  const best = notCompleted[0] ?? eligible[0];

  if (!best) {
    // Governance-safe fallback: do not assert rule facts.
    return {
      selectedLessonId: '',
      dailyPlanJson: {},
      nextActivityPayload: {
        type: 'generic-practice',
        targetSkill: input.targetSkill,
        context: input.context
      },
      citations: [],
      provenance: {
        status: 'missing',
        reasonIfMissing: 'No provenance-complete KB lesson candidates available.'
      }
    };
  }

  return {
    selectedLessonId: best.lessonId,
    dailyPlanJson: {
      dayPlan: 'scaffold',
      lessonId: best.lessonId,
      mode: input.mode
    },
    nextActivityPayload: {
      type: 'lesson-flow',
      lessonId: best.lessonId,
      mode: input.mode,
      context: input.context
    },
    citations: [],
    provenance: { status: 'complete' }
  };
}

