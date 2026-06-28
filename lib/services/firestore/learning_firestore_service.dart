import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/when_then_option.dart';
import '../../models/quiz.dart';
import '../../models/word_attempt.dart';
import '../../models/word_item.dart';
import '../../models/word_pack.dart';
import 'firestore_base.dart';
import '../../models/odd_one_out_models.dart';

mixin LearningFirestoreService on FirestoreBase {

    // QUIZZES

  String generateQuizId() {
    return db.collection('_generated_quiz_ids').doc().id;
  }

  Map<String, dynamic> _quizDataForCreate(Quiz quiz) {
    return {
      ...quiz.toMap(),
      'createdAt': quiz.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(quiz.createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _quizDataForUpdate(Quiz quiz) {
    return {
      ...quiz.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addQuiz(Quiz quiz) async {
    await db
        .collection('teachers')
        .doc(quiz.createdBy)
        .collection('quizzes')
        .doc(quiz.id)
        .set(_quizDataForCreate(quiz));
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
        .set(_quizDataForCreate(quiz));
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

    await addQuiz(quiz);
  }

  Future<void> updateQuiz({
    required String teacherUid,
    required Quiz quiz,
  }) async {
    await db
        .collection('teachers')
        .doc(teacherUid)
        .collection('quizzes')
        .doc(quiz.id)
        .update(_quizDataForUpdate(quiz));
  }

  Future<void> updateClassroomQuiz({
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
        .update(_quizDataForUpdate(quiz));
  }

  Future<void> updateCurrentQuiz(Quiz quiz) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await updateClassroomQuiz(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        quiz: quiz,
      );
      return;
    }

    await updateQuiz(
      teacherUid: currentTeacherUid,
      quiz: quiz,
    );
  }

  Stream<List<Quiz>> getQuizzes(String teacherUid) {
    return db
        .collection('teachers')
        .doc(teacherUid)
        .collection('quizzes')
        .snapshots()
        .map((snapshot) {
      final quizzes = snapshot.docs
          .map((doc) => Quiz.fromMap(doc.id, doc.data()))
          .toList();

      quizzes.sort((first, second) {
        final firstDate = first.updatedAt ?? first.createdAt;
        final secondDate = second.updatedAt ?? second.createdAt;

        if (firstDate != null && secondDate != null) {
          return secondDate.compareTo(firstDate);
        }

        return first.title
            .toLowerCase()
            .compareTo(second.title.toLowerCase());
      });

      return quizzes;
    });
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
        .map((snapshot) {
      final quizzes = snapshot.docs
          .map((doc) => Quiz.fromMap(doc.id, doc.data()))
          .toList();

      quizzes.sort((first, second) {
        final firstDate = first.updatedAt ?? first.createdAt;
        final secondDate = second.updatedAt ?? second.createdAt;

        if (firstDate != null && secondDate != null) {
          return secondDate.compareTo(firstDate);
        }

        return first.title
            .toLowerCase()
            .compareTo(second.title.toLowerCase());
      });

      return quizzes;
    });
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

  Stream<List<Quiz>> getCurrentQuizzesForChild(String childId) {
    return getCurrentQuizzes().map((quizzes) {
      return quizzes.where((quiz) {
        return quiz.isAvailableForChild(childId);
      }).toList();
    });
  }

  Future<void> updateQuizAudience({
    required String teacherUid,
    required String quizId,
    required bool availableToAll,
    required List<String> assignedChildIds,
  }) async {
    await db
        .collection('teachers')
        .doc(teacherUid)
        .collection('quizzes')
        .doc(quizId)
        .update({
      'availableToAll': availableToAll,
      'assignedChildIds':
          availableToAll ? <String>[] : assignedChildIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClassroomQuizAudience({
    required String schoolId,
    required String classroomId,
    required String quizId,
    required bool availableToAll,
    required List<String> assignedChildIds,
  }) async {
    await db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('quizzes')
        .doc(quizId)
        .update({
      'availableToAll': availableToAll,
      'assignedChildIds':
          availableToAll ? <String>[] : assignedChildIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCurrentQuizAudience({
    required String quizId,
    required bool availableToAll,
    required List<String> assignedChildIds,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await updateClassroomQuizAudience(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        quizId: quizId,
        availableToAll: availableToAll,
        assignedChildIds: assignedChildIds,
      );
      return;
    }

    await updateQuizAudience(
      teacherUid: currentTeacherUid,
      quizId: quizId,
      availableToAll: availableToAll,
      assignedChildIds: assignedChildIds,
    );
  }

  Map<String, dynamic> _quizCompletionData({
    required String quizId,
    required int score,
    required int totalQuestions,
    required List<int> selectedAnswerIndexes,
  }) {
    final percentage = totalQuestions <= 0
        ? 0
        : ((score / totalQuestions) * 100).round();

    return {
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'selectedAnswerIndexes': selectedAnswerIndexes,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Future<void> submitQuiz(
    String teacherUid,
    String childId,
    String quizId,
    int score, {
    int? totalQuestions,
    List<int> selectedAnswerIndexes = const [],
  }) async {
    final childRef = db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId);

    final completion = _quizCompletionData(
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions ?? 0,
      selectedAnswerIndexes: selectedAnswerIndexes,
    );

    final attemptRef = childRef
        .collection('quiz_attempts')
        .doc();

    final batch = db.batch();

    batch.set(
      childRef,
      {
        'completedQuizzes': {
          quizId: completion,
        },
      },
      SetOptions(merge: true),
    );

    batch.set(attemptRef, completion);

    await batch.commit();
  }

  Future<void> submitClassroomQuiz({
    required String schoolId,
    required String classroomId,
    required String childId,
    required String quizId,
    required int score,
    int? totalQuestions,
    List<int> selectedAnswerIndexes = const [],
  }) async {
    final childRef = db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('child_profiles')
        .doc(childId);

    final completion = _quizCompletionData(
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions ?? 0,
      selectedAnswerIndexes: selectedAnswerIndexes,
    );

    final attemptRef = childRef
        .collection('quiz_attempts')
        .doc();

    final batch = db.batch();

    batch.set(
      childRef,
      {
        'completedQuizzes': {
          quizId: completion,
        },
      },
      SetOptions(merge: true),
    );

    batch.set(attemptRef, completion);

    await batch.commit();
  }

  Future<void> submitCurrentQuiz({
    required String childId,
    required String quizId,
    required int score,
    int? totalQuestions,
    List<int> selectedAnswerIndexes = const [],
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      await submitClassroomQuiz(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        childId: childId,
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
        selectedAnswerIndexes: selectedAnswerIndexes,
      );
      return;
    }

    await submitQuiz(
      currentTeacherUid,
      childId,
      quizId,
      score,
      totalQuestions: totalQuestions,
      selectedAnswerIndexes: selectedAnswerIndexes,
    );
  }

  Stream<List<Map<String, dynamic>>> getQuizAttempts({
    required String teacherUid,
    required String childId,
  }) {
    return db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId)
        .collection('quiz_attempts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getClassroomQuizAttempts({
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
        .collection('quiz_attempts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>>
      getCurrentQuizAttemptsForChild(String childId) {
    if (hasClassroomSession) {
      return getClassroomQuizAttempts(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        childId: childId,
      );
    }

    return getQuizAttempts(
      teacherUid: currentTeacherUid,
      childId: childId,
    );
  }

  Future<void> deleteQuiz(
    String teacherUid,
    String quizId,
  ) async {
    await db
        .collection('teachers')
        .doc(teacherUid)
        .collection('quizzes')
        .doc(quizId)
        .delete();
  }

  Future<void> deleteClassroomQuiz({
    required String schoolId,
    required String classroomId,
    required String quizId,
  }) async {
    await db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('quizzes')
        .doc(quizId)
        .delete();
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

    // WHEN-THEN BOARD

CollectionReference<Map<String, dynamic>> _whenThenOptionsRef({
  required String teacherUid,
  required String type,
}) {
  return db
      .collection('teachers')
      .doc(teacherUid)
      .collection('when_then_options')
      .doc(type)
      .collection('items');
}

CollectionReference<Map<String, dynamic>> _classroomWhenThenOptionsRef({
  required String schoolId,
  required String classroomId,
  required String type,
}) {
  return db
      .collection('schools')
      .doc(schoolId)
      .collection('classrooms')
      .doc(classroomId)
      .collection('when_then_options')
      .doc(type)
      .collection('items');
}

Stream<List<WhenThenOption>> getWhenThenOptions({
  required String teacherUid,
  required String type,
}) {
  return _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).snapshots().map((snapshot) {
    final options = snapshot.docs
        .map((doc) => WhenThenOption.fromMap(doc.id, doc.data()))
        .toList();

    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  });
}

Stream<List<WhenThenOption>> getClassroomWhenThenOptions({
  required String schoolId,
  required String classroomId,
  required String type,
}) {
  return _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).snapshots().map((snapshot) {
    final options = snapshot.docs
        .map((doc) => WhenThenOption.fromMap(doc.id, doc.data()))
        .toList();

    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  });
}

Stream<List<WhenThenOption>> getCurrentWhenThenOptions({
  required String type,
}) {
  if (hasClassroomSession) {
    return getClassroomWhenThenOptions(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      type: type,
    );
  }

  return getWhenThenOptions(
    teacherUid: currentTeacherUid,
    type: type,
  );
}

Future<void> addWhenThenOption({
  required String teacherUid,
  required String type,
  required WhenThenOption option,
}) async {
  await _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).add(option.toMap());
}

Future<void> addClassroomWhenThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required WhenThenOption option,
}) async {
  await _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).add(option.toMap());
}

Future<void> addCurrentWhenThenOption({
  required String type,
  required WhenThenOption option,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await addClassroomWhenThenOption(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      type: type,
      option: option,
    );
    return;
  }

  await addWhenThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    option: option,
  );
}

Future<void> updateWhenThenOption({
  required String teacherUid,
  required String type,
  required WhenThenOption option,
}) async {
  await _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).doc(option.id).update(option.toMap());
}

Future<void> updateClassroomWhenThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required WhenThenOption option,
}) async {
  await _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).doc(option.id).update(option.toMap());
}

Future<void> updateCurrentWhenThenOption({
  required String type,
  required WhenThenOption option,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await updateClassroomWhenThenOption(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      type: type,
      option: option,
    );
    return;
  }

  await updateWhenThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    option: option,
  );
}

Future<void> deleteWhenThenOption({
  required String teacherUid,
  required String type,
  required String optionId,
}) async {
  await _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: type,
  ).doc(optionId).delete();
}

Future<void> deleteClassroomWhenThenOption({
  required String schoolId,
  required String classroomId,
  required String type,
  required String optionId,
}) async {
  await _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: type,
  ).doc(optionId).delete();
}

Future<void> deleteCurrentWhenThenOption({
  required String type,
  required String optionId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await deleteClassroomWhenThenOption(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      type: type,
      optionId: optionId,
    );
    return;
  }

  await deleteWhenThenOption(
    teacherUid: currentTeacherUid,
    type: type,
    optionId: optionId,
  );
}

Future<void> seedDefaultWhenThenOptions(String teacherUid) async {
  final activitySnapshot = await _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: 'activities',
  ).limit(1).get();

  final rewardSnapshot = await _whenThenOptionsRef(
    teacherUid: teacherUid,
    type: 'rewards',
  ).limit(1).get();

  if (activitySnapshot.docs.isEmpty) {
    final defaults = [
      WhenThenOption(id: '', label: 'Quiz', iconName: 'quiz'),
      WhenThenOption(id: '', label: 'Homework', iconName: 'book'),
      WhenThenOption(id: '', label: 'Clean Up', iconName: 'clean'),
      WhenThenOption(id: '', label: 'Finish Work', iconName: 'task'),
    ];

    for (final option in defaults) {
      await addWhenThenOption(
        teacherUid: teacherUid,
        type: 'activities',
        option: option,
      );
    }
  }

  if (rewardSnapshot.docs.isEmpty) {
    final defaults = [
      WhenThenOption(id: '', label: 'Calming Sounds', iconName: 'music'),
      WhenThenOption(id: '', label: 'Playtime', iconName: 'toys'),
      WhenThenOption(id: '', label: 'Outside Time', iconName: 'outside'),
      WhenThenOption(id: '', label: 'Break', iconName: 'break'),
      WhenThenOption(id: '', label: 'Music', iconName: 'music'),
    ];

    for (final option in defaults) {
      await addWhenThenOption(
        teacherUid: teacherUid,
        type: 'rewards',
        option: option,
      );
    }
  }
}

Future<void> seedDefaultClassroomWhenThenOptions({
  required String schoolId,
  required String classroomId,
}) async {
  final activitySnapshot = await _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: 'activities',
  ).limit(1).get();

  final rewardSnapshot = await _classroomWhenThenOptionsRef(
    schoolId: schoolId,
    classroomId: classroomId,
    type: 'rewards',
  ).limit(1).get();

  if (activitySnapshot.docs.isEmpty) {
    final defaults = [
      WhenThenOption(id: '', label: 'Quiz', iconName: 'quiz'),
      WhenThenOption(id: '', label: 'Homework', iconName: 'book'),
      WhenThenOption(id: '', label: 'Clean Up', iconName: 'clean'),
      WhenThenOption(id: '', label: 'Finish Work', iconName: 'task'),
    ];

    for (final option in defaults) {
      await addClassroomWhenThenOption(
        schoolId: schoolId,
        classroomId: classroomId,
        type: 'activities',
        option: option,
      );
    }
  }

  if (rewardSnapshot.docs.isEmpty) {
    final defaults = [
      WhenThenOption(id: '', label: 'Calming Sounds', iconName: 'music'),
      WhenThenOption(id: '', label: 'Playtime', iconName: 'toys'),
      WhenThenOption(id: '', label: 'Outside Time', iconName: 'outside'),
      WhenThenOption(id: '', label: 'Break', iconName: 'break'),
      WhenThenOption(id: '', label: 'Music', iconName: 'music'),
    ];

    for (final option in defaults) {
      await addClassroomWhenThenOption(
        schoolId: schoolId,
        classroomId: classroomId,
        type: 'rewards',
        option: option,
      );
    }
  }
}

