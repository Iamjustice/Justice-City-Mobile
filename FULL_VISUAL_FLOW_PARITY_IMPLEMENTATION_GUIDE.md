# JUSTICE CITY LTD Flutter Parity Guide

This document is the execution handoff for completing and maintaining **full visual parity + full flow parity** between:

- Web app: `C:\Users\hp\Desktop\Justice-City-Ltd\client` (React/Vite)
- Mobile app: `C:\Users\hp\Desktop\Justice-City-Mobile` (Flutter)
- Shared backend: Node API + Supabase

Use this as the source of truth if continuing work with GitHub Copilot.

## 1. Objective

Deliver a Flutter mobile app that:

- Matches the React web product behavior for core user journeys.
- Uses the same backend contracts (Node + Supabase).
- Uses a consistent, premium UI system (not placeholder list UI).
- Passes regression checks before merge.

Parity is complete only when **flow parity + visual parity + role parity + QA parity** all pass.

## 2. Current Baseline (From Repo Scan)

## Web routes (reference)
File: `C:\Users\hp\Desktop\Justice-City-Ltd\client\src\App.tsx`

- `/`
- `/auth`
- `/verify`
- `/property/:id`
- `/dashboard`
- `/services`
- `/profile`
- `/request-callback`
- `/schedule-tour`
- `/hiring`
- `/terms-of-service`
- `/privacy-policy`
- `/escrow-policy`
- `/provider-package/:token`

## Flutter routes (mobile)
File: `C:\Users\hp\Desktop\Justice-City-Mobile\lib\app\router.dart`

- `/welcome`
- `/sign-in`
- `/auth` (redirects to `/welcome`)
- `/verify`
- `/home`
- `/services`
- `/profile`
- `/request-callback`
- `/schedule-tour`
- `/hiring`
- `/terms-of-service`
- `/privacy-policy`
- `/escrow-policy`
- `/provider-package/:token`
- `/listings`
- `/property/:id`
- `/chat`
- `/chat/:id`
- `/transaction/:conversationId`
- `/dashboard`
- `/admin`

## API contract baseline
File: `C:\Users\hp\Desktop\Justice-City-Mobile\lib\data\api\endpoints.dart`

Mobile already has endpoint contracts for:

- Auth/profile
- Listings + assets + status + payout + verification step status
- Chat + messages + attachments + chat-cards + chat-action resolve
- Transactions + disputes + payout claim + ratings
- Services + provider links + service-pdf jobs + provider package
- Admin dashboard + moderation + hiring
- Verification OTP + docs + Smile submit + verification status

## 3. Non-Negotiable Product Rules

1. One Supabase project for web + mobile.
2. `SUPABASE_SERVICE_ROLE_KEY` is server-only; never in mobile or web app code.
3. Mobile UI must not show action buttons for roles that are not authorized.
4. No fake/derived verification progress in production mode.
5. Every feature patch must pass:
   - `flutter analyze --no-fatal-warnings --no-fatal-infos`
   - `flutter test`

## 4. Visual Parity Standard

Use this mobile design system consistently:

- Background: `#F4F7FB`
- Panel border: `#E2E8F0`
- Heading text: `#0F172A`
- Muted text: `#64748B`
- Primary rounded panels (12px radius)
- KPI/stat cards with strong numeric emphasis
- Uniform spacing rhythm: `4 / 8 / 10 / 12 / 16 / 20 / 24`
- Branded app bars using logo fallback text `JUSTICE CITY LTD`

Reject any screen that looks like:

- Plain raw list with default Material spacing
- No section cards / no hierarchy
- Placeholder-only structure

## 5. Flow Parity Matrix (Execution)

## P0 (must-have)

1. Auth/Entry flow parity
- Welcome (sign-up) first
- Sign-in second
- Trust gate redirects to verification if not verified
- Verified users reach home/dashboard

2. Verification parity
- Email OTP send/check
- Phone OTP send/check
- Docs upload (ID + utility bill)
- Smile ID submit
- Status card with real backend data

3. Listings parity
- Fetch/listings console
- Create/edit/delete
- Duplicate
- Archive/unarchive
- Submit for review
- Mark sold/rented
- Asset upload
- Payout action wiring (role constrained)

4. Chat/transaction parity
- Conversations list
- Thread messages
- Attachment upload
- Chat cards
- Transaction center
- Actions, payout claim, ratings

5. Services/provider parity
- Service offerings list
- Service chat entry
- Provider package fetch by token
- Provider link create/revoke
- Service PDF jobs list/queue

## P1 (admin hardening + deep parity)

1. Admin dashboard parity
- Overview, verifications, flagged listings, hiring
- Conversation moderation entry

2. Dispute/resolve parity
- Open disputes queue
- Resolve path with correct role checks

