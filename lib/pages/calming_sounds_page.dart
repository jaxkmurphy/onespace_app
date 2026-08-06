import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/calming_sound_models.dart';
import '../models/media_asset.dart';
import '../services/firestore_service.dart';

class CalmingSoundsPage extends StatefulWidget {
  final FirestoreService firestoreService;

  const CalmingSoundsPage({super.key, required this.firestoreService});

  @override
  State<CalmingSoundsPage> createState() => _CalmingSoundsPageState();
}

class _CalmingSoundsPageState extends State<CalmingSoundsPage> {
  final AudioPlayer _player = AudioPlayer();

  _CalmingSoundGroup? _selectedGroup;
  _CalmingSoundTrack? _currentTrack;

  bool _isLoading = false;
  bool _isPaused = false;
  double _volume = 0.75;

  @override
  void initState() {
    super.initState();

    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  List<_CalmingSoundGroup> _buildGroups({
    required List<CalmingSoundCategoryConfig> categories,
    required List<StarterCalmingSound> starterSounds,
    required List<MediaAsset> uploadedSounds,
  }) {
    final locale = Localizations.localeOf(context);
    final activeCategories =
        categories.where((category) => category.active).toList()..sort(
          (first, second) => first.sortOrder.compareTo(second.sortOrder),
        );

    final groups = <_CalmingSoundGroup>[];

    for (final category in activeCategories) {
      final tracks = <_CalmingSoundTrack>[
        ...starterSounds
            .where((sound) => sound.active && sound.categoryId == category.id)
            .map(
              (sound) => _CalmingSoundTrack.local(
                id: sound.id,
                title: sound.titleForLocale(locale),
                source: sound.assetPath,
                sortOrder: sound.sortOrder,
              ),
            ),
        ...uploadedSounds
            .where(
              (asset) =>
                  asset.active &&
                  asset.isAudio &&
                  asset.category == MediaAssetCategory.calmingSound &&
                  asset.calmingSoundCategoryId == category.id,
            )
            .map(
              (asset) => _CalmingSoundTrack.remote(
                id: asset.id,
                title: asset.name,
                source: asset.downloadUrl,
                description: asset.description,
                sortOrder: asset.sortOrder,
              ),
            ),
      ]..sort((first, second) {
        final orderCompare = first.sortOrder.compareTo(second.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return first.title.compareTo(second.title);
      });

      if (tracks.isEmpty) continue;

      groups.add(
        _CalmingSoundGroup(
          id: category.id,
          title: category.nameForLocale(locale),
          subtitle: _categorySubtitle(category.id),
          emoji: category.emoji,
          icon: calmingSoundIcon(category.iconName),
          colors: calmingSoundColors(category.id),
          tracks: tracks,
        ),
      );
    }

    return groups;
  }

  String _categorySubtitle(String categoryId) {
    final isIrish = Localizations.localeOf(context).languageCode == 'ga';

    switch (categoryId) {
      case 'ocean':
        return isIrish
            ? 'Tonnta séimhe agus fuaimeanna farraige'
            : 'Gentle waves and sea sounds';
      case 'rain':
        return isIrish
            ? 'Báisteach bhog le haghaidh scíthe'
            : 'Soft rainfall for relaxing';
      case 'wind':
        return isIrish
            ? 'Leoithne bhog agus aer suaimhneach'
            : 'Soft breeze and peaceful air';
      case 'whiteNoise':
        return isIrish
            ? 'Fuaim sheasta le haghaidh fócas agus ciúnais'
            : 'Steady sound for focus and calm';
      default:
        return context.l10n.classroomCalmingSoundsSubtitle;
    }
  }

  void _syncSelectedGroup(List<_CalmingSoundGroup> groups) {
    if (groups.isEmpty) {
      _selectedGroup = null;
      return;
    }

    final current = _selectedGroup;
    if (current == null ||
        !groups.any((group) => group.id == current.id) ||
        current.tracks.isEmpty) {
      _selectedGroup = groups.first;
      return;
    }

    _selectedGroup = groups.firstWhere((group) => group.id == current.id);
  }

  Future<void> _playTrack(_CalmingSoundTrack track) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_currentTrack?.id == track.id && !_isPaused) {
        await _player.pause();

        if (!mounted) return;
        setState(() => _isPaused = true);
        return;
      }

      if (_currentTrack?.id == track.id && _isPaused) {
        await _player.resume();

        if (!mounted) return;
        setState(() => _isPaused = false);
        return;
      }

      await _player.stop();
      await _player.setVolume(_volume);
      await _player.play(
        track.isRemote ? UrlSource(track.source) : AssetSource(track.source),
      );

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
        setState(() => _isLoading = false);
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
    setState(() => _volume = value);
    await _player.setVolume(value);
  }

