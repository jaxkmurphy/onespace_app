import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/media_asset.dart';
import '../services/firestore_service.dart';

const String mediaVisualPrefix = 'media:';

String mediaVisualValue(MediaAsset asset) {
  return '$mediaVisualPrefix${asset.downloadUrl}';
}

bool isMediaVisualValue(String value) {
  return value.trim().startsWith(mediaVisualPrefix);
}

String mediaUrlFromVisualValue(String value) {
  final trimmed = value.trim();

  if (trimmed.startsWith(mediaVisualPrefix)) {
    return trimmed.substring(mediaVisualPrefix.length);
  }

  return trimmed;
}

class MediaImagePreview extends StatelessWidget {
  final String value;
  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const MediaImagePreview({
    super.key,
    required this.value,
    this.size = 48,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = mediaUrlFromVisualValue(value);
    final radius = borderRadius ?? BorderRadius.circular(14);

    if (url.trim().isEmpty) {
      return _MediaFallbackIcon(size: size);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => _MediaFallbackIcon(size: size),
      ),
    );
  }
}

class _MediaFallbackIcon extends StatelessWidget {
  final double size;

  const _MediaFallbackIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colourScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colourScheme.onSurfaceVariant,
      ),
    );
  }
}

Future<MediaAsset?> showMediaAssetPickerDialog({
  required BuildContext context,
  required FirestoreService firestoreService,
  MediaAssetType type = MediaAssetType.image,
  MediaAssetCategory? category,
  String title = 'Choose from Media Library',
}) {
  return showDialog<MediaAsset>(
    context: context,
    builder: (context) {
      return _MediaAssetPickerDialog(
        firestoreService: firestoreService,
        type: type,
        category: category,
        title: title,
      );
    },
  );
}

class _MediaAssetPickerDialog extends StatefulWidget {
  final FirestoreService firestoreService;
  final MediaAssetType type;
  final MediaAssetCategory? category;
  final String title;

  const _MediaAssetPickerDialog({
    required this.firestoreService,
    required this.type,
    required this.category,
    required this.title,
  });

  @override
  State<_MediaAssetPickerDialog> createState() =>
      _MediaAssetPickerDialogState();
}

class _MediaAssetPickerDialogState extends State<_MediaAssetPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  MediaAssetCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _loadImageBytes(MediaAsset asset) async {
    if (asset.storagePath.trim().isEmpty) return null;

    return FirebaseStorage.instance.ref(asset.storagePath).getData(1024 * 1024);
  }

  String _categoryLabel(MediaAssetCategory category) {
    switch (category) {
      case MediaAssetCategory.visualSupport:
        return context.l10n.mediaCategoryVisualSupport;
      case MediaAssetCategory.wordLearningImage:
        return context.l10n.mediaCategoryWordLearningImage;
      case MediaAssetCategory.learningGameImage:
        return context.l10n.mediaCategoryLearningGameImage;
      case MediaAssetCategory.scheduleImage:
        return context.l10n.mediaCategoryScheduleImage;
      case MediaAssetCategory.rewardImage:
        return context.l10n.mediaCategoryRewardImage;
      case MediaAssetCategory.calmingSound:
        return context.l10n.mediaCategoryCalmingSound;
      case MediaAssetCategory.classroomCue:
        return context.l10n.mediaCategoryClassroomCue;
      case MediaAssetCategory.guideline:
        return context.l10n.mediaCategoryGuideline;
      case MediaAssetCategory.classroomDocument:
        return context.l10n.mediaCategoryClassroomDocument;
      case MediaAssetCategory.other:
        return context.l10n.mediaCategoryOther;
    }
  }

  List<MediaAssetCategory> _categoriesForAssets(List<MediaAsset> assets) {
    final categories = assets.map((asset) => asset.category).toSet().toList();

    categories.sort((first, second) {
      return _categoryLabel(first).compareTo(_categoryLabel(second));
    });

    return categories;
  }

  List<MediaAsset> _filterAssets(List<MediaAsset> assets) {
    final query = _searchController.text.trim().toLowerCase();

    return assets.where((asset) {
      final categoryMatches =
          _selectedCategory == null || asset.category == _selectedCategory;
      final searchMatches =
          query.isEmpty ||
          asset.name.toLowerCase().contains(query) ||
          asset.description.toLowerCase().contains(query) ||
          asset.fileName.toLowerCase().contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search media',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<List<MediaAsset>>(
                  stream: widget.firestoreService.getCurrentMediaAssets(
                    type: widget.type,
                    activeOnly: true,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load media.',
                          style: TextStyle(color: colourScheme.error),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allAssets = snapshot.data!;
                    final categories = _categoriesForAssets(allAssets);
                    final categoryCounts = <MediaAssetCategory, int>{};
                    for (final asset in allAssets) {
                      categoryCounts[asset.category] =
                          (categoryCounts[asset.category] ?? 0) + 1;
                    }
                    final assets = _filterAssets(allAssets);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text('All (${allAssets.length})'),
                                  selected: _selectedCategory == null,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = null);
                                  },
                                ),
                              ),
                              for (final category in categories)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(
                                      '${_categoryLabel(category)} '
                                      '(${categoryCounts[category] ?? 0})',
                                    ),
                                    selected: _selectedCategory == category,
                                    onSelected: (_) {
                                      setState(
                                        () => _selectedCategory = category,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child:
                              assets.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No matching media yet.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color: colourScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                  : GridView.builder(
                                    itemCount: assets.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 180,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 0.92,
                                        ),
                                    itemBuilder: (context, index) {
                                      final asset = assets[index];

                                      return _MediaAssetChoiceCard(
                                        asset: asset,
                                        loadImageBytes: _loadImageBytes,
                                        onTap:
                                            () => Navigator.of(
                                              context,
                                            ).pop(asset),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaAssetChoiceCard extends StatelessWidget {
  final MediaAsset asset;
  final Future<Uint8List?> Function(MediaAsset asset) loadImageBytes;
  final VoidCallback onTap;

  const _MediaAssetChoiceCard({
    required this.asset,
    required this.loadImageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Material(
      color: colourScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      asset.isImage
                          ? FutureBuilder<Uint8List?>(
                            future: loadImageBytes(asset),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }

                              return Image.network(
                                asset.downloadUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Center(
                                      child: Icon(Icons.image_outlined),
                                    ),
                              );
                            },
                          )
                          : const Center(child: Icon(Icons.insert_drive_file)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                asset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                asset.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colourScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
