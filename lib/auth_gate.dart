import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'models/school.dart';
import 'models/school_member.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/profiles_page.dart';
import 'services/classroom_session_service.dart';
import 'services/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _getStartPage(User user) async {
    final firestoreService = FirestoreService();
    final session = ClassroomSessionService.instance;

    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims ?? {};

    if (claims['role'] == 'classroom' &&
        claims['schoolId'] is String &&
        claims['classroomId'] is String) {
      final schoolId = claims['schoolId'] as String;
      final classroomId = claims['classroomId'] as String;

      final classroom = await firestoreService.getClassroom(
        schoolId: schoolId,
        classroomId: classroomId,
      );

      if (classroom != null && classroom.active) {
        session.setSession(
          schoolId: schoolId,
          classroomId: classroomId,
          classroomName: classroom.name,
        );

        return const ProfilesPage();
      }
    }

    final SchoolMember? member =
        await firestoreService.getSchoolMemberByUid(user.uid);

    if (member != null && member.active && member.role == 'schoolAdmin') {
      final School? school = await firestoreService.getSchool(member.schoolId);

      if (school != null && school.active) {
        session.clearSession();

        return AdminDashboardPage(
          schoolId: school.id,
          schoolName: school.name,
        );
      }
    }

    session.clearSession();

    return const ProfilesPage();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          ClassroomSessionService.instance.clearSession();
          return const LoginScreen();
        }

        return FutureBuilder<Widget>(
          future: _getStartPage(user),
          builder: (context, pageSnapshot) {
            if (pageSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (pageSnapshot.hasError) {
              ClassroomSessionService.instance.clearSession();
              return const ProfilesPage();
            }

            return pageSnapshot.data ?? const LoginScreen();
          },
        );
      },
    );
  }
}