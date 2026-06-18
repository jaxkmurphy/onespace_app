import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../models/quiz.dart';
import '../models/first_then_option.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/staff_handover_document.dart';
import '../models/handover_quick_note.dart';
import '../models/incident_log_entry.dart';
import '../models/word_pack.dart';
import '../models/word_item.dart';
import '../models/word_attempt.dart';
import '../models/body_check_report.dart';
import '../models/school.dart';
import '../models/classroom.dart';
import '../models/school_member.dart';
import 'classroom_session_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

    // CURRENT CONTEXT HELPERS
  // These methods decide whether the app should use:
  // - classroom path: schools/{schoolId}/classrooms/{classroomId}
  // - old teacher path: teachers/{uid}

  ClassroomSessionService get _session => ClassroomSessionService.instance;

  bool get hasClassroomSession => _session.hasClassroomSession;

  String get currentTeacherUid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No logged-in Firebase user found.');
    }

    return user.uid;
  }

  Stream<List<StaffProfile>> getCurrentStaffProfiles() {
    if (hasClassroomSession) {
      return getClassroomStaffProfiles(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
      );
    }

    return getStaffProfiles(currentTeacherUid);
  }

  Stream<List<ChildProfile>> getCurrentChildProfiles() {
    if (hasClassroomSession) {
      return getClassroomChildProfiles(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
      );
    }

    return getChildProfiles(currentTeacherUid);
  }

  Future<List<ChildProfile>> getCurrentChildProfilesOnce() async {
    if (hasClassroomSession) {
      final snapshot = await _db
          .collection('schools')
          .doc(_session.requireSchoolId)
          .collection('classrooms')
          .doc(_session.requireClassroomId)
          .collection('child_profiles')
          .get();

      return snapshot.docs
          .map(
            (doc) => ChildProfile.fromMap(doc.id, doc.data()).copyWith(
              teacherUid: _session.requireClassroomId,
            ),
          )
          .toList();
    }

    return getChildProfilesOnce(currentTeacherUid);
  }

  Future<void> addCurrentStaffProfile(StaffProfile profile) async {
    if (hasClassroomSession) {
      await addClassroomStaffProfile(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        profile: profile,
      );
      return;
    }

    await addStaffProfile(currentTeacherUid, profile);
  }

  Future<void> addCurrentChildProfile(ChildProfile profile) async {
    if (hasClassroomSession) {
      await addClassroomChildProfile(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        profile: profile,
      );
      return;
    }

    await addChildProfile(currentTeacherUid, profile);
  }

  Future<void> updateCurrentChildProfile(ChildProfile profile) async {
    if (hasClassroomSession) {
      await updateClassroomChildProfile(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        profile: profile,
      );
      return;
    }

    await updateChildProfile(currentTeacherUid, profile);
  }

  Future<void> updateCurrentStaffProfile(StaffProfile profile) async {
    if (hasClassroomSession) {
      await _db
          .collection('schools')
          .doc(_session.requireSchoolId)
          .collection('classrooms')
          .doc(_session.requireClassroomId)
          .collection('staff_profiles')
          .doc(profile.id)
          .update(profile.toMap());
      return;
    }

    await updateStaffProfile(currentTeacherUid, profile);
  }

  Future<void> deleteCurrentStaffProfile(String profileId) async {
    if (hasClassroomSession) {
      await deleteClassroomStaffProfile(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        profileId: profileId,
      );
      return;
    }

    await deleteStaffProfile(currentTeacherUid, profileId);
  }

  Future<void> deleteCurrentChildProfile(String profileId) async {
    if (hasClassroomSession) {
      await deleteClassroomChildProfile(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        profileId: profileId,
      );
      return;
    }

    await deleteChildProfile(currentTeacherUid, profileId);
  }

  Future<void> setCurrentChildZone({
    required String childId,
    required String zone,
  }) async {
    if (hasClassroomSession) {
      await setClassroomChildZone(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
        childId: childId,
        zone: zone,
      );
      return;
    }

    await setChildZone(currentTeacherUid, childId, zone);
  }

  Future<void> setCurrentChildPoints({
    required String childId,
    required int points,
  }) async {
    if (hasClassroomSession) {
      await _db
          .collection('schools')
          .doc(_session.requireSchoolId)
          .collection('classrooms')
          .doc(_session.requireClassroomId)
          .collection('child_profiles')
          .doc(childId)
          .update({'points': points});
      return;
    }

    await setChildPoints(currentTeacherUid, childId, points);
  }

  Future<void> restoreClassroomSessionFromAuthIfNeeded() async {
  if (_session.hasClassroomSession) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final tokenResult = await user.getIdTokenResult(true);
    final claims = tokenResult.claims ?? {};

    if (claims['role'] == 'classroom' &&
        claims['schoolId'] is String &&
        claims['classroomId'] is String) {
      final schoolId = claims['schoolId'] as String;
      final classroomId = claims['classroomId'] as String;

      final classroom = await getClassroom(
        schoolId: schoolId,
        classroomId: classroomId,
      );

      if (classroom != null && classroom.active) {
        _session.setSession(
          schoolId: schoolId,
          classroomId: classroomId,
          classroomName: classroom.name,
        );
      }
    }
  } catch (e) {
    debugPrint('Could not restore classroom session: $e');
  }
}

  // SCHOOL / ADMIN STRUCTURE

  Future<String> createSchool({
    required String name,
    required String schoolCode,
    required String adminUid,
    required String adminEmail,
    int classroomLimit = 3,
  }) async {
    final schoolRef = _db.collection('schools').doc();

    final school = School(
      id: schoolRef.id,
      name: name.trim(),
      schoolCode: schoolCode.trim().toUpperCase(),
      classroomLimit: classroomLimit,
      active: true,
      createdAt: DateTime.now(),
    );

    final member = SchoolMember(
      uid: adminUid,
      schoolId: schoolRef.id,
      email: adminEmail,
      role: 'schoolAdmin',
      active: true,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();

    batch.set(schoolRef, school.toMap());

    batch.set(
    schoolRef.collection('members').doc(adminUid),
    member.toMap(),
    );

    batch.set(
      _db.collection('account_lookup').doc(adminUid),
      {
        'schoolId': schoolRef.id,
        'role': 'schoolAdmin',
        'email': adminEmail,
        'active': true,
        'createdAt': DateTime.now(),
      },
    );

    await batch.commit();

    return schoolRef.id;
  }

  Future<School?> getSchool(String schoolId) async {
    final doc = await _db.collection('schools').doc(schoolId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return School.fromMap(doc.id, doc.data()!);
  }

  Future<School?> getSchoolByCode(String schoolCode) async {
    final query = await _db
        .collection('schools')
        .where('schoolCode', isEqualTo: schoolCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return School.fromMap(doc.id, doc.data());
  }

  Future<SchoolMember?> getSchoolMember({
    required String schoolId,
    required String uid,
  }) async {
    final doc = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('members')
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return SchoolMember.fromMap(doc.id, doc.data()!);
  }

  Future<SchoolMember?> getSchoolMemberByUid(String uid) async {
  try {
    final lookupDoc = await _db.collection('account_lookup').doc(uid).get();

    if (!lookupDoc.exists || lookupDoc.data() == null) {
      return null;
    }

    final lookupData = lookupDoc.data()!;
    final schoolId = lookupData['schoolId'] as String?;

    if (schoolId == null || schoolId.isEmpty) {
      return null;
    }

    final memberDoc = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('members')
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.data() == null) {
      return null;
    }

    return SchoolMember.fromMap(memberDoc.id, memberDoc.data()!);
  } catch (e) {
    debugPrint('Could not check school member: $e');
    return null;
  }
}

  Future<void> createClassroom({
  required String schoolId,
  required String name,
  required String classroomCode,
  required String pin,
}) async {
  final school = await getSchool(schoolId);

  if (school == null) {
    throw Exception('School not found.');
  }

  final existingClassrooms = await getClassroomsOnce(schoolId);

  if (existingClassrooms.length >= school.classroomLimit) {
    throw Exception(
      'Classroom limit reached. Increase the classroom limit in School Settings.',
    );
  }

  final codeAvailable = await isClassroomCodeAvailable(
    schoolId: schoolId,
    classroomCode: classroomCode,
  );

  if (!codeAvailable) {
    throw Exception('That classroom code is already in use.');
  }

  final classroomRef = _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc();

  final classroom = Classroom(
    id: classroomRef.id,
    schoolId: schoolId,
    name: name.trim(),
    classroomCode: classroomCode.trim().toUpperCase(),
    pin: pin.trim(),
    active: true,
    createdAt: DateTime.now(),
  );

  await classroomRef.set(classroom.toMap());
}

  Stream<List<Classroom>> getClassrooms(String schoolId) {
    return _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Classroom.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<Classroom>> getClassroomsOnce(String schoolId) async {
    final snapshot = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Classroom.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Classroom?> getClassroomByCode({
    required String schoolId,
    required String classroomCode,
  }) async {
    final query = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .where(
          'classroomCode',
          isEqualTo: classroomCode.trim().toUpperCase(),
        )
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return Classroom.fromMap(doc.id, doc.data());
  }

  Future<Classroom?> verifyClassroomLogin({
    required String schoolCode,
    required String classroomCode,
    required String pin,
  }) async {
    final school = await getSchoolByCode(schoolCode);

    if (school == null || !school.active) {
      return null;
    }

    final classroom = await getClassroomByCode(
      schoolId: school.id,
      classroomCode: classroomCode,
    );

    if (classroom == null || !classroom.active) {
      return null;
    }

    if (classroom.pin.trim() != pin.trim()) {
      return null;
    }

    return classroom;
  }

  Future<bool> isClassroomCodeAvailable({
  required String schoolId,
  required String classroomCode,
  String? currentClassroomId,
}) async {
  final query = await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .where('classroomCode', isEqualTo: classroomCode.trim().toUpperCase())
      .limit(1)
      .get();

  if (query.docs.isEmpty) {
    return true;
  }

  if (currentClassroomId != null && query.docs.first.id == currentClassroomId) {
    return true;
  }

  return false;
}

Future<Classroom?> getClassroom({
  required String schoolId,
  required String classroomId,
}) async {
  final doc = await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .get();

  if (!doc.exists || doc.data() == null) {
    return null;
  }

  return Classroom.fromMap(doc.id, doc.data()!);
}

Future<void> updateClassroom({
  required String schoolId,
  required String classroomId,
  required String name,
  required String classroomCode,
  required String pin,
  required bool active,
}) async {
  final formattedClassroomCode = classroomCode.trim().toUpperCase();

  final codeAvailable = await isClassroomCodeAvailable(
    schoolId: schoolId,
    classroomCode: formattedClassroomCode,
    currentClassroomId: classroomId,
  );

  if (!codeAvailable) {
    throw Exception('That classroom code is already in use.');
  }

  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .update({
    'name': name.trim(),
    'classroomCode': formattedClassroomCode,
    'pin': pin.trim(),
    'active': active,
    'updatedAt': DateTime.now(),
  });
}

  Future<void> deleteClassroom({
    required String schoolId,
    required String classroomId,
  }) async {
    await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .delete();
  }

  Future<bool> isSchoolCodeAvailable({
  required String schoolCode,
  String? currentSchoolId,
}) async {
  final query = await _db
      .collection('schools')
      .where('schoolCode', isEqualTo: schoolCode.trim().toUpperCase())
      .limit(1)
      .get();

  if (query.docs.isEmpty) {
    return true;
  }

  if (currentSchoolId != null && query.docs.first.id == currentSchoolId) {
    return true;
  }

  return false;
}

Future<void> updateSchool({
  required String schoolId,
  required String name,
  required String schoolCode,
  required int classroomLimit,
  required bool active,
  String principalName = '',
  String vicePrincipalName = '',
  String schoolEmail = '',
  String phoneNumber = '',
  String address = '',
}) async {
  final formattedSchoolCode = schoolCode.trim().toUpperCase();

  final codeAvailable = await isSchoolCodeAvailable(
    schoolCode: formattedSchoolCode,
    currentSchoolId: schoolId,
  );

  if (!codeAvailable) {
    throw Exception('That school code is already in use.');
  }

  await _db.collection('schools').doc(schoolId).update({
    'name': name.trim(),
    'schoolCode': formattedSchoolCode,
    'classroomLimit': classroomLimit,
    'active': active,
    'principalName': principalName.trim(),
    'vicePrincipalName': vicePrincipalName.trim(),
    'schoolEmail': schoolEmail.trim(),
    'phoneNumber': phoneNumber.trim(),
    'address': address.trim(),
    'updatedAt': DateTime.now(),
  });
}

  // Teacher data
  Future<void> setTeacherInfo(Teacher teacher) async {
    await _db.collection('teachers').doc(teacher.uid).set(teacher.toMap(), SetOptions(merge: true));
  }

  Future<Teacher> getTeacherInfo(String uid) async {
    try {
      final doc = await _db.collection('teachers').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return Teacher.fromMap(doc.id, doc.data()!);
      } else {
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        final newTeacher = Teacher(uid: uid, email: email, name: '', pin: '');
        await setTeacherInfo(newTeacher);
        return newTeacher;
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        debugPrint('Firestore unavailable: ${e.message}');
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        return Teacher(uid: uid, email: email, name: '', pin: '');
      } else {
        throw Exception('Failed to get teacher info: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

    // Classroom staff/child profile methods

  Future<void> addClassroomStaffProfile({
    required String schoolId,
    required String classroomId,
    required StaffProfile profile,
  }) async {
    final docRef = _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('staff_profiles')
        .doc();

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
    return _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('staff_profiles')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => StaffProfile.fromMap(doc.id, doc.data()).copyWith(
                  teacherUid: classroomId,
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteClassroomStaffProfile({
    required String schoolId,
    required String classroomId,
    required String profileId,
  }) async {
    await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('staff_profiles')
        .doc(profileId)
        .delete();
  }

  Future<void> addClassroomChildProfile({
    required String schoolId,
    required String classroomId,
    required ChildProfile profile,
  }) async {
    final docRef = _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('child_profiles')
        .doc();

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
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(profile.id)
      .update(profile.toMap());
}

    Future<void> setClassroomChildZone({
      required String schoolId,
      required String classroomId,
      required String childId,
      required String zone,
    }) async {
    await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .update({'zone': zone});
    }

    Stream<ChildProfile> getClassroomChildProfileStream({
      required String schoolId,
      required String classroomId,
      required String childId,
    }) {
      return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .snapshots()
      .map((doc) => ChildProfile.fromMap(doc.id, doc.data()!).copyWith(
            teacherUid: classroomId,
          ));
  }

  Stream<List<ChildProfile>> getClassroomChildProfiles({
    required String schoolId,
    required String classroomId,
  }) {
    return _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('child_profiles')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChildProfile.fromMap(doc.id, doc.data()).copyWith(
                  teacherUid: classroomId,
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteClassroomChildProfile({
    required String schoolId,
    required String classroomId,
    required String profileId,
  }) async {
    await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('child_profiles')
        .doc(profileId)
        .delete();
  }

  // Staff profile methods
  Future<void> addStaffProfile(String teacherUid, StaffProfile profile) async {
    final docRef = _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc();
    final profileWithId = profile.copyWith(id: docRef.id, teacherUid: teacherUid);
    await docRef.set(profileWithId.toMap());
  }

  Stream<List<StaffProfile>> getStaffProfiles(String teacherUid) {
    return _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('staff_profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StaffProfile.fromMap(doc.id, doc.data()).copyWith(teacherUid: teacherUid))
            .toList());
  }

  // Child profile methods
  Future<void> addChildProfile(String teacherUid, ChildProfile profile) async {
    final docRef = _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc();
    final profileWithId = profile.copyWith(id: docRef.id, teacherUid: teacherUid);
    await docRef.set(profileWithId.toMap());
  }

  Stream<List<ChildProfile>> getChildProfiles(String teacherUid) {
    return _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildProfile.fromMap(doc.id, doc.data()).copyWith(teacherUid: teacherUid))
            .toList());
  }

  Future<void> updateStaffProfile(String teacherUid, StaffProfile profile) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('staff_profiles')
      .doc(profile.id)
      .update(profile.toMap());
}

Future<void> updateStaffCircleTimePosition({
  required String teacherUid,
  required String staffId,
  required double x,
  required double y,
  required String side,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('staff_profiles')
      .doc(staffId)
      .update({
    'circleTimeX': x,
    'circleTimeY': y,
    'circleTimeSide': side,
  });
}

Future<void> deleteStaffProfile(String teacherUid, String profileId) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('staff_profiles')
      .doc(profileId)
      .delete();
}

Future<void> updateChildProfile(String teacherUid, ChildProfile profile) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(profile.id)
      .update(profile.toMap());
}

  // CURRENT / CIRCLE TIME

Future<void> updateClassroomStaffCircleTimePosition({
  required String schoolId,
  required String classroomId,
  required String staffId,
  required double x,
  required double y,
  required String side,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('staff_profiles')
      .doc(staffId)
      .update({
    'circleTimeX': x,
    'circleTimeY': y,
    'circleTimeSide': side,
  });
}

Future<void> updateClassroomChildCircleTimePosition({
  required String schoolId,
  required String classroomId,
  required String childId,
  required double x,
  required double y,
  required String side,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .update({
    'circleTimeX': x,
    'circleTimeY': y,
    'circleTimeSide': side,
  });
}

Future<void> updateCurrentStaffCircleTimePosition({
  required String staffId,
  required double x,
  required double y,
  required String side,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomStaffCircleTimePosition(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      staffId: staffId,
      x: x,
      y: y,
      side: side,
    );
    return;
  }

  await updateStaffCircleTimePosition(
    teacherUid: currentTeacherUid,
    staffId: staffId,
    x: x,
    y: y,
    side: side,
  );
}

Future<void> updateCurrentChildCircleTimePosition({
  required String childId,
  required double x,
  required double y,
  required String side,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomChildCircleTimePosition(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
      x: x,
      y: y,
      side: side,
    );
    return;
  }

  await updateChildCircleTimePosition(
    teacherUid: currentTeacherUid,
    childId: childId,
    x: x,
    y: y,
    side: side,
  );
}

Future<void> updateChildCircleTimePosition({
  required String teacherUid,
  required String childId,
  required double x,
  required double y,
  required String side,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .update({
    'circleTimeX': x,
    'circleTimeY': y,
    'circleTimeSide': side,
  });
}

Future<void> deleteChildProfile(String teacherUid, String profileId) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(profileId)
      .delete();
}

  // Zone + Points
  Future<void> setChildZone(String teacherUid, String childId, String zone) async {
    await _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId)
        .update({'zone': zone});
  }

  Future<void> setChildPoints(String teacherUid, String childId, int points) async {
    await _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId)
        .update({'points': points});
  }

  Future<List<ChildProfile>> getChildProfilesOnce(
  String teacherUid,
) async {
  final snapshot = await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .get();

  return snapshot.docs
      .map(
        (doc) => ChildProfile.fromMap(
          doc.id,
          doc.data(),
        ),
      )
      .toList();
}

  // 🗓 SCHEDULE MANAGEMENT

  Future<Map<String, List<Map<String, dynamic>>>> getSchedule(String teacherUid) async {
    final doc = await _db.collection('teachers').doc(teacherUid).get();
    final data = doc.data();
    if (data == null || !data.containsKey('schedule')) return {};

    final schedule = Map<String, dynamic>.from(data['schedule']);
    return schedule.map((day, entries) {
      final list = List<Map<String, dynamic>>.from(entries);
      return MapEntry(day, list);
    });
  }

  Future<void> setScheduleForDay(String teacherUid, String day, List<Map<String, dynamic>> entries) async {
    final docRef = _db.collection('teachers').doc(teacherUid);
    await docRef.set({
      'schedule': {day: entries}
    }, SetOptions(merge: true));
  }

  Future<void> addScheduleEntry(String teacherUid, String day, Map<String, dynamic> entry) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];
    dayEntries.add(entry);
    dayEntries.sort((a, b) => a['start']?.compareTo(b['start']) ?? 0);
    await setScheduleForDay(teacherUid, day, dayEntries);
  }

  Future<void> removeScheduleEntry(String teacherUid, String day, Map<String, dynamic> entry) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];
    dayEntries.removeWhere((e) =>
        e['start'] == entry['start'] &&
        e['end'] == entry['end'] &&
        e['description'] == entry['description']);
    await setScheduleForDay(teacherUid, day, dayEntries);
  }

  Future<void> updateScheduleEntry(String teacherUid, String day, Map<String, dynamic> oldEntry, Map<String, dynamic> newEntry) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];
    final index = dayEntries.indexWhere((e) =>
        e['start'] == oldEntry['start'] &&
        e['end'] == oldEntry['end'] &&
        e['description'] == oldEntry['description']);
    if (index != -1) {
      dayEntries[index] = newEntry;
      dayEntries.sort((a, b) => a['start']?.compareTo(b['start']) ?? 0);
      await setScheduleForDay(teacherUid, day, dayEntries);
    }
  }

    // CURRENT / CLASSROOM SCHEDULE METHODS

  Future<Map<String, List<Map<String, dynamic>>>> getClassroomSchedule({
    required String schoolId,
    required String classroomId,
  }) async {
    final doc = await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .get();

    final data = doc.data();

    if (data == null || !data.containsKey('schedule')) {
      return {};
    }

    final schedule = Map<String, dynamic>.from(data['schedule']);

    return schedule.map((day, entries) {
      final list = List<Map<String, dynamic>>.from(entries);
      return MapEntry(day, list);
    });
  }

  Future<void> setClassroomScheduleForDay({
    required String schoolId,
    required String classroomId,
    required String day,
    required List<Map<String, dynamic>> entries,
  }) async {
    final docRef = _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId);

    await docRef.set({
      'schedule': {
        day: entries,
      },
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<Map<String, dynamic>>>> getCurrentSchedule() async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    return getClassroomSchedule(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getSchedule(currentTeacherUid);
}

  Future<void> setCurrentScheduleForDay({
  required String day,
  required List<Map<String, dynamic>> entries,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await setClassroomScheduleForDay(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      day: day,
      entries: entries,
    );
    return;
  }

  await setScheduleForDay(currentTeacherUid, day, entries);
}

  // QUIZZES

Future<void> addQuiz(Quiz quiz) async {
  await _db
      .collection('teachers')
      .doc(quiz.createdBy)
      .collection('quizzes')
      .doc(quiz.id)
      .set(quiz.toMap());
}

Future<void> addClassroomQuiz({
  required String schoolId,
  required String classroomId,
  required Quiz quiz,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('quizzes')
      .doc(quiz.id)
      .set(quiz.toMap());
}

Future<void> addCurrentQuiz(Quiz quiz) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomQuiz(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      quiz: quiz,
    );
    return;
  }

  await addQuiz(
    quiz,
  );
}

Stream<List<Quiz>> getQuizzes(String teacherUid) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('quizzes')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Quiz.fromMap(doc.id, doc.data()))
          .toList());
}

