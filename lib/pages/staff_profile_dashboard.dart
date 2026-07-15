import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../l10n/body_check_localizations.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../models/body_check_report.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../widgets/staff_dashboard_feature_card.dart';
import 'child_access_page.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';
import 'word_learning_page.dart';
import '../data/app_icon_catalog.dart';
import '../models/calm_plan_models.dart';

class StaffProfileDashboard extends StatefulWidget {
  final StaffProfile profile;
  final LocaleNotifier localeNotifier;
  final String? schoolId;
  final String? classroomId;
  final String? classroomName;

  const StaffProfileDashboard({
    super.key,
    required this.profile,
    required this.localeNotifier,
    this.schoolId,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<StaffProfileDashboard> createState() => _StaffProfileDashboardState();
}

class _StaffProfileDashboardState extends State<StaffProfileDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  Classroom? _classroom;
  bool _isLoadingClassroomFeatures = false;

  @override
  void initState() {
    super.initState();
    _loadClassroomFeatures();
  }

  Future<void> _loadClassroomFeatures() async {
    var schoolId = widget.schoolId;
    var classroomId = widget.classroomId;

    if ((schoolId == null || classroomId == null) &&
        _session.hasClassroomSession) {
      schoolId = _session.requireSchoolId;
      classroomId = _session.requireClassroomId;
    }

    if (schoolId == null || classroomId == null) return;

    setState(() {
      _isLoadingClassroomFeatures = true;
    });

    try {
      final classroom = await _firestoreService.getClassroom(
        schoolId: schoolId,
        classroomId: classroomId,
      );

      if (!mounted) return;

      setState(() {
        _classroom = classroom;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingClassroomFeatures = false;
        });
      }
    }
  }

  bool get _shouldWaitForClassroomFeatures {
    return (widget.schoolId != null && widget.classroomId != null) ||
        _session.hasClassroomSession;
  }

  bool _isFeatureEnabled(ClassroomFeature feature) {
    if (_classroom != null) {
      return _classroom!.isFeatureEnabled(feature);
    }

    return !_shouldWaitForClassroomFeatures;
  }

  String get _classroomName {
    if (widget.classroomName != null &&
        widget.classroomName!.trim().isNotEmpty) {
      return widget.classroomName!;
    }

    if (_session.hasClassroomSession) {
      return _session.currentClassroomName;
    }

    return '';
  }

  void _navigateToPointsOverview() {
    Navigator.pushNamed(context, '/points-overview');
  }

