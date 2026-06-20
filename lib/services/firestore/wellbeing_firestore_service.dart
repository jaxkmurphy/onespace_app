import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/body_check_report.dart';
import '../../models/incident_log_entry.dart';
import '../../models/circle_time_day.dart';
import '../../models/point_history_entry.dart';
import '../../models/point_reward.dart';
import 'firestore_base.dart';

mixin WellbeingFirestoreService on FirestoreBase {
  // ZONES + POINTS

  CollectionReference<Map<String, dynamic>> _currentPointHistoryRef(
  String childId,
) {
  return currentChildDoc(childId).collection('point_history');
}

Stream<List<PointHistoryEntry>> getCurrentPointHistory(
  String childId,
) {
  return _currentPointHistoryRef(childId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => PointHistoryEntry.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList(),
      );
}

  CollectionReference<Map<String, dynamic>> _currentPointRewardsRef() {
  return currentCollection('point_rewards');
}

Stream<List<PointReward>> getCurrentPointRewards({
  bool activeOnly = false,
}) {
  return _currentPointRewardsRef().snapshots().map((snapshot) {
    final rewards = snapshot.docs
        .map(
          (doc) => PointReward.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .where(
          (reward) => !activeOnly || reward.active,
        )
        .toList();

    rewards.sort((first, second) {
      if (first.active != second.active) {
        return first.active ? -1 : 1;
      }

      final costComparison = first.cost.compareTo(second.cost);

      if (costComparison != 0) {
        return costComparison;
      }

      return first.name.compareTo(second.name);
    });

    return rewards;
  });
}

Future<String> addCurrentPointReward({
  required String name,
  required String description,
  required int cost,
  required String iconName,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (name.trim().isEmpty) {
    throw ArgumentError('A reward name is required.');
  }

  if (cost <= 0) {
    throw ArgumentError('Reward cost must be greater than zero.');
  }

  final rewardRef = _currentPointRewardsRef().doc();

  await rewardRef.set({
    'name': name.trim(),
    'description': description.trim(),
    'cost': cost,
    'iconName': iconName,
    'active': true,
    'createdAt': FieldValue.serverTimestamp(),
  });

  return rewardRef.id;
}

Future<void> updateCurrentPointReward(
  PointReward reward,
) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (reward.name.trim().isEmpty) {
    throw ArgumentError('A reward name is required.');
  }

  if (reward.cost <= 0) {
    throw ArgumentError('Reward cost must be greater than zero.');
  }

  await _currentPointRewardsRef().doc(reward.id).update(
        reward.toMap(),
      );
}

Future<void> setCurrentPointRewardActive({
  required String rewardId,
  required bool active,
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  await _currentPointRewardsRef().doc(rewardId).update({
    'active': active,
  });
}

Future<int> addCurrentPointEntry({
  required String childId,
  required int amount,
  required String reason,
  String note = '',
}) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  if (amount == 0) {
    throw ArgumentError('Point amount cannot be zero.');
  }

  if (reason.trim().isEmpty) {
    throw ArgumentError('A reason is required.');
  }

  final childRef = currentChildDoc(childId);
  final historyRef = _currentPointHistoryRef(childId).doc();

  return db.runTransaction<int>((transaction) async {
    final childSnapshot = await transaction.get(childRef);
    final childData = childSnapshot.data();

    if (!childSnapshot.exists || childData == null) {
      throw StateError('Child profile could not be found.');
    }

    final currentPoints =
        (childData['points'] as num?)?.toInt() ?? 0;

    final requestedBalance = currentPoints + amount;
    final newBalance = requestedBalance < 0
        ? 0
        : requestedBalance;

    final actualChange = newBalance - currentPoints;

    if (actualChange == 0) {
      throw StateError('The child already has zero points.');
    }

    transaction.update(
      childRef,
      {
        'points': newBalance,
      },
    );

    transaction.set(
      historyRef,
      {
        'childId': childId,
        'amount': actualChange,
        'balanceAfter': newBalance,
        'reason': reason.trim(),
        'note': note.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    return newBalance;
  });
}

  Future<void> setChildZone(
    String teacherUid,
    String childId,
    String zone,
  ) async {
    await teacherChildDoc(
      teacherUid: teacherUid,
      childId: childId,
    ).update({
      'zone': zone,
    });
  }

  Future<void> setClassroomChildZone({
    required String schoolId,
    required String classroomId,
    required String childId,
    required String zone,
  }) async {
    await classroomChildDoc(
      schoolId: schoolId,
      classroomId: classroomId,
      childId: childId,
    ).update({
      'zone': zone,
    });
  }

  Future<void> setCurrentChildZone({
    required String childId,
    required String zone,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({
      'zone': zone,
    });
  }

  Future<void> setChildPoints(
    String teacherUid,
    String childId,
    int points,
  ) async {
    await teacherChildDoc(
      teacherUid: teacherUid,
      childId: childId,
    ).update({
      'points': points,
    });
  }

  Future<void> setClassroomChildPoints({
    required String schoolId,
    required String classroomId,
    required String childId,
    required int points,
  }) async {
    await classroomChildDoc(
      schoolId: schoolId,
      classroomId: classroomId,
      childId: childId,
    ).update({
      'points': points,
    });
  }

  Future<void> setCurrentChildPoints({
    required String childId,
    required int points,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({
      'points': points,
    });
  }

  // CIRCLE TIME

  DocumentReference<Map<String, dynamic>> _currentCircleTimeDayRef(
  String dateKey,
) {
  return currentCollection('circle_time_days').doc(dateKey);
}

Stream<CircleTimeDay> getCurrentCircleTimeDay(String dateKey) {
  return _currentCircleTimeDayRef(dateKey).snapshots().map((snapshot) {
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return CircleTimeDay(id: dateKey);
    }

    return CircleTimeDay.fromMap(snapshot.id, data);
  });
}

Future<void> saveCurrentCircleTimeDay(
  CircleTimeDay day,
) async {
  await restoreClassroomSessionFromAuthIfNeeded();

  await _currentCircleTimeDayRef(day.id).set(
    {
      ...day.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

  Future<void> updateStaffCircleTimePosition({
    required String teacherUid,
    required String staffId,
    required double x,
    required double y,
    required String side,
  }) async {
    await teacherStaffDoc(
      teacherUid: teacherUid,
      staffId: staffId,
    ).update({
      'circleTimeX': x,
      'circleTimeY': y,
      'circleTimeSide': side,
    });
  }

  Future<void> updateChildCircleTimePosition({
    required String teacherUid,
    required String childId,
    required double x,
    required double y,
    required String side,
  }) async {
    await teacherChildDoc(
      teacherUid: teacherUid,
      childId: childId,
    ).update({
      'circleTimeX': x,
      'circleTimeY': y,
      'circleTimeSide': side,
    });
  }

  Future<void> updateClassroomStaffCircleTimePosition({
    required String schoolId,
    required String classroomId,
    required String staffId,
    required double x,
    required double y,
    required String side,
  }) async {
    await classroomStaffDoc(
      schoolId: schoolId,
      classroomId: classroomId,
      staffId: staffId,
    ).update({
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
    await classroomChildDoc(
      schoolId: schoolId,
      classroomId: classroomId,
      childId: childId,
    ).update({
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

    await currentStaffDoc(staffId).update({
      'circleTimeX': x,
      'circleTimeY': y,
      'circleTimeSide': side,
    });
  }

  Future<void> updateCurrentChildCircleTimePosition({
    required String childId,
    required double x,
    required double y,
    required String side,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({
      'circleTimeX': x,
      'circleTimeY': y,
      'circleTimeSide': side,
    });
  }

  // INCIDENT LOG

  Future<void> addIncidentLogEntry({
    required String teacherUid,
    required IncidentLogEntry entry,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'incident_logs',
    ).add(entry.toMap());
  }

  Stream<List<IncidentLogEntry>> getIncidentLogEntries(String teacherUid) {
    return teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'incident_logs',
    ).orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteIncidentLogEntry({
    required String teacherUid,
    required String incidentId,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'incident_logs',
    ).doc(incidentId).delete();
  }

  Future<void> addClassroomIncidentLogEntry({
    required String schoolId,
    required String classroomId,
    required IncidentLogEntry entry,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'incident_logs',
    ).add(entry.toMap());
  }

  Stream<List<IncidentLogEntry>> getClassroomIncidentLogEntries({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'incident_logs',
    ).orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteClassroomIncidentLogEntry({
    required String schoolId,
    required String classroomId,
    required String incidentId,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'incident_logs',
    ).doc(incidentId).delete();
  }

  Future<void> addCurrentIncidentLogEntry(IncidentLogEntry entry) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentIncidentLogsRef().add(entry.toMap());
  }

  Stream<List<IncidentLogEntry>> getCurrentIncidentLogEntries() {
    return currentIncidentLogsRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteCurrentIncidentLogEntry(String incidentId) async {
    return currentIncidentLogsRef().doc(incidentId).delete();
  }

  // BODY CHECK

  Future<void> addBodyCheckReport({
    required String teacherUid,
    required BodyCheckReport report,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'body_check_reports',
    ).add(report.toMap());
  }

  Stream<List<BodyCheckReport>> getBodyCheckReports(String teacherUid) {
    return teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'body_check_reports',
    ).orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => BodyCheckReport.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markBodyCheckReportChecked({
    required String teacherUid,
    required String reportId,
    String checkedNote = '',
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'body_check_reports',
    ).doc(reportId).update({
      'checked': true,
      'checkedNote': checkedNote,
      'checkedAt': Timestamp.now(),
    });
  }

  Future<void> deleteBodyCheckReport({
    required String teacherUid,
    required String reportId,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'body_check_reports',
    ).doc(reportId).delete();
  }

  Future<void> addClassroomBodyCheckReport({
    required String schoolId,
    required String classroomId,
    required BodyCheckReport report,
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'body_check_reports',
    ).add(report.toMap());
  }

  Stream<List<BodyCheckReport>> getClassroomBodyCheckReports({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'body_check_reports',
    ).orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => BodyCheckReport.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markClassroomBodyCheckReportChecked({
    required String schoolId,
    required String classroomId,
    required String reportId,
    String checkedNote = '',
  }) async {
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'body_check_reports',
    ).doc(reportId).update({
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
    await classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'body_check_reports',
    ).doc(reportId).delete();
  }

  Future<void> addCurrentBodyCheckReport(BodyCheckReport report) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentBodyCheckReportsRef().add(report.toMap());
  }

  Stream<List<BodyCheckReport>> getCurrentBodyCheckReports() {
    return currentBodyCheckReportsRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BodyCheckReport.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markCurrentBodyCheckReportChecked({
    required String reportId,
    String checkedNote = '',
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentBodyCheckReportsRef().doc(reportId).update({
      'checked': true,
      'checkedNote': checkedNote,
      'checkedAt': Timestamp.now(),
    });
  }

  Future<void> deleteCurrentBodyCheckReport(String reportId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentBodyCheckReportsRef().doc(reportId).delete();
  }
}