# Phase 1 Architecture — Student Platform + AI Interview Foundation

## Overview
```mermaid
flowchart TB
  Browser[Student/Parent/Admin Browser] --> Next[Next.js Frontend (React + Tailwind)]
  Next -->|HTTPS| API[Backend API (NestJS)]

  API --> DB[(PostgreSQL)]
  API -->|metadata / storage key| ObjectStorage[(S3 / Cloudflare R2 - planned)]

  API --> Auth[JWT + RBAC Guards]

  subgraph CurriculumKB[Phase 0 Quran KB]
    KBDB[(PostgreSQL KB tables)]
  end

  API --> KBDB

  API --> Assessment[Assessment Sessions (foundation)]
  API --> Audio[Audio Submissions (foundation)]
```

## Scalability notes
- Stateless JWT-based auth for horizontal scaling.
- Read model endpoints should support pagination and selective fields.
- Store only audio storage keys/URLs in DB; stream/transfer via object storage.
- Use explicit indexes on `user_id`, `student_id`, `assessment_session_id`, and `status`.

