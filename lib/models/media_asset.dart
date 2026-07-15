import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaAssetType {
  image('image'),
  audio('audio'),
  document('document');

  final String value;

  const MediaAssetType(this.value);

  static MediaAssetType fromValue(String? value) {
    return MediaAssetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MediaAssetType.image,
    );
  }
}

enum MediaAssetCategory {
  visualSupport('visualSupport'),
  wordLearningImage('wordLearningImage'),
  learningGameImage('learningGameImage'),
  scheduleImage('scheduleImage'),
  rewardImage('rewardImage'),
  calmingSound('calmingSound'),
  classroomCue('classroomCue'),
  guideline('guideline'),
  classroomDocument('classroomDocument'),
  other('other');

  final String value;

  const MediaAssetCategory(this.value);

  static MediaAssetCategory fromValue(String? value) {
    return MediaAssetCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => MediaAssetCategory.other,
    );
  }
}

class MediaAsset {
  final String id;
  final String schoolId;
  final String classroomId;
  final String name;
  final String description;
  final MediaAssetType type;
  final MediaAssetCategory category;
  final String fileName;
  final String contentType;
  final String storagePath;
  final String downloadUrl;
  final int sizeBytes;
  final bool active;
  final String uploadedByStaffId;
  final String uploadedByStaffName;
  final String calmingSoundCategoryId;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MediaAsset({
    required this.id,
    required this.schoolId,
    required this.classroomId,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.fileName,
    required this.contentType,
    required this.storagePath,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.active,
    required this.uploadedByStaffId,
    required this.uploadedByStaffName,
    this.calmingSoundCategoryId = '',
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isImage => type == MediaAssetType.image;
  bool get isAudio => type == MediaAssetType.audio;
  bool get isDocument => type == MediaAssetType.document;

  factory MediaAsset.fromMap(String id, Map<String, dynamic> data) {
    DateTime? dateFromValue(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      return null;
    }

    return MediaAsset(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      classroomId: data['classroomId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: MediaAssetType.fromValue(data['type'] as String?),
      category: MediaAssetCategory.fromValue(data['category'] as String?),
      fileName: data['fileName'] as String? ?? '',
      contentType: data['contentType'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      sizeBytes: data['sizeBytes'] as int? ?? 0,
      active: data['active'] != false,
      uploadedByStaffId: data['uploadedByStaffId'] as String? ?? '',
      uploadedByStaffName: data['uploadedByStaffName'] as String? ?? '',
      calmingSoundCategoryId:
          data['calmingSoundCategoryId'] as String? ?? 'ocean',
      sortOrder: data['sortOrder'] as int? ?? 0,
      createdAt: dateFromValue(data['createdAt']),
      updatedAt: dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'schoolId': schoolId,
      'classroomId': classroomId,
      'name': name.trim(),
      'description': description.trim(),
      'type': type.value,
      'category': category.value,
      'fileName': fileName,
      'contentType': contentType,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'sizeBytes': sizeBytes,
      'active': active,
      'uploadedByStaffId': uploadedByStaffId,
      'uploadedByStaffName': uploadedByStaffName,
      'calmingSoundCategoryId': calmingSoundCategoryId,
      'sortOrder': sortOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      'category': category.value,
      'active': active,
      'calmingSoundCategoryId': calmingSoundCategoryId,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MediaAsset copyWith({
    String? id,
    String? schoolId,
    String? classroomId,
    String? name,
    String? description,
    MediaAssetType? type,
    MediaAssetCategory? category,
    String? fileName,
    String? contentType,
    String? storagePath,
    String? downloadUrl,
    int? sizeBytes,
    bool? active,
    String? uploadedByStaffId,
    String? uploadedByStaffName,
    String? calmingSoundCategoryId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classroomId: classroomId ?? this.classroomId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      active: active ?? this.active,
      uploadedByStaffId: uploadedByStaffId ?? this.uploadedByStaffId,
      uploadedByStaffName: uploadedByStaffName ?? this.uploadedByStaffName,
      calmingSoundCategoryId:
          calmingSoundCategoryId ?? this.calmingSoundCategoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
