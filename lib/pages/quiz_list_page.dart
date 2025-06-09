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

  void _onQuizTap(Quiz quiz) {
    // For staff, now we navigate to quiz play (staff preview mode)
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
        content: Text('Are you sure you want to delete "${quiz.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.firestoreService.deleteQuiz(widget.teacherUid, quiz.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "${quiz.title}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete quiz: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quizzes'),
      ),
      body: StreamBuilder<List<Quiz>>(
        stream: _fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snapshot.data!;
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes found.'));
          }
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Quiz',
                      onPressed: () => _deleteQuiz(quiz),
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
                onTap: () => _onQuizTap(quiz),
              );
            },
          );
        },
      ),
    );
  }
}