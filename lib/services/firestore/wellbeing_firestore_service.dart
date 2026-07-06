import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/body_check_report.dart';
import '../../models/incident_log_entry.dart';
import '../../models/circle_time_day.dart';
import '../../models/point_history_entry.dart';
import '../../models/point_reward.dart';
import 'firestore_base.dart';
import '../../models/calm_plan_models.dart';
import '../../models/child_profile.dart';
import '../../models/classroom_helper_models.dart';
import '../../models/child_note.dart';
import '../../models/staff_profile.dart';

mixin WellbeingFirestoreService on FirestoreBase {
  // ZONES + POINTS

  CollectionReference<Map<String, dynamic>> _currentPointHistoryRef(
    String childId,
  ) {
    return currentChildDoc(childId).collection('point_history');
  }

  Stream<List<PointHistoryEntry>> getCurrentPointHistory(String childId) {
    return _currentPointHistoryRef(childId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PointHistoryEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  CollectionReference<Map<String, dynamic>> _currentPointRewardsRef() {
    return currentCollection('point_rewards');
  }

  Stream<List<PointReward>> getCurrentPointRewards({bool activeOnly = false}) {
    return _currentPointRewardsRef().snapshots().map((snapshot) {
      final rewards =
          snapshot.docs
              .map((doc) => PointReward.fromMap(doc.id, doc.data()))
              .where((reward) => !activeOnly || reward.active)
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

  Future<void> updateCurrentPointReward(PointReward reward) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (reward.name.trim().isEmpty) {
      throw ArgumentError('A reward name is required.');
    }

    if (reward.cost <= 0) {
      throw ArgumentError('Reward cost must be greater than zero.');
    }

    await _currentPointRewardsRef().doc(reward.id).update(reward.toMap());
  }

  Future<void> setCurrentPointRewardActive({
    required String rewardId,
    required bool active,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _currentPointRewardsRef().doc(rewardId).update({'active': active});
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

      final currentPoints = (childData['points'] as num?)?.toInt() ?? 0;

      final requestedBalance = currentPoints + amount;
      final newBalance = requestedBalance < 0 ? 0 : requestedBalance;

      final actualChange = newBalance - currentPoints;

      if (actualChange == 0) {
        throw StateError('The child already has zero points.');
      }

      transaction.update(childRef, {'points': newBalance});

      transaction.set(historyRef, {
        'childId': childId,
        'amount': actualChange,
        'balanceAfter': newBalance,
        'reason': reason.trim(),
        'note': note.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

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
    ).update({'zone': zone});
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
    ).update({'zone': zone});
  }

  Future<void> setCurrentChildZone({
    required String childId,
    required String zone,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({'zone': zone});
  }

  Future<void> setChildPoints(
    String teacherUid,
    String childId,
    int points,
  ) async {
    await teacherChildDoc(
      teacherUid: teacherUid,
      childId: childId,
    ).update({'points': points});
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
    ).update({'points': points});
  }

  Future<void> setCurrentChildPoints({
    required String childId,
    required int points,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({'points': points});
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

  Future<void> saveCurrentCircleTimeDay(CircleTimeDay day) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _currentCircleTimeDayRef(day.id).set({
      ...day.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
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
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
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
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
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
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
  }

  Future<void> updateCurrentStaffCircleTimePosition({
    required String staffId,
    required double x,
    required double y,
    required String side,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentStaffDoc(
      staffId,
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
  }

  Future<void> updateCurrentChildCircleTimePosition({
    required String childId,
    required double x,
    required double y,
    required String side,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(
      childId,
    ).update({'circleTimeX': x, 'circleTimeY': y, 'circleTimeSide': side});
  }

  // INCIDENT LOG

  Map<String, dynamic> _newIncidentData(IncidentLogEntry entry) {
    return {
      ...entry.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedByStaffId': entry.staffId,
      'updatedByStaffName': entry.staffName,
      'isArchived': false,
    };
  }

  Map<String, dynamic> _updatedIncidentData({
    required IncidentLogEntry entry,
    required String updatedByStaffId,
    required String updatedByStaffName,
  }) {
    return {
      ...entry.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedByStaffId': updatedByStaffId,
      'updatedByStaffName': updatedByStaffName,
    };
  }

  Map<String, dynamic> _archivedIncidentData({
    required String reason,
    required String staffId,
    required String staffName,
  }) {
    return {
      'isArchived': true,
      'archiveReason': reason,
      'archivedAt': FieldValue.serverTimestamp(),
      'archivedByStaffId': staffId,
      'archivedByStaffName': staffName,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedByStaffId': staffId,
      'updatedByStaffName': staffName,
    };
  }

  Future<void> addIncidentLogEntry({
    required String teacherUid,
    required IncidentLogEntry entry,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'incident_logs',
    ).add(_newIncidentData(entry));
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
    ).add(_newIncidentData(entry));
  }

  Future<void> addCurrentIncidentLogEntry(IncidentLogEntry entry) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentIncidentLogsRef().add(_newIncidentData(entry));
  }

  Stream<List<IncidentLogEntry>> getIncidentLogEntries(String teacherUid) {
    return teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'incident_logs',
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Stream<List<IncidentLogEntry>> getClassroomIncidentLogEntries({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'incident_logs',
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Stream<List<IncidentLogEntry>> getCurrentIncidentLogEntries() {
    return currentIncidentLogsRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => IncidentLogEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> updateIncidentLogEntry({
    required String teacherUid,
    required IncidentLogEntry entry,
    required String updatedByStaffId,
    required String updatedByStaffName,
  }) async {
    await teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'incident_logs',
        )
        .doc(entry.id)
        .update(
          _updatedIncidentData(
            entry: entry,
            updatedByStaffId: updatedByStaffId,
            updatedByStaffName: updatedByStaffName,
          ),
        );
  }

  Future<void> updateClassroomIncidentLogEntry({
    required String schoolId,
    required String classroomId,
    required IncidentLogEntry entry,
    required String updatedByStaffId,
    required String updatedByStaffName,
  }) async {
    await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'incident_logs',
        )
        .doc(entry.id)
        .update(
          _updatedIncidentData(
            entry: entry,
            updatedByStaffId: updatedByStaffId,
            updatedByStaffName: updatedByStaffName,
          ),
        );
  }

  Future<void> updateCurrentIncidentLogEntry({
    required IncidentLogEntry entry,
    required String updatedByStaffId,
    required String updatedByStaffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentIncidentLogsRef()
        .doc(entry.id)
        .update(
          _updatedIncidentData(
            entry: entry,
            updatedByStaffId: updatedByStaffId,
            updatedByStaffName: updatedByStaffName,
          ),
        );
  }

  Future<void> archiveIncidentLogEntry({
    required String teacherUid,
    required String incidentId,
    required String reason,
    required String staffId,
    required String staffName,
  }) async {
    await teacherCollection(
          teacherUid: teacherUid,
          collectionName: 'incident_logs',
        )
        .doc(incidentId)
        .update(
          _archivedIncidentData(
            reason: reason,
            staffId: staffId,
            staffName: staffName,
          ),
        );
  }

  Future<void> archiveClassroomIncidentLogEntry({
    required String schoolId,
    required String classroomId,
    required String incidentId,
    required String reason,
    required String staffId,
    required String staffName,
  }) async {
    await classroomCollection(
          schoolId: schoolId,
          classroomId: classroomId,
          collectionName: 'incident_logs',
        )
        .doc(incidentId)
        .update(
          _archivedIncidentData(
            reason: reason,
            staffId: staffId,
            staffName: staffName,
          ),
        );
  }

  Future<void> archiveCurrentIncidentLogEntry({
    required String incidentId,
    required String reason,
    required String staffId,
    required String staffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentIncidentLogsRef()
        .doc(incidentId)
        .update(
          _archivedIncidentData(
            reason: reason,
            staffId: staffId,
            staffName: staffName,
          ),
        );
  }

  // Retained temporarily for compatibility with the old Incident Log page.
  // The upgraded interface will archive records instead.
  Future<void> deleteIncidentLogEntry({
    required String teacherUid,
    required String incidentId,
  }) async {
    await teacherCollection(
      teacherUid: teacherUid,
      collectionName: 'incident_logs',
    ).doc(incidentId).delete();
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

  Future<void> deleteCurrentIncidentLogEntry(String incidentId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentIncidentLogsRef().doc(incidentId).delete();
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
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
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
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
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
          (snapshot) =>
              snapshot.docs
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

  // CLASSROOM HELPER

  CollectionReference<Map<String, dynamic>> _classroomHelperJobsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('helper_jobs');
  }

  CollectionReference<Map<String, dynamic>> _classroomHelperCompletionsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('helper_completions');
  }

  CollectionReference<Map<String, dynamic>> _classroomHelperAssignmentsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('helper_assignments');
  }

  CollectionReference<Map<String, dynamic>> _classroomHelperRequestsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('helper_completion_requests');
  }

  Stream<List<ClassroomHelperJob>> getCurrentClassroomHelperJobs() {
    return _classroomHelperJobsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return defaultClassroomHelperJobs;
      }

      final jobs =
          snapshot.docs
              .map((doc) => ClassroomHelperJob.fromMap(doc.id, doc.data()))
              .toList();

      jobs.sort((first, second) {
        final sortCompare = first.sortOrder.compareTo(second.sortOrder);
        if (sortCompare != 0) return sortCompare;
        return first.title.toLowerCase().compareTo(second.title.toLowerCase());
      });

      return jobs;
    });
  }

  Stream<List<ClassroomHelperJob>> getCurrentActiveClassroomHelperJobs() {
    return getCurrentClassroomHelperJobs().map((jobs) {
      return jobs.where((job) => job.active).toList();
    });
  }

  Future<String> addCurrentClassroomHelperJob(ClassroomHelperJob job) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final docRef =
        _classroomHelperJobsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc();

    await docRef.set({
      ...job.copyWith(id: docRef.id).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateCurrentClassroomHelperJob(ClassroomHelperJob job) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _classroomHelperJobsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(job.id).update({
      ...job.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCurrentClassroomHelperJob(String jobId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _classroomHelperJobsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(jobId).delete();
  }

  Future<void> seedCurrentDefaultClassroomHelperJobsIfEmpty() async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final ref = _classroomHelperJobsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );

    final snapshot = await ref.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = db.batch();

    for (final job in defaultClassroomHelperJobs) {
      final docRef = ref.doc(job.id);
      batch.set(docRef, {
        ...job.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<List<ClassroomHelperAssignment>>
  getCurrentClassroomHelperAssignments() {
    return _classroomHelperAssignmentsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).snapshots().map((snapshot) {
      final assignments =
          snapshot.docs
              .map(
                (doc) => ClassroomHelperAssignment.fromMap(doc.id, doc.data()),
              )
              .where((assignment) => assignment.isActive)
              .toList();

      assignments.sort((first, second) {
        final childCompare = first.childName.toLowerCase().compareTo(
          second.childName.toLowerCase(),
        );
        if (childCompare != 0) return childCompare;

        final firstDate =
            first.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return firstDate.compareTo(secondDate);
      });

      return assignments;
    });
  }

  Stream<ClassroomHelperAssignment?>
  getCurrentClassroomHelperAssignmentForChild(String childId) {
    return _classroomHelperAssignmentsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).where('childId', isEqualTo: childId).snapshots().map((snapshot) {
      final assignments =
          snapshot.docs
              .map(
                (doc) => ClassroomHelperAssignment.fromMap(doc.id, doc.data()),
              )
              .where((assignment) => assignment.isActive)
              .toList();

      assignments.sort((first, second) {
        final firstDate =
            first.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return firstDate.compareTo(secondDate);
      });

      if (assignments.isEmpty) return null;
      return assignments.first;
    });
  }

  Future<void> assignCurrentClassroomHelperJob({
    required ClassroomHelperJob job,
    required List<ChildProfile> children,
    required String staffId,
    required String staffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();
    if (children.isEmpty) return;

    final ref = _classroomHelperAssignmentsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );

    final batch = db.batch();
    for (final child in children) {
      final docRef = ref.doc();
      batch.set(docRef, {
        'childId': child.id,
        'childName': child.name,
        'jobId': job.id,
        'jobTitle': job.title,
        'jobDescription': job.description,
        'jobIconName': job.iconName,
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedByStaffId': staffId,
        'assignedByStaffName': staffName,
        'status': 'assigned',
      });
    }

    await batch.commit();
  }

  Future<void> clearCurrentClassroomHelperAssignment(
    String assignmentId,
  ) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _classroomHelperAssignmentsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(assignmentId).update({
      'status': 'cleared',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ClassroomHelperCompletionRequest>>
  getCurrentPendingClassroomHelperRequests() {
    return _classroomHelperRequestsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        )
        .where('status', isEqualTo: ClassroomHelperRequestStatus.pending.value)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => ClassroomHelperCompletionRequest.fromMap(
                      doc.id,
                      doc.data(),
                    ),
                  )
                  .toList()
                ..sort((first, second) {
                  final firstDate =
                      first.requestedAt ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final secondDate =
                      second.requestedAt ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return secondDate.compareTo(firstDate);
                }),
        );
  }

  Stream<ClassroomHelperCompletionRequest?>
  getCurrentPendingClassroomHelperRequestForChild(String childId) {
    return _classroomHelperRequestsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        )
        .where('childId', isEqualTo: childId)
        .where('status', isEqualTo: ClassroomHelperRequestStatus.pending.value)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return ClassroomHelperCompletionRequest.fromMap(doc.id, doc.data());
        });
  }

  Future<void> requestCurrentClassroomHelperCompletion({
    required ClassroomHelperAssignment assignment,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final existing =
        await _classroomHelperRequestsRef(
              schoolId: session.requireSchoolId,
              classroomId: session.requireClassroomId,
            )
            .where('childId', isEqualTo: assignment.childId)
            .where(
              'status',
              isEqualTo: ClassroomHelperRequestStatus.pending.value,
            )
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) return;

    await _classroomHelperRequestsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).add({
      'assignmentId': assignment.id,
      'jobId': assignment.jobId,
      'jobTitle': assignment.jobTitle,
      'jobIconName': assignment.jobIconName,
      'childId': assignment.childId,
      'childName': assignment.childName,
      'status': ClassroomHelperRequestStatus.pending.value,
      'requestedAt': FieldValue.serverTimestamp(),
      'resolvedByStaffId': '',
      'resolvedByStaffName': '',
    });
  }

  Future<void> confirmCurrentClassroomHelperRequest({
    required ClassroomHelperCompletionRequest request,
    required String staffId,
    required String staffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final requestRef = _classroomHelperRequestsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(request.id);
    final completionRef =
        _classroomHelperCompletionsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc();

    final batch = db.batch();
    batch.update(requestRef, {
      'status': ClassroomHelperRequestStatus.confirmed.value,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedByStaffId': staffId,
      'resolvedByStaffName': staffName,
    });
    batch.set(completionRef, {
      'jobId': request.jobId,
      'jobTitle': request.jobTitle,
      'jobIconName': request.jobIconName,
      'childId': request.childId,
      'childName': request.childName,
      'createdAt': FieldValue.serverTimestamp(),
      'confirmedAt': FieldValue.serverTimestamp(),
      'confirmedByStaffId': staffId,
      'confirmedByStaffName': staffName,
    });
    if (request.assignmentId.isNotEmpty) {
      batch.update(
        _classroomHelperAssignmentsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc(request.assignmentId),
        {'status': 'completed', 'completedAt': FieldValue.serverTimestamp()},
      );
    }

    await batch.commit();
  }

  Future<void> clearCurrentClassroomHelperRequest({
    required ClassroomHelperCompletionRequest request,
    required String staffId,
    required String staffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _classroomHelperRequestsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(request.id).update({
      'status': ClassroomHelperRequestStatus.cleared.value,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedByStaffId': staffId,
      'resolvedByStaffName': staffName,
    });
  }

  Stream<List<ClassroomHelperCompletion>>
  getCurrentClassroomHelperCompletions() {
    return _classroomHelperCompletionsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        )
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ClassroomHelperCompletion.fromMap(doc.id, doc.data()),
                  )
                  .toList(),
        );
  }

  Future<void> addCurrentClassroomHelperCompletion({
    required ClassroomHelperJob job,
    required String childId,
    required String childName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _classroomHelperCompletionsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).add({
      'jobId': job.id,
      'jobTitle': job.title,
      'jobIconName': job.iconName,
      'childId': childId,
      'childName': childName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // CALM PLAN

  CollectionReference<Map<String, dynamic>> _calmToolsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('calm_tools');
  }

  CollectionReference<Map<String, dynamic>> _calmRequestsRef({
    required String schoolId,
    required String classroomId,
  }) {
    return db
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('calm_requests');
  }

  Stream<List<CalmTool>> getCurrentCalmTools() {
    return _calmToolsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return defaultCalmTools;
      }

      final tools =
          snapshot.docs
              .map((doc) => CalmTool.fromMap(doc.id, doc.data()))
              .toList();

      tools.sort((first, second) {
        final sortCompare = first.sortOrder.compareTo(second.sortOrder);
        if (sortCompare != 0) return sortCompare;
        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      });

      return tools;
    });
  }

  Stream<List<CalmTool>> getCurrentActiveCalmTools() {
    return getCurrentCalmTools().map((tools) {
      return tools.where((tool) => tool.active).toList();
    });
  }

  Future<String> addCurrentCalmTool(CalmTool tool) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final docRef =
        _calmToolsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc();

    await docRef.set({
      ...tool.copyWith(id: docRef.id).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateCurrentCalmTool(CalmTool tool) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _calmToolsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(tool.id).update({
      ...tool.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCurrentCalmTool(String toolId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _calmToolsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(toolId).delete();
  }

  Future<void> seedCurrentDefaultCalmToolsIfEmpty() async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final ref = _calmToolsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );

    final snapshot = await ref.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = db.batch();

    for (final tool in defaultCalmTools) {
      final docRef = ref.doc(tool.id);
      batch.set(docRef, {
        ...tool.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<List<CalmRequest>> getCurrentCalmRequests({
    CalmRequestStatus? status,
  }) {
    return _calmRequestsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).snapshots().map((snapshot) {
      final requests =
          snapshot.docs
              .map((doc) => CalmRequest.fromMap(doc.id, doc.data()))
              .where((request) => status == null || request.status == status)
              .toList();

      requests.sort((first, second) {
        final firstDate = first.createdAt;
        final secondDate = second.createdAt;

        if (firstDate != null && secondDate != null) {
          return secondDate.compareTo(firstDate);
        }

        return first.childName.toLowerCase().compareTo(
          second.childName.toLowerCase(),
        );
      });

      return requests;
    });
  }

  Stream<List<CalmRequest>> getCurrentActiveCalmRequests() {
    return getCurrentCalmRequests(status: CalmRequestStatus.active);
  }

  Future<String> createCurrentCalmRequest({
    required String childId,
    required String childName,
    required CalmTool tool,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final docRef =
        _calmRequestsRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        ).doc();

    final request = CalmRequest(
      id: docRef.id,
      childId: childId,
      childName: childName,
      toolId: tool.id,
      toolName: tool.name,
      toolIconName: tool.iconName,
      status: CalmRequestStatus.active,
      resolvedByStaffId: '',
      resolvedByStaffName: '',
    );

    await docRef.set({
      ...request.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> resolveCurrentCalmRequest({
    required String requestId,
    required String staffId,
    required String staffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _calmRequestsRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(requestId).update({
      'status': CalmRequestStatus.resolved.value,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedByStaffId': staffId,
      'resolvedByStaffName': staffName,
    });
  }

  // CHILD NOTES

  CollectionReference<Map<String, dynamic>> _childNotesRef({
    required String schoolId,
    required String classroomId,
  }) {
    return classroomCollection(
      schoolId: schoolId,
      classroomId: classroomId,
      collectionName: 'child_notes',
    );
  }

  Stream<List<ChildNote>> getClassroomChildNotes({
    required String schoolId,
    required String classroomId,
  }) {
    return _childNotesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ChildNote.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<ChildNote>> getCurrentChildNotes() {
    return getClassroomChildNotes(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    );
  }

  Stream<List<ChildNote>> getCurrentVisibleChildNotesForStaff({
    required StaffProfile staff,
    String? childId,
  }) {
    return getCurrentChildNotes().map((notes) {
      return notes.where((note) {
        final childMatches = childId == null || note.childId == childId;
        final visibilityMatches = note.isVisibleToStaff(staff.id);

        return childMatches && visibilityMatches;
      }).toList();
    });
  }

  Future<String> addCurrentChildNote({
    required ChildProfile child,
    required StaffProfile staff,
    required String content,
    required ChildNoteCategory category,
    required ChildNoteVisibility visibility,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final schoolId = session.requireSchoolId;
    final classroomId = session.requireClassroomId;

    final note = ChildNote(
      id: '',
      schoolId: schoolId,
      classroomId: classroomId,
      childId: child.id,
      childName: child.name,
      content: content.trim(),
      category: category,
      visibility: visibility,
      createdByStaffId: staff.id,
      createdByStaffName: staff.name,
    );

    final doc = await _childNotesRef(
      schoolId: schoolId,
      classroomId: classroomId,
    ).add(note.toCreateMap());

    return doc.id;
  }

  Future<void> updateCurrentChildNote({
    required ChildNote note,
    required String content,
    required ChildNoteCategory category,
    required ChildNoteVisibility visibility,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _childNotesRef(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        )
        .doc(note.id)
        .update(
          note
              .copyWith(
                content: content.trim(),
                category: category,
                visibility: visibility,
              )
              .toUpdateMap(),
        );
  }

  Future<void> deleteCurrentChildNote(String noteId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _childNotesRef(
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
    ).doc(noteId).delete();
  }
}
