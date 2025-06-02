import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import 'calming_sounds_page.dart';
import 'child_schedule_page.dart'; 

class ChildProfileDashboard extends StatelessWidget {
  final ChildProfile profile;

  const ChildProfileDashboard({super.key, required this.profile});

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
        title: Text('${profile.name} Dashboard'),
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
                  '/zone-select',
                  arguments: {
                    'teacherUid': profile.teacherUid,
                    'child': profile,
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text('View My Points'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/child-points',
                  arguments: profile,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('View Schedule'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildSchedulePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalmingSoundsPage()),
                );
              },
              child: const Text('Calming Sounds'),
            ),
          ],
        ),
      ),
    );
  }
}