import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ChildPointsPage extends StatelessWidget {
  final ChildProfile child;

  const ChildPointsPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Points')),
      body: StreamBuilder<List<ChildProfile>>(
        stream: firestoreService.getCurrentChildProfiles(),
        builder: (context, snapshot) {
          final children = snapshot.data ?? [];

          final updatedChild = children.where((item) => item.id == child.id);

          final points = updatedChild.isNotEmpty
              ? updatedChild.first.points
              : child.points;

          return Center(
            child: Text(
              '$points Points',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}