Future<void> seedDefaultCurrentWhenThenOptions() async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await seedDefaultClassroomWhenThenOptions(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );
    return;
  }

  await seedDefaultWhenThenOptions(currentTeacherUid);
}

Future<void> setWhenThenForChildren({
  required String teacherUid,
  required List<String> childIds,
  required WhenThenOption activity,
  required List<WhenThenOption> rewards,
}) async {
  final batch = db.batch();

  for (final childId in childIds) {
    final docRef = db
        .collection('teachers')
        .doc(teacherUid)
        .collection('child_profiles')
        .doc(childId);

    batch.set(docRef, {
      'whenThen': {
        'activity': activity.toWhenThenMap(),
        'rewards': rewards.map((reward) => reward.toWhenThenMap()).toList(),
        'selectedRewardId': null,
        'isActive': true,
      }
    }, SetOptions(merge: true));
  }

  await batch.commit();
}

Future<void> setClassroomWhenThenForChildren({
  required String schoolId,
  required String classroomId,
  required List<String> childIds,
  required WhenThenOption activity,
  required List<WhenThenOption> rewards,
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
      'whenThen': {
        'activity': activity.toWhenThenMap(),
        'rewards': rewards.map((reward) => reward.toWhenThenMap()).toList(),
        'selectedRewardId': null,
        'isActive': true,
      }
    }, SetOptions(merge: true));
  }

  await batch.commit();
}

