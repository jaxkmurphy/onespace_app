import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/managed_voice_line.dart';
import 'firestore_base.dart';

mixin VoiceLineFirestoreService on FirestoreBase {
  CollectionReference<Map<String, dynamic>> _currentVoiceLinesRef() {
    return currentCollection('voice_lines');
  }

  Stream<List<ManagedVoiceLine>> getCurrentVoiceLines({
    bool activeOnly = false,
  }) {
    return _currentVoiceLinesRef().snapshots().map((snapshot) {
      final lines =
          snapshot.docs
              .map((doc) => ManagedVoiceLine.fromMap(doc.id, doc.data()))
              .where((line) => !activeOnly || line.active)
              .toList();

      lines.sort((first, second) {
        if (first.active != second.active) {
          return first.active ? -1 : 1;
        }

        final orderComparison = first.sortOrder.compareTo(second.sortOrder);
        if (orderComparison != 0) return orderComparison;

        return first.labelEN.compareTo(second.labelEN);
      });

      return lines;
    });
  }

  Future<String> addCurrentVoiceLine(ManagedVoiceLine line) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final docRef = _currentVoiceLinesRef().doc();

    await docRef.set({
      ...line.copyWith(id: docRef.id).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateCurrentVoiceLine(ManagedVoiceLine line) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _currentVoiceLinesRef().doc(line.id).update({
      ...line.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setCurrentVoiceLineActive({
    required String voiceLineId,
    required bool active,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _currentVoiceLinesRef().doc(voiceLineId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCurrentVoiceLine(String voiceLineId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await _currentVoiceLinesRef().doc(voiceLineId).delete();
  }
}
