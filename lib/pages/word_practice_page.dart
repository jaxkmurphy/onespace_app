import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import '../models/word_attempt.dart';

class WordPracticePage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;
  final String childId;
  final WordPack pack;

  const WordPracticePage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
    required this.childId,
    required this.pack,
  });

  @override
  State<WordPracticePage> createState() => _WordPracticePageState();
}

class _WordPracticePageState extends State<WordPracticePage> {
  final Random _random = Random();

  List<WordItem> _allWords = [];
  List<WordItem> _sessionWords = [];

  int _currentIndex = 0;
  WordItem? _currentWord;
  List<String> _choices = [];

  bool _isLoading = true;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await widget.firestoreService
        .getCurrentWordItems(widget.pack.id)
        .first;

    if (!mounted) return;

    if (words.length < 2) {
      setState(() {
        _allWords = words;
        _isLoading = false;
      });
      return;
    }

    words.shuffle();

    setState(() {
      _allWords = words;
      _sessionWords = words;
      _currentIndex = 0;
      _isLoading = false;
    });

    _setCurrentQuestion();
  }

  void _setCurrentQuestion() {
    if (_currentIndex >= _sessionWords.length) {
      setState(() {
        _isComplete = true;
      });
      return;
    }

    final correctWord = _sessionWords[_currentIndex];

    final wrongAnswers = _allWords
        .where((word) => word.id != correctWord.id)
        .map((word) => word.text)
        .toList();

    wrongAnswers.shuffle(_random);

    final choices = [
      correctWord.text,
      ...wrongAnswers.take(2),
    ];

    choices.shuffle(_random);

    setState(() {
      _currentWord = correctWord;
      _choices = choices;
    });
  }

  Future<void> _checkAnswer(String answer) async {
    if (_currentWord == null) return;

    final isCorrect = answer == _currentWord!.text;

    await widget.firestoreService.addCurrentWordAttempt(
      WordAttempt(
        id: '',
        childId: widget.childId,
        packId: widget.pack.id,
        wordId: _currentWord!.id,
        wordText: _currentWord!.text,
        selectedAnswer: answer,
        isCorrect: isCorrect,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'Great job!' : 'Try again',
        ),
        duration: const Duration(milliseconds: 700),
      ),
    );

    if (!isCorrect) return;

    setState(() {
      _currentIndex++;
    });

    _setCurrentQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.pack.name),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_allWords.length < 2) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.pack.name),
        ),
        body: const Center(
          child: Text(
            'This pack needs at least 2 words before it can be practised.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_isComplete) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.pack.name),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Practice Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You practised ${_sessionWords.length} words.',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Practise Again'),
                  onPressed: () {
                    setState(() {
                      _sessionWords.shuffle();
                      _currentIndex = 0;
                      _isComplete = false;
                    });

                    _setCurrentQuestion();
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Packs'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progressText =
        'Word ${_currentIndex + 1} of ${_sessionWords.length}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              progressText,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Text(
              _currentWord?.imageValue ?? '',
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              'What is this?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ..._choices.map((choice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _checkAnswer(choice),
                    child: Text(choice),
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