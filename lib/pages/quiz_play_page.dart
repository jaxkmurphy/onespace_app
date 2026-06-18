import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  final ChildProfile? childProfile;

  const QuizPlayPage({
    super.key,
    required this.quiz,
    this.childProfile,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  final FirestoreService _firestoreService = FirestoreService();

  int current = 0;
  int score = 0;

  bool get isStaffPreview => widget.childProfile == null;

  Future<void> _answer(String selected) async {
    if (isStaffPreview) {
      if (current < widget.quiz.questions.length - 1) {
        setState(() => current++);
      }
      return;
    }

    if (selected == widget.quiz.questions[current].correctAnswer) {
      score++;
    }

    if (current < widget.quiz.questions.length - 1) {
      setState(() => current++);
      return;
    }

    await _submitAndShowResult();
  }

  Future<void> _submitAndShowResult() async {
    final childProfile = widget.childProfile;

    if (childProfile == null) return;

    await _firestoreService.submitCurrentQuiz(
      childId: childProfile.id,
      quizId: widget.quiz.id,
      score: score,
    );

    if (!mounted) return;

    _showResult();
  }

  void _showResult() {
    if (isStaffPreview) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Quiz Complete!'),
          content: Text(
            'Score: $score / ${widget.quiz.questions.length}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/child-dashboard',
                  (route) => false,
                  arguments: widget.childProfile,
                );
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[current];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        bottom: isStaffPreview
            ? PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Container(
                  color: Colors.orangeAccent,
                  height: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    'Staff Preview Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _answer(option),
                    child: Text(option),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}