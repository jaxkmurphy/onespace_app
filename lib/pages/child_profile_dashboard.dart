import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import 'calming_sounds_page.dart';
import '../services/firestore_service.dart';
import 'background_color_picker_page.dart';
import '../utils/hex_colour.dart';  

class ChildProfileDashboard extends StatefulWidget {
  final ChildProfile profile;
  final FirestoreService firestoreService;

  const ChildProfileDashboard({
    super.key,
    required this.profile,
    required this.firestoreService,
  });

  @override
  State<ChildProfileDashboard> createState() => _ChildProfileDashboardState();
}

class _ChildProfileDashboardState extends State<ChildProfileDashboard> {
  late ChildProfile profile;
  Color backgroundColor = Colors.white; // default color

  @override
  void initState() {
    super.initState();
    profile = widget.profile;

    // Listen for real-time updates on the child's profile
    widget.firestoreService
        .getChildProfileStream(profile.teacherUid, profile.id)
        .listen((updatedProfile) {
      setState(() {
        profile = updatedProfile;
        // Parse the background color hex string, default to white if null
        backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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

            // Zones of Regulation button (1st)
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

            const SizedBox(height: 12),

            // Points button (2nd)
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

            // My Schedule button (3rd)
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text("My Schedule"),
              onPressed: () {
                Navigator.pushNamed(context, '/childSchedule');
              },
            ),

            const SizedBox(height: 12),

            // Calming Sounds button (4th)
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

            // Take a Quiz button (5th)
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text("Take a Quiz"),
              onPressed: () {
                print('Navigating to student quiz list page');
                Navigator.pushNamed(
                  context,
                  '/student-quiz-list',
                  arguments: {
                    'firestoreService': widget.firestoreService,
                    'child': profile,
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // Change Background Color button (6th)
            ElevatedButton.icon(
              icon: const Icon(Icons.format_paint),
              label: const Text("Change Background Color"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BackgroundColorPickerPage(
                      child: profile,
                      firestoreService: widget.firestoreService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}