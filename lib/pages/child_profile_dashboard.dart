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
  State<ChildProfileDashboard> createState() => _ChildProfileDashboardState();
}

class _ChildProfileDashboardState extends State<ChildProfileDashboard> {
  late ChildProfile profile;
  Color backgroundColor = Colors.white;
  StreamSubscription<ChildProfile>? _profileSubscription;

  @override
  void initState() {
    super.initState();

    profile = widget.profile;
    backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');

    _profileSubscription = widget.firestoreService
        .getChildProfileStream(profile.teacherUid, profile.id)
        .listen((updatedProfile) {
      if (!mounted) return;

      setState(() {
        profile = updatedProfile;
        backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');
      });
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final loc = SimpleLocalizations(locale);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profiles',
                  (route) => false,
                  arguments: {
                    'schoolId': widget.schoolId,
                    'classroomId': widget.classroomId,
                    'classroomName': widget.classroomName,
                  },
                );
              },
            ),
            title: Text('${profile.name}\'s Dashboard'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.waving_hand_rounded,
                                    size: 46,
                                    color: Color(0xFFFFB300),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${loc.getString("welcome")}, ${profile.name}!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            ChildDashboardFeatureCard(
                              icon: Icons.transfer_within_a_station,
                              title: 'Circle Time',
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.color_lens,
                              title: loc.getString("zones_regulation"),
                              color: const Color(0xFF26A69A),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/zone-select',
                                  arguments: {
                                    'teacherUid': profile.teacherUid,
                                    'child': profile,
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.star,
                              title: loc.getString("my_points"),
                              color: const Color(0xFFFFC107),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/child-points',
                                  arguments: profile,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.schedule,
                              title: loc.getString("my_schedule"),
                              color: const Color(0xFF42A5F5),
                              onTap: () {
                                Navigator.pushNamed(context, '/childSchedule');
                              },
                            ),
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.music_note,
                              title: loc.getString("calming_sounds"),
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.timer,
                              title: loc.getString("visual_timer"),
                              color: const Color(0xFFFF7043),
                              onTap: () {
                                Navigator.pushNamed(context, '/visual-timer');
                              },
                            ),
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.quiz,
                              title: loc.getString("take_quiz"),
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.menu_book,
                              title: 'Word Practice',
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.accessibility_new,
                              title: 'Body Check',
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.view_agenda,
                              title: loc.getString("first_then"),
                              color: const Color(0xFFFFA726),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/first-then-child',
                                  arguments: {
                                    'firestoreService': widget.firestoreService,
                                    'child': profile,
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.record_voice_over,
                              title: loc.getString("voice_lines"),
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
                            const SizedBox(height: 14),

                            ChildDashboardFeatureCard(
                              icon: Icons.format_paint,
                              title: loc.getString("change_background"),
                              color: const Color(0xFFEC407A),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BackgroundColorPickerPage(
                                      child: profile,
                                      firestoreService: widget.firestoreService,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}