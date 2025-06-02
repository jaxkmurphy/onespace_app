import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'pages/profiles_page.dart';
import 'pages/account_settings_page.dart';
import 'pages/add_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/zones_overview_page.dart';
import 'pages/zone_selection_page.dart';
import 'models/staff_profile.dart';
import 'models/child_profile.dart';
import 'pages/staff_profile_dashboard.dart';
import 'pages/child_profile_dashboard.dart';
import 'pages/points_overview_page.dart';
import 'pages/child_points_page.dart'; 
import 'pages/staff_schedule_page.dart';
import 'pages/child_schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await FirebaseFirestore.instance.clearPersistence();
    await FirebaseFirestore.instance.disableNetwork();
    await FirebaseFirestore.instance.enableNetwork();
    debugPrint("Firestore cache cleared and network reset.");
  } catch (e) {
    debugPrint("Error during Firestore prep: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSpace App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/profiles': (context) => ProfilesPage(),
        '/account-settings': (context) => const AccountSettingsPage(),
        '/add-profile': (context) => const AddProfilePage(),
        '/staffSchedule': (context) => const StaffSchedulePage(),
        '/childSchedule': (context) => const ChildSchedulePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/zone-overview') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['teacherUid'] != null) {
            final teacherUid = args['teacherUid'] as String;
            return MaterialPageRoute(
              builder: (context) => ZoneOverviewPage(teacherUid: teacherUid),
            );
          }
        } else if (settings.name == '/zone-select') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> &&
              args['teacherUid'] != null &&
              args['child'] is ChildProfile) {
            final teacherUid = args['teacherUid'] as String;
            final child = args['child'] as ChildProfile;
            return MaterialPageRoute(
              builder: (context) => ZoneSelectionPage(
                teacherUid: teacherUid,
                child: child,
              ),
            );
          }
        } else if (settings.name == '/staff-dashboard') {
          final args = settings.arguments;
          if (args is StaffProfile) {
            return MaterialPageRoute(
              builder: (context) => StaffProfileDashboard(profile: args),
            );
          }
        } else if (settings.name == '/child-dashboard') {
          final args = settings.arguments;
          if (args is ChildProfile) {
            return MaterialPageRoute(
              builder: (context) => ChildProfileDashboard(profile: args),
            );
          }
        } else if (settings.name == '/points-overview') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> &&
              args['teacherUid'] != null &&
              args['children'] is List) {

            return MaterialPageRoute(
              builder: (context) => PointsOverviewPage(
              teacherUid: args['teacherUid'],
            ),
          );
          }
        } else if (settings.name == '/child-points') {
          final args = settings.arguments;
          if (args is ChildProfile) {
            return MaterialPageRoute(
              builder: (context) => ChildPointsPage(child: args),
            );
          }
        }

        // Fallback for unknown routes or missing arguments
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: const Center(
              child: Text("Invalid route or missing arguments."),
            ),
          ),
        );
      },
    );
  }
}