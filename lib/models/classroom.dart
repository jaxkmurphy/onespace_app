import 'classroom_feature.dart';

class Classroom {
  final String id;
  final String schoolId;
  final String name;
  final String classroomCode;
  final String pin;
  final bool active;
  final DateTime? createdAt;
  final Set<ClassroomFeature> enabledFeatures;

  Classroom({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.classroomCode,
    required this.pin,
    required this.active,
    this.createdAt,
    Set<ClassroomFeature>? enabledFeatures,
  }) : enabledFeatures = enabledFeatures ?? ClassroomFeature.allEnabled();

  bool isFeatureEnabled(ClassroomFeature feature) {
    return enabledFeatures.contains(feature);
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'classroomCode': classroomCode,
      'pin': pin,
      'active': active,
      'createdAt': createdAt,
      'enabledFeatures': ClassroomFeature.toFirestoreValue(enabledFeatures),
    };
  }

  factory Classroom.fromMap(String id, Map<String, dynamic> map) {
    return Classroom(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      classroomCode: map['classroomCode'] ?? '',
      pin: map['pin'] ?? '',
      active: map['active'] ?? true,
      createdAt: map['createdAt']?.toDate(),
      enabledFeatures: ClassroomFeature.fromFirestoreValue(
        map['enabledFeatures'],
      ),
    );
  }

  Classroom copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? classroomCode,
    String? pin,
    bool? active,
    DateTime? createdAt,
    Set<ClassroomFeature>? enabledFeatures,
  }) {
    return Classroom(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      classroomCode: classroomCode ?? this.classroomCode,
      pin: pin ?? this.pin,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
    );
  }
}