  void _openChildAccess() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildAccessPage(firestoreService: _firestoreService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final l10n = context.l10n;
        final gameText = LearningGameLocalizations.of(context);
        final waitingForFeatures =
            _shouldWaitForClassroomFeatures && _classroom == null;

        final todayOverviewCard =
            _isFeatureEnabled(ClassroomFeature.todayOverview)
                ? _TodayOverviewSpotlight(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/today-overview',
                      arguments: widget.profile,
                    );
                  },
                )
                : null;

        final alertsPanel =
            _isFeatureEnabled(ClassroomFeature.calmPlan) ||
                    _isFeatureEnabled(ClassroomFeature.bodyCheck)
                ? _StaffAlertsPanel(
                  firestoreService: _firestoreService,
                  staffProfile: widget.profile,
                  showCalmRequests: _isFeatureEnabled(
                    ClassroomFeature.calmPlan,
                  ),
                  showBodyChecks: _isFeatureEnabled(ClassroomFeature.bodyCheck),
                )
                : null;

        final dailyTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.zones))
            StaffDashboardFeatureCard(
              icon: Icons.palette_rounded,
              title: l10n.zones_regulation,
              subtitle: l10n.staffZonesSubtitle,
              color: const Color(0xFF26A69A),
              onTap: () {
                Navigator.pushNamed(context, '/zone-overview');
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.points))
            StaffDashboardFeatureCard(
              icon: Icons.star_rounded,
              title: l10n.points_overview,
              subtitle: l10n.staffPointsSubtitle,
              color: const Color(0xFFFFB300),
              onTap: _navigateToPointsOverview,
            ),
          if (_isFeatureEnabled(ClassroomFeature.schedules))
            StaffDashboardFeatureCard(
              icon: Icons.schedule_rounded,
              title: l10n.view_schedule,
              subtitle: l10n.staffScheduleSubtitle,
              color: const Color(0xFF42A5F5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffSchedulePage()),
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.whenThen))
            StaffDashboardFeatureCard(
              icon: Icons.view_kanban_rounded,
              title: l10n.whenThenSetup,
              subtitle: l10n.staffWhenThenSubtitle,
              color: const Color(0xFFFFA726),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/when-then-setup',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.visualTimer))
            StaffDashboardFeatureCard(
              icon: Icons.timer_rounded,
              title: l10n.visualTimer,
              subtitle: l10n.staffTimerSubtitle,
              color: const Color(0xFFFF7043),
              onTap: () {
                Navigator.pushNamed(context, '/visual-timer');
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.classroomHelper))
            StaffDashboardFeatureCard(
              icon: Icons.volunteer_activism_rounded,
              title: l10n.classroomHelper,
              subtitle: l10n.staffClassroomHelperSubtitle,
              color: const Color(0xFFFFB300),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/classroom-helper-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
        ];

        final communicationTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.bodyCheck))
            StaffDashboardFeatureCard(
              icon: Icons.health_and_safety_rounded,
              title: l10n.bodyCheckReports,
              subtitle: l10n.bodyCheckReportsSubtitle,
              color: const Color(0xFFEF5350),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/body-check-overview',
                  arguments: {
                    'firestoreService': _firestoreService,
                    'teacherUid': widget.profile.teacherUid,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.calmPlan))
            StaffDashboardFeatureCard(
              icon: Icons.spa_rounded,
              title: 'Calm Plan',
              subtitle: 'Review calm support requests and manage calm tools.',
              color: const Color(0xFF26A69A),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/calm-plan-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.childNotes))
            StaffDashboardFeatureCard(
              icon: Icons.sticky_note_2_rounded,
              title: l10n.childNotes,
              subtitle: l10n.staffChildNotesSubtitle,
              color: const Color(0xFF5E7CE2),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/child-notes',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.circleTime))
            StaffDashboardFeatureCard(
              icon: Icons.groups_rounded,
              title: l10n.circleTime,
              subtitle: l10n.staffCircleTimeSubtitle,
              color: const Color(0xFF7E57C2),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/circle-time',
                  arguments: {'teacherUid': widget.profile.teacherUid},
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.voiceLines))
            StaffDashboardFeatureCard(
              icon: Icons.record_voice_over_rounded,
              title: l10n.voiceLines,
              subtitle: 'Manage the phrases children can use.',
              color: const Color(0xFF7E57C2),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/voice-lines-management',
                  arguments: widget.profile,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.calmingSounds))
            StaffDashboardFeatureCard(
              icon: Icons.headphones_rounded,
              title: l10n.calming_sounds,
              subtitle: l10n.staffCalmingSoundsSubtitle,
              color: const Color(0xFF5E35B1),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/calming-sounds-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
        ];

        final learningTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.quizzes))
            StaffDashboardFeatureCard(
              icon: Icons.quiz_rounded,
              title: l10n.quizzes,
              subtitle: l10n.staffQuizzesSubtitle,
              color: const Color(0xFFAB47BC),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/quiz-list',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.wordLearning))
            StaffDashboardFeatureCard(
              icon: Icons.menu_book_rounded,
              title: l10n.wordLearning,
              subtitle: l10n.staffWordLearningSubtitle,
              color: const Color(0xFF66BB6A),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => WordLearningPage(
                          firestoreService: _firestoreService,
                          teacherUid: widget.profile.teacherUid,
                          staffId: widget.profile.id,
                          staffName: widget.profile.name,
                        ),
                  ),
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.associationPairs))
            StaffDashboardFeatureCard(
              icon: Icons.extension_rounded,
              title: gameText.associationPairs,
              subtitle:
                  gameText.isIrish
                      ? 'Cruthaigh pacáistí péirí meaitseála.'
                      : 'Create matching-pair learning packs.',
              color: const Color(0xFF7E57C2),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/association-pairs-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.numberSequence))
            StaffDashboardFeatureCard(
              icon: Icons.pin_rounded,
              title: gameText.numberSequence,
              subtitle:
                  gameText.isIrish
                      ? 'Cruthaigh dúshláin ordaithe uimhreacha.'
                      : 'Create number ordering challenge presets.',
              color: const Color(0xFF29B6F6),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/number-sequence-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.oddOneOut))
            StaffDashboardFeatureCard(
              icon: Icons.psychology_alt_rounded,
              title: gameText.oddOneOut,
              subtitle:
                  gameText.isIrish
                      ? 'Cruthaigh pacáistí réasúnaíochta don cheann corr.'
                      : 'Create visual odd-one-out reasoning packs.',
              color: const Color(0xFF7E57C2),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/odd-one-out-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.emotionDetective))
            StaffDashboardFeatureCard(
              icon: Icons.manage_search_rounded,
              title: gameText.emotionDetective,
              subtitle:
                  gameText.isIrish
                      ? 'Cruthaigh pacáistí mothúchán agus réasúnaíochta sóisialta.'
                      : 'Create feelings and social reasoning packs.',
              color: const Color(0xFFEC6F91),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/emotion-detective-management',
                  arguments: {
                    'staffProfile': widget.profile,
                    'firestoreService': _firestoreService,
                  },
                );
              },
            ),
        ];

        final adminTools = <Widget>[
          StaffDashboardFeatureCard(
            icon: Icons.lock_person_rounded,
            title: 'Child Access',
            subtitle: 'Pause or reopen access to child profiles.',
            color: const Color(0xFF455A64),
            onTap: _openChildAccess,
          ),
          if (_isFeatureEnabled(ClassroomFeature.incidentLog))
            StaffDashboardFeatureCard(
              icon: Icons.event_note_rounded,
              title: l10n.incidentLog,
              subtitle: l10n.staffIncidentLogSubtitle,
              color: const Color(0xFFD84315),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => IncidentLogPage(staffProfile: widget.profile),
                  ),
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.handover))
            StaffDashboardFeatureCard(
              icon: Icons.description_rounded,
              title: l10n.handoverHub,
              subtitle: l10n.staffHandoverSubtitle,
              color: const Color(0xFF5D6D7E),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/handover-hub',
                  arguments: widget.profile,
                );
              },
            ),
          StaffDashboardFeatureCard(
            icon: Icons.menu_book_rounded,
            title: l10n.staffGuidelines,
            subtitle: l10n.staffGuidelinesDashboardSubtitle,
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/guidelines',
                arguments: {
                  'staffProfile': widget.profile,
                  'firestoreService': _firestoreService,
                },
              );
            },
          ),
          if (_isFeatureEnabled(ClassroomFeature.iconReset))
            StaffDashboardFeatureCard(
              icon: Icons.lock_reset_rounded,
              title: l10n.iconReset,
              subtitle: l10n.iconResetSubtitle,
              color: const Color(0xFF6D4C41),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/icon-reset',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
          StaffDashboardFeatureCard(
            icon: Icons.perm_media_rounded,
            title: l10n.mediaLibrary,
            subtitle: l10n.staffMediaLibrarySubtitle,
            color: const Color(0xFF5E7CE2),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/media-library',
                arguments: {
                  'staffProfile': widget.profile,
                  'firestoreService': _firestoreService,
                },
              );
            },
          ),
        ];

        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profiles',
                  (route) => false,
                );
              },
            ),
            title: Text(l10n.staffHubTitle(widget.profile.name)),
          ),
          body: SafeArea(
            child:
                waitingForFeatures
                    ? const Center(child: CircularProgressIndicator())
                    : _StaffDashboardBody(
                      isLoadingClassroomFeatures: _isLoadingClassroomFeatures,
                      profile: widget.profile,
                      classroomName: _classroomName,
                      todayOverviewCard: todayOverviewCard,
                      alertsPanel: alertsPanel,
                      dailyTools: dailyTools,
                      communicationTools: communicationTools,
                      learningTools: learningTools,
                      adminTools: adminTools,
                    ),
          ),
        );
      },
    );
  }
}

