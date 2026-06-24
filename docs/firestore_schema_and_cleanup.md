# OneSpace Firestore schema and cleanup guide

This document describes the Firestore shape the current app expects after the school-admin and classroom-login work.

Use it as the checklist before cleaning the live Firebase project. The most important rule: export/back up Firestore before deleting anything.

## Current root collections

### `account_lookup/{uid}`

Used to find a signed-in school admin's school and role.

Expected fields:

- `schoolId`
- `role` currently `schoolAdmin`
- `email`
- `active`
- `createdAt`

Keep active admin records. Do not delete these unless the admin account should lose access.

### `schools/{schoolId}`

Main school/admin record.

Expected fields:

- `name`
- `schoolCode`
- `classroomLimit`
- `active`
- `createdAt`
- `principalName`
- `vicePrincipalName`
- `schoolEmail`
- `phoneNumber`
- `address`

The classroom login function searches this collection by `schoolCode` and `active == true`.

### `schools/{schoolId}/members/{uid}`

School admin membership record.

Expected fields:

- `schoolId`
- `email`
- `role` currently `schoolAdmin`
- `active`
- `createdAt`

Keep this in sync with `account_lookup/{uid}`.

### `schools/{schoolId}/classrooms/{classroomId}`

Main classroom record.

Expected fields:

- `schoolId`
- `name`
- `classroomCode`
- `pin`
- `active`
- `createdAt`
- `schedule`
- `updatedAt`
- `archivedAt` when deactivated
- `reactivatedAt` when reactivated

The classroom login function searches this subcollection by `classroomCode` and `active == true`, then checks the stored `pin`.

The current schedule system stores schedules in the `schedule` field on this classroom document.

Schedule format:

```text
schedule: {
  monday: [
    { time: "09:00", activity: "Morning work" }
  ],
  tuesday: [],
  ...
}
```

## Classroom subcollections

These live under:

```text
schools/{schoolId}/classrooms/{classroomId}/...
```

### `staff_profiles/{staffProfileId}`

Expected fields:

- `name`
- `role`
- `teacherUid`
- `circleTimeX`
- `circleTimeY`
- `circleTimeSide`

### `child_profiles/{childProfileId}`

Expected fields:

- `name`
- `age`
- `zone`
- `teacherUid`
- `points`
- `backgroundColorHex`
- `accessMode`
- `iconSequence`
- `circleTimeX`
- `circleTimeY`
- `circleTimeSide`

Nested child subcollections:

- `point_history/{entryId}`
- `quiz_attempts/{attemptId}`

### `incident_logs/{incidentId}`

Expected fields:

- `childId`
- `childName`
- `timestamp`
- `description`
- `actionTaken`
- `severity`
- `category`
- `staffId`
- `staffName`
- `followUpStatus`
- `followUpNotes`
- `updatedAt`
- `updatedByStaffId`
- `updatedByStaffName`
- `isArchived`
- `archivedAt`
- `archivedByStaffId`
- `archivedByStaffName`
- `archiveReason`

### `body_check_reports/{reportId}`

Expected fields:

- `childId`
- `childName`
- `bodyPart`
- `painLevel`
- `painType`
- `timestamp`
- `checked`
- `checkedNote`
- `checkedAt`

### Learning collections

- `quizzes/{quizId}`
- `word_packs/{packId}`
- `word_packs/{packId}/words/{wordId}`
- `word_attempts/{attemptId}`
- `when_then_options/{optionGroupId}/items/{itemId}`

### Wellbeing collections

- `point_rewards/{rewardId}`
- `circle_time_days/{dateKey}`

### Handover collections

- `handover_overview/{docId}`
- `staff_handover_documents/{documentId}`
- `handover_quick_notes/{noteId}`

## Still-supported standalone teacher structure

The app still contains standalone teacher-mode paths:

