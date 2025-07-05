import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'pages/profiles_page.dart';

class AuthGate extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const AuthGate({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return ProfilesPage(onLocaleChange: onLocaleChange);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}