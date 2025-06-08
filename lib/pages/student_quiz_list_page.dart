import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import '../models/child_profile.dart';
import 'quiz_play_page.dart';

class StudentQuizListPage extends StatelessWidget {
  final FirestoreService firestoreService;
  final ChildProfile child;

  const StudentQuizListPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: StreamBuilder<List<Quiz>>(
        stream: firestoreService.getQuizzes(child.teacherUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading quizzes'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = snapshot.data!;
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('Tapped quiz: ${quiz.title}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPlayPage(
                          quiz: quiz,
                          studentUid: child.id,
                        ),
                      ),
                    );
                  },
                  child: Text(quiz.title),
                ),
              );
            },
          );
        },
      ),
    );
  }
}