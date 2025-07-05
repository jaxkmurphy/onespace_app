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
import 'pages/quiz_creation_page.dart';
import 'pages/quiz_list_page.dart';
import 'pages/quiz_play_page.dart';
import 'pages/student_quiz_list_page.dart';
import 'models/quiz.dart';
import 'services/firestore_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSpace App',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ga'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(onLocaleChange: _setLocale),  
        '/profiles': (context) => ProfilesPage(onLocaleChange: _setLocale),
        '/account-settings': (context) => AccountSettingsPage(onLocaleChange: _setLocale),  
        '/add-profile': (context) => const AddProfilePage(),
        '/staffSchedule': (context) => const StaffSchedulePage(),
        '/childSchedule': (context) => const ChildSchedulePage(),
        '/child-dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is ChildProfile) {
            return ChildProfileDashboard(
              profile: args,
              firestoreService: FirestoreService(),
            );
          }
          return const Scaffold(body: Center(child: Text('Missing child profile')));
        },
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
        } else if (settings.name == '/quiz-create') {
          final args = settings.arguments;
          if (args is StaffProfile) {
            return MaterialPageRoute(
              builder: (context) => QuizCreationPage(staffUid: args.teacherUid),
            );
          }
        } else if (settings.name == '/quiz-list') {
          final args = settings.arguments;
          if (args is String) {
            return MaterialPageRoute(
              builder: (context) => QuizListPage(teacherUid: args),
            );
          }
        } else if (settings.name == '/quiz-play') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['quiz'] is Quiz) {
            return MaterialPageRoute(
              builder: (context) => QuizPlayPage(
                quiz: args['quiz'],
                childProfile: args['childProfile'] as ChildProfile?,
              ),
            );
          }
        } else if (settings.name == '/student-quiz-list') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final firestoreService = args['firestoreService'] as FirestoreService?;
            final child = args['child'] as ChildProfile?;
            if (firestoreService != null && child != null) {
              return MaterialPageRoute(
                builder: (context) => StudentQuizListPage(
                  firestoreService: firestoreService,
                  child: child,
                ),
              );
            }
          }
        }

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