class _StaffDashboardBody extends StatelessWidget {
  final bool isLoadingClassroomFeatures;
  final StaffProfile profile;
  final String classroomName;
  final Widget? todayOverviewCard;
  final Widget? alertsPanel;
  final List<Widget> dailyTools;
  final List<Widget> communicationTools;
  final List<Widget> learningTools;
  final List<Widget> adminTools;

  const _StaffDashboardBody({
    required this.isLoadingClassroomFeatures,
    required this.profile,
    required this.classroomName,
    required this.todayOverviewCard,
    required this.alertsPanel,
    required this.dailyTools,
    required this.communicationTools,
    required this.learningTools,
    required this.adminTools,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colourScheme.primaryContainer.withValues(alpha: 0.24),
            colourScheme.surface,
            const Color(0xFFEAF7F4),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isLoadingClassroomFeatures) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 16),
                      ],
                      _StaffHeroCard(
                        profile: profile,
                        classroomName: classroomName,
                      ),
                      if (alertsPanel != null) ...[
                        const SizedBox(height: 18),
                        alertsPanel!,
                      ],
                      if (todayOverviewCard != null) ...[
                        const SizedBox(height: 18),
                        todayOverviewCard!,
                      ],
                      const SizedBox(height: 22),
                      _HubSection(
                        icon: Icons.today_rounded,
                        title: context.l10n.dailyTools,
                        subtitle:
                            'Fast access to the tools used during the day.',
                        color: const Color(0xFF5E7CE2),
                        children: dailyTools,
                      ),
                      _HubSection(
                        icon: Icons.forum_rounded,
                        title: context.l10n.communication,
                        subtitle: 'Record, review and support classroom needs.',
                        color: const Color(0xFF26A69A),
                        children: communicationTools,
                      ),
                      _HubSection(
                        icon: Icons.school_rounded,
                        title: context.l10n.learning,
                        subtitle: 'Create and support learning activities.',
                        color: const Color(0xFF66BB6A),
                        children: learningTools,
                      ),
                      _HubSection(
                        icon: Icons.admin_panel_settings_rounded,
                        title: context.l10n.staffAdmin,
                        subtitle: 'Classroom controls and staff-only tools.',
                        color: const Color(0xFF455A64),
                        children: adminTools,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaffHeroCard extends StatelessWidget {
  final StaffProfile profile;
  final String classroomName;

  const _StaffHeroCard({required this.profile, required this.classroomName});

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.name.trim().isEmpty
            ? '?'
            : profile.name.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3949AB), Color(0xFF00897B)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 650;

          final avatar = Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          );

          final text = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${profile.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  classroomName.isEmpty
                      ? 'Your staff tools are ready.'
                      : classroomName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );

          final chip = Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  profile.role.trim().isEmpty ? 'Staff' : profile.role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: 18),
                text,
                const SizedBox(width: 16),
                chip,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(height: 16),
              Row(children: [text]),
              const SizedBox(height: 14),
              chip,
            ],
          );
        },
      ),
    );
  }
}