Stream<List<Quiz>> getClassroomQuizzes({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('quizzes')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Quiz.fromMap(doc.id, doc.data()))
          .toList());
}

Stream<List<Quiz>> getCurrentQuizzes() {
  if (hasClassroomSession) {
    return getClassroomQuizzes(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getQuizzes(currentTeacherUid);
}

Future<void> assignQuizToChild(
  String teacherUid,
  String childId,
  String quizId,
) async {
  final childRef = _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId);

  await childRef.update({
    'assignedQuizzes': FieldValue.arrayUnion([quizId]),
  });
}

Future<void> assignClassroomQuizToChild({
  required String schoolId,
  required String classroomId,
  required String childId,
  required String quizId,
}) async {
  final childRef = _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId);

  await childRef.update({
    'assignedQuizzes': FieldValue.arrayUnion([quizId]),
  });
}

Future<void> assignCurrentQuizToChild({
  required String childId,
  required String quizId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await assignClassroomQuizToChild(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
      quizId: quizId,
    );
    return;
  }

  await assignQuizToChild(
    currentTeacherUid,
    childId,
    quizId,
  );
}

Future<void> submitQuiz(
  String teacherUid,
  String childId,
  String quizId,
  int score,
) async {
  final childRef = _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId);

  await childRef.set({
    'completedQuizzes': {
      quizId: {
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      }
    }
  }, SetOptions(merge: true));
}

