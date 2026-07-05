import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/classroom.dart';
import '../../models/school.dart';
import '../../models/school_member.dart';
import '../../models/teacher.dart';
import '../../models/classroom_feature.dart';
import 'firestore_base.dart';

class SchoolAdminOverview {
  final int totalClassrooms;
  final int activeClassrooms;
  final int inactiveClassrooms;
  final int totalStaffProfiles;
  final int totalChildProfiles;
  final int uncheckedBodyChecks;
  final int activeCalmRequests;
  final int pendingHelperRequests;

  const SchoolAdminOverview({
    required this.totalClassrooms,
    required this.activeClassrooms,
    required this.inactiveClassrooms,
    required this.totalStaffProfiles,
    required this.totalChildProfiles,
    required this.uncheckedBodyChecks,
    required this.activeCalmRequests,
    required this.pendingHelperRequests,
  });
}

class ClassroomAdminHealth {
  final int staffProfiles;
  final int childProfiles;
  final int uncheckedBodyChecks;
  final int activeCalmRequests;
  final int pendingHelperRequests;

  const ClassroomAdminHealth({
    required this.staffProfiles,
    required this.childProfiles,
    required this.uncheckedBodyChecks,
    required this.activeCalmRequests,
    required this.pendingHelperRequests,
  });

  int get totalAlerts =>
      uncheckedBodyChecks + activeCalmRequests + pendingHelperRequests;
}

