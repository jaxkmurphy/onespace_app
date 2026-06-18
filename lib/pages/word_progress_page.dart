import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/word_attempt.dart';
import '../services/firestore_service.dart';

class WordProgressPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;

  const WordProgressPage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
  });

  @override
  State<WordProgressPage> createState() => _WordProgressPageState();
}

class _WordProgressPageState extends State<WordProgressPage> {
  ChildProfile? _selectedChild;
  List<ChildProfile> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await widget.firestoreService.getCurrentChildProfilesOnce();

    if (!mounted) return;

    setState(() {
      _children = children;
      if (children.isNotEmpty) {
        _selectedChild = children.first;
      }
    });
  }

  int _correctCount(List<WordAttempt> attempts) {
    return attempts.where((attempt) => attempt.isCorrect).length;
  }

  double _accuracy(List<WordAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    return (_correctCount(attempts) / attempts.length) * 100;
  }

  Map<String, List<WordAttempt>> _groupByWord(List<WordAttempt> attempts) {
    final grouped = <String, List<WordAttempt>>{};

    for (final attempt in attempts) {
      grouped.putIfAbsent(attempt.wordText, () => []);
      grouped[attempt.wordText]!.add(attempt);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Word Progress'),
        ),
        body: const Center(
          child: Text('No child profiles found.'),
        ),
      );
    }

    final selectedChild = _selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Progress'),
      ),
      body: selectedChild == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<ChildProfile>(
                    initialValue: selectedChild,
                    decoration: const InputDecoration(
                      labelText: 'Select Child',
                      border: OutlineInputBorder(),
                    ),
                    items: _children.map((child) {
                      return DropdownMenuItem<ChildProfile>(
                        value: child,
                        child: Text(child.name),
                      );
                    }).toList(),
                    onChanged: (child) {
                      setState(() {
                        _selectedChild = child;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<WordAttempt>>(
                    stream: widget.firestoreService
                        .getCurrentWordAttemptsForChild(
                      childId: selectedChild.id,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final attempts = snapshot.data!;

                      if (attempts.isEmpty) {
                        return const Center(
                          child: Text('No word practice attempts yet.'),
                        );
                      }

                      final correct = _correctCount(attempts);
                      final accuracy = _accuracy(attempts);
                      final groupedWords = _groupByWord(attempts);

                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedChild.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Total attempts: ${attempts.length}'),
                                  Text('Correct answers: $correct'),
                                  Text(
                                    'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Word Breakdown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...groupedWords.entries.map((entry) {
                            final wordAttempts = entry.value;
                            final wordCorrect = _correctCount(wordAttempts);
                            final wordAccuracy = _accuracy(wordAttempts);

                            return Card(
                              child: ListTile(
                                title: Text(entry.key),
                                subtitle: Text(
                                  'Attempts: ${wordAttempts.length} | Correct: $wordCorrect | Accuracy: ${wordAccuracy.toStringAsFixed(1)}%',
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}