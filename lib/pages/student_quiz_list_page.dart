import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import 'quiz_play_page.dart'; 

class StudentQuizListPage extends StatefulWidget {
  final FirestoreService firestoreService;

  const StudentQuizListPage({Key? key, required this.firestoreService}) : super(key: key);

  @override
  State<StudentQuizListPage> createState() => _StudentQuizListPageState();
}

class _StudentQuizListPageState extends State<StudentQuizListPage> {
  late final Stream<List<Quiz>> _quizStream;

  @override
  void initState() {
    super.initState();
    _quizStream = widget.firestoreService.getAllQuizzes(); // gets all quizzes
  }

  void _onQuizSelected(Quiz quiz) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizPlayPage(
        quiz: quiz,
        studentUid: 'example-student-uid',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: StreamBuilder<List<Quiz>>(
        stream: _quizStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = snapshot.data!;
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          }

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz.title),
                subtitle: Text('Created by: ${quiz.createdBy}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => _onQuizSelected(quiz),
              );
            },
          );
        },
      ),
    );
  }
}