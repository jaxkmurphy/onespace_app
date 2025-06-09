import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../models/quiz.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    await _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteStaffProfile(String teacherUid, String profileId) async {
    await _db.collection('teachers').doc(teacherUid).collection('staff_profiles').doc(profileId).delete();
  }

  Future<void> updateChildProfile(String teacherUid, ChildProfile profile) async {
    await _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteChildProfile(String teacherUid, String profileId) async {
    await _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(profileId).delete();
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

   // Add a new quiz
  Future<void> addQuiz(Quiz quiz) async {
  await _db
    .collection('teachers')
    .doc(quiz.createdBy)  
    .collection('quizzes')
    .doc(quiz.id)
    .set(quiz.toMap());
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

  Future<void> assignQuizToChild(String teacherUid, String childId, String quizId) async {
  final childRef = _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(childId);
  await childRef.update({
    'assignedQuizzes': FieldValue.arrayUnion([quizId]),
  });
}

Future<void> submitQuiz(String teacherUid, String childId, String quizId, int score) async {
  final childRef = _db.collection('teachers').doc(teacherUid).collection('child_profiles').doc(childId);
  await childRef.set({
    'completedQuizzes': {
      quizId: {
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
        }
      }
    }, SetOptions(merge: true));
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
}