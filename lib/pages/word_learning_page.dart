import 'package:flutter/material.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import 'word_pack_editor_page.dart';
import 'word_progress_page.dart';

class WordLearningPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;
  final String staffId;
  final String staffName;

  const WordLearningPage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<WordLearningPage> createState() => _WordLearningPageState();
}

class _WordLearningPageState extends State<WordLearningPage> {
  Future<void> _createWordPack() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Create Word Pack'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Pack Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    final newPack = WordPack(
      id: '',
      name: result,
      description: '',
      createdByStaffId: widget.staffId,
      createdByStaffName: widget.staffName,
      assignedChildIds: [],
    );

    await widget.firestoreService.addWordPack(
      teacherUid: widget.teacherUid,
      pack: newPack,
    );
  }

  Future<void> _deletePack(WordPack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Word Pack'),
          content: Text(
            'Delete "${pack.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.firestoreService.deleteWordPack(
      teacherUid: widget.teacherUid,
      packId: pack.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Learning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Progress',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WordProgressPage(
                    firestoreService: widget.firestoreService,
                    teacherUid: widget.teacherUid,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createWordPack,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<WordPack>>(
        stream: widget.firestoreService.getWordPacks(
          widget.teacherUid,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final packs = snapshot.data!;

          if (packs.isEmpty) {
            return const Center(
              child: Text(
                'No word packs yet.\nTap + to create one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: packs.length,
            itemBuilder: (context, index) {
              final pack = packs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordPackEditorPage(
                        firestoreService: widget.firestoreService,
                        teacherUid: widget.teacherUid,
                        pack: pack,
                      ),
                    ),
                  );
                },
                title: Text(pack.name),
                subtitle: Text(
                  'Created by ${pack.createdByStaffName}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePack(pack),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}