Future<void> submitClassroomQuiz({
  required String schoolId,
  required String classroomId,
  required String childId,
  required String quizId,
  required int score,
}) async {
  final childRef = _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId);

  await childRef.set({
    'completedQuizzes': {
      quizId: {
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      }
    }
  }, SetOptions(merge: true));
}

Future<void> submitCurrentQuiz({
  required String childId,
  required String quizId,
  required int score,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await submitClassroomQuiz(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
      quizId: quizId,
      score: score,
    );
    return;
  }

  await submitQuiz(
    currentTeacherUid,
    childId,
    quizId,
    score,
  );
}

Future<void> deleteQuiz(String teacherUid, String quizId) async {
  try {
    await _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('quizzes')
        .doc(quizId)
        .delete();
  } catch (e) {
    throw Exception('Failed to delete quiz: $e');
  }
}

Future<void> deleteClassroomQuiz({
  required String schoolId,
  required String classroomId,
  required String quizId,
}) async {
  try {
    await _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('quizzes')
        .doc(quizId)
        .delete();
  } catch (e) {
    throw Exception('Failed to delete classroom quiz: $e');
  }
}

Future<void> deleteCurrentQuiz(String quizId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomQuiz(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      quizId: quizId,
    );
    return;
  }

  await deleteQuiz(
    currentTeacherUid,
    quizId,
  );
}

  Future<void> updateChildBackgroundColor(String teacherUid, String childId, String colorHex) async {
    await _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId)
        .update({'backgroundColor': colorHex});
  }

  Stream<ChildProfile> getChildProfileStream(String teacherUid, String childId) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .snapshots()
      .map((doc) => ChildProfile.fromMap(doc.id, doc.data()!));
}

  Future<void> updateChildIconSequence(
  String teacherUid,
  String childId,
  List<String> iconSequence,
) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .update({
    'accessMode': 'iconSequence',
    'iconSequence': iconSequence,
  });
}

    // FIRST-THEN BOARD

