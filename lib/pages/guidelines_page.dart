import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class GuidelinesPage extends StatelessWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const GuidelinesPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

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
        'staffProfile': staffProfile,
        'firestoreService': firestoreService,
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

  Widget _buildGuidelineCard(BuildContext context, MediaAsset asset) {
    final updatedDate = _formatDate(asset.updatedAt ?? asset.createdAt);

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
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _copyLink(context, asset),
                icon: const Icon(Icons.link_rounded),
                label: Text(context.l10n.copyGuidelineLink),
              ),
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
          stream: firestoreService.getCurrentMediaAssets(
            type: MediaAssetType.document,
            category: MediaAssetCategory.guideline,
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

            final guidelines = snapshot.data!;

            if (guidelines.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _GuidelinesHeader(
                  title: context.l10n.staffGuidelines,
                  description: context.l10n.staffGuidelinesDescription,
                  onManage: () => _openMediaLibrary(context),
                ),
                const SizedBox(height: 16),
                ...guidelines.map(
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
  final VoidCallback onManage;

  const _GuidelinesHeader({
    required this.title,
    required this.description,
    required this.onManage,
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
          final compact = constraints.maxWidth < 620;
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
