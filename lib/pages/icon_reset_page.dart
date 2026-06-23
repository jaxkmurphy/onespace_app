import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../l10n/profile_unlock_localizations.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../data/profile_unlock_icons.dart';
import '../widgets/child_icon_sequence_setup_dialog.dart';

class IconResetPage extends StatefulWidget {
  final String teacherUid;

  const IconResetPage({super.key, required this.teacherUid});

  @override
  State<IconResetPage> createState() => _IconResetPageState();
}

class _IconResetPageState extends State<IconResetPage> {
  final FirestoreService firestoreService = FirestoreService();

  Future<void> _resetSequence(ChildProfile child) async {
    final newSequence = await showDialog<List<String>>(
      context: context,
      builder: (_) => ChildIconSequenceSetupDialog(childName: child.name),
    );

    if (newSequence == null || newSequence.length != 3) return;

    try {
      await firestoreService.updateCurrentChildIconSequence(
        childId: child.id,
        iconSequence: newSequence,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.unlockSequenceResetFor(child.name)),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.unlockSequenceResetFailed(e.toString())),
        ),
      );
    }
  }

  Widget _buildSequenceIcons(List<String> sequence) {
    return Wrap(
      spacing: 8,
      children:
          sequence.map((keyName) {
            final match = profileUnlockIcons.where(
              (icon) => icon.keyName == keyName,
            );
            final option = match.isNotEmpty ? match.first : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option?.icon ?? Icons.help_outline, size: 28),
                const SizedBox(height: 4),
                Text(
                  localizedProfileUnlockIcon(
                    context.l10n,
                    option?.keyName ?? keyName,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.iconReset)),
      body: StreamBuilder<List<ChildProfile>>(
        stream: firestoreService.getCurrentChildProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.childrenLoadError(snapshot.error.toString()),
              ),
            );
          }

          final children = snapshot.data ?? [];

          if (children.isEmpty) {
            return Center(child: Text(context.l10n.noChildProfilesFoundShort));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final child = children[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.child_care, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSequenceIcons(child.iconSequence),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _resetSequence(child),
                        icon: const Icon(Icons.lock_reset),
                        label: Text(context.l10n.reset),
                      ),
                    ],
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
