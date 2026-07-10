import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';
import 'locale_notifier.dart';
import 'models/child_profile.dart';
import 'models/quiz.dart';
import 'models/staff_profile.dart';
import 'pages/account_settings_page.dart';
import 'pages/add_profile_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/body_check_overview_page.dart';
import 'pages/body_check_page.dart';
import 'pages/child_points_page.dart';
import 'pages/child_profile_dashboard.dart';
import 'pages/child_schedule_page.dart';
import 'pages/circle_time_page.dart';
import 'pages/classroom_details_page.dart';
import 'pages/contact_directory_page.dart';
import 'pages/create_classroom_page.dart';
import 'pages/when_then_child_page.dart';
import 'pages/when_then_setup_page.dart';
import 'pages/handover_hub_page.dart';
import 'pages/guidelines_page.dart';
import 'pages/icon_reset_page.dart';
import 'pages/points_overview_page.dart';
import 'pages/profiles_page.dart';
import 'pages/quiz_creation_page.dart';
import 'pages/quiz_list_page.dart';
import 'pages/quiz_play_page.dart';
import 'pages/school_settings_page.dart';
import 'pages/staff_profile_dashboard.dart';
import 'pages/staff_schedule_page.dart';
import 'pages/student_quiz_list_page.dart';
import 'pages/today_overview_page.dart';
import 'pages/visual_timer_page.dart';
import 'pages/voice_lines_page.dart';
import 'pages/zone_selection_page.dart';
import 'pages/zones_overview_page.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';
import 'pages/voice_lines_management_page.dart';
import 'pages/association_pairs_page.dart';
import 'pages/association_pairs_management_page.dart';
import 'pages/number_sequence_page.dart';
import 'pages/number_sequence_management_page.dart';
import 'pages/odd_one_out_management_page.dart';
import 'pages/odd_one_out_page.dart';
import 'pages/emotion_detective_page.dart';
import 'pages/emotion_detective_management_page.dart';
import 'pages/calm_plan_page.dart';
import 'pages/calm_plan_management_page.dart';
import 'pages/classroom_helper_page.dart';
import 'pages/child_notes_page.dart';
import 'pages/media_library_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    debugPrint('Firestore cache cleared and network reset.');
  } catch (e) {
    debugPrint('Error during Firestore prep: $e');
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

  MaterialPageRoute<dynamic> _page(Widget page) {
    return MaterialPageRoute<dynamic>(builder: (_) => page);
  }

  MaterialPageRoute<dynamic> _errorPage(
    String Function(AppLocalizations l10n) messageBuilder,
  ) {
    return MaterialPageRoute<dynamic>(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(context.l10n.error)),
            body: Center(child: Text(messageBuilder(context.l10n))),
          ),
    );
  }

  StaffProfile? _staffFromArgs(Object? args) {
    if (args is StaffProfile) {
      return args;
    }

    if (args is Map<String, dynamic> && args['profile'] is StaffProfile) {
      return args['profile'] as StaffProfile;
    }

    return null;
  }

  ChildProfile? _childFromArgs(Object? args) {
    if (args is ChildProfile) {
      return args;
    }

    if (args is Map<String, dynamic> && args['profile'] is ChildProfile) {
      return args['profile'] as ChildProfile;
    }

    if (args is Map<String, dynamic> && args['childProfile'] is ChildProfile) {
      return args['childProfile'] as ChildProfile;
    }

    return null;
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    final args = settings.arguments;

    if (routeName.startsWith('/staff-dashboard/')) {
      final staffId = routeName.split('/').last;
      final profile = _staffFromArgs(args);

      if (profile != null) {
        return _page(
          StaffProfileDashboard(
            profile: profile,
            localeNotifier: localeNotifier,
          ),
        );
      }

      return _page(
        _StaffDashboardLoader(staffId: staffId, localeNotifier: localeNotifier),
      );
    }

    if (routeName.startsWith('/child-dashboard/')) {
      final childId = routeName.split('/').last;
      final profile = _childFromArgs(args);

      if (profile != null) {
        return _page(
          ChildProfileDashboard(
            profile: profile,
            firestoreService: FirestoreService(),
            localeNotifier: localeNotifier,
          ),
        );
      }

      return _page(
        _ChildDashboardLoader(childId: childId, localeNotifier: localeNotifier),
      );
    }

    switch (routeName) {
      case '/admin-dashboard':
        if (args is Map<String, dynamic> &&
            args['schoolId'] is String &&
            args['schoolName'] is String) {
          return _page(
            AdminDashboardPage(
              schoolId: args['schoolId'] as String,
              schoolName: args['schoolName'] as String,
            ),
          );
        }
        return _errorPage((l10n) => l10n.missingAdminDashboardDetails);

      case '/contact-directory':
        if (args is Map<String, dynamic> && args['schoolId'] is String) {
          return _page(
            ContactDirectoryPage(schoolId: args['schoolId'] as String),
          );
        }
        return _errorPage((l10n) => l10n.missingAdminDashboardDetails);

      case '/zone-overview':
        if (args is Map<String, dynamic> && args['teacherUid'] is String) {
          return _page(
            ZoneOverviewPage(teacherUid: args['teacherUid'] as String),
          );
        }
        return _page(const ZoneOverviewPage());

      case '/zone-select':
        if (args is Map<String, dynamic> && args['child'] is ChildProfile) {
          return _page(
            ZoneSelectionPage(
              teacherUid: args['teacherUid'] as String?,
              child: args['child'] as ChildProfile,
            ),
          );
        }
        return _errorPage((l10n) => l10n.missingChildProfile);

      case '/staff-dashboard':
        final profile = _staffFromArgs(args);
        if (profile != null) {
          return _page(
            StaffProfileDashboard(
              profile: profile,
              localeNotifier: localeNotifier,
            ),
          );
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/media-library':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              MediaLibraryPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/child-dashboard':
        final profile = _childFromArgs(args);
        if (profile != null) {
          return _page(
            ChildProfileDashboard(
              profile: profile,
              firestoreService: FirestoreService(),
              localeNotifier: localeNotifier,
            ),
          );
        }
        return _errorPage((l10n) => l10n.missingChildProfile);

      case '/points-overview':
        if (args is Map<String, dynamic> && args['teacherUid'] is String) {
          return _page(
            PointsOverviewPage(teacherUid: args['teacherUid'] as String),
          );
        }
        return _page(const PointsOverviewPage());

      case '/child-points':
        if (args is ChildProfile) {
          return _page(ChildPointsPage(child: args));
        }
        return _errorPage((l10n) => l10n.missingChildProfile);

      case '/quiz-create':
        if (args is Map<String, dynamic>) {
          final staffUid = args['staffUid'] as String?;
          final quiz = args['quiz'] as Quiz?;

          if (staffUid != null) {
            return _page(
              QuizCreationPage(staffUid: staffUid, existingQuiz: quiz),
            );
          }
        }

        if (args is StaffProfile) {
          return _page(QuizCreationPage(staffUid: args.teacherUid));
        }

        if (args is String) {
          return _page(QuizCreationPage(staffUid: args));
        }

        return _errorPage((l10n) => l10n.missingQuizCreator);

      case '/quiz-list':
        if (args is String) {
          return _page(QuizListPage(teacherUid: args));
        }
        return _errorPage((l10n) => l10n.missingTeacherId);

      case '/quiz-play':
        if (args is Map<String, dynamic> && args['quiz'] is Quiz) {
          return _page(
            QuizPlayPage(
              quiz: args['quiz'] as Quiz,
              childProfile: args['childProfile'] as ChildProfile?,
            ),
          );
        }
        return _errorPage((l10n) => l10n.missingQuiz);

      case '/student-quiz-list':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final child = args['child'] as ChildProfile?;

          if (firestoreService != null && child != null) {
            return _page(
              StudentQuizListPage(
                firestoreService: firestoreService,
                child: child,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingStudentQuizDetails);

      case '/association-pairs':
        if (args is Map<String, dynamic> && args['child'] is ChildProfile) {
          return _page(
            AssociationPairsPage(
              child: args['child'] as ChildProfile,
              firestoreService: args['firestoreService'] as FirestoreService?,
            ),
          );
        }
        return _page(const AssociationPairsPage());

      case '/number-sequence':
        if (args is Map<String, dynamic> && args['child'] is ChildProfile) {
          return _page(
            NumberSequencePage(
              child: args['child'] as ChildProfile,
              firestoreService: args['firestoreService'] as FirestoreService?,
            ),
          );
        }
        return _page(const NumberSequencePage());

      case '/association-pairs-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              AssociationPairsManagementPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.error);

      case '/number-sequence-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              NumberSequenceManagementPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.error);

      case '/odd-one-out':
        if (args is Map<String, dynamic>) {
          final child = args['child'] as ChildProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (child != null && firestoreService != null) {
            return _page(
              OddOneOutPage(profile: child, firestoreService: firestoreService),
            );
          }
        }
        return _errorPage((l10n) => l10n.error);

      case '/emotion-detective':
        if (args is Map<String, dynamic>) {
          final child = args['child'] as ChildProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (child != null && firestoreService != null) {
            return _page(
              EmotionDetectivePage(
                profile: child,
                firestoreService: firestoreService,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.error);

      case '/emotion-detective-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              EmotionDetectiveManagementPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.error);

      case '/odd-one-out-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              OddOneOutManagementPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/voice-lines':
        if (args is Map<String, dynamic> &&
            args['firestoreService'] is FirestoreService) {
          return _page(
            VoiceLinesPage(
              firestoreService: args['firestoreService'] as FirestoreService,
            ),
          );
        }

        return _page(VoiceLinesPage(firestoreService: FirestoreService()));

      case '/voice-lines-management':
        if (args is StaffProfile) {
          return _page(VoiceLinesManagementPage(staffProfile: args));
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/calm-plan-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              CalmPlanManagementPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/child-notes':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              ChildNotesPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/guidelines':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              GuidelinesPage(
                staffProfile: staffProfile,
                firestoreService: firestoreService,
              ),
            );
          }
        }

        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/calm-plan':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final child = args['child'] as ChildProfile?;

          if (firestoreService != null && child != null) {
            return _page(
              CalmPlanPage(firestoreService: firestoreService, child: child),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingChildProfile);

      case '/classroom-helper-management':
        if (args is Map<String, dynamic>) {
          final staffProfile = args['staffProfile'] as StaffProfile?;
          final firestoreService =
              args['firestoreService'] as FirestoreService?;

          if (staffProfile != null && firestoreService != null) {
            return _page(
              ClassroomHelperPage(
                firestoreService: firestoreService,
                staffProfile: staffProfile,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/classroom-helper':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final child = args['child'] as ChildProfile?;

          if (firestoreService != null && child != null) {
            return _page(
              ClassroomHelperPage(
                firestoreService: firestoreService,
                child: child,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingChildProfile);

      case '/icon-reset':
        if (args is String) {
          return _page(IconResetPage(teacherUid: args));
        }
        return _errorPage((l10n) => l10n.missingTeacherId);

      case '/when-then-setup':
        if (args is String) {
          return _page(WhenThenSetupPage(teacherUid: args));
        }
        return _errorPage((l10n) => l10n.missingTeacherId);

      case '/when-then-child':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final child = args['child'] as ChildProfile?;

          if (firestoreService != null && child != null) {
            return _page(
              WhenThenChildPage(
                firestoreService: firestoreService,
                child: child,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingWhenThenChildDetails);

      case '/circle-time':
        if (args is Map<String, dynamic>) {
          final teacherUid = args['teacherUid'] as String?;
          final child = args['child'] as ChildProfile?;

          if (teacherUid != null) {
            return _page(
              CircleTimePage(teacherUid: teacherUid, childProfile: child),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingCircleTimeDetails);

      case '/handover-hub':
        if (args is StaffProfile) {
          return _page(HandoverHubPage(currentStaff: args));
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      case '/body-check':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final child = args['child'] as ChildProfile?;

          if (firestoreService != null && child != null) {
            return _page(
              BodyCheckPage(firestoreService: firestoreService, child: child),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingBodyCheckDetails);

      case '/body-check-overview':
        if (args is Map<String, dynamic>) {
          final firestoreService =
              args['firestoreService'] as FirestoreService?;
          final teacherUid = args['teacherUid'] as String?;

          if (firestoreService != null && teacherUid != null) {
            return _page(
              BodyCheckOverviewPage(
                firestoreService: firestoreService,
                teacherUid: teacherUid,
              ),
            );
          }
        }
        return _errorPage((l10n) => l10n.missingBodyCheckOverviewDetails);

      case '/today-overview':
        if (args is StaffProfile) {
          return _page(TodayOverviewPage(staffProfile: args));
        }
        return _errorPage((l10n) => l10n.missingStaffProfile);

      default:
        return _errorPage((l10n) => l10n.invalidRouteOrMissingArguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          onGenerateTitle: (context) {
            return AppLocalizations.of(context)!.appTitle;
          },
          theme: AppTheme.lightTheme,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthGate(),
            '/account-settings':
                (context) => AccountSettingsPage(
                  locale: locale,
                  onLocaleChange: localeNotifier.changeLocale,
                ),
            '/staffSchedule': (context) => const StaffSchedulePage(),
            '/childSchedule': (context) => const ChildSchedulePage(),
            '/visual-timer': (context) => const VisualTimerPage(),
            '/profiles': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              if (args is Map<String, dynamic>) {
                return ProfilesPage(
                  schoolId: args['schoolId'] as String?,
                  classroomId: args['classroomId'] as String?,
                  classroomName: args['classroomName'] as String?,
                );
              }

              return const ProfilesPage();
            },
            '/add-profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              if (args is Map<String, dynamic>) {
                return AddProfilePage(
                  schoolId: args['schoolId'] as String?,
                  classroomId: args['classroomId'] as String?,
                  classroomName: args['classroomName'] as String?,
                );
              }

              return const AddProfilePage();
            },
            '/create-classroom': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              if (args is Map<String, dynamic> && args['schoolId'] is String) {
                return CreateClassroomPage(
                  schoolId: args['schoolId'] as String,
                );
              }

              return Scaffold(
                body: Center(child: Text(context.l10n.missingSchoolId)),
              );
            },
            '/classroom-details': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              if (args is Map<String, dynamic> &&
                  args['schoolId'] is String &&
                  args['classroomId'] is String) {
                return ClassroomDetailsPage(
                  schoolId: args['schoolId'] as String,
                  classroomId: args['classroomId'] as String,
                );
              }

              return Scaffold(
                body: Center(child: Text(context.l10n.missingClassroomDetails)),
              );
            },
            '/school-settings': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              if (args is Map<String, dynamic> && args['schoolId'] is String) {
                return SchoolSettingsPage(schoolId: args['schoolId'] as String);
              }

              return Scaffold(
                body: Center(child: Text(context.l10n.missingSchoolId)),
              );
            },
          },
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }
}

class _StaffDashboardLoader extends StatelessWidget {
  final String staffId;
  final LocaleNotifier localeNotifier;

  const _StaffDashboardLoader({
    required this.staffId,
    required this.localeNotifier,
  });

  Future<StaffProfile?> _loadStaffProfile() async {
    final firestoreService = FirestoreService();

    await firestoreService.restoreClassroomSessionFromAuthIfNeeded();

    final staffProfiles =
        await firestoreService.getCurrentStaffProfiles().first;

    for (final staff in staffProfiles) {
      if (staff.id == staffId) {
        return staff;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StaffProfile?>(
      future: _loadStaffProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.staffProfileNotFound)),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/profiles',
                    (route) => false,
                  );
                },
                child: Text(context.l10n.returnToProfiles),
              ),
            ),
          );
        }

        return StaffProfileDashboard(
          profile: profile,
          localeNotifier: localeNotifier,
        );
      },
    );
  }
}

class _ChildDashboardLoader extends StatelessWidget {
  final String childId;
  final LocaleNotifier localeNotifier;

  const _ChildDashboardLoader({
    required this.childId,
    required this.localeNotifier,
  });

  Future<ChildProfile?> _loadChildProfile() async {
    final firestoreService = FirestoreService();

    await firestoreService.restoreClassroomSessionFromAuthIfNeeded();

    final childProfiles =
        await firestoreService.getCurrentChildProfiles().first;

    for (final child in childProfiles) {
      if (child.id == childId) {
        return child;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChildProfile?>(
      future: _loadChildProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.childProfileNotFound)),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/profiles',
                    (route) => false,
                  );
                },
                child: Text(context.l10n.returnToProfiles),
              ),
            ),
          );
        }

        return ChildProfileDashboard(
          profile: profile,
          firestoreService: FirestoreService(),
          localeNotifier: localeNotifier,
        );
      },
    );
  }
}
