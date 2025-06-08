import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import 'calming_sounds_page.dart';

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
        title: Text('${profile.name}\'s Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${profile.name}!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 24),

            // Take a Quiz button
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text("Take a Quiz"),
              onPressed: () {
                print('Navigating to quiz list page');
                Navigator.pushNamed(
                  context,
                  '/quiz-list',
                  arguments: profile.teacherUid,
                );
              },
            ),

            const SizedBox(height: 12),

            // Calming Sounds button
            ElevatedButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text("Calming Sounds"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalmingSoundsPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            // My Schedule button
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text("My Schedule"),
              onPressed: () {
                Navigator.pushNamed(context, '/childSchedule');
              },
            ),

            const SizedBox(height: 12),

            // Points button
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text("My Points"),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/child-points',
                  arguments: profile,
                );
              },
            ),

            const SizedBox(height: 12),

            // Zones of Regulation button
            ElevatedButton.icon(
              icon: const Icon(Icons.color_lens),
              label: const Text("Zones of Regulation"),
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
          ],
        ),
      ),
    );
  }
}