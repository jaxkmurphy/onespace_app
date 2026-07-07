import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/handover_overview.dart';
import '../../models/handover_quick_note.dart';
import '../../models/staff_handover_document.dart';
import '../../models/staff_profile.dart';
import 'firestore_base.dart';

mixin HandoverFirestoreService on FirestoreBase {
  // HANDOVER OVERVIEW

  Stream<HandoverOverview> getHandoverOverview(String teacherUid) {
    return teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'handover_overview',
    ).doc('main').snapshots().map((doc) {
      return HandoverOverview.fromMap(doc.data());
    });
  }

  Stream<HandoverOverview> getClassroomHandoverOverview({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'handover_overview',
    ).doc('main').snapshots().map((doc) {
      return HandoverOverview.fromMap(doc.data());
    });
  }

  Stream<HandoverOverview> getCurrentHandoverOverview() {
    if (hasClassroomSession) {
      return getClassroomHandoverOverview(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return getHandoverOverview(currentTeacherUid);
  }

  Future<void> updateHandoverOverview({
    required String teacherUid,
    required HandoverOverview overview,
    required String updatedByName,
  }) async {
    await teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'handover_overview',
        )
        .doc('main')
        .set(
          overview.toMap(updatedByName: updatedByName),
          SetOptions(merge: true),
        );
  }

  Future<void> updateClassroomHandoverOverview({
    required String schoolId,
    required String classroomId,
    required HandoverOverview overview,
    required String updatedByName,
  }) async {
    await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'handover_overview',
        )
        .doc('main')
        .set(
          overview.toMap(updatedByName: updatedByName),
          SetOptions(merge: true),
        );
  }

  Future<void> updateCurrentHandoverOverview({
    required HandoverOverview overview,
    required String updatedByName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await updateClassroomHandoverOverview(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        overview: overview,
        updatedByName: updatedByName,
      );
      return;
    }

    await updateHandoverOverview(
      teacherUid: currentTeacherUid,
      overview: overview,
      updatedByName: updatedByName,
    );
  }

  // STAFF HANDOVER DOCUMENTS

  Stream<StaffHandoverDocument> getStaffHandoverDocument({
    required String teacherUid,
    required StaffProfile staff,
  }) {
    return teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'staff_handover_documents',
    ).doc(staff.id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return StaffHandoverDocument.empty(
          staffProfileId: staff.id,
          staffName: staff.name,
        );
      }

      return StaffHandoverDocument.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<StaffHandoverDocument> getClassroomStaffHandoverDocument({
    required String schoolId,
    required String classroomId,
    required StaffProfile staff,
  }) {
    return classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'staff_handover_documents',
    ).doc(staff.id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return StaffHandoverDocument.empty(
          staffProfileId: staff.id,
          staffName: staff.name,
        );
      }

      return StaffHandoverDocument.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<StaffHandoverDocument> getCurrentStaffHandoverDocument({
    required StaffProfile staff,
  }) {
    if (hasClassroomSession) {
      return getClassroomStaffHandoverDocument(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        staff: staff,
      );
    }

    return getStaffHandoverDocument(
      teacherUid: currentTeacherUid,
      staff: staff,
    );
  }

  Future<void> updateStaffHandoverDocument({
    required String teacherUid,
    required StaffHandoverDocument document,
  }) async {
    await teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'staff_handover_documents',
        )
        .doc(document.staffProfileId)
        .set(document.toMap(), SetOptions(merge: true));
  }

  Future<void> updateClassroomStaffHandoverDocument({
    required String schoolId,
    required String classroomId,
    required StaffHandoverDocument document,
  }) async {
    await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'staff_handover_documents',
        )
        .doc(document.staffProfileId)
        .set(document.toMap(), SetOptions(merge: true));
  }

  Future<void> updateCurrentStaffHandoverDocument({
    required StaffHandoverDocument document,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await updateClassroomStaffHandoverDocument(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        document: document,
      );
      return;
    }

    await updateStaffHandoverDocument(
      teacherUid: currentTeacherUid,
      document: document,
    );
  }

  // QUICK NOTES

  Stream<List<HandoverQuickNote>> getHandoverQuickNotes(String teacherUid) {
    return teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'handover_quick_notes',
        )
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => HandoverQuickNote.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Stream<List<HandoverQuickNote>> getClassroomHandoverQuickNotes({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'handover_quick_notes',
        )
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => HandoverQuickNote.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Stream<List<HandoverQuickNote>> getCurrentHandoverQuickNotes() {
    if (hasClassroomSession) {
      return getClassroomHandoverQuickNotes(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return getHandoverQuickNotes(currentTeacherUid);
  }

  Future<void> addHandoverQuickNote({
    required String teacherUid,
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
    required StaffProfile createdBy,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'handover_quick_notes',
    ).add({
      'title': title,
      'content': content,
      'priority': priority.value,
      'pinned': pinned,
      'createdByStaffId': createdBy.id,
      'createdByName': createdBy.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addClassroomHandoverQuickNote({
    required String schoolId,
    required String classroomId,
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
    required StaffProfile createdBy,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'handover_quick_notes',
    ).add({
      'title': title,
      'content': content,
      'priority': priority.value,
      'pinned': pinned,
      'createdByStaffId': createdBy.id,
      'createdByName': createdBy.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCurrentHandoverQuickNote({
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
    required StaffProfile createdBy,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await addClassroomHandoverQuickNote(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        title: title,
        content: content,
        priority: priority,
        pinned: pinned,
        createdBy: createdBy,
      );
      return;
    }

    await addHandoverQuickNote(
      teacherUid: currentTeacherUid,
      title: title,
      content: content,
      priority: priority,
      pinned: pinned,
      createdBy: createdBy,
    );
  }

  Future<void> updateHandoverQuickNote({
    required String teacherUid,
    required String noteId,
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'handover_quick_notes',
    ).doc(noteId).update({
      'title': title,
      'content': content,
      'priority': priority.value,
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClassroomHandoverQuickNote({
    required String schoolId,
    required String classroomId,
    required String noteId,
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'handover_quick_notes',
    ).doc(noteId).update({
      'title': title,
      'content': content,
      'priority': priority.value,
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCurrentHandoverQuickNote({
    required String noteId,
    required String title,
    required String content,
    required HandoverQuickNotePriority priority,
    required bool pinned,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await updateClassroomHandoverQuickNote(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        noteId: noteId,
        title: title,
        content: content,
        priority: priority,
        pinned: pinned,
      );
      return;
    }

    await updateHandoverQuickNote(
      teacherUid: currentTeacherUid,
      noteId: noteId,
      title: title,
      content: content,
      priority: priority,
      pinned: pinned,
    );
  }

  Future<void> deleteHandoverQuickNote({
    required String teacherUid,
    required String noteId,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'handover_quick_notes',
    ).doc(noteId).delete();
  }

  Future<void> deleteClassroomHandoverQuickNote({
    required String schoolId,
    required String classroomId,
    required String noteId,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'handover_quick_notes',
    ).doc(noteId).delete();
  }

  Future<void> deleteCurrentHandoverQuickNote(String noteId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await deleteClassroomHandoverQuickNote(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        noteId: noteId,
      );
      return;
    }

    await deleteHandoverQuickNote(
      teacherUid: currentTeacherUid,
      noteId: noteId,
    );
  }
}