Future<void> setCurrentWhenThenForChildren({
  required List<String> childIds,
  required WhenThenOption activity,
  required List<WhenThenOption> rewards,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await setClassroomWhenThenForChildren(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childIds: childIds,
      activity: activity,
      rewards: rewards,
    );
    return;
  }

  await setWhenThenForChildren(
    teacherUid: currentTeacherUid,
    childIds: childIds,
    activity: activity,
    rewards: rewards,
  );
}

Future<void> clearWhenThenForChild({
  required String teacherUid,
  required String childId,
}) async {
  await db
      .collection('teachers')
      .doc(teacherUid)
      .collection('child_profiles')
      .doc(childId)
      .set({
    'whenThen': {
      'activity': null,
      'rewards': [],
      'selectedRewardId': null,
      'isActive': false,
    }
  }, SetOptions(merge: true));
}

Future<void> clearClassroomWhenThenForChild({
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
    'whenThen': {
      'activity': null,
      'rewards': [],
      'selectedRewardId': null,
      'isActive': false,
    }
  }, SetOptions(merge: true));
}

Future<void> clearCurrentWhenThenForChild(String childId) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await clearClassroomWhenThenForChild(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childId: childId,
    );
    return;
  }

  await clearWhenThenForChild(
    teacherUid: currentTeacherUid,
    childId: childId,
  );
}

