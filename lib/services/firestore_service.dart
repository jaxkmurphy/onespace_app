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

    // WORD LEARNING

  CollectionReference<Map<String, dynamic>> _wordPacksRef(String teacherUid) {
    return _db.collection('teachers').doc(teacherUid).collection('word_packs');
  }

  CollectionReference<Map<String, dynamic>> _wordItemsRef({
    required String teacherUid,
    required String packId,
  }) {
    return _wordPacksRef(teacherUid).doc(packId).collection('words');
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

  Future<void> updateWordPack({
    required String teacherUid,
    required WordPack pack,
  }) async {
    await _wordPacksRef(teacherUid).doc(pack.id).update({
      ...pack.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  Stream<List<WordPack>>
    getAssignedWordPacks({
  required String teacherUid,
  required String childId,
}) {
  return _wordPacksRef(
    teacherUid,
  ).snapshots().map((snapshot) {
    return snapshot.docs
        .map(
          (doc) => WordPack.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .where(
          (pack) => pack
              .assignedChildIds
              .contains(childId),
        )
        .toList();
  });
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

}