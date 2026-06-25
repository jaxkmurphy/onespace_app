import 'firestore_base.dart';

mixin ChildAccessFirestoreService on FirestoreBase {
  Future<void> setCurrentChildProfileAccess({
    required String childId,
    required bool enabled,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final update = <String, dynamic>{'profileAccessEnabled': enabled};

    if (!enabled) {
      update['profileAccessRevokedAtMillis'] =
          DateTime.now().millisecondsSinceEpoch;
    }

    await currentChildDoc(childId).update(update);
  }

  Future<void> setAllCurrentChildProfileAccess({required bool enabled}) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    final snapshot = await currentChildProfilesRef().get();

    if (snapshot.docs.isEmpty) return;

    final batch = db.batch();
    final revokedAtMillis = DateTime.now().millisecondsSinceEpoch;

    for (final doc in snapshot.docs) {
      final update = <String, dynamic>{'profileAccessEnabled': enabled};

      if (!enabled) {
        update['profileAccessRevokedAtMillis'] = revokedAtMillis;
      }

      batch.update(doc.reference, update);
    }

    await batch.commit();
  }

  Future<void> kickCurrentChildProfileOut(String childId) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentChildDoc(childId).update({
      'profileAccessEnabled': true,
      'profileAccessRevokedAtMillis': DateTime.now().millisecondsSinceEpoch,
    });
  }
}