import 'dart:async';

import 'package:flutter/material.dart';

import '../locale_notifier.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';
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
  State<ChildProfileDashboard> createState() =>
      _ChildProfileDashboardState();
}

class _ChildProfileDashboardState
    extends State<ChildProfileDashboard> {
  late ChildProfile profile;
  late Color backgroundColor;

  StreamSubscription<ChildProfile>? _profileSubscription;

  @override
  void initState() {
    super.initState();

    profile = widget.profile;
    backgroundColor = HexColor(
      profile.backgroundColorHex ?? '#FFFFFF',
    );

    _profileSubscription = widget.firestoreService
        .getCurrentChildProfileStream(profile.id)
        .listen((updatedProfile) {
      if (!mounted) return;

      setState(() {
        profile = updatedProfile;
        backgroundColor = HexColor(
          profile.backgroundColorHex ?? '#FFFFFF',
        );
      });
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _openBackgroundPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BackgroundColorPickerPage(
          child: profile,
          firestoreService: widget.firestoreService,
        ),
      ),
    );
  }

  List<Color> get _backgroundGradient {
    final softened = Color.lerp(
      backgroundColor,
      Colors.white,
      0.64,
    )!;

    final warmer = Color.lerp(
      backgroundColor,
      const Color(0xFFFFF5E6),
      0.76,
    )!;

    final cooler = Color.lerp(
      backgroundColor,
      const Color(0xFFF3F0FF),
      0.78,
    )!;

    return [
      softened,
      warmer,
      cooler,
    ];
  }

  Widget _buildWelcomeCard(SimpleLocalizations loc) {
    final initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7E57C2),
            Color(0xFF5C6BC0),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2)
                .withValues(alpha: 0.25),
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
                  '${loc.getString("welcome")}, ${profile.name}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'What would you like to do?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
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

  List<_DashboardFeature> _myDayFeatures(
    SimpleLocalizations loc,
  ) {
    return [
      _DashboardFeature(
        icon: Icons.groups_rounded,
        title: 'Circle Time',
        subtitle: 'Start the day together.',
        color: const Color(0xFF7E57C2),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/circle-time',
            arguments: {
              'teacherUid': profile.teacherUid,
              'child': profile,
            },
          );
        },
      ),
      _DashboardFeature(
        icon: Icons.calendar_today_rounded,
        title: loc.getString('my_schedule'),
        subtitle: 'See what is happening today.',
        color: const Color(0xFF42A5F5),
        onTap: () {
          Navigator.pushNamed(context, '/childSchedule');
        },
      ),
      _DashboardFeature(
        icon: Icons.view_agenda_rounded,
        title: loc.getString('when_then'),
        subtitle: 'See your next activity and reward.',
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
    ];
  }

  List<_DashboardFeature> _feelingsFeatures(
    SimpleLocalizations loc,
  ) {
    return [
      _DashboardFeature(
        icon: Icons.color_lens_rounded,
        title: loc.getString('zones_regulation'),
        subtitle: 'Share how you are feeling.',
        color: const Color(0xFF26A69A),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/zone-select',
            arguments: {
              'child': profile,
            },
          );
        },
      ),
      _DashboardFeature(
        icon: Icons.accessibility_new_rounded,
        title: 'Body Check',
        subtitle: 'Show where your body feels sore.',
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
      _DashboardFeature(
        icon: Icons.headphones_rounded,
        title: loc.getString('calming_sounds'),
        subtitle: 'Listen and take a calm moment.',
        color: const Color(0xFF5C6BC0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CalmingSoundsPage(),
            ),
          );
        },
      ),
      _DashboardFeature(
        icon: Icons.record_voice_over_rounded,
        title: loc.getString('voice_lines'),
        subtitle: 'Listen to helpful words and phrases.',
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

  List<_DashboardFeature> _learningFeatures(
    SimpleLocalizations loc,
  ) {
    return [
      _DashboardFeature(
        icon: Icons.star_rounded,
        title: loc.getString('my_points'),
        subtitle: 'See your points and rewards.',
        color: const Color(0xFFFFB300),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/child-points',
            arguments: profile,
          );
        },
      ),
      _DashboardFeature(
        icon: Icons.quiz_rounded,
        title: loc.getString('take_quiz'),
        subtitle: 'Play a quiz and learn something new.',
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
      _DashboardFeature(
        icon: Icons.menu_book_rounded,
        title: 'Word Practice',
        subtitle: 'Practise words at your own pace.',
        color: const Color(0xFF66BB6A),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildWordLearningPage(
                firestoreService: widget.firestoreService,
                child: profile,
              ),
            ),
          );
        },
      ),
      _DashboardFeature(
        icon: Icons.timer_rounded,
        title: loc.getString('visual_timer'),
        subtitle: 'See how much time is left.',
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
        final loc = SimpleLocalizations(locale);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Profiles',
              icon: const Icon(Icons.home_rounded),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profiles',
                  (route) => false,
                );
              },
            ),
            title: Text('${profile.name}’s Space'),
            actions: [
              IconButton(
                tooltip: loc.getString('change_background'),
                onPressed: _openBackgroundPicker,
                icon: const Icon(Icons.palette_rounded),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Container(
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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 980,
                    ),
                    child: Column(
                      children: [
                        _buildWelcomeCard(loc),
                        const SizedBox(height: 26),
                        _DashboardSection(
                          icon: Icons.wb_sunny_rounded,
                          title: 'My Day',
                          subtitle: 'See what is happening next.',
                          color: const Color(0xFFFFA726),
                          features: _myDayFeatures(loc),
                        ),
                        const SizedBox(height: 24),
                        _DashboardSection(
                          icon: Icons.favorite_rounded,
                          title: 'How I Feel',
                          subtitle:
                              'Check in with your body and feelings.',
                          color: const Color(0xFFEC407A),
                          features: _feelingsFeatures(loc),
                        ),
                        const SizedBox(height: 24),
                        _DashboardSection(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Learn & Play',
                          subtitle:
                              'Practise, explore and have some fun.',
                          color: const Color(0xFF7E57C2),
                          features: _learningFeatures(loc),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
        ),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
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
              final columns = constraints.maxWidth >= 660 ? 2 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 126,
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