CollectionReference<Map<String, dynamic>> _firstThenOptionsRef({
  required String teacherUid,
  required String type,
}) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('first_then_options')
      .doc(type)
      .collection('items');
}

CollectionReference<Map<String, dynamic>> _classroomFirstThenOptionsRef({
  required String schoolId,
  required String classroomId,
  required String type,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('first_then_options')
      .doc(type)
      .collection('items');
}

Stream<List<FirstThenOption>> getFirstThenOptions({
  required String teacherUid,
  required String type,
}) {
  return _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).snapshots().map((snapshot) {
    final options = snapshot.docs
        .map((doc) => FirstThenOption.fromMap(doc.id, doc.data()))
        .toList();

    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  });
}

Stream<List<FirstThenOption>> getClassroomFirstThenOptions({
  required String schoolId,
  required String classroomId,
  required String type,
}) {
  return _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).snapshots().map((snapshot) {
    final options = snapshot.docs
        .map((doc) => FirstThenOption.fromMap(doc.id, doc.data()))
        .toList();

    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  });
}

Stream<List<FirstThenOption>> getCurrentFirstThenOptions({
  required String type,
}) {
  if (hasClassroomSession) {
    return getClassroomFirstThenOptions(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      type: type,
    );
  }

  return getFirstThenOptions(
    teacherUid: currentTeacherUid,
    type: type,
  );
}

Future<void> addFirstThenOption({
  required String teacherUid,
  required String type,
  required FirstThenOption option,
}) async {
  await _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).add(option.toMap());
}

Future<void> addClassroomFirstThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required FirstThenOption option,
}) async {
  await _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).add(option.toMap());
}

Future<void> addCurrentFirstThenOption({
  required String type,
  required FirstThenOption option,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomFirstThenOption(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      type: type,
      option: option,
    );
    return;
  }

  await addFirstThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    option: option,
  );
}

