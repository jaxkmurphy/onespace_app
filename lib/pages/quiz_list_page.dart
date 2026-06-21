import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/quiz_visuals.dart';
import '../models/child_profile.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';

class QuizListPage extends StatefulWidget {
  final String teacherUid;
  final FirestoreService firestoreService;

  QuizListPage({
    super.key,
    required this.teacherUid,
    FirestoreService? firestoreService,
  }) : firestoreService = firestoreService ?? FirestoreService();

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  void _createQuiz() {
    Navigator.pushNamed(
      context,
      '/quiz-create',
      arguments: {
        'staffUid': widget.teacherUid,
      },
    );
  }

  void _editQuiz(Quiz quiz) {
    Navigator.pushNamed(
      context,
      '/quiz-create',
      arguments: {
        'staffUid': widget.teacherUid,
        'quiz': quiz,
      },
    );
  }

  void _previewQuiz(Quiz quiz) {
    if (quiz.questions.isEmpty) {
      _showMessage('Add at least one question before previewing.');
      return;
    }

    Navigator.pushNamed(
      context,
      '/quiz-play',
      arguments: {
        'quiz': quiz,
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _duplicateQuiz(Quiz quiz) async {
    final now = DateTime.now();

    final duplicate = quiz.copyWith(
      id: widget.firestoreService.generateQuizId(),
      title: '${quiz.title} Copy',
      createdAt: now,
      updatedAt: now,
    );

    try {
      await widget.firestoreService.addCurrentQuiz(duplicate);
      _showMessage('Quiz duplicated successfully.');
    } catch (error) {
      _showMessage('Could not duplicate the quiz: $error');
    }
  }

  Future<void> _deleteQuiz(Quiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete quiz?'),
          content: Text(
            'Are you sure you want to delete “${quiz.title}”? '
            'Existing result history will be kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentQuiz(quiz.id);
      _showMessage('Quiz deleted.');
    } catch (error) {
      _showMessage('Could not delete the quiz: $error');
    }
  }

  Widget _buildLibraryTab() {
    return StreamBuilder<List<Quiz>>(
      stream: widget.firestoreService.getCurrentQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _MessageState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load quizzes',
            message: '${snapshot.error}',
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizzes = snapshot.data!;

        if (quizzes.isEmpty) {
          return _MessageState(
            icon: Icons.quiz_rounded,
            title: 'Your quiz library is empty',
            message: 'Create your first quiz to get started.',
            actionLabel: 'Create Quiz',
            onAction: _createQuiz,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth > 700 ? 24.0 : 14.0;

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                100,
              ),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 285,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];

                return _QuizLibraryCard(
                  quiz: quiz,
                  onPreview: () => _previewQuiz(quiz),
                  onEdit: () => _editQuiz(quiz),
                  onDuplicate: () => _duplicateQuiz(quiz),
                  onDelete: () => _deleteQuiz(quiz),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildResultsTab() {
    return StreamBuilder<List<ChildProfile>>(
      stream: widget.firestoreService.getCurrentChildProfiles(),
      builder: (context, childSnapshot) {
        if (childSnapshot.hasError) {
          return const _MessageState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load results',
            message: 'Child profiles could not be loaded.',
          );
        }

        if (!childSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Quiz>>(
          stream: widget.firestoreService.getCurrentQuizzes(),
          builder: (context, quizSnapshot) {
            if (!quizSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final children = childSnapshot.data!;
            final quizzes = quizSnapshot.data!;
            final quizzesById = {
              for (final quiz in quizzes) quiz.id: quiz,
            };

            if (children.isEmpty) {
              return const _MessageState(
                icon: Icons.people_outline_rounded,
                title: 'No child profiles',
                message:
                    'Quiz results will appear after profiles are added.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
              children: [
                Text(
                  'Quiz results',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Recent attempts and scores for each child.',
                ),
                const SizedBox(height: 18),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ChildQuizResultsCard(
                      child: child,
                      quizzesById: quizzesById,
                      firestoreService: widget.firestoreService,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.library_books_rounded),
                text: 'Quiz Library',
              ),
              Tab(
                icon: Icon(Icons.insights_rounded),
                text: 'Results',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createQuiz,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create Quiz'),
        ),
        body: TabBarView(
          children: [
            _buildLibraryTab(),
            _buildResultsTab(),
          ],
        ),
      ),
    );
  }
}

class _QuizLibraryCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _QuizLibraryCard({
    required this.quiz,
    required this.onPreview,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final style = quizStyleFor(quiz.iconName);
    final color = quizColorFromHex(quiz.colorHex);

    final audienceText = quiz.availableToAll
        ? 'Everyone'
        : '${quiz.assignedChildIds.length} selected';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            color: color,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor:
                            color.withValues(alpha: 0.15),
                        child: Icon(
                          style.icon,
                          color: color,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          quiz.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'More options',
                        onSelected: (value) {
                          switch (value) {
                            case 'duplicate':
                              onDuplicate();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'duplicate',
                            child: ListTile(
                              leading: Icon(Icons.copy_rounded),
                              title: Text('Duplicate'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quiz.description.isEmpty
                        ? 'No description added.'
                        : quiz.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.help_outline_rounded,
                        label:
                            '${quiz.questions.length} ${quiz.questions.length == 1 ? 'question' : 'questions'}',
                        color: color,
                      ),
                      _InfoChip(
                        icon: quiz.availableToAll
                            ? Icons.groups_rounded
                            : Icons.people_alt_rounded,
                        label: audienceText,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: quiz.questions.isEmpty
                              ? null
                              : onPreview,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Preview'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit'),
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildQuizResultsCard extends StatelessWidget {
  final ChildProfile child;
  final Map<String, Quiz> quizzesById;
  final FirestoreService firestoreService;

  const _ChildQuizResultsCard({
    required this.child,
    required this.quizzesById,
    required this.firestoreService,
  });

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) return 'Just now';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream:
          firestoreService.getCurrentQuizAttemptsForChild(child.id),
      builder: (context, snapshot) {
        final attempts = snapshot.data ?? [];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Text(
                child.name.isEmpty
                    ? '?'
                    : child.name.substring(0, 1).toUpperCase(),
              ),
            ),
            title: Text(
              child.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Loading attempts...'
                  : attempts.isEmpty
                      ? 'No quiz attempts yet'
                      : '${attempts.length} ${attempts.length == 1 ? 'attempt' : 'attempts'}',
            ),
            children: [
              if (snapshot.hasError)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Could not load attempts.'),
                )
              else if (attempts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Results will appear after this child completes a quiz.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...attempts.take(5).map((attempt) {
                  final quizId = attempt['quizId'] as String? ?? '';
                  final quiz = quizzesById[quizId];

                  final score = attempt['score'] as int? ?? 0;
                  final total =
                      attempt['totalQuestions'] as int? ?? 0;
                  final percentage =
                      attempt['percentage'] as int? ?? 0;

                  final style = quizStyleFor(
                    quiz?.iconName ?? 'quiz',
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          style.color.withValues(alpha: 0.14),
                      child: Icon(
                        style.icon,
                        color: style.color,
                      ),
                    ),
                    title: Text(
                      quiz?.title ?? 'Deleted quiz',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(_formatDate(attempt['timestamp'])),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        total > 0
                            ? '$score/$total  •  $percentage%'
                            : '$score points',
                        style: TextStyle(
                          color: style.color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 74,
              color: const Color(0xFF7E57C2),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}