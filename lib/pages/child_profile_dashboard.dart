import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../locale_notifier.dart';
import '../models/child_profile.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../utils/hex_colour.dart';
import '../widgets/child_dashboard_feature_card.dart';
import 'background_color_picker_page.dart';
import 'calming_sounds_page.dart';
import 'child_word_learning_page.dart';

class ChildProfileDashboard extends StatefulWidget {
  final ChildProfile profile;
  final FirestoreService firestoreService;
  final LocaleNotifier localeNotifier;
  final String? schoolId;
  final String? classroomId;
  final String? classroomName;

  const ChildProfileDashboard({
    super.key,
    required this.profile,
    required this.firestoreService,
    required this.localeNotifier,
    this.schoolId,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<ChildProfileDashboard> createState() => _ChildProfileDashboardState();
}

class _ChildProfileDashboardState extends State<ChildProfileDashboard> {
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  late ChildProfile profile;
  late Color backgroundColor;

  StreamSubscription<ChildProfile>? _profileSubscription;

  Classroom? _classroom;
  bool _isLoadingClassroomFeatures = false;
  bool _hasHandledAccessPause = false;

  @override
  void initState() {
    super.initState();

    profile = widget.profile;
    backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');

    _loadClassroomFeatures();

    _profileSubscription = widget.firestoreService
        .getCurrentChildProfileStream(profile.id)
        .listen((updatedProfile) {
          if (!mounted) return;

          setState(() {
            profile = updatedProfile;
            backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');
          });

          if (!updatedProfile.profileAccessEnabled && !_hasHandledAccessPause) {
            _handleAccessPaused();
          }
        });
  }

  Future<void> _handleAccessPaused() async {
    _hasHandledAccessPause = true;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.childProfilePausedMessage)),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/profiles', (route) => false);
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
      final classroom = await widget.firestoreService.getClassroom(
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

  @override
  void dispose() {
    final subscription = _profileSubscription;
    _profileSubscription = null;

    subscription?.cancel().catchError((Object error, StackTrace stackTrace) {
      debugPrint('Could not cancel child profile listener cleanly: $error');
    });

    super.dispose();
  }

  void _openBackgroundPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BackgroundColorPickerPage(
              child: profile,
              firestoreService: widget.firestoreService,
            ),
      ),
    );
  }

  List<Color> get _backgroundGradient {
    if (backgroundColor == Colors.white) {
      return const [Color(0xFFFFFBF2), Color(0xFFF6F0FF), Color(0xFFEAF7FF)];
    }

    final softened = Color.lerp(backgroundColor, Colors.white, 0.18)!;
    final warmer = Color.lerp(backgroundColor, const Color(0xFFFFF1D6), 0.32)!;
    final cooler = Color.lerp(backgroundColor, const Color(0xFFEDE7FF), 0.36)!;

    return [softened, warmer, cooler];
  }

  Widget _buildWelcomeCard(AppLocalizations l10n) {
    final initial =
        profile.name.trim().isEmpty
            ? '?'
            : profile.name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5C6BC0)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Positioned(
                right: -7,
                top: -7,
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: Color(0xFFFFD54F),
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(width: 19),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeChild(profile.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.whatWouldYouLikeToDo,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (_isFeatureEnabled(ClassroomFeature.points))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFEB3B),
                    size: 30,
                  ),
                  Text(
                    '${profile.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_DashboardFeature> _myDayFeatures(AppLocalizations l10n) {
    return [
      if (_isFeatureEnabled(ClassroomFeature.circleTime))
        _DashboardFeature(
          icon: Icons.groups_rounded,
          title: l10n.circleTime,
          subtitle: l10n.childCircleTimeSubtitle,
          color: const Color(0xFF7E57C2),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/circle-time',
              arguments: {'teacherUid': profile.teacherUid, 'child': profile},
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.schedules))
        _DashboardFeature(
          icon: Icons.calendar_today_rounded,
          title: l10n.my_schedule,
          subtitle: l10n.childScheduleSubtitle,
          color: const Color(0xFF42A5F5),
          onTap: () {
            Navigator.pushNamed(context, '/childSchedule');
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.whenThen))
        _DashboardFeature(
          icon: Icons.view_agenda_rounded,
          title: l10n.whenThen,
          subtitle: l10n.childWhenThenSubtitle,
          color: const Color(0xFFFFA726),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/when-then-child',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.classroomHelper))
        _DashboardFeature(
          icon: Icons.volunteer_activism_rounded,
          title: l10n.classroomHelper,
          subtitle: l10n.childClassroomHelperSubtitle,
          color: const Color(0xFFFFB300),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/classroom-helper',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
    ];
  }

  List<_DashboardFeature> _feelingsFeatures(AppLocalizations l10n) {
    return [
      if (_isFeatureEnabled(ClassroomFeature.zones))
        _DashboardFeature(
          icon: Icons.color_lens_rounded,
          title: l10n.zones_regulation,
          subtitle: l10n.childZonesSubtitle,
          color: const Color(0xFF26A69A),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/zone-select',
              arguments: {'child': profile},
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.bodyCheck))
        _DashboardFeature(
          icon: Icons.accessibility_new_rounded,
          title: l10n.bodyCheck,
          subtitle: l10n.childBodyCheckSubtitle,
          color: const Color(0xFFEF5350),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/body-check',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.calmingSounds))
        _DashboardFeature(
          icon: Icons.headphones_rounded,
          title: l10n.calming_sounds,
          subtitle: l10n.childCalmingSoundsSubtitle,
          color: const Color(0xFF5C6BC0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => CalmingSoundsPage(
                      firestoreService: widget.firestoreService,
                    ),
              ),
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.calmPlan))
        _DashboardFeature(
          icon: Icons.spa_rounded,
          title: l10n.childCalmToolsTitle,
          subtitle: l10n.childCalmToolsSubtitle,
          color: const Color(0xFF26A69A),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/calm-plan',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.voiceLines))
        _DashboardFeature(
          icon: Icons.record_voice_over_rounded,
          title: l10n.voiceLines,
          subtitle: l10n.childVoiceLinesSubtitle,
          color: const Color(0xFF29B6F6),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/voice-lines',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
    ];
  }

  List<_DashboardFeature> _learningFeatures(AppLocalizations l10n) {
    final gameText = LearningGameLocalizations.of(context);

    return [
      if (_isFeatureEnabled(ClassroomFeature.points))
        _DashboardFeature(
          icon: Icons.star_rounded,
          title: l10n.my_points,
          subtitle: l10n.childPointsSubtitle,
          color: const Color(0xFFFFB300),
          onTap: () {
            Navigator.pushNamed(context, '/child-points', arguments: profile);
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.quizzes))
        _DashboardFeature(
          icon: Icons.quiz_rounded,
          title: l10n.take_quiz,
          subtitle: l10n.childQuizSubtitle,
          color: const Color(0xFFAB47BC),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/student-quiz-list',
              arguments: {
                'firestoreService': widget.firestoreService,
                'child': profile,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.associationPairs))
        _DashboardFeature(
          icon: Icons.extension_rounded,
          title: gameText.associationPairs,
          subtitle: gameText.matchThings,
          color: const Color(0xFF7E57C2),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/association-pairs',
              arguments: {
                'child': profile,
                'firestoreService': widget.firestoreService,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.numberSequence))
        _DashboardFeature(
          icon: Icons.pin_rounded,
          title: gameText.numberSequence,
          subtitle: gameText.tapNumbersInOrder,
          color: const Color(0xFF29B6F6),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/number-sequence',
              arguments: {
                'child': profile,
                'firestoreService': widget.firestoreService,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.wordLearning))
        _DashboardFeature(
          icon: Icons.menu_book_rounded,
          title: l10n.wordPractice,
          subtitle: l10n.childWordPracticeSubtitle,
          color: const Color(0xFF66BB6A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ChildWordLearningPage(
                      firestoreService: widget.firestoreService,
                      child: profile,
                    ),
              ),
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.oddOneOut))
        _DashboardFeature(
          icon: Icons.psychology_alt_rounded,
          title: gameText.oddOneOut,
          subtitle: gameText.findOddOne,
          color: const Color(0xFF7E57C2),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/odd-one-out',
              arguments: {
                'child': profile,
                'firestoreService': widget.firestoreService,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.emotionDetective))
        _DashboardFeature(
          icon: Icons.manage_search_rounded,
          title: gameText.emotionDetective,
          subtitle: gameText.thinkAboutFeelings,
          color: const Color(0xFFEC6F91),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/emotion-detective',
              arguments: {
                'child': profile,
                'firestoreService': widget.firestoreService,
              },
            );
          },
        ),
      if (_isFeatureEnabled(ClassroomFeature.visualTimer))
        _DashboardFeature(
          icon: Icons.timer_rounded,
          title: l10n.visualTimer,
          subtitle: l10n.childTimerSubtitle,
          color: const Color(0xFFFF7043),
          onTap: () {
            Navigator.pushNamed(context, '/visual-timer');
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final l10n = context.l10n;
        final waitingForFeatures =
            _shouldWaitForClassroomFeatures && _classroom == null;

        final myDayFeatures = _myDayFeatures(l10n);
        final feelingsFeatures = _feelingsFeatures(l10n);
        final learningFeatures = _learningFeatures(l10n);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: l10n.profiles,
              icon: const Icon(Icons.home_rounded),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profiles',
                  (route) => false,
                );
              },
            ),
            title: Text(l10n.childSpaceTitle(profile.name)),
            actions: [
              if (_isFeatureEnabled(ClassroomFeature.backgroundPicker))
                IconButton(
                  tooltip: l10n.change_background,
                  onPressed: _openBackgroundPicker,
                  icon: const Icon(Icons.palette_rounded),
                ),
              const SizedBox(width: 6),
            ],
          ),
          body:
              waitingForFeatures
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _backgroundGradient,
                      ),
                    ),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        key: PageStorageKey<String>(
                          'child-dashboard-${profile.teacherUid}-${profile.id}',
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              children: [
                                if (_isLoadingClassroomFeatures) ...[
                                  const LinearProgressIndicator(),
                                  const SizedBox(height: 16),
                                ],
                                _buildWelcomeCard(l10n),
                                const SizedBox(height: 26),
                                _DashboardSection(
                                  icon: Icons.wb_sunny_rounded,
                                  title: l10n.myDay,
                                  subtitle: l10n.myDaySubtitle,
                                  color: const Color(0xFFFFA726),
                                  features: myDayFeatures,
                                ),
                                if (myDayFeatures.isNotEmpty)
                                  const SizedBox(height: 24),
                                _DashboardSection(
                                  icon: Icons.favorite_rounded,
                                  title: l10n.howIFeel,
                                  subtitle: l10n.howIFeelSubtitle,
                                  color: const Color(0xFFEC407A),
                                  features: feelingsFeatures,
                                ),
                                if (feelingsFeatures.isNotEmpty)
                                  const SizedBox(height: 24),
                                _DashboardSection(
                                  icon: Icons.auto_awesome_rounded,
                                  title: l10n.learnAndPlay,
                                  subtitle: l10n.learnAndPlaySubtitle,
                                  color: const Color(0xFF7E57C2),
                                  features: learningFeatures,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }
}

class _DashboardFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _DashboardSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<_DashboardFeature> features;

  const _DashboardSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 27),
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
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 660 ? 2 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 134,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];

                  return ChildDashboardFeatureCard(
                    icon: feature.icon,
                    title: feature.title,
                    subtitle: feature.subtitle,
                    color: feature.color,
                    onTap: feature.onTap,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