```text
teachers/{teacherUid}
teachers/{teacherUid}/staff_profiles
teachers/{teacherUid}/child_profiles
teachers/{teacherUid}/quizzes
teachers/{teacherUid}/word_packs
teachers/{teacherUid}/word_attempts
teachers/{teacherUid}/when_then_options
teachers/{teacherUid}/point_rewards
teachers/{teacherUid}/circle_time_days
teachers/{teacherUid}/incident_logs
teachers/{teacherUid}/body_check_reports
teachers/{teacherUid}/handover_overview
teachers/{teacherUid}/staff_handover_documents
teachers/{teacherUid}/handover_quick_notes
```

Schedules in teacher mode are stored in the `schedule` field on `teachers/{teacherUid}`.

Do not mass-delete the `teachers` collection until we decide whether standalone teacher mode is being retired. It may still be useful for personal/demo accounts.

## Legacy or cleanup candidates

## Snapshot from console screenshots

Based on the screenshots reviewed on 24 June 2026, the live database currently contains:

- root collections: `account_lookup`, `schedules`, `schools`, `teachers`
- two `account_lookup` docs
- one old top-level `schedules` doc
- two `schools` docs
- at least one current school with `classrooms` and `members`
- at least one current classroom under the current school
- multiple old `teachers` docs
- old teacher subcollections including `child_profiles`, `staff_profiles`, and `first_then_options`

Observed cleanup notes:

- The old top-level `schedules` doc uses the legacy string-array format and can be removed after backup.
- `first_then_options` appears to be older data. The current app code uses `when_then_options`.
- The current school/admin structure looks correct: `account_lookup`, `schools/{schoolId}`, `schools/{schoolId}/members/{uid}`, and `schools/{schoolId}/classrooms/{classroomId}` are all present.
- There are two school docs. Decide which one is the real demo/pilot school before deleting either.
- The `teachers` collection contains old standalone/demo data. Keep it for now unless standalone teacher mode is intentionally retired.
- A `teachers/classroom_...` style document can be considered old/generated clutter if the real classroom data exists under `schools/{schoolId}/classrooms/{classroomId}`.

### `schedules`

The current code does not read from the top-level `schedules` collection.

Older records may look like this:

```text
schedules/{teacherUid}
  monday: ["09:00 | test"]
  tuesday: ["Test | "]
```

This is legacy data. The current app expects schedules on:

- `teachers/{teacherUid}.schedule` for standalone teacher mode
- `schools/{schoolId}/classrooms/{classroomId}.schedule` for classroom mode

After backing up Firestore and confirming no old deployed build is being used, `schedules` can be deleted or ignored.

### `_generated_quiz_ids`

Used only to generate Firestore-style quiz IDs client-side. It should not contain important app data.

## Cleanup checklist for the live project

1. Export or back up Firestore first.
2. Pick the pilot/demo school document that should be kept.
3. Keep `account_lookup` docs for real active admins.
4. Keep matching `schools/{schoolId}/members/{uid}` records for those admins.
5. Keep the active classroom docs under the pilot/demo school.
6. Clear bad schedule entries from the classroom document's `schedule` field, not from the old top-level `schedules` collection.
7. Remove stale inactive classrooms only after checking whether they contain child/staff/report history you want to preserve.
8. Treat top-level `schedules` as legacy and safe to remove after backup.
9. Do not delete `teachers` yet unless we intentionally remove standalone teacher mode.
10. Re-test:
    - admin login
    - classroom login by school code, classroom code and PIN
    - staff schedule
    - child schedule
    - incident log
    - body check overview

## Security/rules note

This repo currently has Firebase Functions configured, but it does not appear to track a `firestore.rules` file or declare Firestore rules in `firebase.json`.

Before a real school pilot, we should add and deploy Firestore rules that enforce:

- school admins can only access their own school
- classroom sessions can only access their own classroom document and subcollections
- child/staff profile access is scoped to the active classroom
- parent-safe report sharing is handled through a controlled server function, not direct broad Firestore reads
- classroom PINs are not broadly readable by normal classroom users

That security pass should happen before adding chat, parent email delivery, or broader pilot data.
