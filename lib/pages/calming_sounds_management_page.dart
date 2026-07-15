import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/calming_sound_models.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class CalmingSoundsManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const CalmingSoundsManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<CalmingSoundsManagementPage> createState() =>
      _CalmingSoundsManagementPageState();
}

class _CalmingSoundsManagementPageState
    extends State<CalmingSoundsManagementPage> {
  final AudioPlayer _player = AudioPlayer();

  String? _playingId;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _categoryName(CalmingSoundCategoryConfig category) {
    return category.nameForLocale(Localizations.localeOf(context));
  }

  Future<void> _preview({
    required String id,
    required bool remote,
    required String source,
  }) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      if (_playingId == id) {
        await _player.stop();

        if (!mounted) return;
        setState(() => _playingId = null);
        return;
      }

      await _player.stop();
      await _player.play(remote ? UrlSource(source) : AssetSource(source));

      if (!mounted) return;
      setState(() => _playingId = id);
    } catch (_) {
      _showMessage(context.l10n.soundPlaybackFailed);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _toggleStarterSound(StarterCalmingSound sound) async {
    setState(() => _isBusy = true);

    try {
      await widget.firestoreService.updateCurrentStarterCalmingSound(
        sound.copyWith(active: !sound.active),
      );

      if (_playingId == sound.id && sound.active) {
        await _player.stop();
        _playingId = null;
      }
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _toggleUploadedSound(MediaAsset asset) async {
    final enabledMessage = context.l10n.calmingSoundEnabled;
    final disabledMessage = context.l10n.calmingSoundDisabled;
    final String Function(String error) failureMessage =
        context.l10n.mediaAssetUpdateFailed;

    setState(() => _isBusy = true);

    try {
      await widget.firestoreService.setCurrentMediaAssetActive(
        assetId: asset.id,
        active: !asset.active,
      );

      if (_playingId == asset.id && asset.active) {
        await _player.stop();
        _playingId = null;
      }

      _showMessage(asset.active ? disabledMessage : enabledMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _deleteUploadedSound(MediaAsset asset) async {
    final successMessage = context.l10n.mediaAssetDeleted;
    final String Function(String error) failureMessage =
        context.l10n.mediaAssetDeleteFailed;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteCalmingSound),
          content: Text(context.l10n.deleteCalmingSoundMessage(asset.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isBusy = true);

    try {
      if (_playingId == asset.id) {
        await _player.stop();
        _playingId = null;
      }

      await widget.firestoreService.deleteCurrentMediaAsset(
        assetId: asset.id,
        storagePath: asset.storagePath,
      );

      _showMessage(successMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _moveStarterSound({
    required StarterCalmingSound sound,
    required String categoryId,
  }) async {
    await widget.firestoreService.updateCurrentStarterCalmingSound(
      sound.copyWith(categoryId: categoryId),
    );
  }

  Future<void> _moveUploadedSound({
    required MediaAsset asset,
    required String categoryId,
  }) async {
    await widget.firestoreService.updateCurrentMediaAssetCalmingSoundPlacement(
      assetId: asset.id,
      calmingSoundCategoryId: categoryId,
      sortOrder: asset.sortOrder,
    );
  }

  Future<void> _nudgeStarterSound(StarterCalmingSound sound, int delta) async {
    await widget.firestoreService.updateCurrentStarterCalmingSound(
      sound.copyWith(sortOrder: (sound.sortOrder + delta).clamp(0, 9999)),
    );
  }

  Future<void> _nudgeUploadedSound(MediaAsset asset, int delta) async {
    await widget.firestoreService.updateCurrentMediaAssetCalmingSoundPlacement(
      assetId: asset.id,
      calmingSoundCategoryId: asset.calmingSoundCategoryId,
      sortOrder: (asset.sortOrder + delta).clamp(0, 9999),
    );
  }

  Future<void> _editCategory({
    CalmingSoundCategoryConfig? category,
    required List<CalmingSoundCategoryConfig> categories,
  }) async {
    final result = await showDialog<CalmingSoundCategoryConfig>(
      context: context,
      builder: (context) {
        return _CalmingSoundCategoryDialog(
          category: category,
          nextSortOrder: categories.length + 10,
        );
      },
    );

    if (result == null) return;

    await widget.firestoreService.upsertCurrentCalmingSoundCategory(result);
  }

  Future<void> _deleteCategory({
    required CalmingSoundCategoryConfig category,
    required List<StarterCalmingSound> starterSounds,
    required List<MediaAsset> uploadedSounds,
  }) async {
    if (category.isDefault) {
      _showMessage(context.l10n.defaultCalmingCategoryCannotDelete);
      return;
    }

    final hasSounds =
        starterSounds.any((sound) => sound.categoryId == category.id) ||
        uploadedSounds.any(
          (asset) => asset.calmingSoundCategoryId == category.id,
        );

    if (hasSounds) {
      _showMessage(context.l10n.moveSoundsBeforeDeletingCategory);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteCalmingCategory),
          content: Text(context.l10n.deleteCalmingCategoryMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.firestoreService.deleteCurrentCalmingSoundCategory(
      category.id,
    );
  }

  void _openMediaLibrary() {
    Navigator.pushNamed(
      context,
      '/media-library',
      arguments: {
        'staffProfile': widget.staffProfile,
        'firestoreService': widget.firestoreService,
        'initialType': MediaAssetType.audio,
      },
    );
  }

  List<_ManagedSoundItem> _itemsForCategory({
    required CalmingSoundCategoryConfig category,
    required List<StarterCalmingSound> starterSounds,
    required List<MediaAsset> uploadedSounds,
  }) {
    final locale = Localizations.localeOf(context);

    final items = <_ManagedSoundItem>[
      ...starterSounds
          .where((sound) => sound.categoryId == category.id)
          .map(
            (sound) => _ManagedSoundItem.starter(
              id: sound.id,
              title: sound.titleForLocale(locale),
              source: sound.assetPath,
              active: sound.active,
              sortOrder: sound.sortOrder,
              sound: sound,
            ),
          ),
      ...uploadedSounds
          .where((asset) => asset.calmingSoundCategoryId == category.id)
          .map(
            (asset) => _ManagedSoundItem.uploaded(
              id: asset.id,
              title: asset.name,
              description: asset.description,
              source: asset.downloadUrl,
              active: asset.active,
              sortOrder: asset.sortOrder,
              asset: asset,
            ),
          ),
    ];

    items.sort((first, second) {
      final orderCompare = first.sortOrder.compareTo(second.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return first.title.compareTo(second.title);
    });

    return items;
  }

  Widget _buildHeader({
    required List<CalmingSoundCategoryConfig> categories,
    required int soundCount,
    required int activeCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF26A69A)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.manageCalmingSounds,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.manageCalmingSoundsSubtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                icon: Icons.folder_rounded,
                label: context.l10n.categories,
                value: '${categories.length}',
              ),
              _StatChip(
                icon: Icons.library_music_rounded,
                label: context.l10n.totalSounds,
                value: '$soundCount',
              ),
              _StatChip(
                icon: Icons.check_circle_rounded,
                label: context.l10n.activeSounds,
                value: '$activeCount',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _openMediaLibrary,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5E35B1),
                ),
                icon: const Icon(Icons.perm_media_rounded),
                label: Text(context.l10n.addCalmingSound),
              ),
              OutlinedButton.icon(
                onPressed:
                    () => _editCategory(category: null, categories: categories),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.create_new_folder_rounded),
                label: Text(context.l10n.addCalmingCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required CalmingSoundCategoryConfig category,
    required List<CalmingSoundCategoryConfig> categories,
    required List<StarterCalmingSound> starterSounds,
    required List<MediaAsset> uploadedSounds,
  }) {
    final items = _itemsForCategory(
      category: category,
      starterSounds: starterSounds,
      uploadedSounds: uploadedSounds,
    );
    final colors = calmingSoundColors(category.id);
    final color = colors.first;

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: color.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    calmingSoundIcon(category.iconName),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categoryName(category),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${items.length} ${context.l10n.sounds}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: category.active,
                  onChanged: (value) {
                    widget.firestoreService.upsertCurrentCalmingSoundCategory(
                      category.copyWith(active: value),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editCategory(category: category, categories: categories);
                    } else if (value == 'delete') {
                      _deleteCategory(
                        category: category,
                        starterSounds: starterSounds,
                        uploadedSounds: uploadedSounds,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.edit_rounded),
                            title: Text(context.l10n.edit),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_rounded,
                              color:
                                  category.isDefault ? Colors.grey : Colors.red,
                            ),
                            title: Text(context.l10n.delete),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.l10n.noSoundsInCategory),
              )
            else
              ...items.map(
                (item) => _SoundManagementTile(
                  item: item,
                  categories: categories,
                  categoryName: _categoryName,
                  playing: _playingId == item.id,
                  busy: _isBusy,
                  onPreview:
                      () => _preview(
                        id: item.id,
                        remote: item.isUploaded,
                        source: item.source,
                      ),
                  onToggle:
                      item.isUploaded
                          ? () => _toggleUploadedSound(item.asset!)
                          : () => _toggleStarterSound(item.sound!),
                  onMove: (categoryId) {
                    if (item.isUploaded) {
                      _moveUploadedSound(
                        asset: item.asset!,
                        categoryId: categoryId,
                      );
                    } else {
                      _moveStarterSound(
                        sound: item.sound!,
                        categoryId: categoryId,
                      );
                    }
                  },
                  onNudgeUp:
                      item.isUploaded
                          ? () => _nudgeUploadedSound(item.asset!, -1)
                          : () => _nudgeStarterSound(item.sound!, -1),
                  onNudgeDown:
                      item.isUploaded
                          ? () => _nudgeUploadedSound(item.asset!, 1)
                          : () => _nudgeStarterSound(item.sound!, 1),
                  onDelete:
                      item.isUploaded
                          ? () => _deleteUploadedSound(item.asset!)
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.manageCalmingSounds)),
      body: StreamBuilder<List<CalmingSoundCategoryConfig>>(
        stream: widget.firestoreService.getCurrentCalmingSoundCategories(),
        builder: (context, categorySnapshot) {
          return StreamBuilder<List<StarterCalmingSound>>(
            stream: widget.firestoreService.getCurrentStarterCalmingSounds(),
            builder: (context, starterSnapshot) {
              return StreamBuilder<List<MediaAsset>>(
                stream: widget.firestoreService.getCurrentMediaAssets(
                  type: MediaAssetType.audio,
                ),
                builder: (context, mediaSnapshot) {
                  if (categorySnapshot.hasError ||
                      starterSnapshot.hasError ||
                      mediaSnapshot.hasError) {
                    return Center(
                      child: Text(
                        context.l10n.mediaLoadFailed(
                          [
                            categorySnapshot.error,
                            starterSnapshot.error,
                            mediaSnapshot.error,
                          ].whereType<Object>().join(' '),
                        ),
                      ),
                    );
                  }

                  if (!categorySnapshot.hasData ||
                      !starterSnapshot.hasData ||
                      !mediaSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = categorySnapshot.data!;
                  final starterSounds = starterSnapshot.data!;
                  final uploadedSounds =
                      mediaSnapshot.data!
                          .where(
                            (asset) =>
                                asset.isAudio &&
                                asset.category ==
                                    MediaAssetCategory.calmingSound,
                          )
                          .toList();

                  final totalSoundCount =
                      starterSounds.length + uploadedSounds.length;
                  final activeSoundCount =
                      starterSounds.where((sound) => sound.active).length +
                      uploadedSounds.where((asset) => asset.active).length;

                  return Container(
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(
                                  categories: categories,
                                  soundCount: totalSoundCount,
                                  activeCount: activeSoundCount,
                                ),
                                const SizedBox(height: 18),
                                ...categories.map(
                                  (category) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildCategorySection(
                                      category: category,
                                      categories: categories,
                                      starterSounds: starterSounds,
                                      uploadedSounds: uploadedSounds,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class _ManagedSoundItem {
  final String id;
  final String title;
  final String description;
  final String source;
  final bool active;
  final int sortOrder;
  final StarterCalmingSound? sound;
  final MediaAsset? asset;

  const _ManagedSoundItem._({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.active,
    required this.sortOrder,
    this.sound,
    this.asset,
  });

  factory _ManagedSoundItem.starter({
    required String id,
    required String title,
    required String source,
    required bool active,
    required int sortOrder,
    required StarterCalmingSound sound,
  }) {
    return _ManagedSoundItem._(
      id: id,
      title: title,
      description: '',
      source: source,
      active: active,
      sortOrder: sortOrder,
      sound: sound,
    );
  }

  factory _ManagedSoundItem.uploaded({
    required String id,
    required String title,
    required String description,
    required String source,
    required bool active,
    required int sortOrder,
    required MediaAsset asset,
  }) {
    return _ManagedSoundItem._(
      id: id,
      title: title,
      description: description,
      source: source,
      active: active,
      sortOrder: sortOrder,
      asset: asset,
    );
  }

  bool get isUploaded => asset != null;
}

class _SoundManagementTile extends StatelessWidget {
  final _ManagedSoundItem item;
  final List<CalmingSoundCategoryConfig> categories;
  final String Function(CalmingSoundCategoryConfig category) categoryName;
  final bool playing;
  final bool busy;
  final VoidCallback onPreview;
  final VoidCallback onToggle;
  final ValueChanged<String> onMove;
  final VoidCallback onNudgeUp;
  final VoidCallback onNudgeDown;
  final VoidCallback? onDelete;

  const _SoundManagementTile({
    required this.item,
    required this.categories,
    required this.categoryName,
    required this.playing,
    required this.busy,
    required this.onPreview,
    required this.onToggle,
    required this.onMove,
    required this.onNudgeUp,
    required this.onNudgeDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.active ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: busy ? null : onPreview,
            icon: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.isUploaded
                      ? context.l10n.uploadedSound
                      : context.l10n.starterSound,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.description.trim().isNotEmpty)
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.moveUp,
            onPressed: busy ? null : onNudgeUp,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton(
            tooltip: context.l10n.moveDown,
            onPressed: busy ? null : onNudgeDown,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          DropdownButton<String>(
            value:
                item.isUploaded
                    ? item.asset!.calmingSoundCategoryId
                    : item.sound!.categoryId,
            underline: const SizedBox.shrink(),
            items:
                categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(categoryName(category)),
                      ),
                    )
                    .toList(),
            onChanged:
                busy
                    ? null
                    : (value) {
                      if (value != null) onMove(value);
                    },
          ),
          if (onDelete != null)
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: busy ? null : onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
          Switch(
            value: item.active,
            onChanged: busy ? null : (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class _CalmingSoundCategoryDialog extends StatefulWidget {
  final CalmingSoundCategoryConfig? category;
  final int nextSortOrder;

  const _CalmingSoundCategoryDialog({
    required this.category,
    required this.nextSortOrder,
  });

  @override
  State<_CalmingSoundCategoryDialog> createState() =>
      _CalmingSoundCategoryDialogState();
}

class _CalmingSoundCategoryDialogState
    extends State<_CalmingSoundCategoryDialog> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameGaController;
  late final TextEditingController _emojiController;
  String _iconName = 'headphones';
  bool _active = true;

  @override
  void initState() {
    super.initState();

    final category = widget.category;
    _nameEnController = TextEditingController(text: category?.nameEn ?? '');
    _nameGaController = TextEditingController(text: category?.nameGa ?? '');
    _emojiController = TextEditingController(text: category?.emoji ?? '🎧');
    _iconName = category?.iconName ?? 'headphones';
    _active = category?.active ?? true;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameGaController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  String _newId(String name) {
    final base = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return base.isEmpty
        ? 'custom-${DateTime.now().millisecondsSinceEpoch}'
        : 'custom-$base';
  }

  void _save() {
    final nameEn = _nameEnController.text.trim();
    if (nameEn.isEmpty) return;

    final existing = widget.category;

    Navigator.pop(
      context,
      CalmingSoundCategoryConfig(
        id: existing?.id ?? _newId(nameEn),
        nameEn: nameEn,
        nameGa: _nameGaController.text.trim(),
        emoji:
            _emojiController.text.trim().isEmpty
                ? '🎧'
                : _emojiController.text.trim(),
        iconName: _iconName,
        active: _active,
        isDefault: existing?.isDefault ?? false,
        sortOrder: existing?.sortOrder ?? widget.nextSortOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null
            ? context.l10n.addCalmingCategory
            : context.l10n.editCalmingCategory,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameEnController,
                decoration: InputDecoration(
                  labelText: context.l10n.englishName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameGaController,
                decoration: InputDecoration(labelText: context.l10n.irishName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emojiController,
                decoration: InputDecoration(labelText: context.l10n.emoji),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _iconName,
                decoration: InputDecoration(labelText: context.l10n.icon),
                items: const [
                  DropdownMenuItem(
                    value: 'headphones',
                    child: Text('Headphones'),
                  ),
                  DropdownMenuItem(value: 'spa', child: Text('Calm')),
                  DropdownMenuItem(value: 'music', child: Text('Music')),
                  DropdownMenuItem(value: 'forest', child: Text('Forest')),
                  DropdownMenuItem(value: 'waves', child: Text('Waves')),
                  DropdownMenuItem(value: 'rain', child: Text('Rain')),
                  DropdownMenuItem(value: 'wind', child: Text('Wind')),
                  DropdownMenuItem(
                    value: 'whiteNoise',
                    child: Text('White noise'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _iconName = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(context.l10n.active),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.save)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
