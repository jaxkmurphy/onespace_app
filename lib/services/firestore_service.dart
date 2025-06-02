import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> addStaffProfile(String teacherUid, StaffProfile profile) async {
    try {
      final docRef = _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc();
      final profileWithId = profile.copyWith(id: docRef.id, teacherUid: teacherUid);
      await docRef.set(profileWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add staff profile: $e');
    }
  }

  Stream<List<StaffProfile>> getStaffProfiles(String teacherUid) {
    try {
      return _db
          .collection('teachers')
          .doc(teacherUid)
          .collection('staff_profiles')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StaffProfile.fromMap(doc.id, doc.data()).copyWith(teacherUid: teacherUid))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addChildProfile(String teacherUid, ChildProfile profile) async {
    try {
      final docRef = _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc();
      final profileWithId = profile.copyWith(id: docRef.id, teacherUid: teacherUid);
      await docRef.set(profileWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add child profile: $e');
    }
  }

  Stream<List<ChildProfile>> getChildProfiles(String teacherUid) {
    try {
      return _db
          .collection('teachers')
          .doc(teacherUid)
          .collection('child_profiles')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChildProfile.fromMap(doc.id, doc.data()).copyWith(teacherUid: teacherUid))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStaffProfile(String teacherUid, StaffProfile profile) async {
    try {
      await _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc(profile.id).update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update staff profile: $e');
    }
  }

  Future<void> deleteStaffProfile(String teacherUid, String profileId) async {
    try {
      await _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc(profileId).delete();
    } catch (e) {
      throw Exception('Failed to delete staff profile: $e');
    }
  }

  Future<void> updateChildProfile(String teacherUid, ChildProfile profile) async {
    try {
      await _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(profile.id).update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update child profile: $e');
    }
  }

  Future<void> deleteChildProfile(String teacherUid, String profileId) async {
    try {
      await _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(profileId).delete();
    } catch (e) {
      throw Exception('Failed to delete child profile: $e');
    }
  }

  Future<void> setChildZone(String teacherUid, String childId, String zone) async {
    try {
      await _db
          .collection('teachers')
          .doc(teacherUid)
          .collection('child_profiles')
          .doc(childId)
          .update({'zone': zone});
    } catch (e) {
      throw Exception('Failed to update child zone: $e');
    }
  }

  Future<void> setChildPoints(String teacherUid, String childId, int points) async {
  try {
    await _db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId)
        .update({'points': points});
  } catch (e) {
    throw Exception('Failed to update child points: $e');
    }
  }

  Future<void> addScheduleEntry(String teacherUid, String day, String entry) async {
  final docRef = _db.collection('schedules').doc(teacherUid);
  await _db.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    final existingEntries = (snapshot.data()?[day] as List?)?.cast<String>() ?? [];
    existingEntries.add(entry);
    transaction.set(docRef, {day: existingEntries}, SetOptions(merge: true));
  });
}

  Future<void> removeScheduleEntry(String teacherUid, String day, String entry) async {
  final docRef = _db.collection('schedules').doc(teacherUid);
  await _db.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    final existingEntries = (snapshot.data()?[day] as List?)?.cast<String>() ?? [];
    existingEntries.remove(entry);
    transaction.set(docRef, {day: existingEntries}, SetOptions(merge: true));
  });
}

  Future<Map<String, List<String>>> getSchedule(String teacherUid) async {
  final doc = await _db.collection('schedules').doc(teacherUid).get();
  final data = doc.data() ?? {};
  return {
    for (final day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'])
      day: (data[day] as List?)?.cast<String>() ?? []
  };
}

  Future<void> setScheduleForDay(String teacherUid, String day, List<String> entries) async {
  try {
    await _db.collection('schedules').doc(teacherUid).set({day: entries}, SetOptions(merge: true));
  } catch (e) {
    throw Exception('Failed to reorder schedule: $e');
  }
}

}
