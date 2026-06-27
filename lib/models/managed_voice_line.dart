import 'package:cloud_firestore/cloud_firestore.dart';

class ManagedVoiceLine {
  final String id;
  final String presetKey;
  final String labelEN;
  final String labelGA;
  final String spokenEN;
  final String spokenGA;
  final String iconName;
  final String colorHex;
  final bool active;
  final int sortOrder;
  final String createdByStaffId;
  final String createdByStaffName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ManagedVoiceLine({
    required this.id,
    this.presetKey = '',
    required this.labelEN,
    required this.labelGA,
    required this.spokenEN,
    required this.spokenGA,
    required this.iconName,
    required this.colorHex,
    required this.active,
    required this.sortOrder,
    required this.createdByStaffId,
    required this.createdByStaffName,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'labelEN': labelEN,
      'presetKey': presetKey,
      'labelGA': labelGA,
      'spokenEN': spokenEN,
      'spokenGA': spokenGA,
      'iconName': iconName,
      'colorHex': colorHex,
      'active': active,
      'sortOrder': sortOrder,
      'createdByStaffId': createdByStaffId,
      'createdByStaffName': createdByStaffName,
    };
  }

  factory ManagedVoiceLine.fromMap(String id, Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    final updatedAtValue = map['updatedAt'];

    return ManagedVoiceLine(
      id: id,
      presetKey: map['presetKey'] as String? ?? '',
      labelEN: map['labelEN'] as String? ?? '',
      labelGA: map['labelGA'] as String? ?? '',
      spokenEN: map['spokenEN'] as String? ?? '',
      spokenGA: map['spokenGA'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'voice',
      colorHex: map['colorHex'] as String? ?? '#7E57C2',
      active: map['active'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      createdByStaffId: map['createdByStaffId'] as String? ?? '',
      createdByStaffName: map['createdByStaffName'] as String? ?? '',
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }

  ManagedVoiceLine copyWith({
    String? id,
    String? presetKey,
    String? labelEN,
    String? labelGA,
    String? spokenEN,
    String? spokenGA,
    String? iconName,
    String? colorHex,
    bool? active,
    int? sortOrder,
    String? createdByStaffId,
    String? createdByStaffName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagedVoiceLine(
      id: id ?? this.id,
      presetKey: presetKey ?? this.presetKey,
      labelEN: labelEN ?? this.labelEN,
      labelGA: labelGA ?? this.labelGA,
      spokenEN: spokenEN ?? this.spokenEN,
      spokenGA: spokenGA ?? this.spokenGA,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      createdByStaffId: createdByStaffId ?? this.createdByStaffId,
      createdByStaffName: createdByStaffName ?? this.createdByStaffName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
