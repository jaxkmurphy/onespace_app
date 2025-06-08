import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizPlayPage extends StatefulWidget {  // <-- StatefulWidget here
  final Quiz quiz;
  final String studentUid;

  const QuizPlayPage({
    Key? key,
    required this.quiz,
    required this.studentUid,
  }) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int current = 0;
  int score = 0;

  void _answer(String selected) {
    if (selected == widget.quiz.questions[current].correctAnswer) {
      score++;
    }

    if (current < widget.quiz.questions.length - 1) {
      setState(() => current++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Score: $score / ${widget.quiz.questions.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: const Text('Done'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[current];

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...question.options.map((option) => ElevatedButton(
              onPressed: () => _answer(option),
              child: Text(option),
            )).toList(),
          ],
        ),
      ),
    );
  }
}