mixin AdminFirestoreService on FirestoreBase {
  // SCHOOL / ADMIN STRUCTURE

  Future<String> createSchool({
    required String name,
    required String schoolCode,
    required String adminUid,
    required String adminEmail,
    int classroomLimit = 3,
  }) async {
    final schoolRef = db.collection('schools').doc();

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

    final batch = db.batch();

    batch.set(schoolRef, school.toMap());

    batch.set(schoolRef.collection('members').doc(adminUid), member.toMap());

    batch.set(db.collection('account_lookup').doc(adminUid), {
      'schoolId': schoolRef.id,
      'role': 'schoolAdmin',
      'email': adminEmail,
      'active': true,
      'createdAt': DateTime.now(),
    });

    await batch.commit();

    return schoolRef.id;
  }

  Future<School?> getSchool(String schoolId) async {
    final doc = await schoolDoc(schoolId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return School.fromMap(doc.id, doc.data()!);
  }

  Future<School?> getSchoolByCode(String schoolCode) async {
    final query =
        await db
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

  Future<bool> isSchoolCodeAvailable({
    required String schoolCode,
    String? currentSchoolId,
  }) async {
    final query =
        await db
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

    await schoolDoc(schoolId).update({
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

  // SCHOOL MEMBERS

  Future<SchoolMember?> getSchoolMember({
    required String schoolId,
    required String uid,
  }) async {
    final doc = await schoolDoc(schoolId).collection('members').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return SchoolMember.fromMap(doc.id, doc.data()!);
  }

  Future<SchoolMember?> getSchoolMemberByUid(String uid) async {
    try {
      final lookupDoc = await db.collection('account_lookup').doc(uid).get();

      if (!lookupDoc.exists || lookupDoc.data() == null) {
        return null;
      }

      final lookupData = lookupDoc.data()!;
      final schoolId = lookupData['schoolId'] as String?;

      if (schoolId == null || schoolId.isEmpty) {
        return null;
      }

      final memberDoc =
          await schoolDoc(schoolId).collection('members').doc(uid).get();

      if (!memberDoc.exists || memberDoc.data() == null) {
        return null;
      }

      return SchoolMember.fromMap(memberDoc.id, memberDoc.data()!);
    } catch (e) {
      debugPrint('Could not check school member: $e');
      return null;
    }
  }

  // CLASSROOMS

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

    final classroomRef = classroomsRef(schoolId).doc();

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
    return classroomsRef(schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Classroom.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<List<Classroom>> getClassroomsOnce(String schoolId) async {
    final snapshot = await classroomsRef(schoolId).orderBy('name').get();

    return snapshot.docs
        .map((doc) => Classroom.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Classroom?> getClassroom({
    required String schoolId,
    required String classroomId,
  }) async {
    final doc =
        await classroomDoc(schoolId: schoolId, classroomId: classroomId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Classroom.fromMap(doc.id, doc.data()!);
  }

  Future<Classroom?> getClassroomByCode({
    required String schoolId,
    required String classroomCode,
  }) async {
    final query =
        await classroomsRef(schoolId)
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
    final query =
        await classroomsRef(schoolId)
            .where(
              'classroomCode',
              isEqualTo: classroomCode.trim().toUpperCase(),
            )
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      return true;
    }

    if (currentClassroomId != null &&
        query.docs.first.id == currentClassroomId) {
      return true;
    }

    return false;
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

    await classroomDoc(schoolId: schoolId, classroomId: classroomId).update({
      'name': name.trim(),
      'classroomCode': formattedClassroomCode,
      'pin': pin.trim(),
      'active': active,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> updateClassroomEnabledFeatures({
    required String schoolId,
    required String classroomId,
    required Set<ClassroomFeature> enabledFeatures,
  }) async {
    await classroomDoc(schoolId: schoolId, classroomId: classroomId).update({
      'enabledFeatures': ClassroomFeature.toFirestoreValue(enabledFeatures),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deactivateClassroom({
    required String schoolId,
    required String classroomId,
  }) async {
    await classroomDoc(schoolId: schoolId, classroomId: classroomId).update({
      'active': false,
      'updatedAt': DateTime.now(),
      'archivedAt': DateTime.now(),
    });
  }

  Future<void> reactivateClassroom({
    required String schoolId,
    required String classroomId,
  }) async {
    await classroomDoc(schoolId: schoolId, classroomId: classroomId).update({
      'active': true,
      'updatedAt': DateTime.now(),
      'reactivatedAt': DateTime.now(),
    });
  }

  Future<SchoolAdminOverview> getSchoolAdminOverview(String schoolId) async {
    final classrooms = await getClassroomsOnce(schoolId);

    var totalStaffProfiles = 0;
    var totalChildProfiles = 0;
    var uncheckedBodyChecks = 0;
    var activeCalmRequests = 0;
    var pendingHelperRequests = 0;

    for (final classroom in classrooms) {
      final health = await getClassroomAdminHealth(
        schoolId: schoolId,
        classroomId: classroom.id,
      );

      totalStaffProfiles += health.staffProfiles;
      totalChildProfiles += health.childProfiles;
      uncheckedBodyChecks += health.uncheckedBodyChecks;
      activeCalmRequests += health.activeCalmRequests;
      pendingHelperRequests += health.pendingHelperRequests;
    }

    return SchoolAdminOverview(
      totalClassrooms: classrooms.length,
      activeClassrooms:
          classrooms.where((classroom) => classroom.active).length,
      inactiveClassrooms:
          classrooms.where((classroom) => !classroom.active).length,
      totalStaffProfiles: totalStaffProfiles,
      totalChildProfiles: totalChildProfiles,
      uncheckedBodyChecks: uncheckedBodyChecks,
      activeCalmRequests: activeCalmRequests,
      pendingHelperRequests: pendingHelperRequests,
    );
  }

  Future<ClassroomAdminHealth> getClassroomAdminHealth({
    required String schoolId,
    required String classroomId,
  }) async {
    final staffSnapshot =
        await classroomStaffProfilesRef(
          schoolId: schoolId,
          classroomId: classroomId,
        ).get();

    final childSnapshot =
        await classroomChildProfilesRef(
          schoolId: schoolId,
          classroomId: classroomId,
        ).get();

    final bodyChecksSnapshot =
        await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'body_check_reports',
        ).where('checked', isEqualTo: false).get();

    final calmRequestsSnapshot =
        await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'calm_requests',
        ).where('status', isEqualTo: 'active').get();

    final helperRequestsSnapshot =
        await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'helper_completion_requests',
        ).where('status', isEqualTo: 'pending').get();

    return ClassroomAdminHealth(
      staffProfiles: staffSnapshot.size,
      childProfiles: childSnapshot.size,
      uncheckedBodyChecks: bodyChecksSnapshot.size,
      activeCalmRequests: calmRequestsSnapshot.size,
      pendingHelperRequests: helperRequestsSnapshot.size,
    );
  }

  // LEGACY TEACHER ACCOUNT DATA

  Future<void> setTeacherInfo(Teacher teacher) async {
    await teacherDoc(teacher.uid).set(teacher.toMap(), SetOptions(merge: true));
  }

  Future<Teacher> getTeacherInfo(String uid) async {
    try {
      final doc = await teacherDoc(uid).get();

      if (doc.exists && doc.data() != null) {
        return Teacher.fromMap(doc.id, doc.data()!);
      }

      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      final newTeacher = Teacher(uid: uid, email: email, name: '', pin: '');

      await setTeacherInfo(newTeacher);
      return newTeacher;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        debugPrint('Firestore unavailable: ${e.message}');

        final email = FirebaseAuth.instance.currentUser?.email ?? '';

        return Teacher(uid: uid, email: email, name: '', pin: '');
      }

      throw Exception('Failed to get teacher info: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