Future<void> updateFirstThenOption({
  required String teacherUid,
  required String type,
  required FirstThenOption option,
}) async {
  await _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).doc(option.id).update(option.toMap());
}

Future<void> updateClassroomFirstThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required FirstThenOption option,
}) async {
  await _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).doc(option.id).update(option.toMap());
}

Future<void> updateCurrentFirstThenOption({
  required String type,
  required FirstThenOption option,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomFirstThenOption(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      type: type,
      option: option,
    );
    return;
  }

  await updateFirstThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    option: option,
  );
}

Future<void> deleteFirstThenOption({
  required String teacherUid,
  required String type,
  required String optionId,
}) async {
  await _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).doc(optionId).delete();
}

Future<void> deleteClassroomFirstThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required String optionId,
}) async {
  await _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).doc(optionId).delete();
}

Future<void> deleteCurrentFirstThenOption({
  required String type,
  required String optionId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomFirstThenOption(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      type: type,
      optionId: optionId,
    );
    return;
  }

  await deleteFirstThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    optionId: optionId,
  );
}

Future<void> seedDefaultFirstThenOptions(String teacherUid) async {
  final activitySnapshot = await _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: 'activities',
  ).limit(1).get();

  final rewardSnapshot = await _firstThenOptionsRef(
    teacherUid: teacherUid,
    type: 'rewards',
  ).limit(1).get();

  if (activitySnapshot.docs.isEmpty) {
    final defaults = [
      FirstThenOption(id: '', label: 'Quiz', iconName: 'quiz'),
      FirstThenOption(id: '', label: 'Homework', iconName: 'book'),
      FirstThenOption(id: '', label: 'Clean Up', iconName: 'clean'),
      FirstThenOption(id: '', label: 'Finish Work', iconName: 'task'),
    ];

    for (final option in defaults) {
      await addFirstThenOption(
        teacherUid: teacherUid,
        type: 'activities',
        option: option,
      );
    }
  }

  if (rewardSnapshot.docs.isEmpty) {
    final defaults = [
      FirstThenOption(id: '', label: 'Calming Sounds', iconName: 'music'),
      FirstThenOption(id: '', label: 'Playtime', iconName: 'toys'),
      FirstThenOption(id: '', label: 'Outside Time', iconName: 'outside'),
      FirstThenOption(id: '', label: 'Break', iconName: 'break'),
      FirstThenOption(id: '', label: 'Music', iconName: 'music'),
    ];

    for (final option in defaults) {
      await addFirstThenOption(
        teacherUid: teacherUid,
        type: 'rewards',
        option: option,
      );
    }
  }
}

Future<void> seedDefaultClassroomFirstThenOptions({
  required String schoolId,
  required String classroomId,
}) async {
  final activitySnapshot = await _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: 'activities',
  ).limit(1).get();

  final rewardSnapshot = await _classroomFirstThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: 'rewards',
  ).limit(1).get();

  if (activitySnapshot.docs.isEmpty) {
    final defaults = [
      FirstThenOption(id: '', label: 'Quiz', iconName: 'quiz'),
      FirstThenOption(id: '', label: 'Homework', iconName: 'book'),
      FirstThenOption(id: '', label: 'Clean Up', iconName: 'clean'),
      FirstThenOption(id: '', label: 'Finish Work', iconName: 'task'),
    ];

    for (final option in defaults) {
      await addClassroomFirstThenOption(
        schoolId: schoolId,
        classroomId: classroomId,
        type: 'activities',
        option: option,
      );
    }
  }

  if (rewardSnapshot.docs.isEmpty) {
    final defaults = [
      FirstThenOption(id: '', label: 'Calming Sounds', iconName: 'music'),
      FirstThenOption(id: '', label: 'Playtime', iconName: 'toys'),
      FirstThenOption(id: '', label: 'Outside Time', iconName: 'outside'),
      FirstThenOption(id: '', label: 'Break', iconName: 'break'),
      FirstThenOption(id: '', label: 'Music', iconName: 'music'),
    ];

    for (final option in defaults) {
      await addClassroomFirstThenOption(
        schoolId: schoolId,
        classroomId: classroomId,
        type: 'rewards',
        option: option,
      );
    }
  }
}

Future<void> seedDefaultCurrentFirstThenOptions() async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await seedDefaultClassroomFirstThenOptions(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
    return;
  }

  await seedDefaultFirstThenOptions(currentTeacherUid);
}

Future<void> setFirstThenForChildren({
  required String teacherUid,
  required List<String> childIds,
  required FirstThenOption activity,
  required List<FirstThenOption> rewards,
}) async {
  final batch = _db.batch();

  for (final childId in childIds) {
    final docRef = _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId);

    batch.set(docRef, {
      'firstThen': {
        'activity': activity.toFirstThenMap(),
        'rewards': rewards.map((reward) => reward.toFirstThenMap()).toList(),
        'selectedRewardId': null,
        'isActive': true,
      }
    }, SetOptions(merge: true));
  }

  await batch.commit();
}

Future<void> setClassroomFirstThenForChildren({
  required String schoolId,
  required String classroomId,
  required List<String> childIds,
  required FirstThenOption activity,
  required List<FirstThenOption> rewards,
}) async {
  final batch = _db.batch();

  for (final childId in childIds) {
    final docRef = _db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('child_profiles')
        .doc(childId);

    batch.set(docRef, {
      'firstThen': {
        'activity': activity.toFirstThenMap(),
        'rewards': rewards.map((reward) => reward.toFirstThenMap()).toList(),
        'selectedRewardId': null,
        'isActive': true,
      }
    }, SetOptions(merge: true));
  }

  await batch.commit();
}

Future<void> setCurrentFirstThenForChildren({
  required List<String> childIds,
  required FirstThenOption activity,
  required List<FirstThenOption> rewards,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await setClassroomFirstThenForChildren(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childIds: childIds,
      activity: activity,
      rewards: rewards,
    );
    return;
  }

  await setFirstThenForChildren(
    teacherUid: currentTeacherUid,
    childIds: childIds,
    activity: activity,
    rewards: rewards,
  );
}

