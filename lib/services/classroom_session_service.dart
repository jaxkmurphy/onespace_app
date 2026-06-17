class ClassroomSessionService {
  static final ClassroomSessionService instance =
      ClassroomSessionService._internal();

  ClassroomSessionService._internal();

  String? schoolId;
  String? classroomId;
  String? classroomName;

  bool get hasClassroomSession =>
      schoolId != null && classroomId != null;

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