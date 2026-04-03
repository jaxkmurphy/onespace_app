import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../data/voice_lines.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';

class VoiceLinesPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final ChildProfile child;

  const VoiceLinesPage({
    super.key,
    required this.firestoreService,
    required this.child,
  });

  @override
  State<VoiceLinesPage> createState() => _VoiceLinesPageState();
}

class _VoiceLinesPageState extends State<VoiceLinesPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playVoiceLine(BuildContext context, VoiceLine line) async {
    if (_isLoading) return;

    final locale = Localizations.localeOf(context).languageCode;
    final rawPath = locale == 'ga' ? line.audioGA : line.audioEN;
    final assetPath = rawPath.replaceFirst(RegExp(r'^assets/'), '');

    setState(() => _isLoading = true);

    try {
      if (_currentlyPlayingPath == assetPath) {
        await _player.stop();
        if (mounted) {
          setState(() => _currentlyPlayingPath = null);
        }
        return;
      }

      await _player.stop();
      await _player.play(AssetSource(assetPath));

      if (mounted) {
        setState(() => _currentlyPlayingPath = assetPath);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _currentlyPlayingPath = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice line audio is missing or could not be played.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = SimpleLocalizations(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getString('voice_lines_title')),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: voiceLines.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final line = voiceLines[index];
              final label = locale == 'ga' ? line.labelGA : line.labelEN;
              final rawPath = locale == 'ga' ? line.audioGA : line.audioEN;
              final assetPath = rawPath.replaceFirst(RegExp(r'^assets/'), '');
              final isPlaying = _currentlyPlayingPath == assetPath;

              return Material(
                color: isPlaying
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _playVoiceLine(context, line),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          line.icon,
                          size: 52,
                          color: isPlaying
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Icon(
                          isPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.volume_up_rounded,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}