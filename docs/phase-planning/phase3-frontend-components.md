# Phase 3 — Frontend Components (Next.js)

## Student-facing

### 1) Lesson Delivery Screen
State machine:
- Intro → Scholar Reference → Demonstration → Practice → Feedback → Next Activity

Components:
- `LessonIntroductionCard`
- `ScholarReferenceCarousel` (watch/read links; citations for transparency)
- `MediaDemonstrationPlayer` (audio/video segment playback)
- `PracticeRecorder` (record audio; upload)
- `PracticePrompt` (steps)
- `FeedbackPanel` (rubric results + correction plan)
- `NextActivityCard`

### 2) Pronunciation Correction Screen
Components:
- `DiagnosticSummary` (Makharij/Sifaat/Tajweed labels)
- `CorrectionGuidance` (provenance-grounded text or deferral message)
- `ReviewSegmentLinks` (jump to correct media excerpts)
- `DrillWizard` (step-by-step practice sequence)

### 3) Teaching Mode Selector
- `Child Mode`
- `Adult Mode`
- `Advanced Mode`

Note: mode changes presentation only.

## Admin dashboard
Components:
- `StudentProgressTable` (topic mastery / last_practice)
- `CommonMistakesHeatmap` (by topic)
- `LessonEffectivenessChart` (before/after correction outcomes)
- `ProvenanceCoveragePanel` (optional; show missing ingestion areas)

