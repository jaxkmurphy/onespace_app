import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  final String studentUid; // Add student UID to save result per student

  const QuizPlayPage({Key? key, required this.quiz, required this.studentUid}) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  int score = 0;
  bool quizCompleted = false;

  void _submitAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      if (answer == widget.quiz.questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      } else {
        setState(() {
          quizCompleted = true;
        });
        _saveResult();
        _showQuizCompleteDialog();
      }
    });
  }

  Future<void> _saveResult() async {
    final resultsCollection = FirebaseFirestore.instance.collection('quizResults');

    await resultsCollection.add({
      'quizId': widget.quiz.id,
      'studentUid': widget.studentUid,
      'score': score,
      'total': widget.quiz.questions.length,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showQuizCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Your score: $score / ${widget.quiz.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to quiz list or previous page
            },
            child: const Text('Back to Quizzes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _restartQuiz();
            },
            child: const Text('Retake Quiz'),
          ),
        ],
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      score = 0;
      quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      // Show final score or some summary if you want
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: Center(
          child: Text('Quiz Complete! Your score: $score / ${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 24)),
        ),
      );
    }

    final question = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ...question.options.map((option) {
              final isSelected = option == selectedAnswer;
              final isCorrect = selectedAnswer != null && option == question.correctAnswer;

              return GestureDetector(
                onTap: selectedAnswer == null ? () => _submitAnswer(option) : null,
                child: Card(
                  color: selectedAnswer == null
                      ? Colors.white
                      : isCorrect
                          ? Colors.green
                          : isSelected
                              ? Colors.red
                              : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}