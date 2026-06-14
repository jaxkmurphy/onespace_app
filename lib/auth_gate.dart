import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'models/school.dart';
import 'models/school_member.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/profiles_page.dart';
import 'services/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _getStartPage(User user) async {
    final firestoreService = FirestoreService();

    final SchoolMember? member =
        await firestoreService.getSchoolMemberByUid(user.uid);

    if (member != null && member.active && member.role == 'schoolAdmin') {
      final School? school = await firestoreService.getSchool(member.schoolId);

      if (school != null && school.active) {
        return AdminDashboardPage(
          schoolId: school.id,
          schoolName: school.name,
        );
      }
    }

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
              return const ProfilesPage();
            }

            return pageSnapshot.data ?? const LoginScreen();
          },
        );
      },
    );
  }
}