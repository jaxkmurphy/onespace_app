import '../../models/child_profile.dart';
import '../../models/staff_profile.dart';
import 'firestore_base.dart';

mixin ProfileFirestoreService on FirestoreBase {
  // CURRENT PROFILE WRAPPERS

  Stream<List<StaffProfile>> getCurrentStaffProfiles() {
    if (hasClassroomSession) {
      return getClassroomStaffProfiles(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return getStaffProfiles(currentTeacherUid);
  }

  Stream<List<ChildProfile>> getCurrentChildProfiles() {
    if (hasClassroomSession) {
      return getClassroomChildProfiles(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return getChildProfiles(currentTeacherUid);
  }

  Future<List<ChildProfile>> getCurrentChildProfilesOnce() async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final snapshot = await currentChildProfilesRef().get();

    return snapshot.docs
        .map(
          (doc) => ChildProfile.fromMap(doc.id, doc.data()).copyWith(
            teacherUid:
                hasClassroomSession
                    ? session.requireClassroomId
                    : currentTeacherUid,
          ),
        )
        .toList();
  }

  Future<void> addCurrentStaffProfile(StaffProfile profile) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await addClassroomStaffProfile(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        profile: profile,
      );
      return;
    }

    await addStaffProfile(currentTeacherUid, profile);
  }

  Future<void> addCurrentChildProfile(ChildProfile profile) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await addClassroomChildProfile(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        profile: profile,
      );
      return;
    }

    await addChildProfile(currentTeacherUid, profile);
  }

  Future<void> updateCurrentStaffProfile(StaffProfile profile) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentStaffProfilesRef().doc(profile.id).update(profile.toMap());
  }

  Future<void> updateCurrentChildProfile(ChildProfile profile) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildProfilesRef().doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteCurrentStaffProfile(String profileId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentStaffProfilesRef().doc(profileId).delete();
  }

  Future<void> deleteCurrentChildProfile(String profileId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildProfilesRef().doc(profileId).delete();
  }

  Stream<ChildProfile> getCurrentChildProfileStream(String childId) {
    if (hasClassroomSession) {
      return getClassroomChildProfileStream(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        childId: childId,
      );
    }

    return getChildProfileStream(currentTeacherUid, childId);
  }

  Future<void> updateCurrentChildIconSequence({
    required String childId,
    required List<String> iconSequence,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildProfilesRef().doc(childId).update({
      'accessMode': 'iconSequence',
      'iconSequence': iconSequence,
    });
  }

  Future<void> updateCurrentChildBackgroundColor({
    required String childId,
    required String colorHex,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildProfilesRef().doc(childId).update({
      'backgroundColorHex': colorHex,
    });
  }

  // TEACHER STAFF PROFILE METHODS

  Future<void> addStaffProfile(String teacherUid, StaffProfile profile) async {
    final docRef = teacherStaffProfilesRef(teacherUid).doc();

    final profileWithId = profile.copyWith(
      id: docRef.id,
      teacherUid: teacherUid,
    );

    await docRef.set(profileWithId.toMap());
  }

  Stream<List<StaffProfile>> getStaffProfiles(String teacherUid) {
    return teacherStaffProfilesRef(teacherUid).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => StaffProfile.fromMap(
                  doc.id,
                  doc.data(),
                ).copyWith(teacherUid: teacherUid),
              )
              .toList(),
    );
  }

  Future<void> updateStaffProfile(
    String teacherUid,
    StaffProfile profile,
  ) async {
    await teacherStaffProfilesRef(
      teacherUid,
    ).doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteStaffProfile(String teacherUid, String profileId) async {
    await teacherStaffProfilesRef(teacherUid).doc(profileId).delete();
  }

  // TEACHER CHILD PROFILE METHODS

  Future<void> addChildProfile(String teacherUid, ChildProfile profile) async {
    final docRef = teacherChildProfilesRef(teacherUid).doc();

    final profileWithId = profile.copyWith(
      id: docRef.id,
      teacherUid: teacherUid,
    );

    await docRef.set(profileWithId.toMap());
  }

  Stream<List<ChildProfile>> getChildProfiles(String teacherUid) {
    return teacherChildProfilesRef(teacherUid).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => ChildProfile.fromMap(
                  doc.id,
                  doc.data(),
                ).copyWith(teacherUid: teacherUid),
              )
              .toList(),
    );
  }

  Future<List<ChildProfile>> getChildProfilesOnce(String teacherUid) async {
    final snapshot = await teacherChildProfilesRef(teacherUid).get();

    return snapshot.docs
        .map(
          (doc) => ChildProfile.fromMap(
            doc.id,
            doc.data(),
          ).copyWith(teacherUid: teacherUid),
        )
        .toList();
  }

  Stream<ChildProfile> getChildProfileStream(
    String teacherUid,
    String childId,
  ) {
    return teacherChildProfilesRef(teacherUid)
        .doc(childId)
        .snapshots()
        .map(
          (doc) => ChildProfile.fromMap(
            doc.id,
            doc.data()!,
          ).copyWith(teacherUid: teacherUid),
        );
  }

  Future<void> updateChildProfile(
    String teacherUid,
    ChildProfile profile,
  ) async {
    await teacherChildProfilesRef(
      teacherUid,
    ).doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteChildProfile(String teacherUid, String profileId) async {
    await teacherChildProfilesRef(teacherUid).doc(profileId).delete();
  }

  Future<void> updateChildBackgroundColor(
    String teacherUid,
    String childId,
    String colorHex,
  ) async {
    await teacherChildProfilesRef(
      teacherUid,
    ).doc(childId).update({'backgroundColorHex': colorHex});
  }

  Future<void> updateChildIconSequence(
    String teacherUid,
    String childId,
    List<String> iconSequence,
  ) async {
    await teacherChildProfilesRef(teacherUid).doc(childId).update({
      'accessMode': 'iconSequence',
      'iconSequence': iconSequence,
    });
  }

  // CLASSROOM STAFF PROFILE METHODS

  Future<void> addClassroomStaffProfile({
    required String schoolId,
    required String classroomId,
    required StaffProfile profile,
  }) async {
    final docRef =
        classroomStaffProfilesRef(
          schoolId: schoolId,
          classroomId: classroomId,
        ).doc();

    final profileWithId = profile.copyWith(
      id: docRef.id,
      teacherUid: classroomId,
    );

    await docRef.set(profileWithId.toMap());
  }

  Stream<List<StaffProfile>> getClassroomStaffProfiles({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomStaffProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => StaffProfile.fromMap(
                  doc.id,
                  doc.data(),
                ).copyWith(teacherUid: classroomId),
              )
              .toList(),
    );
  }

  Future<void> deleteClassroomStaffProfile({
    required String schoolId,
    required String classroomId,
    required String profileId,
  }) async {
    await classroomStaffProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(profileId).delete();
  }

  // CLASSROOM CHILD PROFILE METHODS

  Future<void> addClassroomChildProfile({
    required String schoolId,
    required String classroomId,
    required ChildProfile profile,
  }) async {
    final docRef =
        classroomChildProfilesRef(
          schoolId: schoolId,
          classroomId: classroomId,
        ).doc();

    final profileWithId = profile.copyWith(
      id: docRef.id,
      teacherUid: classroomId,
    );

    await docRef.set(profileWithId.toMap());
  }

  Future<void> updateClassroomChildProfile({
    required String schoolId,
    required String classroomId,
    required ChildProfile profile,
  }) async {
    await classroomChildProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(profile.id).update(profile.toMap());
  }

  Stream<ChildProfile> getClassroomChildProfileStream({
    required String schoolId,
    required String classroomId,
    required String childId,
  }) {
    return classroomChildProfilesRef(
          schoolId: schoolId,
          classroomId: classroomId,
        )
        .doc(childId)
        .snapshots()
        .map(
          (doc) => ChildProfile.fromMap(
            doc.id,
            doc.data()!,
          ).copyWith(teacherUid: classroomId),
        );
  }

  Stream<List<ChildProfile>> getClassroomChildProfiles({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomChildProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => ChildProfile.fromMap(
                  doc.id,
                  doc.data(),
                ).copyWith(teacherUid: classroomId),
              )
              .toList(),
    );
  }

  Future<void> deleteClassroomChildProfile({
    required String schoolId,
    required String classroomId,
    required String profileId,
  }) async {
    await classroomChildProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(profileId).delete();
  }

  Future<void> updateClassroomChildIconSequence({
    required String schoolId,
    required String classroomId,
    required String childId,
    required List<String> iconSequence,
  }) async {
    await classroomChildProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(childId).update({
      'accessMode': 'iconSequence',
      'iconSequence': iconSequence,
    });
  }
}