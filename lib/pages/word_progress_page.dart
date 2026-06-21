import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
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
  bool _isLoadingChildren = true;

  static const Color _mainColor = Color(0xFF5E35B1);
  static const Color _accentColor = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children =
          await widget.firestoreService.getCurrentChildProfilesOnce();

      if (!mounted) return;

      setState(() {
        _children = children;
        _selectedChild = children.isNotEmpty ? children.first : null;
        _isLoadingChildren = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _children = [];
        _selectedChild = null;
        _isLoadingChildren = false;
      });
    }
  }

  int _correctCount(List<WordAttempt> attempts) {
    return attempts.where((attempt) => attempt.isCorrect).length;
  }

  double _accuracy(List<WordAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    return (_correctCount(attempts) / attempts.length) * 100;
  }

  Map<String, List<WordAttempt>> _groupByWord(
    List<WordAttempt> attempts,
  ) {
    final grouped = <String, List<WordAttempt>>{};

    for (final attempt in attempts) {
      final word = attempt.wordText.trim().isEmpty
          ? context.l10n.word
          : attempt.wordText.trim();

      grouped.putIfAbsent(word, () => []);
      grouped[word]!.add(attempt);
    }

    return grouped;
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: _mainColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _mainColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ChildProfile child) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _mainColor,
            _accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _mainColor.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.wordProgress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  child.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector(ChildProfile selectedChild) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _mainColor.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: DropdownButtonFormField<ChildProfile>(
          initialValue: selectedChild,
          decoration: InputDecoration(
            labelText: context.l10n.selectChild,
            prefixIcon: const Icon(Icons.child_care_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
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
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<WordAttempt> attempts) {
    final correct = _correctCount(attempts);
    final accuracy = _accuracy(attempts).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: [
          _buildSummaryCard(
            icon: Icons.touch_app_rounded,
            label: context.l10n.totalAttempts(attempts.length),
            value: attempts.length.toString(),
            color: _mainColor,
          ),
          _buildSummaryCard(
            icon: Icons.check_circle_rounded,
            label: context.l10n.correctAnswers(correct),
            value: correct.toString(),
            color: Colors.green.shade700,
          ),
          _buildSummaryCard(
            icon: Icons.percent_rounded,
            label: context.l10n.accuracy(accuracy),
            value: '$accuracy%',
            color: _accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWordBreakdown(List<WordAttempt> attempts) {
    final groupedWords = _groupByWord(attempts).entries.toList()
      ..sort((first, second) {
        final firstAccuracy = _accuracy(first.value);
        final secondAccuracy = _accuracy(second.value);

        return secondAccuracy.compareTo(firstAccuracy);
      });

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _mainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.abc_rounded,
                  color: _mainColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.wordBreakdown,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...groupedWords.map((entry) {
            final wordAttempts = entry.value;
            final wordCorrect = _correctCount(wordAttempts);
            final wordAccuracy = _accuracy(wordAttempts);
            final progress = wordAttempts.isEmpty
                ? 0.0
                : wordCorrect / wordAttempts.length;

            final progressColor = wordAccuracy >= 75
                ? Colors.green.shade700
                : wordAccuracy >= 45
                    ? Colors.orange.shade700
                    : Colors.red.shade700;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: progressColor.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${wordAccuracy.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.attemptSummary(
                        wordAttempts.length,
                        wordCorrect,
                        wordAccuracy.toStringAsFixed(1),
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        color: progressColor,
                        backgroundColor:
                            progressColor.withValues(alpha: 0.13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressContent(
    ChildProfile selectedChild,
    List<WordAttempt> attempts,
  ) {
    if (attempts.isEmpty) {
      return _buildMessageState(
        icon: Icons.auto_stories_outlined,
        title: context.l10n.noWordAttempts,
        subtitle: context.l10n.selectChildForProgress,
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            _buildHeader(selectedChild),
            _buildChildSelector(selectedChild),
            _buildSummary(attempts),
            _buildWordBreakdown(attempts),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = _selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.wordProgress),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F2FF),
              Color(0xFFF3FFF5),
              Color(0xFFFFF8E8),
            ],
          ),
        ),
        child: _isLoadingChildren
            ? const Center(child: CircularProgressIndicator())
            : _children.isEmpty
                ? _buildMessageState(
                    icon: Icons.group_off_rounded,
                    title: context.l10n.noChildrenAvailable,
                  )
                : selectedChild == null
                    ? _buildMessageState(
                        icon: Icons.child_care_rounded,
                        title: context.l10n.selectChildForProgress,
                      )
                    : StreamBuilder<List<WordAttempt>>(
                        stream: widget.firestoreService
                            .getCurrentWordAttemptsForChild(
                          childId: selectedChild.id,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildMessageState(
                              icon: Icons.cloud_off_rounded,
                              title: context.l10n.error,
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return _buildProgressContent(
                            selectedChild,
                            snapshot.data!,
                          );
                        },
                      ),
      ),
    );
  }
}