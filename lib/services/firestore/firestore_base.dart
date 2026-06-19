import 'package:cloud_firestore/cloud_firestore.dart';
import '../classroom_session_service.dart';

mixin FirestoreBase {
  FirebaseFirestore get db;

  ClassroomSessionService get session;

  bool get hasClassroomSession;

  String get currentTeacherUid;

  Future<void> restoreClassroomSessionFromAuthIfNeeded();

  // TEACHER ROOTS

  DocumentReference<Map<String, dynamic>> teacherDoc(String teacherUid) {
    return db.collection('teachers').doc(teacherUid);
  }

  CollectionReference<Map<String, dynamic>> teacherStaffProfilesRef(
    String teacherUid,
  ) {
    return teacherDoc(teacherUid).collection('staff_profiles');
  }

  CollectionReference<Map<String, dynamic>> teacherChildProfilesRef(
    String teacherUid,
  ) {
    return teacherDoc(teacherUid).collection('child_profiles');
  }

  DocumentReference<Map<String, dynamic>> teacherStaffDoc({
    required String teacherUid,
    required String staffId,
  }) {
    return teacherStaffProfilesRef(teacherUid).doc(staffId);
  }

  DocumentReference<Map<String, dynamic>> teacherChildDoc({
    required String teacherUid,
    required String childId,
  }) {
    return teacherChildProfilesRef(teacherUid).doc(childId);
  }

  // SCHOOL / CLASSROOM ROOTS

  DocumentReference<Map<String, dynamic>> schoolDoc(String schoolId) {
    return db.collection('schools').doc(schoolId);
  }

  CollectionReference<Map<String, dynamic>> classroomsRef(String schoolId) {
    return schoolDoc(schoolId).collection('classrooms');
  }

  DocumentReference<Map<String, dynamic>> classroomDoc({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomsRef(schoolId).doc(classroomId);
  }

  CollectionReference<Map<String, dynamic>> classroomStaffProfilesRef({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomDoc(
      schoolId: schoolId,
      classroomId: classroomId,
    ).collection('staff_profiles');
  }

  CollectionReference<Map<String, dynamic>> classroomChildProfilesRef({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomDoc(
      schoolId: schoolId,
      classroomId: classroomId,
    ).collection('child_profiles');
  }

  DocumentReference<Map<String, dynamic>> classroomStaffDoc({
    required String schoolId,
    required String classroomId,
    required String staffId,
  }) {
    return classroomStaffProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(staffId);
  }

  DocumentReference<Map<String, dynamic>> classroomChildDoc({
    required String schoolId,
    required String classroomId,
    required String childId,
  }) {
    return classroomChildProfilesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(childId);
  }

  // CURRENT CONTEXT ROOTS

  CollectionReference<Map<String, dynamic>> currentStaffProfilesRef() {
    if (hasClassroomSession) {
      return classroomStaffProfilesRef(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return teacherStaffProfilesRef(currentTeacherUid);
  }

  CollectionReference<Map<String, dynamic>> currentChildProfilesRef() {
    if (hasClassroomSession) {
      return classroomChildProfilesRef(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return teacherChildProfilesRef(currentTeacherUid);
  }

  DocumentReference<Map<String, dynamic>> currentStaffDoc(String staffId) {
    return currentStaffProfilesRef().doc(staffId);
  }

  DocumentReference<Map<String, dynamic>> currentChildDoc(String childId) {
    return currentChildProfilesRef().doc(childId);
  }

  // CURRENT CONTEXT GENERIC COLLECTIONS

  CollectionReference<Map<String, dynamic>> teacherCollection({
    required String teacherUid,
    required String collectionName,
  }) {
    return teacherDoc(teacherUid).collection(collectionName);
  }

  CollectionReference<Map<String, dynamic>> classroomCollection({
    required String schoolId,
    required String classroomId,
    required String collectionName,
  }) {
    return classroomDoc(
      schoolId: schoolId,
      classroomId: classroomId,
    ).collection(collectionName);
  }

  CollectionReference<Map<String, dynamic>> currentCollection(
    String collectionName,
  ) {
    if (hasClassroomSession) {
      return classroomCollection(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        collectionName: collectionName,
      );
    }

    return teacherCollection(
      teacherUid: currentTeacherUid,
      collectionName: collectionName,
    );
  }

  DocumentReference<Map<String, dynamic>> currentCollectionDoc({
    required String collectionName,
    required String docId,
  }) {
    return currentCollection(collectionName).doc(docId);
  }

  CollectionReference<Map<String, dynamic>> currentIncidentLogsRef() {
  return currentCollection('incident_logs');
}

CollectionReference<Map<String, dynamic>> currentBodyCheckReportsRef() {
  return currentCollection('body_check_reports');
}

}