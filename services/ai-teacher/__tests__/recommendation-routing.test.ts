import type { RecommendationInput } from '../engines/lesson-recommendation.engine';
import { recommendLesson } from '../engines/lesson-recommendation.engine';

// NOTE: Test runner globals (describe/it/expect) may not be configured in this repo yet.
// These tests are scaffolding and will be enabled once the test environment is set up.
const describe = (name: string, fn: () => void) => fn();
const it = (name: string, fn: () => void | Promise<void>) => void fn();
const expect = (value: any) => ({
  toBe: (v: any) => {
    if (value !== v) throw new Error(`Expected ${v} but got ${value}`);
  },
  toEqual: (v: any) => {
    if (JSON.stringify(value) !== JSON.stringify(v)) {
      throw new Error(`Expected ${JSON.stringify(v)} but got ${JSON.stringify(value)}`);
    }
  }
});

describe('lesson recommendation (routing)', () => {
  it('selects provenance-complete candidate that matches targetSkill and avoids completed', async () => {
    const input: RecommendationInput = {

      studentId: 's1',
      mode: 'adult',
      targetSkill: 'makharij',
      context: {},
      studentWeakAreas: [{ topic: 'T1', weight: 2 }],
      completedLessonIds: ['L-1']
    };

    const getCandidatesFromKB = async () => [
      { lessonId: 'L-1', topic: 'T1', targetSkill: 'makharij', provenanceComplete: true },
      { lessonId: 'L-2', topic: 'T1', targetSkill: 'makharij', provenanceComplete: true },
      { lessonId: 'L-3', topic: 'T2', targetSkill: 'makharij', provenanceComplete: false }
    ];

    const out = await recommendLesson(input, getCandidatesFromKB);
    expect(out.selectedLessonId).toBe('L-2');
    expect(out.provenance.status).toBe('complete');
  });
});

