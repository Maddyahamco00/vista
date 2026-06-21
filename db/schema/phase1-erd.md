# Phase 1 ERD additions — Student Platform

```mermaid
erDiagram
  USERS {
    uuid id PK
    text name
    citext email UNIQUE
    text password_hash
    text role
    timestamptz created_at
    timestamptz updated_at
  }

  STUDENT_PROFILES {
    uuid student_id PK, FK users.id
    integer age
    text gender
    text country
    text preferred_language
    text current_level
    text learning_goal
    timestamptz created_at
    timestamptz updated_at
  }

  PARENTS {
    uuid parent_id PK, FK users.id
    uuid user_id "(FK users.id)" 
  }

  PARENT_STUDENTS {
    uuid parent_id FK
    uuid student_id FK
    timestamptz created_at
    PK parent_id, student_id
  }

  COURSES {
    uuid course_id PK
    text name
    text description
  }

  COURSE_LESSON_ITEMS {
    uuid course_lesson_id PK
    uuid course_id FK
    text lesson_id "FK lessons.id"
    text level_id "(optional)"
    integer sort_order
  }

  STUDENT_COURSE_PROGRESS {
    uuid student_id FK
    uuid course_id FK
    integer progress_percent
    text status
    timestamptz updated_at
    PK student_id, course_id
  }

  LESSON_COMPLETION {
    uuid student_id FK
    text lesson_id FK
    text status
    timestamptz completed_at
    timestamptz updated_at
    PK student_id, lesson_id
  }

  ASSESSMENT_SESSIONS {
    uuid id PK
    uuid student_id FK
    text type
    text status
    timestamptz created_at
    timestamptz updated_at
  }

  AUDIO_SUBMISSIONS {
    uuid id PK
    uuid student_id FK
    uuid assessment_session_id FK
    text storage_key_or_url
    timestamptz created_at
  }

  USERS ||--o{ STUDENT_PROFILES : "student_id"
  USERS ||--o{ PARENTS : "parent_id"
  PARENTS ||--o{ PARENT_STUDENTS : "parent_id"
  STUDENT_PROFILES ||--o{ PARENT_STUDENTS : "student_id"

  COURSES ||--o{ COURSE_LESSON_ITEMS : "contains"
  STUDENT_PROFILES ||--o{ STUDENT_COURSE_PROGRESS : "progress"
  COURSES ||--o{ STUDENT_COURSE_PROGRESS : "progress"

  STUDENT_PROFILES ||--o{ LESSON_COMPLETION : "completion"

  STUDENT_PROFILES ||--o{ ASSESSMENT_SESSIONS : "sessions"
  ASSESSMENT_SESSIONS ||--o{ AUDIO_SUBMISSIONS : "submissions"
```

> Note: Phase 0 `lessons` table remains the canonical lesson source. Phase 1 introduces `courses` abstraction and student-specific completion/progress.

