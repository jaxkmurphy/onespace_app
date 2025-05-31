import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class PointsOverviewPage extends StatefulWidget {
  final String teacherUid;
  const PointsOverviewPage({super.key, required this.teacherUid});

  @override
  State<PointsOverviewPage> createState() => _PointsOverviewPageState();
}

class _PointsOverviewPageState extends State<PointsOverviewPage> {
  final FirestoreService firestore = FirestoreService();

  void _updatePoints(ChildProfile child, int delta) {
    int newPoints = (child.points + delta).clamp(0, 10);
    firestore.setChildPoints(widget.teacherUid, child.id, newPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Points Overview')),
      body: StreamBuilder<List<ChildProfile>>(
        stream: firestore.getChildProfiles(widget.teacherUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final children = snapshot.data!;

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return ListTile(
                title: Text(child.name),
                subtitle: Text("Points: ${child.points}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updatePoints(child, -1),
                      onLongPress: () => _updatePoints(child, -5), // long press subtracts 5
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updatePoints(child, 1),
                      onLongPress: () => _updatePoints(child, 5), // long press adds 5
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