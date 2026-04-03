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
  bool _isLoading = false;

  final List<Map<String, String>> _sounds = const [
    {'title': 'Ocean Sound 1', 'asset': 'sounds/oceanSound1.mp3'},
    {'title': 'Ocean Sound 2', 'asset': 'sounds/oceanSound2.mp3'},
    {'title': 'Ocean Sound 3', 'asset': 'sounds/oceanSound3.mp3'},
    {'title': 'Ocean Sound 4', 'asset': 'sounds/oceanSound4.mp3'},
    {'title': 'Ocean Sound 5', 'asset': 'sounds/oceanSound5.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _currentSound = null);
      }
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playOrStopSound(String title, String assetPath) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_currentSound == title) {
        await _player.stop();
        if (mounted) {
          setState(() => _currentSound = null);
        }
        return;
      }

      await _player.stop();
      await _player.play(AssetSource(assetPath));

      if (mounted) {
        setState(() => _currentSound = title);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _currentSound = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play "$title". Check the asset file.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calming Sounds'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sounds.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sound = _sounds[index];
          final title = sound['title']!;
          final asset = sound['asset']!;
          final isPlaying = _currentSound == title;

          return Card(
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Icon(
                isPlaying ? Icons.graphic_eq : Icons.spa_outlined,
                size: 32,
              ),
              title: Text(title),
              subtitle: Text(isPlaying ? 'Tap to stop' : 'Tap to play'),
              trailing: Icon(
                isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_fill,
                size: 34,
              ),
              onTap: () => _playOrStopSound(title, asset),
            ),
          );
        },
      ),
    );
  }
}