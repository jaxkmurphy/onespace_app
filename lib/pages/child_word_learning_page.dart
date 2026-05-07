import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import 'word_practice_page.dart';

class ChildWordLearningPage
    extends StatelessWidget {
  final FirestoreService
      firestoreService;
  final ChildProfile child;

  const ChildWordLearningPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Word Practice'),
      ),
      body:
          StreamBuilder<
              List<WordPack>>(
        stream:
            firestoreService
                .getAssignedWordPacks(
          teacherUid:
              child.teacherUid,
          childId: child.id,
        ),
        builder: (
          context,
          snapshot,
        ) {
          if (!snapshot
              .hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final packs =
              snapshot.data!;

          if (packs.isEmpty) {
            return const Center(
              child: Text(
                'No word packs assigned yet.',
              ),
            );
          }

          return ListView.builder(
            itemCount:
                packs.length,
            itemBuilder: (
              context,
              index,
            ) {
              final pack =
                  packs[index];

              return Card(
                margin:
                    const EdgeInsets.all(
                  8,
                ),
                child:
                    ListTile(
                  leading:
                      const Icon(
                    Icons
                        .menu_book,
                  ),
                  title: Text(
                    pack.name,
                  ),
                  subtitle:
                      Text(
                    'Tap to practise',
                  ),
                  onTap: () {
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
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}