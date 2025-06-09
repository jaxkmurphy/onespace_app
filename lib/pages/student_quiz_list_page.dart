import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import '../models/child_profile.dart';

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

  @override
  void initState() {
    super.initState();
    _quizStream = widget.firestoreService.getQuizzes(widget.child.teacherUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: StreamBuilder<List<Quiz>>(
        stream: _quizStream,
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
                    Navigator.pushNamed(
                      context,
                      '/quiz-play',
                      arguments: {
                        'quiz': quiz,
                        'studentUid': widget.child.id,
                      },
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