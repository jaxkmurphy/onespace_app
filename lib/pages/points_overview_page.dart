import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class PointsOverviewPage extends StatefulWidget {
  final String? teacherUid;

  const PointsOverviewPage({
    super.key,
    this.teacherUid,
  });

  @override
  State<PointsOverviewPage> createState() => _PointsOverviewPageState();
}

class _PointsOverviewPageState extends State<PointsOverviewPage> {
  final FirestoreService firestore = FirestoreService();

  Future<void> _updatePoints(ChildProfile child, int delta) async {
    final newPoints = (child.points + delta).clamp(0, 10);

    try {
      await firestore.setCurrentChildPoints(
        childId: child.id,
        points: newPoints,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update points: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points Overview'),
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: firestore.getCurrentChildProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data!;

          if (children.isEmpty) {
            return const Center(child: Text('No child profiles found'));
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];

              return ListTile(
                title: Text(child.name),
                subtitle: Text('Points: ${child.points}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updatePoints(child, -1),
                      onLongPress: () => _updatePoints(child, -5),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updatePoints(child, 1),
                      onLongPress: () => _updatePoints(child, 5),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}