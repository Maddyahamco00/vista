import type { RecommendationInput, RecommendationOutput } from '../engines/lesson-recommendation.engine';

export type TeacherMode = 'child' | 'adult' | 'advanced';

export type TeacherRoute = 'lesson.next' | 'pronunciation.correct' | 'conversation.followup';

export interface TeacherOrchestratorInputs {
  studentQuery: string;
  mode: TeacherMode;
  targetSkill:
    | 'quran-reading-foundation'
    | 'tajweed-rule'
    | 'makharij'
    | 'sifaat'
    | 'recitation-example'
    | 'stopping-starting'
    | 'pronunciation-correction'
    | 'general';
  context: {
    lessonId?: string;
    letter?: string;
    ruleTopic?: string;
    surahNumber?: number;
    ayahNumber?: number;
    attemptId?: string;
  };
  studentWeakAreas?: Array<{ topic: string; weight: number; lastPractice?: string }>;
  completedLessonIds?: string[];
}

export interface TeacherOrchestratorDecision {
  route: TeacherRoute;
  inputs: Record<string, unknown>;
}

export interface TeacherOrchestratorLessonNextDeps {
  recommendLesson: (input: RecommendationInput) => Promise<RecommendationOutput>;
}

export type TeacherOrchestratorDeps = TeacherOrchestratorLessonNextDeps;

export interface LessonNextPayload {
  selectedLessonId: string;
  dailyPlanJson: unknown;
  nextActivityPayload: unknown;
  citations: Array<{ workId: string; referenceSpanId: string }>;
  provenance: { status: 'complete' | 'partial' | 'missing'; reasonIfMissing?: string };
}

