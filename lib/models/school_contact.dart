import 'package:cloud_firestore/cloud_firestore.dart';

enum SchoolContactType {
  staff('staff'),
  guardian('guardian');

  final String value;

  const SchoolContactType(this.value);

  static SchoolContactType fromValue(String? value) {
    return SchoolContactType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SchoolContactType.guardian,
    );
  }
}

class SchoolContact {
  final String id;
  final String schoolId;
  final SchoolContactType type;
  final String name;
  final String email;
  final bool active;
  final String classroomId;
  final String classroomName;
  final String childId;
  final String childName;
  final String staffProfileId;
  final String staffProfileName;
  final String relationship;
  final String role;
  final bool canReceiveReports;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SchoolContact({
    required this.id,
    required this.schoolId,
    required this.type,
    required this.name,
    required this.email,
    this.active = true,
    this.classroomId = '',
    this.classroomName = '',
    this.childId = '',
    this.childName = '',
    this.staffProfileId = '',
    this.staffProfileName = '',
    this.relationship = '',
    this.role = '',
    this.canReceiveReports = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolContact.fromMap(String id, Map<String, dynamic> data) {
    return SchoolContact(
      id: id,
      schoolId: data['schoolId'] ?? '',
      type: SchoolContactType.fromValue(data['type']),
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      active: data['active'] != false,
      classroomId: data['classroomId'] ?? '',
      classroomName: data['classroomName'] ?? '',
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      staffProfileId: data['staffProfileId'] ?? '',
      staffProfileName: data['staffProfileName'] ?? '',
      relationship: data['relationship'] ?? '',
      role: data['role'] ?? '',
      canReceiveReports: data['canReceiveReports'] != false,
      createdAt:
          data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'schoolId': schoolId,
      'type': type.value,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'active': active,
      'classroomId': classroomId,
      'classroomName': classroomName,
      'childId': childId,
      'childName': childName,
      'staffProfileId': staffProfileId,
      'staffProfileName': staffProfileName,
      'relationship': relationship.trim(),
      'role': role.trim(),
      'canReceiveReports': canReceiveReports,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'schoolId': schoolId,
      'type': type.value,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'active': active,
      'classroomId': classroomId,
      'classroomName': classroomName,
      'childId': childId,
      'childName': childName,
      'staffProfileId': staffProfileId,
      'staffProfileName': staffProfileName,
      'relationship': relationship.trim(),
      'role': role.trim(),
      'canReceiveReports': canReceiveReports,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isStaff => type == SchoolContactType.staff;
  bool get isGuardian => type == SchoolContactType.guardian;

  SchoolContact copyWith({
    String? id,
    String? schoolId,
    SchoolContactType? type,
    String? name,
    String? email,
    bool? active,
    String? classroomId,
    String? classroomName,
    String? childId,
    String? childName,
    String? staffProfileId,
    String? staffProfileName,
    String? relationship,
    String? role,
    bool? canReceiveReports,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolContact(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      active: active ?? this.active,
      classroomId: classroomId ?? this.classroomId,
      classroomName: classroomName ?? this.classroomName,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      staffProfileName: staffProfileName ?? this.staffProfileName,
      relationship: relationship ?? this.relationship,
      role: role ?? this.role,
      canReceiveReports: canReceiveReports ?? this.canReceiveReports,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
