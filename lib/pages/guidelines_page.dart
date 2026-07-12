import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

enum _GuidelineFilter { all, guidelines, classroomDocuments, other }

class GuidelinesPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const GuidelinesPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<GuidelinesPage> createState() => _GuidelinesPageState();
}

class _GuidelinesPageState extends State<GuidelinesPage> {
  final TextEditingController _searchController = TextEditingController();
  _GuidelineFilter _filter = _GuidelineFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _t(String en, String ga) {
    return Localizations.localeOf(context).languageCode == 'ga' ? ga : en;
  }

  Future<void> _copyLink(BuildContext context, MediaAsset asset) async {
    final message = context.l10n.guidelineLinkCopied;
    await Clipboard.setData(ClipboardData(text: asset.downloadUrl));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openMediaLibrary(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/media-library',
      arguments: {
        'staffProfile': widget.staffProfile,
        'firestoreService': widget.firestoreService,
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _categoryLabel(MediaAssetCategory category) {
    switch (category) {
      case MediaAssetCategory.guideline:
        return context.l10n.mediaCategoryGuideline;
      case MediaAssetCategory.classroomDocument:
        return context.l10n.mediaCategoryClassroomDocument;
      case MediaAssetCategory.other:
        return context.l10n.mediaCategoryOther;
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
    }
  }

  String _filterLabel(_GuidelineFilter filter) {
    switch (filter) {
      case _GuidelineFilter.all:
        return _t('All documents', 'Gach cáipéis');
      case _GuidelineFilter.guidelines:
        return context.l10n.mediaCategoryGuideline;
      case _GuidelineFilter.classroomDocuments:
        return context.l10n.mediaCategoryClassroomDocument;
      case _GuidelineFilter.other:
        return context.l10n.mediaCategoryOther;
    }
  }

  IconData _categoryIcon(MediaAssetCategory category) {
    switch (category) {
      case MediaAssetCategory.guideline:
        return Icons.policy_rounded;
      case MediaAssetCategory.classroomDocument:
        return Icons.school_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _categoryColor(MediaAssetCategory category) {
    switch (category) {
      case MediaAssetCategory.guideline:
        return const Color(0xFF2E7D32);
      case MediaAssetCategory.classroomDocument:
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF6D4C41);
    }
  }

  List<MediaAsset> _filteredDocuments(List<MediaAsset> documents) {
    final query = _searchController.text.trim().toLowerCase();

    return documents.where((asset) {
      final categoryMatches = switch (_filter) {
        _GuidelineFilter.all => true,
        _GuidelineFilter.guidelines =>
          asset.category == MediaAssetCategory.guideline,
        _GuidelineFilter.classroomDocuments =>
          asset.category == MediaAssetCategory.classroomDocument,
        _GuidelineFilter.other =>
          asset.category != MediaAssetCategory.guideline &&
              asset.category != MediaAssetCategory.classroomDocument,
      };

      final queryMatches =
          query.isEmpty ||
          asset.name.toLowerCase().contains(query) ||
          asset.description.toLowerCase().contains(query) ||
          asset.fileName.toLowerCase().contains(query) ||
          _categoryLabel(asset.category).toLowerCase().contains(query);

      return categoryMatches && queryMatches;
    }).toList();
  }

  int _countForFilter(List<MediaAsset> documents, _GuidelineFilter filter) {
    return documents.where((asset) {
      return switch (filter) {
        _GuidelineFilter.all => true,
        _GuidelineFilter.guidelines =>
          asset.category == MediaAssetCategory.guideline,
        _GuidelineFilter.classroomDocuments =>
          asset.category == MediaAssetCategory.classroomDocument,
        _GuidelineFilter.other =>
          asset.category != MediaAssetCategory.guideline &&
              asset.category != MediaAssetCategory.classroomDocument,
      };
    }).length;
  }

  Widget _buildGuidelineCard(BuildContext context, MediaAsset asset) {
    final updatedDate = _formatDate(asset.updatedAt ?? asset.createdAt);
    final color = _categoryColor(asset.category);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(
                    _categoryIcon(asset.category),
                    color: color,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(
                              _categoryIcon(asset.category),
                              size: 17,
                              color: color,
                            ),
                            label: Text(_categoryLabel(asset.category)),
                          ),
                          if (!asset.active)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(_t('Inactive', 'Neamhghníomhach')),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        updatedDate.isEmpty
                            ? _formatSize(asset.sizeBytes)
                            : context.l10n.guidelineUpdated(
                              updatedDate,
                              _formatSize(asset.sizeBytes),
                            ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (asset.description.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(asset.description),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(context.l10n.guidelineOpenHint)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMediaLibrary(context),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text(_t('Manage file', 'Bainistigh comhad')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _copyLink(context, asset),
                    icon: const Icon(Icons.link_rounded),
                    label: Text(context.l10n.copyGuidelineLink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 76,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noGuidelinesYet,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noGuidelinesYetDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _openMediaLibrary(context),
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(context.l10n.openMediaLibrary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 62,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            _t(
              'No documents match this search.',
              'Níl aon cháipéis ag teacht leis an gcuardach seo.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.staffGuidelines),
        actions: [
          IconButton(
            tooltip: context.l10n.openMediaLibrary,
            onPressed: () => _openMediaLibrary(context),
            icon: const Icon(Icons.perm_media_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<MediaAsset>>(
          stream: widget.firestoreService.getCurrentMediaAssets(
            type: MediaAssetType.document,
            activeOnly: true,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.guidelinesLoadFailed(
                      snapshot.error.toString(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final documents = snapshot.data!;
            final filteredDocuments = _filteredDocuments(documents);

            if (documents.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _GuidelinesHeader(
                  title: context.l10n.staffGuidelines,
                  description: context.l10n.staffGuidelinesDescription,
                  documentCount: documents.length,
                  guidelineCount: _countForFilter(
                    documents,
                    _GuidelineFilter.guidelines,
                  ),
                  classroomDocumentCount: _countForFilter(
                    documents,
                    _GuidelineFilter.classroomDocuments,
                  ),
                  onManage: () => _openMediaLibrary(context),
                  t: _t,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _t(
                      'Search guidelines and documents',
                      'Cuardaigh treoirlínte agus cáipéisí',
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon:
                        _searchController.text.trim().isEmpty
                            ? null
                            : IconButton(
                              tooltip: _t('Clear search', 'Glan cuardach'),
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _GuidelineFilter.values.map((filter) {
                          final count = _countForFilter(documents, filter);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: _filter == filter,
                              label: Text('${_filterLabel(filter)} ($count)'),
                              onSelected: (_) {
                                setState(() => _filter = filter);
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (filteredDocuments.isEmpty)
                  _buildNoResults(context)
                else
                  ...filteredDocuments.map(
                    (asset) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildGuidelineCard(context, asset),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuidelinesHeader extends StatelessWidget {
  final String title;
  final String description;
  final int documentCount;
  final int guidelineCount;
  final int classroomDocumentCount;
  final VoidCallback onManage;
  final String Function(String en, String ga) t;

  const _GuidelinesHeader({
    required this.title,
    required this.description,
    required this.documentCount,
    required this.guidelineCount,
    required this.classroomDocumentCount,
    required this.onManage,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final icon = Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF2E7D32),
              size: 32,
            ),
          );

          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GuidelineStatPill(
                icon: Icons.description_rounded,
                label: t('Documents', 'Cáipéisí'),
                value: documentCount.toString(),
              ),
              _GuidelineStatPill(
                icon: Icons.policy_rounded,
                label: context.l10n.mediaCategoryGuideline,
                value: guidelineCount.toString(),
              ),
              _GuidelineStatPill(
                icon: Icons.school_rounded,
                label: context.l10n.mediaCategoryClassroomDocument,
                value: classroomDocumentCount.toString(),
              ),
            ],
          );

          final copy = Expanded(
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
                const SizedBox(height: 12),
                stats,
              ],
            ),
          );

          final action = OutlinedButton.icon(
            onPressed: onManage,
            icon: const Icon(Icons.perm_media_rounded),
            label: Text(context.l10n.manageGuidelines),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description),
                const SizedBox(height: 12),
                stats,
                const SizedBox(height: 14),
                action,
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: 16),
              copy,
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _GuidelineStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GuidelineStatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
