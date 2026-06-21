# Phase 1 TODO — Student Platform + AI Interview Foundation

## Phase 1 deliverables
- [x] 1. Extend `db/schema/schema.sql` with Phase 1 tables:
  - [ ] users + RBAC roles
  - [ ] student_profiles
  - [ ] parents + parent_students relationship
  - [ ] course abstractions + student progress/completion
  - [ ] assessment session foundation (assessment_sessions)
  - [ ] audio submissions foundation (audio_submissions)
  - [ ] add required indexes + constraints
- [x] 2. Add ERD + architecture docs (Mermaid):
  - [x] System architecture diagram (`docs/phase-planning/phase1-architecture-diagram.md`)
  - [x] ER diagram (Phase 1 additions) (`db/schema/phase1-erd.md`)
- [ ] 3. Backend scaffolding (NestJS):
  - [ ] folder structure + env templates
  - [ ] Auth module (register/login/JWT/RBAC)
  - [ ] Student module (profile + dashboard read model)
  - [ ] Parent module (linked students + progress read)
  - [ ] Curriculum module (courses + completion)
  - [ ] Assessment module (POST start assessment → creates assessment_sessions)
  - [ ] Audio module (POST upload metadata / signed URL placeholder)
  - [ ] Admin module (dashboard foundation)
  - [ ] DB access layer (Prisma or TypeORM — decide + implement)
- [ ] 4. Frontend scaffolding (Next.js + Tailwind):
  - [ ] folder structure
  - [ ] auth pages
  - [ ] student dashboard/profile
  - [ ] parent dashboard foundation
  - [ ] admin dashboard foundation
  - [ ] API client + auth guards
- [ ] 5. Testing checklist + smoke tests:
  - [ ] register/login
  - [ ] RBAC enforcement
  - [ ] protected student endpoints
  - [ ] start assessment session
  - [ ] audio upload endpoint

