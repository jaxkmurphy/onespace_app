import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/first_then_option.dart';
import '../../models/quiz.dart';
import '../../models/word_attempt.dart';
import '../../models/word_item.dart';
import '../../models/word_pack.dart';
import 'firestore_base.dart';

mixin LearningFirestoreService on FirestoreBase {
  // QUIZZES

Future<void> addQuiz(Quiz quiz) async {
  await db
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
  await db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      quiz: quiz,
    );
    return;
  }

  await addQuiz(
    quiz,
  );
}

Stream<List<Quiz>> getQuizzes(String teacherUid) {
  return db
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
  return db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );
  }

  return getQuizzes(currentTeacherUid);
}

Future<void> assignQuizToChild(
  String teacherUid,
  String childId,
  String quizId,
) async {
  final childRef = db
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
  final childRef = db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  final childRef = db
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
  final childRef = db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
    await db
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
    await db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      quizId: quizId,
    );
    return;
  }

  await deleteQuiz(
    currentTeacherUid,
    quizId,
  );
}

    // FIRST-THEN BOARD

CollectionReference<Map<String, dynamic>> _firstThenOptionsRef({
  required String teacherUid,
  required String type,
}) {
  return db
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
  return db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  final batch = db.batch();

  for (final childId in childIds) {
    final docRef = db
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
  final batch = db.batch();

  for (final childId in childIds) {
    final docRef = db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  await db
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
  await db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  await db
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
  await db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  return db
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
  return db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childId: childId,
    );
  }

  return getFirstThenStream(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}


    // WORD LEARNING

CollectionReference<Map<String, dynamic>> _wordPacksRef(String teacherUid) {
  return db.collection('teachers').doc(teacherUid).collection('word_packs');
}

CollectionReference<Map<String, dynamic>> _classroomWordPacksRef({
  required String schoolId,
  required String classroomId,
}) {
  return db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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

  final batch = db.batch();

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

  final batch = db.batch();

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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  await db
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
  await db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
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
  return db
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
  return db
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
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childId: childId,
    );
  }

  return getWordAttemptsForChild(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

}