class _StaffAlertsPanel extends StatelessWidget {
  final FirestoreService firestoreService;
  final StaffProfile staffProfile;
  final bool showCalmRequests;
  final bool showBodyChecks;

  const _StaffAlertsPanel({
    required this.firestoreService,
    required this.staffProfile,
    required this.showCalmRequests,
    required this.showBodyChecks,
  });

  Future<void> _resolveCalmRequest(
    BuildContext context,
    CalmRequest request,
  ) async {
    try {
      await firestoreService.resolveCurrentCalmRequest(
        requestId: request.id,
        staffId: staffProfile.id,
        staffName: staffProfile.name,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.staffAlertsCalmRequestResolved(request.childName),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.staffAlertsCalmResolveFailed(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openBodyChecks(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/body-check-overview',
      arguments: {
        'firestoreService': firestoreService,
        'teacherUid': staffProfile.teacherUid,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showCalmRequests && !showBodyChecks) {
      return const SizedBox.shrink();
    }

    final calmStream =
        showCalmRequests
            ? firestoreService.getCurrentActiveCalmRequests()
            : Stream<List<CalmRequest>>.value(const []);

    return StreamBuilder<List<CalmRequest>>(
      stream: calmStream,
      builder: (context, calmSnapshot) {
        if (calmSnapshot.hasError) {
          return _AttentionLoadError(
            message: context.l10n.staffAlertsLoadFailed,
          );
        }

        if (!calmSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final bodyStream =
            showBodyChecks
                ? firestoreService.getCurrentBodyCheckReports()
                : Stream<List<BodyCheckReport>>.value(const []);

        return StreamBuilder<List<BodyCheckReport>>(
          stream: bodyStream,
          builder: (context, bodySnapshot) {
            if (bodySnapshot.hasError) {
              return _AttentionLoadError(
                message: context.l10n.staffAlertsLoadFailed,
              );
            }

            if (!bodySnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final calmRequests = calmSnapshot.data!;
            final bodyChecks =
                bodySnapshot.data!.where((report) => !report.checked).toList()
                  ..sort((first, second) {
                    if (first.painLevel != second.painLevel) {
                      return second.painLevel.compareTo(first.painLevel);
                    }

                    return second.timestamp.compareTo(first.timestamp);
                  });

            final alerts = <Widget>[
              ...bodyChecks
                  .take(3)
                  .map(
                    (report) => _AttentionBodyCheckCard(
                      report: report,
                      onOpen: () => _openBodyChecks(context),
                    ),
                  ),
              ...calmRequests
                  .take(3)
                  .map(
                    (request) => _AttentionCalmCard(
                      request: request,
                      onResolve: () => _resolveCalmRequest(context, request),
                    ),
                  ),
            ];

            if (alerts.isEmpty) {
              return const SizedBox.shrink();
            }

            final totalAlerts = bodyChecks.length + calmRequests.length;
            final hiddenCount =
                (bodyChecks.length - bodyChecks.take(3).length) +
                (calmRequests.length - calmRequests.take(3).length);

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.28),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA726).withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFA726,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFE65100),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.staffAlertsNeedsAttention,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              context.l10n.staffAlertsActiveCount(totalAlerts),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...alerts.map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: alert,
                    ),
                  ),
                  if (hiddenCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.staffAlertsMoreCount(hiddenCount),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AttentionLoadError extends StatelessWidget {
  final String message;

  const _AttentionLoadError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(message, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _AttentionBodyCheckCard extends StatelessWidget {
  final BodyCheckReport report;
  final VoidCallback onOpen;

  const _AttentionBodyCheckCard({required this.report, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final color = report.painLevel == 3 ? Colors.red : Colors.deepOrange;
    final childName =
        report.childName.trim().isEmpty
            ? context.l10n.staffAlertsUnknownChild
            : report.childName;

    return _AttentionCardShell(
      color: color,
      icon: Icons.health_and_safety_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.staffAlertsBodyCheckSubmitted(childName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${localizedBodyPart(context.l10n, report.bodyPart)} • ${localizedPainLevel(context.l10n, report.painLevel)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );

          final button = FilledButton.icon(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(context.l10n.viewBodyCheckReports),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [details]),
                const SizedBox(height: 12),
                button,
              ],
            );
          }

          return Row(children: [details, const SizedBox(width: 12), button]);
        },
      ),
    );
  }
}

class _AttentionCalmCard extends StatelessWidget {
  final CalmRequest request;
  final VoidCallback onResolve;

  const _AttentionCalmCard({required this.request, required this.onResolve});

  String _timeLabel() {
    final createdAt = request.createdAt;
    if (createdAt == null) return 'Just now';

    final minutes = DateTime.now().difference(createdAt).inMinutes;

    if (minutes < 1) return 'Just now';
    if (minutes == 1) return '1 min ago';
    if (minutes < 60) return '$minutes min ago';

    final hours = minutes ~/ 60;
    if (hours == 1) return '1 hour ago';
    return '$hours hours ago';
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF26A69A);
    final childName =
        request.childName.trim().isEmpty
            ? context.l10n.staffAlertsUnknownChild
            : request.childName;
    final toolName =
        request.toolName.trim().isEmpty
            ? context.l10n.calmPlan
            : request.toolName;

    return _AttentionCardShell(
      color: color,
      icon: appIconForKey(request.toolIconName, fallbackKey: 'leaf'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.staffAlertsCalmNeedsSupport(childName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.staffAlertsCalmSelected(toolName, _timeLabel()),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );

          final button = FilledButton.icon(
            onPressed: onResolve,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(context.l10n.markResolved),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [details]),
                const SizedBox(height: 12),
                button,
              ],
            );
          }

          return Row(children: [details, const SizedBox(width: 12), button]);
        },
      ),
    );
  }
}

class _AttentionCardShell extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Widget child;

  const _AttentionCardShell({
    required this.color,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TodayOverviewSpotlight extends StatelessWidget {
  final VoidCallback onTap;

  const _TodayOverviewSpotlight({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5E7CE2),
                    Color(0xFF7C6BFF),
                    Color(0xFFFFB199),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E7CE2).withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.todayOverview,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.l10n.todayOverviewSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HubSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Widget> children;

  const _HubSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 3 : 2;
              final adjustedColumns = constraints.maxWidth < 540 ? 1 : columns;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: adjustedColumns,
                  mainAxisExtent: 166,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) => children[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
