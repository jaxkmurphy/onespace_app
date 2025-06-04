import 'package:flutter/material.dart';
import '../models/quiz.dart'; // Make sure this points to your Quiz model
import '../services/firestore_service.dart'; // Your FirestoreService import

class QuizListPage extends StatefulWidget {
  final String teacherUid;
  final FirestoreService firestoreService;

  QuizListPage({
    Key? key,
    required this.teacherUid,
    FirestoreService? firestoreService,
  })  : firestoreService = firestoreService ?? FirestoreService(),
        super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  Stream<List<Quiz>> _fetchQuizzes() {
  return widget.firestoreService.getQuizzes(widget.teacherUid);
}

  void _onQuizTap(Quiz quiz) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected quiz: ${quiz.title}')),
    );
    // TODO: Navigate to quiz play page or quiz details
    // Navigator.pushNamed(context, '/quiz-play', arguments: quiz);
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
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => _onQuizTap(quiz),
              );
            },
          );
        },
      ),
    );
  }
}