import 'package:flutter/material.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../models/child_profile.dart';
import 'staff_schedule_page.dart'; 

class StaffProfileDashboard extends StatefulWidget {
  final StaffProfile profile;

  const StaffProfileDashboard({super.key, required this.profile});

  @override
  State<StaffProfileDashboard> createState() => _StaffProfileDashboardState();
}

class _StaffProfileDashboardState extends State<StaffProfileDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToPointsOverview() async {
    try {
      final List<ChildProfile> children = await _firestoreService
          .getChildProfiles(widget.profile.teacherUid)
          .first;  // get first snapshot only

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/points-overview',
        arguments: {
          'teacherUid': widget.profile.teacherUid,
          'children': children,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load children profiles: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profiles',
              (route) => false,
            );
          },
        ),
        title: Text('${widget.profile.name} Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.palette),
              label: const Text('Zones of Regulation'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/zone-overview',
                  arguments: {
                    'teacherUid': widget.profile.teacherUid,
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text('Points Overview'),
              onPressed: _navigateToPointsOverview,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('View Schedule'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffSchedulePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}