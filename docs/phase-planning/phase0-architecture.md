# Phase 0 Architecture (AI Teacher + Quran KB)

## What Phase 0 provides
- A **curriculum knowledge base** representation.
- A **database schema** for scalable storage.
- **lesson/rule templates** designed to prevent hallucination.

## Key principle
AI answers must be assembled from stored KB content that is backed by scholar reference spans.

## Components
1. Curriculum hierarchy JSON
2. Lessons JSON (structure-first + provenance placeholders)
3. Tajweed rules JSON skeletons (structure-first + provenance placeholders)
4. Scholar reference model (schema + citations pointers)
5. AI retrieval contract + response contract

## Phase 1 integration
Phase 1 will add:
- student attempts storage
- evaluation signals mapping
- media upload/streaming (if needed)

