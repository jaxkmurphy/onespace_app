import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_base.dart';

mixin ClassroomFirestoreService on FirestoreBase {
  // SCHEDULE MANAGEMENT

  Future<Map<String, List<Map<String, dynamic>>>> getSchedule(
    String teacherUid,
  ) async {
    final doc = await teacherDoc(teacherUid).get();
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

  Future<void> setScheduleForDay(
    String teacherUid,
    String day,
    List<Map<String, dynamic>> entries,
  ) async {
    await teacherDoc(teacherUid).set({
      'schedule': {
        day: entries,
      },
    }, SetOptions(merge: true));
  }

  Future<void> addScheduleEntry(
    String teacherUid,
    String day,
    Map<String, dynamic> entry,
  ) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];

    dayEntries.add(entry);
    dayEntries.sort((a, b) => a['start']?.compareTo(b['start']) ?? 0);

    await setScheduleForDay(teacherUid, day, dayEntries);
  }

  Future<void> removeScheduleEntry(
    String teacherUid,
    String day,
    Map<String, dynamic> entry,
  ) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];

    dayEntries.removeWhere(
      (existingEntry) =>
          existingEntry['start'] == entry['start'] &&
          existingEntry['end'] == entry['end'] &&
          existingEntry['description'] == entry['description'],
    );

    await setScheduleForDay(teacherUid, day, dayEntries);
  }

  Future<void> updateScheduleEntry(
    String teacherUid,
    String day,
    Map<String, dynamic> oldEntry,
    Map<String, dynamic> newEntry,
  ) async {
    final schedule = await getSchedule(teacherUid);
    final dayEntries = schedule[day] ?? [];

    final index = dayEntries.indexWhere(
      (entry) =>
          entry['start'] == oldEntry['start'] &&
          entry['end'] == oldEntry['end'] &&
          entry['description'] == oldEntry['description'],
    );

    if (index == -1) {
      return;
    }

    dayEntries[index] = newEntry;
    dayEntries.sort((a, b) => a['start']?.compareTo(b['start']) ?? 0);

    await setScheduleForDay(teacherUid, day, dayEntries);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getClassroomSchedule({
    required String schoolId,
    required String classroomId,
  }) async {
    final doc = await classroomDoc(
      schoolId: schoolId,
      classroomId: classroomId,
    ).get();

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
    await classroomDoc(
      schoolId: schoolId,
      classroomId: classroomId,
    ).set({
      'schedule': {
        day: entries,
      },
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<Map<String, dynamic>>>> getCurrentSchedule() async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (hasClassroomSession) {
      return getClassroomSchedule(
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
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
        schoolId: session.requireSchoolId,
        classroomId: session.requireClassroomId,
        day: day,
        entries: entries,
      );
      return;
    }

    await setScheduleForDay(
      currentTeacherUid,
      day,
      entries,
    );
  }
}