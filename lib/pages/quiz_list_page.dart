import 'package:flutter/material.dart';
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
  Stream<List<Quiz>> _fetchQuizzes() {
    return widget.firestoreService.getQuizzes(widget.teacherUid);
  }

  void _createQuiz() {
    Navigator.pushNamed(
      context,
      '/quiz-create',
      arguments: widget.teacherUid,
    );
  }

  void _onQuizTap(Quiz quiz) {
    Navigator.pushNamed(
      context,
      '/quiz-play',
      arguments: {
        'quiz': quiz,
      },
    );
  }

  Future<void> _deleteQuiz(Quiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteQuiz(widget.teacherUid, quiz.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz "${quiz.title}" deleted')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete quiz: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createQuiz,
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
      ),
      body: StreamBuilder<List<Quiz>>(
        stream: _fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading quizzes: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = snapshot.data!;

          if (quizzes.isEmpty) {
            return const Center(
              child: Text(
                'No quizzes found.\nTap "Create Quiz" to add one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(quiz.title),
                  subtitle: Text('${quiz.questions.length} question(s)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Quiz',
                    onPressed: () => _deleteQuiz(quiz),
                  ),
                  onTap: () => _onQuizTap(quiz),
                ),
              );
            },
          );
        },
      ),
    );
  }
}