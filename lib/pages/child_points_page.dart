import 'package:flutter/material.dart';
import '../models/child_profile.dart';

class ChildPointsPage extends StatelessWidget {
  final ChildProfile child;

  const ChildPointsPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Points')),
      body: Center(
        child: Text(
          '${child.points} Points',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
