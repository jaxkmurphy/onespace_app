import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/body_check_report.dart';
import '../../models/incident_log_entry.dart';
import 'firestore_base.dart';

mixin WellbeingFirestoreService on FirestoreBase {
  // ZONES + POINTS

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