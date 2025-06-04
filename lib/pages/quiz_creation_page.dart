import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; 
import '../models/question.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';

class QuizCreationPage extends StatefulWidget {
  final String staffUid;

  const QuizCreationPage({super.key, required this.staffUid});

  @override
  _QuizCreationPageState createState() => _QuizCreationPageState();
}

class _QuizCreationPageState extends State<QuizCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();

  final List<QuestionForm> _questionForms = [QuestionForm()];

  final FirestoreService _firestoreService = FirestoreService();

  void _addQuestion() {
    setState(() {
      _questionForms.add(QuestionForm());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionForms.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate each question form
    for (var qf in _questionForms) {
      if (!qf.isValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all question fields properly')),
        );
        return;
      }
    }

    // Build the quiz object
    var quizId = Uuid().v4();
    List<Question> questions = _questionForms.map((qf) => qf.toQuestion()).toList();

    var quiz = Quiz(
      id: quizId,
      title: _quizTitleController.text.trim(),
      createdBy: widget.staffUid,
      questions: questions,
    );

    // Save to Firestore
    await _firestoreService.addQuiz(quiz);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quiz saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Quiz'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quizTitleController,
                decoration: InputDecoration(labelText: 'Quiz Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a quiz title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _questionForms.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Question ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                              if (_questionForms.length > 1)
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeQuestion(index),
                                )
                            ],
                          ),
                          _questionForms[index],
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: Icon(Icons.add),
                label: Text('Add Question'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuiz,
                child: Text('Save Quiz'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget to handle question inputs
class QuestionForm extends StatefulWidget {
  final _QuestionFormState _state = _QuestionFormState();

  QuestionForm({super.key});

  bool isValid() => _state.validate();

  Question toQuestion() => _state.toQuestion();

  @override
  _QuestionFormState createState() => _state;
}

class _QuestionFormState extends State<QuestionForm> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctOptionIndex = 0;

  bool validate() {
    if (_questionController.text.trim().isEmpty) return false;
    for (var c in _optionControllers) {
      if (c.text.trim().isEmpty) return false;
    }
    if (_correctOptionIndex < 0 || _correctOptionIndex >= _optionControllers.length) return false;
    return true;
  }

  Question toQuestion() {
    return Question(
      question: _questionController.text.trim(),
      options: _optionControllers.map((c) => c.text.trim()).toList(),
      correctAnswer: _optionControllers[_correctOptionIndex].text.trim(),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _questionController,
          decoration: InputDecoration(labelText: 'Question'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a question';
            }
            return null;
          },
        ),
        SizedBox(height: 12),
        ...List.generate(_optionControllers.length, (index) {
          return RadioListTile<int>(
            value: index,
            groupValue: _correctOptionIndex,
            onChanged: (value) {
              setState(() {
                _correctOptionIndex = value!;
              });
            },
            title: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(labelText: 'Option ${index + 1}'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter option ${index + 1}';
                }
                return null;
              },
            ),
          );
        }),
      ],
    );
  }
}