  Widget _buildHeader() {
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

  Widget _buildNowPlayingCard(List<_CalmingSoundGroup> groups) {
    final track = _currentTrack;
    if (track == null || groups.isEmpty) return const SizedBox.shrink();

    final group = groups.firstWhere(
      (group) => group.tracks.any((item) => item.id == track.id),
      orElse: () => groups.first,
    );

    final mainColor = group.colors.first;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: group.colors),
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
          Text(group.emoji, style: const TextStyle(fontSize: 54)),
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
            track.title,
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

  Widget _buildGroupCard(_CalmingSoundGroup group) {
    final selected = _selectedGroup?.id == group.id;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => setState(() => _selectedGroup = group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: group.colors) : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color:
                selected
                    ? Colors.transparent
                    : group.colors.first.withValues(alpha: 0.20),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: group.colors.first.withValues(
                alpha: selected ? 0.24 : 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(group.emoji, style: const TextStyle(fontSize: 46)),
            const SizedBox(height: 10),
            Text(
              group.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : group.colors.first,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              group.subtitle,
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

  Widget _buildGroupSelector(List<_CalmingSoundGroup> groups) {
    if (groups.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      constraints: const BoxConstraints(maxWidth: 1060),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: groups.map(_buildGroupCard).toList(),
      ),
    );
  }

  Widget _buildTrackCard(_CalmingSoundGroup group, _CalmingSoundTrack track) {
    final isCurrent = _currentTrack?.id == track.id;
    final mainColor = group.colors.first;

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
                gradient: LinearGradient(colors: group.colors),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(group.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
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
                  if (track.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      track.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

  Widget _buildTrackList() {
    final group = _selectedGroup;
    if (group == null) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          context.l10n.noCalmingSoundsAvailable,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      constraints: const BoxConstraints(maxWidth: 860),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: group.colors.first.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: group.colors),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(group.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: TextStyle(
                        color: group.colors.first,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      group.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...group.tracks.map((track) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTrackCard(group, track),
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
      body: StreamBuilder<List<CalmingSoundCategoryConfig>>(
        stream: widget.firestoreService.getCurrentCalmingSoundCategories(),
        builder: (context, categorySnapshot) {
          return StreamBuilder<List<StarterCalmingSound>>(
            stream: widget.firestoreService.getCurrentStarterCalmingSounds(),
            builder: (context, starterSnapshot) {
              return StreamBuilder<List<MediaAsset>>(
                stream: widget.firestoreService.getCurrentMediaAssets(
                  type: MediaAssetType.audio,
                  category: MediaAssetCategory.calmingSound,
                  activeOnly: true,
                ),
                builder: (context, mediaSnapshot) {
                  final loading =
                      !categorySnapshot.hasData ||
                      !starterSnapshot.hasData ||
                      !mediaSnapshot.hasData;
                  final hasError =
                      categorySnapshot.hasError ||
                      starterSnapshot.hasError ||
                      mediaSnapshot.hasError;

                  final groups = _buildGroups(
                    categories:
                        categorySnapshot.data ?? defaultCalmingSoundCategories,
                    starterSounds:
                        starterSnapshot.data ?? defaultStarterCalmingSounds,
                    uploadedSounds: mediaSnapshot.data ?? const [],
                  );
                  _syncSelectedGroup(groups);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF7F2FF),
                          Color(0xFFF3FFF5),
                          Color(0xFFFFF8E8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child:
                          hasError
                              ? Center(
                                child: Text(context.l10n.soundPlaybackFailed),
                              )
                              : SingleChildScrollView(
                                key: const PageStorageKey<String>(
                                  'calming-sounds-child',
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      _buildHeader(),
                                      if (loading)
                                        const Padding(
                                          padding: EdgeInsets.all(18),
                                          child: CircularProgressIndicator(),
                                        ),
                                      _buildNowPlayingCard(groups),
                                      _buildGroupSelector(groups),
                                      _buildTrackList(),
                                    ],
                                  ),
                                ),
                              ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CalmingSoundGroup {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final List<Color> colors;
  final List<_CalmingSoundTrack> tracks;

  const _CalmingSoundGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    required this.colors,
    required this.tracks,
  });
}

class _CalmingSoundTrack {
  final String id;
  final String title;
  final String source;
  final String description;
  final int sortOrder;
  final bool isRemote;

  const _CalmingSoundTrack._({
    required this.id,
    required this.title,
    required this.source,
    required this.description,
    required this.sortOrder,
    required this.isRemote,
  });

  const _CalmingSoundTrack.local({
    required String id,
    required String title,
    required String source,
    required int sortOrder,
  }) : this._(
         id: id,
         title: title,
         source: source,
         description: '',
         sortOrder: sortOrder,
         isRemote: false,
       );

  const _CalmingSoundTrack.remote({
    required String id,
    required String title,
    required String source,
    required String description,
    required int sortOrder,
  }) : this._(
         id: id,
         title: title,
         source: source,
         description: description,
         sortOrder: sortOrder,
         isRemote: true,
       );
}
