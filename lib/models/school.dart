class School {
  final String id;
  final String name;
  final String schoolCode;
  final int classroomLimit;
  final bool active;
  final DateTime? createdAt;

  final String principalName;
  final String vicePrincipalName;
  final String schoolEmail;
  final String phoneNumber;
  final String address;

  School({
    required this.id,
    required this.name,
    required this.schoolCode,
    required this.classroomLimit,
    required this.active,
    this.createdAt,
    this.principalName = '',
    this.vicePrincipalName = '',
    this.schoolEmail = '',
    this.phoneNumber = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'schoolCode': schoolCode,
      'classroomLimit': classroomLimit,
      'active': active,
      'createdAt': createdAt,
      'principalName': principalName,
      'vicePrincipalName': vicePrincipalName,
      'schoolEmail': schoolEmail,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory School.fromMap(String id, Map<String, dynamic> map) {
    return School(
      id: id,
      name: map['name'] ?? '',
      schoolCode: map['schoolCode'] ?? '',
      classroomLimit: map['classroomLimit'] ?? 3,
      active: map['active'] ?? true,
      createdAt: map['createdAt']?.toDate(),
      principalName: map['principalName'] ?? '',
      vicePrincipalName: map['vicePrincipalName'] ?? '',
      schoolEmail: map['schoolEmail'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
    );
  }

  School copyWith({
    String? id,
    String? name,
    String? schoolCode,
    int? classroomLimit,
    bool? active,
    DateTime? createdAt,
    String? principalName,
    String? vicePrincipalName,
    String? schoolEmail,
    String? phoneNumber,
    String? address,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolCode: schoolCode ?? this.schoolCode,
      classroomLimit: classroomLimit ?? this.classroomLimit,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      principalName: principalName ?? this.principalName,
      vicePrincipalName: vicePrincipalName ?? this.vicePrincipalName,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }
}