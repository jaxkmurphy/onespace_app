import 'package:flutter/material.dart';

import '../data/word_learning_visuals.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import 'word_practice_page.dart';

class ChildWordLearningPage extends StatelessWidget {
  final FirestoreService firestoreService;
  final ChildProfile child;

  const ChildWordLearningPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  void _openPack(
    BuildContext context,
    WordPack pack,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordPracticePage(
          firestoreService: firestoreService,
          teacherUid: child.teacherUid,
          childId: child.id,
          pack: pack,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
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
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A)
                      .withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFF43A047),
                  size: 58,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.noAssignedWordPacks,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 2),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF66BB6A),
            Color(0xFF26A69A),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047)
                .withValues(alpha: 0.24),
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
              Icons.abc_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.wordPractice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.chooseMatchingWord,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.wordPractice),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3FFF5),
              Color(0xFFFFF8E8),
              Color(0xFFF7F2FF),
            ],
          ),
        ),
        child: StreamBuilder<List<WordPack>>(
          stream: firestoreService.getCurrentAssignedWordPacks(
            childId: child.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ChildWordMessageState(
                icon: Icons.cloud_off_rounded,
                message: context.l10n.couldNotLoadWordPacks,
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final packs = snapshot.data!;

            if (packs.isEmpty) {
              return _buildEmptyState(context);
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(16, 18, 16, 36),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 410,
                      mainAxisExtent: 292,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: packs.length,
                    itemBuilder: (context, index) {
                      final pack = packs[index];

                      return _ChildWordPackCard(
                        pack: pack,
                        firestoreService: firestoreService,
                        onTap: () => _openPack(
                          context,
                          pack,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChildWordPackCard extends StatelessWidget {
  final WordPack pack;
  final FirestoreService firestoreService;
  final VoidCallback onTap;

  const _ChildWordPackCard({
    required this.pack,
    required this.firestoreService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = wordPackStyleFor(pack.iconName);
    final color = wordPackColorFromHex(pack.colorHex);

    return StreamBuilder<List<WordItem>>(
      stream: firestoreService.getCurrentWordItems(pack.id),
      builder: (context, snapshot) {
        final words = snapshot.data ?? [];
        final canPractise = words.length >= 2;

        return Semantics(
          button: canPractise,
          label: pack.name,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: canPractise ? onTap : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: canPractise ? 1 : 0.62,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withValues(alpha: 0.30),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withValues(alpha: 0.72),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Icon(
                        style.icon,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              pack.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              pack.description.isEmpty
                                  ? context.l10n.tapToPractise
                                  : pack.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.abc_rounded,
                                  color: color,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  context.l10n
                                      .wordCount(words.length),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: canPractise
                                    ? color
                                    : Colors.grey.shade400,
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                canPractise
                                    ? context.l10n.tapToPractise
                                    : context
                                        .l10n.packNeedsTwoWords,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChildWordMessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ChildWordMessageState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: const Color(0xFF66BB6A),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}