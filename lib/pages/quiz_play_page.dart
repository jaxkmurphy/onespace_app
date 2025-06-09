import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/child_profile.dart'; 

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
  int current = 0;
  int score = 0;

  bool get isStaffPreview => widget.childProfile == null;

  void _answer(String selected) {
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
    } else {
      _showResult();
    }
  }

  void _showResult() {
    if (isStaffPreview) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Score: $score / ${widget.quiz.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/child-dashboard',
                (route) => false,
                arguments: widget.childProfile, // pass full profile back
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...question.options.map((option) => ElevatedButton(
              onPressed: () => _answer(option),
              child: Text(option),
            )),
          ],
        ),
      ),
    );
  }
}