Future<void> clearFirstThenForChild({
  required String teacherUid,
  required String childId,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .set({
    'firstThen': {
      'activity': null,
      'rewards': [],
      'selectedRewardId': null,
      'isActive': false,
    }
  }, SetOptions(merge: true));
}

Future<void> clearClassroomFirstThenForChild({
  required String schoolId,
  required String classroomId,
  required String childId,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .set({
    'firstThen': {
      'activity': null,
      'rewards': [],
      'selectedRewardId': null,
      'isActive': false,
    }
  }, SetOptions(merge: true));
}

Future<void> clearCurrentFirstThenForChild(String childId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await clearClassroomFirstThenForChild(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
    );
    return;
  }

  await clearFirstThenForChild(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

Future<void> selectFirstThenReward({
  required String teacherUid,
  required String childId,
  required String rewardId,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .update({
    'firstThen.selectedRewardId': rewardId,
  });
}

Future<void> selectClassroomFirstThenReward({
  required String schoolId,
  required String classroomId,
  required String childId,
  required String rewardId,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .update({
    'firstThen.selectedRewardId': rewardId,
  });
}

Future<void> selectCurrentFirstThenReward({
  required String childId,
  required String rewardId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await selectClassroomFirstThenReward(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
      rewardId: rewardId,
    );
    return;
  }

  await selectFirstThenReward(
    teacherUid: currentTeacherUid,
    childId: childId,
    rewardId: rewardId,
  );
}

Stream<Map<String, dynamic>?> getFirstThenStream({
  required String teacherUid,
  required String childId,
}) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null) return null;

    final firstThen = data['firstThen'];
    if (firstThen is Map<String, dynamic>) {
      return firstThen;
    }
    if (firstThen is Map) {
      return Map<String, dynamic>.from(firstThen);
    }

    return null;
  });
}

Stream<Map<String, dynamic>?> getClassroomFirstThenStream({
  required String schoolId,
  required String classroomId,
  required String childId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('child_profiles')
      .doc(childId)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null) return null;

    final firstThen = data['firstThen'];
    if (firstThen is Map<String, dynamic>) {
      return firstThen;
    }
    if (firstThen is Map) {
      return Map<String, dynamic>.from(firstThen);
    }

    return null;
  });
}

