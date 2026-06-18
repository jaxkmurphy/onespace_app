class ClassroomSessionService {
  static final ClassroomSessionService instance =
      ClassroomSessionService._internal();

  ClassroomSessionService._internal();

  String? schoolId;
  String? classroomId;
  String? classroomName;

  bool get hasClassroomSession => schoolId != null && classroomId != null;

  bool get isClassroomMode => hasClassroomSession;

  String get requireSchoolId {
    final value = schoolId;

    if (value == null || value.isEmpty) {
      throw StateError('No active school session found.');
    }

    return value;
  }

  String get requireClassroomId {
    final value = classroomId;

    if (value == null || value.isEmpty) {
      throw StateError('No active classroom session found.');
    }

    return value;
  }

  String get currentClassroomName {
    final value = classroomName;

    if (value == null || value.isEmpty) {
      return 'Classroom';
    }

    return value;
  }

  void setSession({
    required String schoolId,
    required String classroomId,
    required String classroomName,
  }) {
    this.schoolId = schoolId;
    this.classroomId = classroomId;
    this.classroomName = classroomName;
  }

  void clearSession() {
    schoolId = null;
    classroomId = null;
    classroomName = null;
  }
}