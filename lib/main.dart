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
import 'locale_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/voice_lines_page.dart';
import 'pages/icon_reset_page.dart';
import 'pages/visual_timer_page.dart';
import 'pages/first_then_setup_page.dart';
import 'pages/first_then_child_page.dart';
import 'pages/handover_hub_page.dart';
import 'pages/circle_time_page.dart';
import 'pages/body_check_page.dart';
import 'pages/body_check_overview_page.dart';
import 'theme/app_theme.dart';

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
  final LocaleNotifier localeNotifier = LocaleNotifier(const Locale('en'));

  @override
  void dispose() {
    localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
      title: 'OneSpace App',
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [
        Locale('en'), 
    ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
    ],
      localeResolutionCallback: (locale, supportedLocales) {
      return const Locale('en'); // force Flutter's internal UI to use English
    },

          initialRoute: '/',
          routes: {
            '/': (context) => const AuthGate(),
            '/profiles': (context) => const ProfilesPage(),
            '/account-settings': (context) => AccountSettingsPage(locale: locale,onLocaleChange: localeNotifier.changeLocale,),
            '/add-profile': (context) => const AddProfilePage(),
            '/staffSchedule': (context) => const StaffSchedulePage(),
            '/childSchedule': (context) => const ChildSchedulePage(),
            '/visual-timer': (context) => const VisualTimerPage(),
            '/child-dashboard': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is ChildProfile) {
            return ChildProfileDashboard(
              profile: args,
              firestoreService: FirestoreService(),
              localeNotifier: localeNotifier,
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
                  builder: (context) => StaffProfileDashboard(
                  profile: args,
                  localeNotifier: localeNotifier,
                  ),
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
            } else if (settings.name == '/voice-lines') {
              final args = settings.arguments;
              if (args is Map<String, dynamic>) {
              final firestoreService = args['firestoreService'] as FirestoreService?;
              final child = args['child'] as ChildProfile?;
                if (firestoreService != null && child != null) {
                  return MaterialPageRoute(
                    builder: (context) => VoiceLinesPage(
                      firestoreService: firestoreService,
                      child: child,
                    ),
                  );
                }
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
            } else if (settings.name == '/icon-reset') {
              final args = settings.arguments;
              if (args is String) {
                return MaterialPageRoute(
                  builder: (context) => IconResetPage(teacherUid: args),
                  );
                }
            } else if (settings.name == '/first-then-setup') {
              final args = settings.arguments;
              if (args is String) {
                return MaterialPageRoute(
                  builder: (context) => FirstThenSetupPage(
                    teacherUid: args,
                  ),
                );
              }
            } else if (settings.name == '/first-then-child') {
              final args = settings.arguments;
              if (args is Map<String, dynamic>) {
                final firestoreService =
                    args['firestoreService'] as FirestoreService?;
                final child = args['child'] as ChildProfile?;
                if (firestoreService != null && child != null) {
                  return MaterialPageRoute(
                    builder: (context) => FirstThenChildPage(
                      firestoreService: firestoreService,
                      child: child,
                    ),
                  );
                }
              }
            } else if (settings.name == '/circle-time') {
              final args = settings.arguments;
              if (args is Map<String, dynamic>) {
              final teacherUid = args['teacherUid'] as String?;
              final child = args['child'] as ChildProfile?;
              if (teacherUid != null) {
                return MaterialPageRoute(
                  builder: (context) => CircleTimePage(
                    teacherUid: teacherUid,
                    childProfile: child,
                    ),
                  );
                }
              } 
            }else if (settings.name == '/handover-hub') {
              final args = settings.arguments;
              if (args is StaffProfile) {
                return MaterialPageRoute(
                  builder: (context) => HandoverHubPage(
                  currentStaff: args,
                ),
              );
            }
          } else if (settings.name == '/body-check') {
              final args = settings.arguments;
              if (args is Map<String, dynamic>) {
                final firestoreService = args['firestoreService'] as FirestoreService?;
                final child = args['child'] as ChildProfile?;

              if (firestoreService != null && child != null) {
                return MaterialPageRoute(
                  builder: (context) => BodyCheckPage(
                    firestoreService: firestoreService,
                    child: child,
                    ),
                  );
                }
              }
            } else if (settings.name == '/body-check-overview') {
                final args = settings.arguments;
                if (args is Map<String, dynamic>) {
                  final firestoreService = args['firestoreService'] as FirestoreService?;
                  final teacherUid = args['teacherUid'] as String?;

                if (firestoreService != null && teacherUid != null) {
                  return MaterialPageRoute(
                    builder: (context) => BodyCheckOverviewPage(
                      firestoreService: firestoreService,
                      teacherUid: teacherUid,
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
      },
    );
  }
}