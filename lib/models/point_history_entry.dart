import 'package:cloud_firestore/cloud_firestore.dart';

class PointHistoryEntry {
  final String id;
  final String childId;
  final int amount;
  final int balanceAfter;
  final String reason;
  final String note;
  final DateTime? createdAt;

  const PointHistoryEntry({
    required this.id,
    required this.childId,
    required this.amount,
    required this.balanceAfter,
    required this.reason,
    required this.note,
    this.createdAt,
  });

  factory PointHistoryEntry.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final createdAtValue = map['createdAt'];

    return PointHistoryEntry(
      id: id,
      childId: map['childId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      balanceAfter:
          (map['balanceAfter'] as num?)?.toInt() ?? 0,
      reason: map['reason'] as String? ?? '',
      note: map['note'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : null,
    );
  }
}