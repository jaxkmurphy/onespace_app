import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'classroom_session_service.dart';
import 'firestore/admin_firestore_service.dart';
import 'firestore/classroom_firestore_service.dart';
import 'firestore/firestore_base.dart';
import 'firestore/handover_firestore_service.dart';
import 'firestore/learning_firestore_service.dart';
import 'firestore/profile_firestore_service.dart';
import 'firestore/wellbeing_firestore_service.dart';

class FirestoreService
    with
        FirestoreBase,
        ProfileFirestoreService,
        WellbeingFirestoreService,
        ClassroomFirestoreService,
        LearningFirestoreService,
        HandoverFirestoreService,
        AdminFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final ClassroomSessionService _session = ClassroomSessionService.instance;

  @override
  FirebaseFirestore get db => _db;

  @override
  ClassroomSessionService get session => _session;

  @override
  bool get hasClassroomSession => _session.hasClassroomSession;

  @override
  String get currentTeacherUid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No logged-in Firebase user found.');
    }

    return user.uid;
  }

  @override
  Future<void> restoreClassroomSessionFromAuthIfNeeded() async {
    if (_session.hasClassroomSession) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims ?? {};

      if (claims['role'] == 'classroom' &&
          claims['schoolId'] is String &&
          claims['classroomId'] is String) {
        final schoolId = claims['schoolId'] as String;
        final classroomId = claims['classroomId'] as String;

        final classroom = await getClassroom(
          schoolId: schoolId,
          classroomId: classroomId,
        );

        if (classroom != null && classroom.active) {
          _session.setSession(
            schoolId: schoolId,
            classroomId: classroomId,
            classroomName: classroom.name,
          );
        }
      }
    } catch (e) {
      debugPrint('Could not restore classroom session: $e');
    }
  }
}