Stream<Map<String, dynamic>?> getCurrentFirstThenStream({
  required String childId,
}) {
  if (hasClassroomSession) {
    return getClassroomFirstThenStream(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
    );
  }

  return getFirstThenStream(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

  // HANDOVER HUB

Stream<String> getHandoverOverview(String teacherUid) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_overview')
      .doc('main')
      .snapshots()
      .map((doc) {
    final data = doc.data();
    return data?['content'] ?? '';
  });
}

Stream<String> getClassroomHandoverOverview({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_overview')
      .doc('main')
      .snapshots()
      .map((doc) {
    final data = doc.data();
    return data?['content'] ?? '';
  });
}

Stream<String> getCurrentHandoverOverview() {
  if (hasClassroomSession) {
    return getClassroomHandoverOverview(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getHandoverOverview(currentTeacherUid);
}

Future<void> updateHandoverOverview({
  required String teacherUid,
  required String content,
  required String updatedByName,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_overview')
      .doc('main')
      .set({
    'content': content,
    'updatedByName': updatedByName,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateClassroomHandoverOverview({
  required String schoolId,
  required String classroomId,
  required String content,
  required String updatedByName,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_overview')
      .doc('main')
      .set({
    'content': content,
    'updatedByName': updatedByName,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateCurrentHandoverOverview({
  required String content,
  required String updatedByName,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomHandoverOverview(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      content: content,
      updatedByName: updatedByName,
    );
    return;
  }

  await updateHandoverOverview(
    teacherUid: currentTeacherUid,
    content: content,
    updatedByName: updatedByName,
  );
}

Stream<StaffHandoverDocument> getStaffHandoverDocument({
  required String teacherUid,
  required StaffProfile staff,
}) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('staff_handover_documents')
      .doc(staff.id)
      .snapshots()
      .map((doc) {
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
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('staff_handover_documents')
      .doc(staff.id)
      .snapshots()
      .map((doc) {
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
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
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
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('staff_handover_documents')
      .doc(document.staffProfileId)
      .set(document.toMap(), SetOptions(merge: true));
}

Future<void> updateClassroomStaffHandoverDocument({
  required String schoolId,
  required String classroomId,
  required StaffHandoverDocument document,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('staff_handover_documents')
      .doc(document.staffProfileId)
      .set(document.toMap(), SetOptions(merge: true));
}

Future<void> updateCurrentStaffHandoverDocument({
  required StaffHandoverDocument document,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomStaffHandoverDocument(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      document: document,
    );
    return;
  }

  await updateStaffHandoverDocument(
    teacherUid: currentTeacherUid,
    document: document,
  );
}

Stream<List<HandoverQuickNote>> getHandoverQuickNotes(String teacherUid) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_quick_notes')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => HandoverQuickNote.fromMap(doc.id, doc.data()))
          .toList());
}

Stream<List<HandoverQuickNote>> getClassroomHandoverQuickNotes({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_quick_notes')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => HandoverQuickNote.fromMap(doc.id, doc.data()))
          .toList());
}

Stream<List<HandoverQuickNote>> getCurrentHandoverQuickNotes() {
  if (hasClassroomSession) {
    return getClassroomHandoverQuickNotes(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getHandoverQuickNotes(currentTeacherUid);
}

Future<void> addHandoverQuickNote({
  required String teacherUid,
  required String title,
  required String content,
  required StaffProfile createdBy,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_quick_notes')
      .add({
    'title': title,
    'content': content,
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
  required StaffProfile createdBy,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_quick_notes')
      .add({
    'title': title,
    'content': content,
    'createdByStaffId': createdBy.id,
    'createdByName': createdBy.name,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addCurrentHandoverQuickNote({
  required String title,
  required String content,
  required StaffProfile createdBy,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomHandoverQuickNote(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      title: title,
      content: content,
      createdBy: createdBy,
    );
    return;
  }

  await addHandoverQuickNote(
    teacherUid: currentTeacherUid,
    title: title,
    content: content,
    createdBy: createdBy,
  );
}

Future<void> updateHandoverQuickNote({
  required String teacherUid,
  required String noteId,
  required String title,
  required String content,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_quick_notes')
      .doc(noteId)
      .update({
    'title': title,
    'content': content,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateClassroomHandoverQuickNote({
  required String schoolId,
  required String classroomId,
  required String noteId,
  required String title,
  required String content,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_quick_notes')
      .doc(noteId)
      .update({
    'title': title,
    'content': content,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateCurrentHandoverQuickNote({
  required String noteId,
  required String title,
  required String content,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomHandoverQuickNote(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      noteId: noteId,
      title: title,
      content: content,
    );
    return;
  }

  await updateHandoverQuickNote(
    teacherUid: currentTeacherUid,
    noteId: noteId,
    title: title,
    content: content,
  );
}

Future<void> deleteHandoverQuickNote({
  required String teacherUid,
  required String noteId,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('handover_quick_notes')
      .doc(noteId)
      .delete();
}

Future<void> deleteClassroomHandoverQuickNote({
  required String schoolId,
  required String classroomId,
  required String noteId,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('handover_quick_notes')
      .doc(noteId)
      .delete();
}

Future<void> deleteCurrentHandoverQuickNote(String noteId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomHandoverQuickNote(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      noteId: noteId,
    );
    return;
  }

  await deleteHandoverQuickNote(
    teacherUid: currentTeacherUid,
    noteId: noteId,
  );
}

  // INCIDENT LOG

Future<void> addIncidentLogEntry({
  required String teacherUid,
  required IncidentLogEntry entry,
}) async {
  final docRef = _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('incident_logs')
      .doc();

  await docRef.set(entry.toMap());
}

Stream<List<IncidentLogEntry>> getIncidentLogEntries(String teacherUid) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('incident_logs')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
          .toList());
}

Future<void> deleteIncidentLogEntry({
  required String teacherUid,
  required String incidentId,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('incident_logs')
      .doc(incidentId)
      .delete();
}

  Future<void> addClassroomIncidentLogEntry({
  required String schoolId,
  required String classroomId,
  required IncidentLogEntry entry,
}) async {
  final docRef = _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('incident_logs')
      .doc();

  await docRef.set(entry.toMap());
}

Stream<List<IncidentLogEntry>> getClassroomIncidentLogEntries({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('incident_logs')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
          .toList());
}

Future<void> deleteClassroomIncidentLogEntry({
  required String schoolId,
  required String classroomId,
  required String incidentId,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('incident_logs')
      .doc(incidentId)
      .delete();
}

Future<void> addCurrentIncidentLogEntry(IncidentLogEntry entry) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomIncidentLogEntry(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      entry: entry,
    );
    return;
  }

  await addIncidentLogEntry(
    teacherUid: currentTeacherUid,
    entry: entry,
  );
}

Stream<List<IncidentLogEntry>> getCurrentIncidentLogEntries() {
  if (hasClassroomSession) {
    return getClassroomIncidentLogEntries(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getIncidentLogEntries(currentTeacherUid);
}

Future<void> deleteCurrentIncidentLogEntry(String incidentId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomIncidentLogEntry(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      incidentId: incidentId,
    );
    return;
  }

  await deleteIncidentLogEntry(
    teacherUid: currentTeacherUid,
    incidentId: incidentId,
  );
}

    // WORD LEARNING

CollectionReference<Map<String, dynamic>> _wordPacksRef(String teacherUid) {
  return _db.collection('teachers').doc(teacherUid).collection('word_packs');
}

CollectionReference<Map<String, dynamic>> _classroomWordPacksRef({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('word_packs');
}

CollectionReference<Map<String, dynamic>> _wordItemsRef({
  required String teacherUid,
  required String packId,
}) {
  return _wordPacksRef(teacherUid).doc(packId).collection('words');
}

CollectionReference<Map<String, dynamic>> _classroomWordItemsRef({
  required String schoolId,
  required String classroomId,
  required String packId,
}) {
  return _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc(packId).collection('words');
}

Stream<List<WordPack>> getWordPacks(String teacherUid) {
  return _wordPacksRef(teacherUid)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => WordPack.fromMap(doc.id, doc.data()))
        .toList();
  });
}

Stream<List<WordPack>> getClassroomWordPacks({
  required String schoolId,
  required String classroomId,
}) {
  return _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => WordPack.fromMap(doc.id, doc.data()))
        .toList();
  });
}

Stream<List<WordPack>> getCurrentWordPacks() {
  if (hasClassroomSession) {
    return getClassroomWordPacks(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getWordPacks(currentTeacherUid);
}

Future<String> addWordPack({
  required String teacherUid,
  required WordPack pack,
}) async {
  final docRef = _wordPacksRef(teacherUid).doc();

  await docRef.set({
    ...pack.copyWith(id: docRef.id).toMap(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return docRef.id;
}

Future<String> addClassroomWordPack({
  required String schoolId,
  required String classroomId,
  required WordPack pack,
}) async {
  final docRef = _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc();

  await docRef.set({
    ...pack.copyWith(id: docRef.id).toMap(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return docRef.id;
}

Future<String> addCurrentWordPack(WordPack pack) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    return addClassroomWordPack(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      pack: pack,
    );
  }

  return addWordPack(
    teacherUid: currentTeacherUid,
    pack: pack,
  );
}

Future<void> updateWordPack({
  required String teacherUid,
  required WordPack pack,
}) async {
  await _wordPacksRef(teacherUid).doc(pack.id).update({
    ...pack.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateClassroomWordPack({
  required String schoolId,
  required String classroomId,
  required WordPack pack,
}) async {
  await _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc(pack.id).update({
    ...pack.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateCurrentWordPack(WordPack pack) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomWordPack(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      pack: pack,
    );
    return;
  }

  await updateWordPack(
    teacherUid: currentTeacherUid,
    pack: pack,
  );
}

Future<void> deleteWordPack({
  required String teacherUid,
  required String packId,
}) async {
  final wordsSnapshot = await _wordItemsRef(
    teacherUid: teacherUid,
    packId: packId,
  ).get();

  final batch = _db.batch();

  for (final doc in wordsSnapshot.docs) {
    batch.delete(doc.reference);
  }

  batch.delete(_wordPacksRef(teacherUid).doc(packId));

  await batch.commit();
}

Future<void> deleteClassroomWordPack({
  required String schoolId,
  required String classroomId,
  required String packId,
}) async {
  final wordsSnapshot = await _classroomWordItemsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    packId: packId,
  ).get();

  final batch = _db.batch();

  for (final doc in wordsSnapshot.docs) {
    batch.delete(doc.reference);
  }

  batch.delete(
    _classroomWordPacksRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(packId),
  );

  await batch.commit();
}

Future<void> deleteCurrentWordPack(String packId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomWordPack(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      packId: packId,
    );
    return;
  }

  await deleteWordPack(
    teacherUid: currentTeacherUid,
    packId: packId,
  );
}

Stream<List<WordItem>> getWordItems({
  required String teacherUid,
  required String packId,
}) {
  return _wordItemsRef(
    teacherUid: teacherUid,
    packId: packId,
  ).snapshots().map((snapshot) {
    final words = snapshot.docs
        .map((doc) => WordItem.fromMap(doc.id, doc.data()))
        .toList();

    words.sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    return words;
  });
}

Stream<List<WordItem>> getClassroomWordItems({
  required String schoolId,
  required String classroomId,
  required String packId,
}) {
  return _classroomWordItemsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    packId: packId,
  ).snapshots().map((snapshot) {
    final words = snapshot.docs
        .map((doc) => WordItem.fromMap(doc.id, doc.data()))
        .toList();

    words.sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    return words;
  });
}

Stream<List<WordItem>> getCurrentWordItems(String packId) {
  if (hasClassroomSession) {
    return getClassroomWordItems(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      packId: packId,
    );
  }

  return getWordItems(
    teacherUid: currentTeacherUid,
    packId: packId,
  );
}

Future<void> addWordItem({
  required String teacherUid,
  required String packId,
  required WordItem word,
}) async {
  final docRef = _wordItemsRef(
    teacherUid: teacherUid,
    packId: packId,
  ).doc();

  await docRef.set(word.copyWith(id: docRef.id).toMap());

  await _wordPacksRef(teacherUid).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addClassroomWordItem({
  required String schoolId,
  required String classroomId,
  required String packId,
  required WordItem word,
}) async {
  final docRef = _classroomWordItemsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    packId: packId,
  ).doc();

  await docRef.set(word.copyWith(id: docRef.id).toMap());

  await _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addCurrentWordItem({
  required String packId,
  required WordItem word,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomWordItem(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      packId: packId,
      word: word,
    );
    return;
  }

  await addWordItem(
    teacherUid: currentTeacherUid,
    packId: packId,
    word: word,
  );
}

Future<void> updateWordItem({
  required String teacherUid,
  required String packId,
  required WordItem word,
}) async {
  await _wordItemsRef(
    teacherUid: teacherUid,
    packId: packId,
  ).doc(word.id).update(word.toMap());

  await _wordPacksRef(teacherUid).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateClassroomWordItem({
  required String schoolId,
  required String classroomId,
  required String packId,
  required WordItem word,
}) async {
  await _classroomWordItemsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    packId: packId,
  ).doc(word.id).update(word.toMap());

  await _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateCurrentWordItem({
  required String packId,
  required WordItem word,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomWordItem(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      packId: packId,
      word: word,
    );
    return;
  }

  await updateWordItem(
    teacherUid: currentTeacherUid,
    packId: packId,
    word: word,
  );
}

Future<void> deleteWordItem({
  required String teacherUid,
  required String packId,
  required String wordId,
}) async {
  await _wordItemsRef(
    teacherUid: teacherUid,
    packId: packId,
  ).doc(wordId).delete();

  await _wordPacksRef(teacherUid).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteClassroomWordItem({
  required String schoolId,
  required String classroomId,
  required String packId,
  required String wordId,
}) async {
  await _classroomWordItemsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    packId: packId,
  ).doc(wordId).delete();

  await _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).doc(packId).update({
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteCurrentWordItem({
  required String packId,
  required String wordId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomWordItem(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      packId: packId,
      wordId: wordId,
    );
    return;
  }

  await deleteWordItem(
    teacherUid: currentTeacherUid,
    packId: packId,
    wordId: wordId,
  );
}

Stream<List<WordPack>> getAssignedWordPacks({
  required String teacherUid,
  required String childId,
}) {
  return _wordPacksRef(teacherUid).snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => WordPack.fromMap(doc.id, doc.data()))
        .where((pack) => pack.assignedChildIds.contains(childId))
        .toList();
  });
}

Stream<List<WordPack>> getClassroomAssignedWordPacks({
  required String schoolId,
  required String classroomId,
  required String childId,
}) {
  return _classroomWordPacksRef(
    schoolId: schoolId,
    classroomId: classroomId,
  ).snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => WordPack.fromMap(doc.id, doc.data()))
        .where((pack) => pack.assignedChildIds.contains(childId))
        .toList();
  });
}

Stream<List<WordPack>> getCurrentAssignedWordPacks({
  required String childId,
}) {
  if (hasClassroomSession) {
    return getClassroomAssignedWordPacks(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
    );
  }

  return getAssignedWordPacks(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

Future<void> addWordAttempt({
  required String teacherUid,
  required WordAttempt attempt,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('word_attempts')
      .add({
    ...attempt.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addClassroomWordAttempt({
  required String schoolId,
  required String classroomId,
  required WordAttempt attempt,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('word_attempts')
      .add({
    ...attempt.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addCurrentWordAttempt(WordAttempt attempt) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomWordAttempt(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      attempt: attempt,
    );
    return;
  }

  await addWordAttempt(
    teacherUid: currentTeacherUid,
    attempt: attempt,
  );
}

Stream<List<WordAttempt>> getWordAttemptsForChild({
  required String teacherUid,
  required String childId,
}) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('word_attempts')
      .where('childId', isEqualTo: childId)
      .snapshots()
      .map((snapshot) {
    final attempts = snapshot.docs
        .map((doc) => WordAttempt.fromMap(doc.id, doc.data()))
        .toList();

    return attempts;
  });
}

Stream<List<WordAttempt>> getClassroomWordAttemptsForChild({
  required String schoolId,
  required String classroomId,
  required String childId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('word_attempts')
      .where('childId', isEqualTo: childId)
      .snapshots()
      .map((snapshot) {
    final attempts = snapshot.docs
        .map((doc) => WordAttempt.fromMap(doc.id, doc.data()))
        .toList();

    return attempts;
  });
}

Stream<List<WordAttempt>> getCurrentWordAttemptsForChild({
  required String childId,
}) {
  if (hasClassroomSession) {
    return getClassroomWordAttemptsForChild(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      childId: childId,
    );
  }

  return getWordAttemptsForChild(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

 // BODY CHECK

Future<void> addBodyCheckReport({
  required String teacherUid,
  required BodyCheckReport report,
}) async {
  final docRef = _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('body_check_reports')
      .doc();

  await docRef.set(report.toMap());
}

Stream<List<BodyCheckReport>> getBodyCheckReports(String teacherUid) {
  return _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('body_check_reports')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BodyCheckReport.fromMap(doc.id, doc.data()))
          .toList());
}

Future<void> markBodyCheckReportChecked({
  required String teacherUid,
  required String reportId,
  String checkedNote = '',
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('body_check_reports')
      .doc(reportId)
      .update({
    'checked': true,
    'checkedNote': checkedNote,
    'checkedAt': Timestamp.now(),
  });
}

Future<void> deleteBodyCheckReport({
  required String teacherUid,
  required String reportId,
}) async {
  await _db
      .collection('teachers')
      .doc(teacherUid)
      .collection('body_check_reports')
      .doc(reportId)
      .delete();
}

// CLASSROOM / BODY CHECK

Future<void> addClassroomBodyCheckReport({
  required String schoolId,
  required String classroomId,
  required BodyCheckReport report,
}) async {
  final docRef = _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('body_check_reports')
      .doc();

  await docRef.set(report.toMap());
}

Stream<List<BodyCheckReport>> getClassroomBodyCheckReports({
  required String schoolId,
  required String classroomId,
}) {
  return _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('body_check_reports')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BodyCheckReport.fromMap(doc.id, doc.data()))
          .toList());
}

Future<void> markClassroomBodyCheckReportChecked({
  required String schoolId,
  required String classroomId,
  required String reportId,
  String checkedNote = '',
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('body_check_reports')
      .doc(reportId)
      .update({
    'checked': true,
    'checkedNote': checkedNote,
    'checkedAt': Timestamp.now(),
  });
}

Future<void> deleteClassroomBodyCheckReport({
  required String schoolId,
  required String classroomId,
  required String reportId,
}) async {
  await _db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('body_check_reports')
      .doc(reportId)
      .delete();
}

// CURRENT / BODY CHECK

Future<void> addCurrentBodyCheckReport(BodyCheckReport report) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomBodyCheckReport(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      report: report,
    );
    return;
  }

  await addBodyCheckReport(
    teacherUid: currentTeacherUid,
    report: report,
  );
}

Stream<List<BodyCheckReport>> getCurrentBodyCheckReports() {
  if (hasClassroomSession) {
    return getClassroomBodyCheckReports(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
    );
  }

  return getBodyCheckReports(currentTeacherUid);
}

Future<void> markCurrentBodyCheckReportChecked({
  required String reportId,
  String checkedNote = '',
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await markClassroomBodyCheckReportChecked(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      reportId: reportId,
      checkedNote: checkedNote,
    );
    return;
  }

  await markBodyCheckReportChecked(
    teacherUid: currentTeacherUid,
    reportId: reportId,
    checkedNote: checkedNote,
  );
}

Future<void> deleteCurrentBodyCheckReport(String reportId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomBodyCheckReport(
      schoolId: _session.requireSchoolId,
      classroomId: _session.requireClassroomId,
      reportId: reportId,
    );
    return;
  }

  await deleteBodyCheckReport(
    teacherUid: currentTeacherUid,
    reportId: reportId,
  );
}

}