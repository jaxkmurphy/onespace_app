import 'package:cloud_firestore/cloud_firestore.dart';

class StaffHandoverDocument {
  final String staffProfileId;
  final String staffName;
  final String aboutThisClass;
  final String whatWorksWell;
  final String commonTriggers;
  final String successfulStrategies;
  final String communicationTips;
  final String otherNotes;
  final DateTime? updatedAt;

  StaffHandoverDocument({
    required this.staffProfileId,
    required this.staffName,
    this.aboutThisClass = '',
    this.whatWorksWell = '',
    this.commonTriggers = '',
    this.successfulStrategies = '',
    this.communicationTips = '',
    this.otherNotes = '',
    this.updatedAt,
  });

  factory StaffHandoverDocument.empty({
    required String staffProfileId,
    required String staffName,
  }) {
    return StaffHandoverDocument(
      staffProfileId: staffProfileId,
      staffName: staffName,
    );
  }

  factory StaffHandoverDocument.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return StaffHandoverDocument(
      staffProfileId: id,
      staffName: data['staffName'] ?? '',
      aboutThisClass: data['aboutThisClass'] ?? '',
      whatWorksWell: data['whatWorksWell'] ?? '',
      commonTriggers: data['commonTriggers'] ?? '',
      successfulStrategies: data['successfulStrategies'] ?? '',
      communicationTips: data['communicationTips'] ?? '',
      otherNotes: data['otherNotes'] ?? '',
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffName': staffName,
      'aboutThisClass': aboutThisClass,
      'whatWorksWell': whatWorksWell,
      'commonTriggers': commonTriggers,
      'successfulStrategies': successfulStrategies,
      'communicationTips': communicationTips,
      'otherNotes': otherNotes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}