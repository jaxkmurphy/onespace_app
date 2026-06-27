import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';
import '../widgets/staff_dashboard_feature_card.dart';
import 'child_access_page.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';
import 'word_learning_page.dart';

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
        ];

        final adminTools = <Widget>[
          StaffDashboardFeatureCard(
            icon: Icons.lock_person_rounded,
            title: 'Child Access',
            subtitle: 'Pause or reopen access to child profiles.',
            color: const Color(0xFF455A64),
            onTap: _openChildAccess,
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
  final List<Widget> dailyTools;
  final List<Widget> communicationTools;
  final List<Widget> learningTools;
  final List<Widget> adminTools;

  const _StaffDashboardBody({
    required this.isLoadingClassroomFeatures,
    required this.profile,
    required this.classroomName,
    required this.todayOverviewCard,
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