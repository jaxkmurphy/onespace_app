import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ZoneOverviewPage extends StatelessWidget {
  final String? teacherUid;

  const ZoneOverviewPage({
    super.key,
    this.teacherUid,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Zones Overview')),
      body: StreamBuilder<List<ChildProfile>>(
        stream: firestoreService.getCurrentChildProfiles(),
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
              final zone = child.zone ?? '';
              final zoneColor = _getColorFromZone(zone);

              return ListTile(
                title: Text(child.name),
                subtitle: Text(
                  zone.isEmpty ? 'Zone: Not selected' : 'Zone: $zone',
                ),
                tileColor: zoneColor.withAlpha((0.2 * 255).round()),
                leading: CircleAvatar(
                  backgroundColor: zoneColor,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorFromZone(String zone) {
    switch (zone.toLowerCase()) {
      case 'green':
        return const Color(0xFF33975F);
      case 'red':
        return const Color(0xFFC72D2C);
      case 'yellow':
        return const Color(0xFFF6DE39);
      case 'blue':
        return const Color(0xFF425DAC);
      default:
        return Colors.grey;
    }
  }
}