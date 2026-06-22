import 'package:flutter/material.dart';
import '../data/quiz_visuals.dart';
import '../models/child_profile.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';

class StudentQuizListPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final ChildProfile child;

  const StudentQuizListPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  @override
  State<StudentQuizListPage> createState() => _StudentQuizListPageState();
}

class _StudentQuizListPageState extends State<StudentQuizListPage> {
  late Stream<List<Quiz>> _quizStream;
  late Stream<List<Map<String, dynamic>>> _attemptStream;

  @override
  void initState() {
    super.initState();

    _quizStream = widget.firestoreService.getCurrentQuizzesForChild(
      widget.child.id,
    );

    _attemptStream = widget.firestoreService.getCurrentQuizAttemptsForChild(
      widget.child.id,
    );
  }

  void _openQuiz(Quiz quiz) {
    Navigator.pushNamed(
      context,
      '/quiz-play',
      arguments: {'quiz': quiz, 'childProfile': widget.child},
    );
  }

  Map<String, Map<String, dynamic>> _latestAttemptsByQuiz(
    List<Map<String, dynamic>> attempts,
  ) {
    final latest = <String, Map<String, dynamic>>{};

    for (final attempt in attempts) {
      final quizId = attempt['quizId'] as String? ?? '';

      if (quizId.isNotEmpty && !latest.containsKey(quizId)) {
        latest[quizId] = attempt;
      }
    }

    return latest;
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFF7E57C2).withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF7E57C2),
                  size: 58,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.l10n.noQuizzesNow,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.quizWillAppear,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 70,
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.childQuizzesLoadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.waitAndTryAgain, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required int quizCount, required int completedCount}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5C6BC0)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.readyToPlay(widget.child.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.quizzesToExplore(quizCount),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                if (completedCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFEB3B),
                        size: 22,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        context.l10n.quizzesPlayed(completedCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizGrid(
    List<Quiz> quizzes,
    Map<String, Map<String, dynamic>> latestAttempts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 410,
            mainAxisExtent: 295,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];

            return _ChildQuizCard(
              quiz: quiz,
              latestAttempt: latestAttempts[quiz.id],
              onTap: () => _openQuiz(quiz),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myQuizzes), centerTitle: true),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3F7FF), Color(0xFFFFF8E8), Color(0xFFF8F2FF)],
          ),
        ),
        child: StreamBuilder<List<Quiz>>(
          stream: _quizStream,
          builder: (context, quizSnapshot) {
            if (quizSnapshot.hasError) {
              return _buildErrorState();
            }

            if (!quizSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final quizzes =
                quizSnapshot.data!
                    .where((quiz) => quiz.questions.isNotEmpty)
                    .toList();

            if (quizzes.isEmpty) {
              return _buildEmptyState();
            }

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _attemptStream,
              builder: (context, attemptSnapshot) {
                final attempts = attemptSnapshot.data ?? [];
                final latestAttempts = _latestAttemptsByQuiz(attempts);

                final completedCount =
                    quizzes.where((quiz) {
                      return latestAttempts.containsKey(quiz.id);
                    }).length;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(
                        quizCount: quizzes.length,
                        completedCount: completedCount,
                      ),
                      _buildQuizGrid(quizzes, latestAttempts),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChildQuizCard extends StatelessWidget {
  final Quiz quiz;
  final Map<String, dynamic>? latestAttempt;
  final VoidCallback onTap;

  const _ChildQuizCard({
    required this.quiz,
    required this.latestAttempt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = quizStyleFor(quiz.iconName);
    final color = quizColorFromHex(quiz.colorHex);

    final score = latestAttempt?['score'] as int? ?? 0;
    final total = latestAttempt?['totalQuestions'] as int? ?? 0;

    final hasPlayed = latestAttempt != null;

    return Semantics(
      button: true,
      label: context.l10n.quizCardSemantics(quiz.title, quiz.questions.length),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withValues(alpha: 0.30), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.13),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 92,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.72)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(style.icon, color: Colors.white, size: 52),
                    ),
                    if (hasPlayed)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber.shade700,
                                size: 19,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                total > 0
                                    ? '$score/$total'
                                    : context.l10n.played,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        quiz.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        quiz.description.isEmpty
                            ? context.l10n.tapToStartQuiz
                            : quiz.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            context.l10n.questionCount(quiz.questions.length),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasPlayed
                                  ? Icons.replay_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasPlayed
                                  ? context.l10n.playAgain
                                  : context.l10n.letsPlay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
