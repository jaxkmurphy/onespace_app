import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class CalmingSoundsPage extends StatefulWidget {
  const CalmingSoundsPage({super.key});

  @override
  State<CalmingSoundsPage> createState() => _CalmingSoundsPageState();
}

class _CalmingSoundsPageState extends State<CalmingSoundsPage> {
  final AudioPlayer _player = AudioPlayer();

  CalmingSoundCategory? _selectedCategory;
  CalmingSoundTrack? _currentTrack;

  bool _isLoading = false;
  bool _isPaused = false;
  double _volume = 0.75;

  final List<CalmingSoundCategory> _categories = const [
    CalmingSoundCategory(
      id: 'ocean',
      titleEn: 'Ocean',
      titleGa: 'Aigéan',
      subtitleEn: 'Gentle waves and sea sounds',
      subtitleGa: 'Tonnta séimhe agus fuaimeanna farraige',
      emoji: '🌊',
      icon: Icons.waves_rounded,
      colors: [Color(0xFF26A69A), Color(0xFF29B6F6)],
      tracks: [
        CalmingSoundTrack(
          titleEn: 'Gentle Waves',
          titleGa: 'Tonnta Séimhe',
          assetPath: 'sounds/ocean/oceanSound1.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Calm Beach',
          titleGa: 'Trá Chiúin',
          assetPath: 'sounds/ocean/oceanSound2.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Rolling Tide',
          titleGa: 'Taoide Réidh',
          assetPath: 'sounds/ocean/oceanSound3.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Soft Sea',
          titleGa: 'Farraige Bhog',
          assetPath: 'sounds/ocean/oceanSound4.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Deep Ocean',
          titleGa: 'Aigéan Domhain',
          assetPath: 'sounds/ocean/oceanSound5.mp3',
        ),
      ],
    ),
    CalmingSoundCategory(
      id: 'rain',
      titleEn: 'Rain',
      titleGa: 'Báisteach',
      subtitleEn: 'Soft rainfall for relaxing',
      subtitleGa: 'Báisteach bhog le haghaidh scíthe',
      emoji: '🌧️',
      icon: Icons.water_drop_rounded,
      colors: [Color(0xFF42A5F5), Color(0xFF5C6BC0)],
      tracks: [
        CalmingSoundTrack(
          titleEn: 'Soft Rain',
          titleGa: 'Báisteach Bhog',
          assetPath: 'sounds/rain/rainSound1.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Rainy Window',
          titleGa: 'Fuinneog Báistí',
          assetPath: 'sounds/rain/rainSound2.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Gentle Shower',
          titleGa: 'Cith Séimh',
          assetPath: 'sounds/rain/rainSound3.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Calm Rainfall',
          titleGa: 'Báisteach Chiúin',
          assetPath: 'sounds/rain/rainSound4.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Peaceful Rain',
          titleGa: 'Báisteach Shuaimhneach',
          assetPath: 'sounds/rain/rainSound5.mp3',
        ),
      ],
    ),
    CalmingSoundCategory(
      id: 'wind',
      titleEn: 'Wind',
      titleGa: 'Gaoth',
      subtitleEn: 'Soft breeze and peaceful air',
      subtitleGa: 'Leoithne bhog agus aer suaimhneach',
      emoji: '🌬️',
      icon: Icons.air_rounded,
      colors: [Color(0xFF66BB6A), Color(0xFF26A69A)],
      tracks: [
        CalmingSoundTrack(
          titleEn: 'Soft Breeze',
          titleGa: 'Leoithne Bhog',
          assetPath: 'sounds/wind/windSound1.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Gentle Wind',
          titleGa: 'Gaoth Shéimh',
          assetPath: 'sounds/wind/windSound2.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Open Air',
          titleGa: 'Aer Oscailte',
          assetPath: 'sounds/wind/windSound3.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Quiet Breeze',
          titleGa: 'Leoithne Chiúin',
          assetPath: 'sounds/wind/windSound4.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Peaceful Wind',
          titleGa: 'Gaoth Shuaimhneach',
          assetPath: 'sounds/wind/windSound5.mp3',
        ),
      ],
    ),
    CalmingSoundCategory(
      id: 'whiteNoise',
      titleEn: 'White Noise',
      titleGa: 'Torann Bán',
      subtitleEn: 'Steady sound for focus and calm',
      subtitleGa: 'Fuaim sheasta le haghaidh fócas agus ciúnais',
      emoji: '🤍',
      icon: Icons.blur_on_rounded,
      colors: [Color(0xFF78909C), Color(0xFFB0BEC5)],
      tracks: [
        CalmingSoundTrack(
          titleEn: 'Soft Static',
          titleGa: 'Torann Bog',
          assetPath: 'sounds/whiteNoise/whiteNoiseSound1.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Gentle Noise',
          titleGa: 'Torann Séimh',
          assetPath: 'sounds/whiteNoise/whiteNoiseSound2.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Calm Hum',
          titleGa: 'Crónán Ciúin',
          assetPath: 'sounds/whiteNoise/whiteNoiseSound3.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Steady Sound',
          titleGa: 'Fuaim Sheasta',
          assetPath: 'sounds/whiteNoise/whiteNoiseSound4.mp3',
        ),
        CalmingSoundTrack(
          titleEn: 'Focus Noise',
          titleGa: 'Torann Fócais',
          assetPath: 'sounds/whiteNoise/whiteNoiseSound5.mp3',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _selectedCategory = _categories.first;

    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTrack(CalmingSoundTrack track) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_currentTrack?.assetPath == track.assetPath && !_isPaused) {
        await _player.pause();

        if (!mounted) return;

        setState(() {
          _isPaused = true;
        });

        return;
      }

      if (_currentTrack?.assetPath == track.assetPath && _isPaused) {
        await _player.resume();

        if (!mounted) return;

        setState(() {
          _isPaused = false;
        });

        return;
      }

      await _player.stop();
      await _player.setVolume(_volume);
      await _player.play(AssetSource(track.assetPath));

      if (!mounted) return;

      setState(() {
        _currentTrack = track;
        _isPaused = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _currentTrack = null;
        _isPaused = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.soundPlaybackFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _stopSound() async {
    await _player.stop();

    if (!mounted) return;

    setState(() {
      _currentTrack = null;
      _isPaused = false;
    });
  }

  Future<void> _changeVolume(double value) async {
    setState(() {
      _volume = value;
    });

    await _player.setVolume(value);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF26A69A)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.calming_sounds,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.calmingSoundsIntro,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context) {
    final track = _currentTrack;
    if (track == null) return const SizedBox.shrink();

    final category = _categories.firstWhere(
      (category) =>
          category.tracks.any((item) => item.assetPath == track.assetPath),
      orElse: () => _categories.first,
    );

    final mainColor = category.colors.first;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: category.colors),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 54)),
          const SizedBox(height: 8),
          Text(
            _isPaused ? context.l10n.paused : context.l10n.nowPlaying,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            track.title(context),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_down_rounded, color: Colors.white),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0,
                        max: 1,
                        onChanged: _changeVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Colors.white),
                  ],
                ),
                Text(
                  context.l10n.volume,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                height: 52,
                width: 160,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : () => _playTrack(track),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: mainColor,
                  ),
                  icon: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  label: Text(
                    _isPaused ? context.l10n.play : context.l10n.pause,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                width: 160,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _stopSound,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(
                    context.l10n.stop,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CalmingSoundCategory category,
  ) {
    final selected = _selectedCategory?.id == category.id;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: category.colors) : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color:
                selected
                    ? Colors.transparent
                    : category.colors.first.withValues(alpha: 0.20),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: category.colors.first.withValues(
                alpha: selected ? 0.24 : 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 46)),
            const SizedBox(height: 10),
            Text(
              category.title(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : category.colors.first,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.subtitle(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      constraints: const BoxConstraints(maxWidth: 1060),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children:
            _categories.map((category) {
              return _buildCategoryCard(context, category);
            }).toList(),
      ),
    );
  }

  Widget _buildTrackCard(
    BuildContext context,
    CalmingSoundCategory category,
    CalmingSoundTrack track,
  ) {
    final isCurrent = _currentTrack?.assetPath == track.assetPath;
    final mainColor = category.colors.first;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: _isLoading ? null : () => _playTrack(track),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isCurrent
                  ? mainColor.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isCurrent ? mainColor : Colors.black.withValues(alpha: 0.06),
            width: isCurrent ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: isCurrent ? 0.18 : 0.07),
              blurRadius: 17,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: category.colors),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(category.emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title(context),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCurrent
                        ? _isPaused
                            ? context.l10n.pausedTapToPlay
                            : context.l10n.playingTapToPause
                        : context.l10n.tapToPlay,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (_isLoading && isCurrent)
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(
                isCurrent
                    ? _isPaused
                        ? Icons.play_circle_fill_rounded
                        : Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: mainColor,
                size: 42,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context) {
    final category = _selectedCategory ?? _categories.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      constraints: const BoxConstraints(maxWidth: 860),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: category.colors.first.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: category.colors),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.title(context),
                  style: TextStyle(
                    color: category.colors.first,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...category.tracks.map((track) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTrackCard(context, category, track),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calming_sounds),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F2FF), Color(0xFFF3FFF5), Color(0xFFFFF8E8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildNowPlayingCard(context),
                  _buildCategorySelector(context),
                  _buildTrackList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalmingSoundCategory {
  final String id;
  final String titleEn;
  final String titleGa;
  final String subtitleEn;
  final String subtitleGa;
  final String emoji;
  final IconData icon;
  final List<Color> colors;
  final List<CalmingSoundTrack> tracks;

  const CalmingSoundCategory({
    required this.id,
    required this.titleEn,
    required this.titleGa,
    required this.subtitleEn,
    required this.subtitleGa,
    required this.emoji,
    required this.icon,
    required this.colors,
    required this.tracks,
  });

  String title(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ga'
        ? titleGa
        : titleEn;
  }

  String subtitle(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ga'
        ? subtitleGa
        : subtitleEn;
  }
}

class CalmingSoundTrack {
  final String titleEn;
  final String titleGa;
  final String assetPath;

  const CalmingSoundTrack({
    required this.titleEn,
    required this.titleGa,
    required this.assetPath,
  });

  String title(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ga'
        ? titleGa
        : titleEn;
  }
}
