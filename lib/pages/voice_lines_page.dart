import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/voice_lines.dart';
import '../simple_localizations.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class VoiceLinesPage extends StatelessWidget {
  final AudioPlayer _player = AudioPlayer();

  final FirestoreService firestoreService;
  final ChildProfile child;

  VoiceLinesPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  void _playVoiceLine(BuildContext context, VoiceLine line) {
    final locale = Localizations.localeOf(context).languageCode;
    final path = locale == 'ga' ? line.audioGA : line.audioEN;

    _player.stop(); // Stop any previous audio
    _player.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = SimpleLocalizations(Localizations.localeOf(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getString('voice_lines_title')),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: voiceLines.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final line = voiceLines[index];
          final locale = Localizations.localeOf(context).languageCode;
          final label = locale == 'ga' ? line.labelGA : line.labelEN;

          return GestureDetector(
            onTap: () => _playVoiceLine(context, line),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(line.icon, size: 48),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}