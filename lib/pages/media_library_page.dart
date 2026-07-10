import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class MediaLibraryPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const MediaLibraryPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage> {
  MediaAssetType? _selectedType;
  bool _showActiveOnly = false;

  String _typeLabel(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return context.l10n.mediaImages;
      case MediaAssetType.audio:
        return context.l10n.mediaAudio;
      case MediaAssetType.document:
        return context.l10n.mediaDocuments;
    }
  }

  IconData _typeIcon(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return Icons.image_rounded;
      case MediaAssetType.audio:
        return Icons.audiotrack_rounded;
      case MediaAssetType.document:
        return Icons.picture_as_pdf_rounded;
    }
  }

  Color _typeColor(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return const Color(0xFF42A5F5);
      case MediaAssetType.audio:
        return const Color(0xFF7E57C2);
      case MediaAssetType.document:
        return const Color(0xFFEF5350);
    }
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

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  List<String> _allowedExtensionsForType(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return ['jpg', 'jpeg', 'png', 'webp'];
      case MediaAssetType.audio:
        return ['mp3', 'm4a', 'wav'];
      case MediaAssetType.document:
        return ['pdf'];
    }
  }

  String _contentTypeForFile(String fileName, MediaAssetType type) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      default:
        switch (type) {
          case MediaAssetType.image:
            return 'image/jpeg';
          case MediaAssetType.audio:
            return 'audio/mpeg';
          case MediaAssetType.document:
            return 'application/pdf';
        }
    }
  }

  MediaAssetCategory _defaultCategoryForType(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return MediaAssetCategory.visualSupport;
      case MediaAssetType.audio:
        return MediaAssetCategory.calmingSound;
      case MediaAssetType.document:
        return MediaAssetCategory.guideline;
    }
  }

  List<MediaAssetCategory> _categoriesForType(MediaAssetType type) {
    switch (type) {
      case MediaAssetType.image:
        return const [
          MediaAssetCategory.visualSupport,
          MediaAssetCategory.wordLearningImage,
          MediaAssetCategory.learningGameImage,
          MediaAssetCategory.scheduleImage,
          MediaAssetCategory.rewardImage,
          MediaAssetCategory.other,
        ];
      case MediaAssetType.audio:
        return const [
          MediaAssetCategory.calmingSound,
          MediaAssetCategory.classroomCue,
          MediaAssetCategory.other,
        ];
      case MediaAssetType.document:
        return const [
          MediaAssetCategory.guideline,
          MediaAssetCategory.classroomDocument,
          MediaAssetCategory.other,
        ];
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _copyLink(MediaAsset asset) async {
    final message = context.l10n.mediaLinkCopied;
    await Clipboard.setData(ClipboardData(text: asset.downloadUrl));
    _showMessage(message);
  }

  Future<Uint8List?> _loadImageBytes(MediaAsset asset) {
    return FirebaseStorage.instance
        .ref(asset.storagePath)
        .getData(20 * 1024 * 1024);
  }

  Future<void> _toggleAsset(MediaAsset asset) async {
    final successMessage =
        asset.active
            ? context.l10n.mediaAssetDisabled
            : context.l10n.mediaAssetEnabled;
    final String Function(String error) failureMessage =
        context.l10n.mediaAssetUpdateFailed;

    try {
      await widget.firestoreService.setCurrentMediaAssetActive(
        assetId: asset.id,
        active: !asset.active,
      );

      _showMessage(successMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    }
  }

  Future<void> _deleteAsset(MediaAsset asset) async {
    final successMessage = context.l10n.mediaAssetDeleted;
    final String Function(String error) failureMessage =
        context.l10n.mediaAssetDeleteFailed;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteMediaAsset),
          content: Text(context.l10n.deleteMediaAssetMessage(asset.name)),
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

    try {
      await widget.firestoreService.deleteCurrentMediaAsset(
        assetId: asset.id,
        storagePath: asset.storagePath,
      );

      _showMessage(successMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    }
  }

  Future<void> _editAsset(MediaAsset asset) async {
    final successMessage = context.l10n.mediaAssetUpdated;
    final String Function(String error) failureMessage =
        context.l10n.mediaAssetUpdateFailed;

    final updatedAsset = await showDialog<MediaAsset>(
      context: context,
      builder: (context) {
        return _MediaAssetDetailsDialog(
          asset: asset,
          categoryLabel: _categoryLabel,
          categoriesForType: _categoriesForType,
        );
      },
    );

    if (updatedAsset == null) return;

    try {
      await widget.firestoreService.updateCurrentMediaAsset(updatedAsset);
      _showMessage(successMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    }
  }

  Future<void> _uploadAsset() async {
    final noFileMessage = context.l10n.mediaNoFileSelected;
    final successMessage = context.l10n.mediaAssetUploaded;
    final String Function(String error) failureMessage =
        context.l10n.mediaUploadFailed;

    final uploadRequest = await showDialog<_MediaUploadRequest>(
      context: context,
      builder: (context) {
        return _MediaUploadDialog(
          typeLabel: _typeLabel,
          categoryLabel: _categoryLabel,
          categoriesForType: _categoriesForType,
          defaultCategoryForType: _defaultCategoryForType,
        );
      },
    );

    if (uploadRequest == null) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensionsForType(uploadRequest.type),
        withData: true,
        allowMultiple: false,
      );

      final file = result?.files.single;
      final bytes = file?.bytes;

      if (file == null || bytes == null) {
        _showMessage(noFileMessage);
        return;
      }

      final contentType = _contentTypeForFile(file.name, uploadRequest.type);

      await widget.firestoreService.uploadCurrentMediaAsset(
        name: uploadRequest.name,
        description: uploadRequest.description,
        type: uploadRequest.type,
        category: uploadRequest.category,
        fileName: file.name,
        contentType: contentType,
        sizeBytes: file.size,
        bytes: bytes,
        uploadedByStaffId: widget.staffProfile.id,
        uploadedByStaffName: widget.staffProfile.name,
      );

      _showMessage(successMessage);
    } catch (error) {
      _showMessage(failureMessage(error.toString()));
    }
  }

  void _previewAsset(MediaAsset asset) {
    if (asset.isImage) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(asset.name),
                    actions: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Flexible(
                    child: FutureBuilder<Uint8List?>(
                      future: _loadImageBytes(asset),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(
                            height: 320,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final bytes = snapshot.data;

                        if (snapshot.hasError || bytes == null) {
                          return InteractiveViewer(
                            child: Image.network(
                              asset.downloadUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(context.l10n.mediaPreviewFailed),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        onPressed: () => _copyLink(asset),
                                        icon: const Icon(Icons.link_rounded),
                                        label: Text(context.l10n.mediaCopyLink),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        return InteractiveViewer(
                          child: Image.memory(bytes, fit: BoxFit.contain),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(asset.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.mediaPreviewNotAvailableYet),
              const SizedBox(height: 12),
              SelectableText(asset.downloadUrl),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _copyLink(asset),
              icon: const Icon(Icons.link_rounded),
              label: Text(context.l10n.copy),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          selected: _selectedType == null,
          label: Text(context.l10n.all),
          onSelected: (_) => setState(() => _selectedType = null),
        ),
        ...MediaAssetType.values.map((type) {
          return ChoiceChip(
            selected: _selectedType == type,
            avatar: Icon(_typeIcon(type), size: 18),
            label: Text(_typeLabel(type)),
            onSelected: (_) => setState(() => _selectedType = type),
          );
        }),
        FilterChip(
          selected: _showActiveOnly,
          avatar: const Icon(Icons.visibility_rounded, size: 18),
          label: Text(context.l10n.mediaActiveOnly),
          onSelected: (value) {
            setState(() => _showActiveOnly = value);
          },
        ),
      ],
    );
  }

  Widget _buildAssetCard(MediaAsset asset) {
    final color = _typeColor(asset.type);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: color.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        onTap: () => _previewAsset(asset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 118,
              child: Container(
                decoration: BoxDecoration(color: color.withValues(alpha: 0.10)),
                child:
                    asset.isImage
                        ? _MediaThumbnail(
                          asset: asset,
                          color: color,
                          fallbackIcon: _typeIcon(asset.type),
                          loadImageBytes: _loadImageBytes,
                        )
                        : Icon(_typeIcon(asset.type), size: 56, color: color),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'preview') {
                            _previewAsset(asset);
                          } else if (value == 'copy') {
                            _copyLink(asset);
                          } else if (value == 'edit') {
                            _editAsset(asset);
                          } else if (value == 'toggle') {
                            _toggleAsset(asset);
                          } else if (value == 'delete') {
                            _deleteAsset(asset);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: 'preview',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.visibility_rounded),
                                title: Text(context.l10n.preview),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'copy',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.link_rounded),
                                title: Text(context.l10n.mediaCopyLink),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.edit_rounded),
                                title: Text(context.l10n.edit),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  asset.active
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                title: Text(
                                  asset.active
                                      ? context.l10n.disable
                                      : context.l10n.enable,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                                title: Text(context.l10n.delete),
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _categoryLabel(asset.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_typeLabel(asset.type)} • ${_formatSize(asset.sizeBytes)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  if (asset.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      asset.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Chip(
                    avatar: Icon(
                      asset.active
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      size: 18,
                    ),
                    label: Text(
                      asset.active
                          ? context.l10n.active
                          : context.l10n.inactive,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.perm_media_rounded,
              size: 72,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noMediaAssetsYet,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noMediaAssetsYetDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _uploadAsset,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(context.l10n.uploadMedia),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.firestoreService.getCurrentMediaAssets(
      type: _selectedType,
      activeOnly: _showActiveOnly,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.mediaLibrary),
        actions: [
          IconButton(
            tooltip: context.l10n.uploadMedia,
            onPressed: _uploadAsset,
            icon: const Icon(Icons.upload_file_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadAsset,
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(context.l10n.upload),
      ),
      body: SafeArea(
        child: StreamBuilder<List<MediaAsset>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.mediaLoadFailed(snapshot.error.toString()),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final assets = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: _MediaLibraryHeader(
                          title: context.l10n.mediaLibrary,
                          description: context.l10n.mediaLibraryDescription,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: _buildFilters(),
                      ),
                    ),
                    if (assets.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 96),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildAssetCard(assets[index]),
                            childCount: assets.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                mainAxisExtent: 330,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MediaLibraryHeader extends StatelessWidget {
  final String title;
  final String description;

  const _MediaLibraryHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.perm_media_rounded,
              size: 32,
              color: Color(0xFF5E7CE2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final MediaAsset asset;
  final Color color;
  final IconData fallbackIcon;
  final Future<Uint8List?> Function(MediaAsset asset) loadImageBytes;

  const _MediaThumbnail({
    required this.asset,
    required this.color,
    required this.fallbackIcon,
    required this.loadImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: loadImageBytes(asset),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
          );
        }

        final bytes = snapshot.data;

        if (snapshot.hasError || bytes == null) {
          return Image.network(
            asset.downloadUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Icon(fallbackIcon, size: 44, color: color);
            },
          );
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}

class _MediaUploadRequest {
  final String name;
  final String description;
  final MediaAssetType type;
  final MediaAssetCategory category;

  const _MediaUploadRequest({
    required this.name,
    required this.description,
    required this.type,
    required this.category,
  });
}

class _MediaUploadDialog extends StatefulWidget {
  final String Function(MediaAssetType type) typeLabel;
  final String Function(MediaAssetCategory category) categoryLabel;
  final List<MediaAssetCategory> Function(MediaAssetType type)
  categoriesForType;
  final MediaAssetCategory Function(MediaAssetType type) defaultCategoryForType;

  const _MediaUploadDialog({
    required this.typeLabel,
    required this.categoryLabel,
    required this.categoriesForType,
    required this.defaultCategoryForType,
  });

  @override
  State<_MediaUploadDialog> createState() => _MediaUploadDialogState();
}

class _MediaUploadDialogState extends State<_MediaUploadDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  MediaAssetType _type = MediaAssetType.image;
  late MediaAssetCategory _category = widget.defaultCategoryForType(_type);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setType(MediaAssetType type) {
    setState(() {
      _type = type;
      _category = widget.defaultCategoryForType(type);
    });
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.mediaNameRequired)));
      return;
    }

    Navigator.pop(
      context,
      _MediaUploadRequest(
        name: name,
        description: _descriptionController.text.trim(),
        type: _type,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoriesForType(_type);

    return AlertDialog(
      title: Text(context.l10n.uploadMedia),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.name,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.mediaType,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    MediaAssetType.values.map((type) {
                      return ChoiceChip(
                        selected: _type == type,
                        label: Text(widget.typeLabel(type)),
                        onSelected: (_) => _setType(type),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MediaAssetCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  border: const OutlineInputBorder(),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(widget.categoryLabel(category)),
                      );
                    }).toList(),
                onChanged: (category) {
                  if (category == null) return;
                  setState(() => _category = category);
                },
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.mediaUploadPickerHint,
                style: Theme.of(context).textTheme.bodySmall,
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
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.folder_open_rounded),
          label: Text(context.l10n.chooseFile),
        ),
      ],
    );
  }
}

class _MediaAssetDetailsDialog extends StatefulWidget {
  final MediaAsset asset;
  final String Function(MediaAssetCategory category) categoryLabel;
  final List<MediaAssetCategory> Function(MediaAssetType type)
  categoriesForType;

  const _MediaAssetDetailsDialog({
    required this.asset,
    required this.categoryLabel,
    required this.categoriesForType,
  });

  @override
  State<_MediaAssetDetailsDialog> createState() =>
      _MediaAssetDetailsDialogState();
}

class _MediaAssetDetailsDialogState extends State<_MediaAssetDetailsDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.asset.name,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.asset.description);

  late MediaAssetCategory _category = widget.asset.category;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.mediaNameRequired)));
      return;
    }

    Navigator.pop(
      context,
      widget.asset.copyWith(
        name: name,
        description: _descriptionController.text.trim(),
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoriesForType(widget.asset.type);

    return AlertDialog(
      title: Text(context.l10n.editMediaAsset),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.name,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MediaAssetCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  border: const OutlineInputBorder(),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(widget.categoryLabel(category)),
                      );
                    }).toList(),
                onChanged: (category) {
                  if (category == null) return;
                  setState(() => _category = category);
                },
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
        FilledButton(onPressed: _submit, child: Text(context.l10n.save)),
      ],
    );
  }
}
