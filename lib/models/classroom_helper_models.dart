import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomHelperJob {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool active;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClassroomHelperJob({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.active,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ClassroomHelperJob.fromMap(String id, Map<String, dynamic> data) {
    return ClassroomHelperJob(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'star',
      active: data['active'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'active': active,
      'sortOrder': sortOrder,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  ClassroomHelperJob copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    bool? active,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassroomHelperJob(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ClassroomHelperCompletion {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobIconName;
  final String childId;
  final String childName;
  final String confirmedByStaffId;
  final String confirmedByStaffName;
  final DateTime? createdAt;
  final DateTime? confirmedAt;

  const ClassroomHelperCompletion({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobIconName,
    required this.childId,
    required this.childName,
    required this.confirmedByStaffId,
    required this.confirmedByStaffName,
    this.createdAt,
    this.confirmedAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ClassroomHelperCompletion.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ClassroomHelperCompletion(
      id: id,
      jobId: data['jobId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      jobIconName: data['jobIconName'] as String? ?? 'star',
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      confirmedByStaffId: data['confirmedByStaffId'] as String? ?? '',
      confirmedByStaffName: data['confirmedByStaffName'] as String? ?? '',
      createdAt: _dateFromValue(data['createdAt']),
      confirmedAt: _dateFromValue(data['confirmedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobIconName': jobIconName,
      'childId': childId,
      'childName': childName,
      'confirmedByStaffId': confirmedByStaffId,
      'confirmedByStaffName': confirmedByStaffName,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
    };
  }
}

class ClassroomHelperAssignment {
  final String id;
  final String childId;
  final String childName;
  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final String jobIconName;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String assignedByStaffId;
  final String assignedByStaffName;
  final String status;

  const ClassroomHelperAssignment({
    required this.id,
    required this.childId,
    required this.childName,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.jobIconName,
    this.assignedAt,
    this.completedAt,
    required this.assignedByStaffId,
    required this.assignedByStaffName,
    this.status = 'assigned',
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ClassroomHelperAssignment.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ClassroomHelperAssignment(
      id: id,
      childId: data['childId'] as String? ?? id,
      childName: data['childName'] as String? ?? '',
      jobId: data['jobId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      jobDescription: data['jobDescription'] as String? ?? '',
      jobIconName: data['jobIconName'] as String? ?? 'star',
      assignedAt: _dateFromValue(data['assignedAt']),
      completedAt: _dateFromValue(data['completedAt']),
      assignedByStaffId: data['assignedByStaffId'] as String? ?? '',
      assignedByStaffName: data['assignedByStaffName'] as String? ?? '',
      status: data['status'] as String? ?? 'assigned',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'childName': childName,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'jobIconName': jobIconName,
      if (assignedAt != null) 'assignedAt': Timestamp.fromDate(assignedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'assignedByStaffId': assignedByStaffId,
      'assignedByStaffName': assignedByStaffName,
      'status': status,
    };
  }

  bool get isActive => status != 'completed' && status != 'cleared';
}

enum ClassroomHelperRequestStatus {
  pending('pending'),
  confirmed('confirmed'),
  cleared('cleared');

  final String value;

  const ClassroomHelperRequestStatus(this.value);

  static ClassroomHelperRequestStatus fromValue(String? value) {
    return ClassroomHelperRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ClassroomHelperRequestStatus.pending,
    );
  }
}

class ClassroomHelperCompletionRequest {
  final String id;
  final String assignmentId;
  final String jobId;
  final String jobTitle;
  final String jobIconName;
  final String childId;
  final String childName;
  final ClassroomHelperRequestStatus status;
  final DateTime? requestedAt;
  final DateTime? resolvedAt;
  final String resolvedByStaffId;
  final String resolvedByStaffName;

  const ClassroomHelperCompletionRequest({
    required this.id,
    required this.assignmentId,
    required this.jobId,
    required this.jobTitle,
    required this.jobIconName,
    required this.childId,
    required this.childName,
    required this.status,
    this.requestedAt,
    this.resolvedAt,
    required this.resolvedByStaffId,
    required this.resolvedByStaffName,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ClassroomHelperCompletionRequest.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ClassroomHelperCompletionRequest(
      id: id,
      assignmentId: data['assignmentId'] as String? ?? '',
      jobId: data['jobId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      jobIconName: data['jobIconName'] as String? ?? 'star',
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      status: ClassroomHelperRequestStatus.fromValue(data['status'] as String?),
      requestedAt: _dateFromValue(data['requestedAt']),
      resolvedAt: _dateFromValue(data['resolvedAt']),
      resolvedByStaffId: data['resolvedByStaffId'] as String? ?? '',
      resolvedByStaffName: data['resolvedByStaffName'] as String? ?? '',
    );
  }
}

const List<ClassroomHelperJob> defaultClassroomHelperJobs = [
  ClassroomHelperJob(
    id: 'line-leader',
    title: 'Line leader',
    description: 'Help the class line up safely.',
    iconName: 'walk',
    active: true,
    sortOrder: 0,
  ),
  ClassroomHelperJob(
    id: 'door-helper',
    title: 'Door helper',
    description: 'Help open and close the classroom door.',
    iconName: 'door',
    active: true,
    sortOrder: 1,
  ),
  ClassroomHelperJob(
    id: 'tidy-helper',
    title: 'Tidy helper',
    description: 'Help put things back where they belong.',
    iconName: 'sparkles',
    active: true,
    sortOrder: 2,
  ),
  ClassroomHelperJob(
    id: 'paper-helper',
    title: 'Paper helper',
    description: 'Help hand out or collect classroom papers.',
    iconName: 'clipboard',
    active: true,
    sortOrder: 3,
  ),
  ClassroomHelperJob(
    id: 'plant-helper',
    title: 'Plant helper',
    description: 'Help look after the classroom plants.',
    iconName: 'plant',
    active: true,
    sortOrder: 4,
  ),
  ClassroomHelperJob(
    id: 'kindness-helper',
    title: 'Kindness helper',
    description: 'Notice kind choices and friendly moments.',
    iconName: 'heart',
    active: true,
    sortOrder: 5,
  ),
];
