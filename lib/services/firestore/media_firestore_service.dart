import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/media_asset.dart';
import 'firestore_base.dart';

mixin MediaFirestoreService on FirestoreBase {
  CollectionReference<Map<String, dynamic>> currentMediaAssetsRef() {
    return currentCollection('media_assets');
  }

  String _safeFileName(String fileName) {
    final trimmed = fileName.trim();

    if (trimmed.isEmpty) {
      return 'upload';
    }

    return trimmed.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  void _ensureClassroomMediaContext() {
    if (!hasClassroomSession) {
      throw StateError('Media Library requires an active classroom session.');
    }
  }

  String _currentMediaStoragePath({
    required String assetId,
    required String fileName,
  }) {
    _ensureClassroomMediaContext();

    final schoolId = session.requireSchoolId;
    final classroomId = session.requireClassroomId;
    final safeName = _safeFileName(fileName);

    return 'schools/$schoolId/classrooms/$classroomId/media/$assetId/$safeName';
  }

  Stream<List<MediaAsset>> getCurrentMediaAssets({
    MediaAssetType? type,
    MediaAssetCategory? category,
    bool activeOnly = false,
  }) {
    return currentMediaAssetsRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final assets =
              snapshot.docs
                  .map((doc) => MediaAsset.fromMap(doc.id, doc.data()))
                  .where((asset) {
                    if (type != null && asset.type != type) {
                      return false;
                    }

                    if (category != null && asset.category != category) {
                      return false;
                    }

                    if (activeOnly && !asset.active) {
                      return false;
                    }

                    return true;
                  })
                  .toList();

          assets.sort((first, second) {
            if (first.active != second.active) {
              return first.active ? -1 : 1;
            }

            final firstDate =
                first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final secondDate =
                second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return secondDate.compareTo(firstDate);
          });

          return assets;
        });
  }

  Future<MediaAsset> uploadCurrentMediaAsset({
    required String name,
    required String description,
    required MediaAssetType type,
    required MediaAssetCategory category,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required Uint8List bytes,
    required String uploadedByStaffId,
    required String uploadedByStaffName,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();
    _ensureClassroomMediaContext();

    final assetDoc = currentMediaAssetsRef().doc();
    final assetId = assetDoc.id;
    final storagePath = _currentMediaStoragePath(
      assetId: assetId,
      fileName: fileName,
    );

    final storageRef = FirebaseStorage.instance.ref(storagePath);

    await storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'schoolId': session.requireSchoolId,
          'classroomId': session.requireClassroomId,
          'assetId': assetId,
        },
      ),
    );

    final downloadUrl = await storageRef.getDownloadURL();

    final asset = MediaAsset(
      id: assetId,
      schoolId: session.requireSchoolId,
      classroomId: session.requireClassroomId,
      name: name,
      description: description,
      type: type,
      category: category,
      fileName: _safeFileName(fileName),
      contentType: contentType,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      sizeBytes: sizeBytes,
      active: true,
      uploadedByStaffId: uploadedByStaffId,
      uploadedByStaffName: uploadedByStaffName,
    );

    await assetDoc.set(asset.toCreateMap());

    return asset;
  }

  Future<void> updateCurrentMediaAsset(MediaAsset asset) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentMediaAssetsRef().doc(asset.id).update(asset.toUpdateMap());
  }

  Future<void> setCurrentMediaAssetActive({
    required String assetId,
    required bool active,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    await currentMediaAssetsRef().doc(assetId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCurrentMediaAsset({
    required String assetId,
    required String storagePath,
  }) async {
    await restoreClassroomSessionFromAuthIfNeeded();

    if (storagePath.trim().isNotEmpty) {
      await FirebaseStorage.instance.ref(storagePath).delete();
    }

    await currentMediaAssetsRef().doc(assetId).delete();
  }
}