Future<void> selectWhenThenReward({
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
    'whenThen.selectedRewardId': rewardId,
  });
}

Future<void> selectClassroomWhenThenReward({
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
    'whenThen.selectedRewardId': rewardId,
  });
}

Future<void> selectCurrentWhenThenReward({
  required String childId,
  required String rewardId,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (hasClassroomSession) {
    await selectClassroomWhenThenReward(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childId: childId,
      rewardId: rewardId,
    );
    return;
  }

  await selectWhenThenReward(
    teacherUid: currentTeacherUid,
    childId: childId,
    rewardId: rewardId,
  );
}

Stream<Map<String, dynamic>?> getWhenThenStream({
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

    final whenThen = data['whenThen'];
    if (whenThen is Map<String, dynamic>) {
      return whenThen;
    }
    if (whenThen is Map) {
      return Map<String, dynamic>.from(whenThen);
    }

    return null;
  });
}

Stream<Map<String, dynamic>?> getClassroomWhenThenStream({
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

    final whenThen = data['whenThen'];
    if (whenThen is Map<String, dynamic>) {
      return whenThen;
    }
    if (whenThen is Map) {
      return Map<String, dynamic>.from(whenThen);
    }

    return null;
  });
}

Stream<Map<String, dynamic>?> getCurrentWhenThenStream({
  required String childId,
}) {
  if (hasClassroomSession) {
    return getClassroomWhenThenStream(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      childId: childId,
    );
  }

  return getWhenThenStream(
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
        .where((pack) => pack.isAvailableForChild(childId))
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
        .where((pack) => pack.isAvailableForChild(childId))
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

        attempts.sort((first, second) {
      final firstDate = first.createdAt;
      final secondDate = second.createdAt;

      if (firstDate == null && secondDate == null) return 0;
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;

      return secondDate.compareTo(firstDate);
    });

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

        attempts.sort((first, second) {
      final firstDate = first.createdAt;
      final secondDate = second.createdAt;

      if (firstDate == null && secondDate == null) return 0;
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;

      return secondDate.compareTo(firstDate);
    });

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

    // ODD ONE OUT

  CollectionReference<Map<String, dynamic>> _oddOneOutPacksRef(
    String teacherUid,
  ) {
    return db.collection('teachers').doc(teacherUid).collection(
          'odd_one_out_packs',
        );
  }

  CollectionReference<Map<String, dynamic>> _classroomOddOneOutPacksRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('odd_one_out_packs');
  }

  CollectionReference<Map<String, dynamic>> _oddOneOutRoundsRef({
    required String teacherUid,
    required String packId,
  }) {
    return _oddOneOutPacksRef(teacherUid).doc(packId).collection('rounds');
  }

  CollectionReference<Map<String, dynamic>> _classroomOddOneOutRoundsRef({
    required String schoolId,
    required String classroomId,
    required String packId,
  }) {
    return _classroomOddOneOutPacksRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).doc(packId).collection('rounds');
  }

  Stream<List<OddOneOutPack>> getOddOneOutPacks(String teacherUid) {
    return _oddOneOutPacksRef(teacherUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OddOneOutPack.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<OddOneOutPack>> getClassroomOddOneOutPacks({
    required String schoolId,
    required String classroomId,
  }) {
    return _classroomOddOneOutPacksRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OddOneOutPack.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<OddOneOutPack>> getCurrentOddOneOutPacks() {
    if (hasClassroomSession) {
      return getClassroomOddOneOutPacks(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      );
    }

    return getOddOneOutPacks(currentTeacherUid);
  }

  Stream<List<OddOneOutPack>> getCurrentAssignedOddOneOutPacks({
    required String childId,
  }) {
    return getCurrentOddOneOutPacks().map((packs) {
      return packs.where((pack) => pack.isAvailableForChild(childId)).toList();
    });
  }

  Future<String> addCurrentOddOneOutPack(OddOneOutPack pack) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      final docRef = _classroomOddOneOutPacksRef(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      ).doc();

      await docRef.set({
        ...pack.copyWith(id: docRef.id).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    }

    final docRef = _oddOneOutPacksRef(currentTeacherUid).doc();

    await docRef.set({
      ...pack.copyWith(id: docRef.id).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateCurrentOddOneOutPack(OddOneOutPack pack) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final data = {
      ...pack.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (hasClassroomSession) {
      await _classroomOddOneOutPacksRef(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      ).doc(pack.id).update(data);
      return;
    }

    await _oddOneOutPacksRef(currentTeacherUid).doc(pack.id).update(data);
  }

  Future<void> deleteCurrentOddOneOutPack(String packId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final roundsRef = hasClassroomSession
        ? _classroomOddOneOutRoundsRef(
            schoolId: session.requireSchoolId,
            classroomId: session.requireClassroomId,
            packId: packId,
          )
        : _oddOneOutRoundsRef(
            teacherUid: currentTeacherUid,
            packId: packId,
          );

    final roundsSnapshot = await roundsRef.get();
    final batch = db.batch();

    for (final doc in roundsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    if (hasClassroomSession) {
      batch.delete(
        _classroomOddOneOutPacksRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc(packId),
      );
    } else {
      batch.delete(_oddOneOutPacksRef(currentTeacherUid).doc(packId));
    }

    await batch.commit();
  }

  Stream<List<OddOneOutRound>> getCurrentOddOneOutRounds(String packId) {
    final stream = hasClassroomSession
        ? _classroomOddOneOutRoundsRef(
            schoolId: session.requireSchoolId,
            classroomId: session.requireClassroomId,
            packId: packId,
          ).snapshots()
        : _oddOneOutRoundsRef(
            teacherUid: currentTeacherUid,
            packId: packId,
          ).snapshots();

    return stream.map((snapshot) {
      final rounds = snapshot.docs
          .map((doc) => OddOneOutRound.fromMap(doc.id, doc.data()))
          .toList();

      rounds.sort((first, second) => first.sortOrder.compareTo(
            second.sortOrder,
          ));

      return rounds;
    });
  }

  Future<String> addCurrentOddOneOutRound({
    required String packId,
    required OddOneOutRound round,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final roundsRef = hasClassroomSession
        ? _classroomOddOneOutRoundsRef(
            schoolId: session.requireSchoolId,
            classroomId: session.requireClassroomId,
            packId: packId,
          )
        : _oddOneOutRoundsRef(
            teacherUid: currentTeacherUid,
            packId: packId,
          );

    final docRef = roundsRef.doc();

    await docRef.set(round.copyWith(id: docRef.id).toMap());
    await _touchCurrentOddOneOutPack(packId);

    return docRef.id;
  }

  Future<void> updateCurrentOddOneOutRound({
    required String packId,
    required OddOneOutRound round,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final roundsRef = hasClassroomSession
        ? _classroomOddOneOutRoundsRef(
            schoolId: session.requireSchoolId,
            classroomId: session.requireClassroomId,
            packId: packId,
          )
        : _oddOneOutRoundsRef(
            teacherUid: currentTeacherUid,
            packId: packId,
          );

    await roundsRef.doc(round.id).update(round.toMap());
    await _touchCurrentOddOneOutPack(packId);
  }

  Future<void> deleteCurrentOddOneOutRound({
    required String packId,
    required String roundId,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final roundsRef = hasClassroomSession
        ? _classroomOddOneOutRoundsRef(
            schoolId: session.requireSchoolId,
            classroomId: session.requireClassroomId,
            packId: packId,
          )
        : _oddOneOutRoundsRef(
            teacherUid: currentTeacherUid,
            packId: packId,
          );

    await roundsRef.doc(roundId).delete();
    await _touchCurrentOddOneOutPack(packId);
  }

  Future<void> _touchCurrentOddOneOutPack(String packId) async {
    if (hasClassroomSession) {
      await _classroomOddOneOutPacksRef(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
      ).doc(packId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await _oddOneOutPacksRef(currentTeacherUid).doc(packId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}