3. Chat action resolve parity
- Accept/decline/submit flows
- Correct action state transitions

4. Service PDF manual process parity
- `POST /api/service-pdf-jobs/process-next` admin tool

## P2 (final polish)

1. Strict typography/spacing tune against React screenshots.
2. Empty/loading/error state parity on every screen.
3. Remove legacy fallback visuals.
4. Documentation + runbook + release checklist refresh.

## 6. Suggested Batch Plan for Copilot

Use one branch per batch:

- `parity/batch1-visual-core`
- `parity/batch2-dashboard-chat-admin`
- `parity/batch3-admin-hardening`
- `parity/batch4-final-polish`

Commit pattern:

- `feat(mobile-ui): ...`
- `feat(mobile-flow): ...`
- `fix(role-gating): ...`
- `chore(parity): ...`

## 7. Copilot Prompt Pack (Copy/Paste)

## Prompt A: Visual system enforcement

```
Apply strict Justice City visual system to target screens:
- background #F4F7FB
- panel border #E2E8F0
- heading #0F172A
- muted #64748B
- panel radius 12
- no plain list-only screen

Do not change API behavior. UI-only refactor.
Run flutter analyze and flutter test after changes.
```

## Prompt B: Role-gated actions

```
Audit all action buttons on listings/chat/transactions/admin screens.
Hide or disable controls for unauthorized roles before API call.
Keep backend as source of truth, but prevent avoidable forbidden requests from UI.
Add clear inline reason text where actions are unavailable.
Run flutter analyze and flutter test.
```

## Prompt C: Admin hardening endpoints

```
Implement and wire full UI flows for:
- POST /api/chat-actions/:actionId/resolve
- GET /api/disputes/open
- POST /api/disputes/:id/resolve
- POST /api/service-pdf-jobs/process-next

Use existing repository pattern and keep routing changes minimal.
Add loading/error states and success toasts.
Run flutter analyze and flutter test.
```

## Prompt D: Final parity QA sweep

```
Run full parity QA checklist:
1) auth flow
2) verify flow
3) listings full action menu
4) property verification modal behavior
5) chat + attachments + cards
6) transactions actions/payout/ratings/disputes
7) services + provider package + provider links + PDF jobs
8) admin moderation

Fix only confirmed regressions. No broad refactor.
Run flutter analyze and flutter test.
```

## 8. QA Checklist (Must Pass Before Merge)

## Build checks

- `flutter pub get`
- `flutter analyze --no-fatal-warnings --no-fatal-infos`
- `flutter test`
- `flutter build apk --release` (local or CI)

## Runtime checks

1. Welcome -> Sign in -> Verification routing works.
2. Not-verified user cannot access protected routes.
3. Verified user can access dashboard/listings/chat.
4. Listings actions execute without UUID/input errors.
5. Property verification view shows live backend status.
6. Chat attachments upload and render in thread.
7. Transaction actions + payout claim + ratings submit successfully.
8. Provider package token opens and shows attachments/transcript.
9. Admin screens enforce admin-only operations.

## 9. CI/Codemagic Baseline

File: `C:\Users\hp\Desktop\Justice-City-Mobile\codemagic.yaml`

Ensure all workflows keep:

- `flutter analyze`
- `flutter test`
- platform build command (`web`, `apk/aab`, `ipa`)

No CI workflow should skip tests for parity branches.

## 10. Data/Schema Alignment Rules

Backend and DB source of truth live in:

- `C:\Users\hp\Desktop\Justice-City-Ltd\server`
- `C:\Users\hp\Desktop\Justice-City-Ltd\supabase`

Mobile must consume API contracts; it should not invent DB logic.

When adding a flow:

1. Confirm endpoint exists in Node routes.
2. Confirm table/policy exists in Supabase SQL.
3. Map endpoint in `lib/data/api/endpoints.dart`.
4. Add repository method.
5. Add UI wiring with role-safe visibility.

## 11. Common Failure Patterns to Avoid

1. Building from wrong folder (`Justice-City-Flutter` vs `Justice-City-Mobile`).
2. Using service role key in mobile `--dart-define`.
3. UI showing actions for roles that cannot perform them.
4. Mixing unrelated local changes into parity commits.
5. Using fallback/derived status in production instead of DB/API state.

## 12. Done Criteria (Definition of Complete)

Parity is complete only when:

1. All P0 + P1 flows are functional and role-correct.
2. Visual parity passes screen-by-screen comparison against React references.
3. Analyze/tests/build pass on local and CI.
4. No unresolved fallback mode remains in production behavior.
5. Release notes and checklist are updated.

---

If continuing with Copilot, run batch-by-batch and keep each batch reviewable.
Do not ship giant mixed commits.
