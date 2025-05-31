import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CalmingSoundsPage extends StatefulWidget {
  const CalmingSoundsPage({super.key});

  @override
  State<CalmingSoundsPage> createState() => _CalmingSoundsPageState();
}

class _CalmingSoundsPageState extends State<CalmingSoundsPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentSound;

  final List<Map<String, String>> _sounds = [
    {'title': 'Sound 1', 'asset': 'assets/sounds/oceanSound1.mp3'},
    {'title': 'Sound 2', 'asset': 'assets/sounds/oceanSound2.mp3'},
    {'title': 'Sound 3', 'asset': 'assets/sounds/oceanSound3.mp3'},
    {'title': 'Sound 4', 'asset': 'assets/sounds/oceanSound4.mp3'},
    {'title': 'Sound 5', 'asset': 'assets/sounds/oceanSound5.mp3'},
  ];

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSound(String title, String assetPath) async {
    if (_currentSound == title) {
      await _player.stop();
      setState(() => _currentSound = null);
      return;
    }

    await _player.stop(); // Stop current sound if any
    await _player.play(AssetSource(assetPath));
    _player.setReleaseMode(ReleaseMode.loop); // Loop the sound
    setState(() => _currentSound = title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calming Sounds')),
      body: ListView.builder(
        itemCount: _sounds.length,
        itemBuilder: (context, index) {
          final sound = _sounds[index];
          final isPlaying = _currentSound == sound['title'];

          return Card(
            color: isPlaying ? Colors.blue.shade100 : null,
            child: ListTile(
              title: Text(sound['title']!),
              trailing: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
              onTap: () => _playSound(sound['title']!, sound['asset']!),
            ),
          );
        },
      ),
    );
  }
}