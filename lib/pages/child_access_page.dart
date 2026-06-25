import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ChildAccessPage extends StatefulWidget {
  final FirestoreService firestoreService;

  const ChildAccessPage({super.key, required this.firestoreService});

  @override
  State<ChildAccessPage> createState() => _ChildAccessPageState();
}

class _ChildAccessPageState extends State<ChildAccessPage> {
  final Set<String> _savingChildIds = {};
  bool _isSavingAll = false;

  Future<void> _setChildAccess({
    required ChildProfile child,
    required bool enabled,
  }) async {
    setState(() {
      _savingChildIds.add(child.id);
    });

    try {
      await widget.firestoreService.setCurrentChildProfileAccess(
        childId: child.id,
        enabled: enabled,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? '${child.name} can access their profile again.'
                : '${child.name} has been returned to the profile screen.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update ${child.name}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingChildIds.remove(child.id);
        });
      }
    }
  }

  Future<void> _setAllAccess({required bool enabled}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              enabled ? 'Unlock all profiles?' : 'Lock all profiles?',
            ),
            content: Text(
              enabled
                  ? 'All children will be able to access their profiles again.'
                  : 'All children will be returned to the profile screen and will need a teacher to unlock access.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(enabled ? 'Unlock all' : 'Lock all'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSavingAll = true;
    });

    try {
      await widget.firestoreService.setAllCurrentChildProfileAccess(
        enabled: enabled,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'All child profiles are unlocked.'
                : 'All child profiles are locked.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update child access: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAll = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Child Access')),
      body: SafeArea(
        child: StreamBuilder<List<ChildProfile>>(
          stream: widget.firestoreService.getCurrentChildProfiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Could not load child profiles: ${snapshot.error}'),
              );
            }

            final children = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: colourScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      Icons.lock_person_rounded,
                                      color: colourScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Control child profile access',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Pause a child profile when staff need the child back at the profile screen.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilledButton.icon(
                                    icon:
                                        _isSavingAll
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(Icons.lock_rounded),
                                    label: const Text('Lock all'),
                                    onPressed:
                                        _isSavingAll || children.isEmpty
                                            ? null
                                            : () =>
                                                _setAllAccess(enabled: false),
                                  ),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.lock_open_rounded),
                                    label: const Text('Unlock all'),
                                    onPressed:
                                        _isSavingAll || children.isEmpty
                                            ? null
                                            : () =>
                                                _setAllAccess(enabled: true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (children.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text('No child profiles found.'),
                          ),
                        )
                      else
                        ...children.map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ChildAccessCard(
                              child: child,
                              isSaving: _savingChildIds.contains(child.id),
                              onChanged:
                                  (enabled) => _setChildAccess(
                                    child: child,
                                    enabled: enabled,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChildAccessCard extends StatelessWidget {
  final ChildProfile child;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  const _ChildAccessCard({
    required this.child,
    required this.isSaving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final enabled = child.profileAccessEnabled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  enabled
                      ? colourScheme.primaryContainer
                      : colourScheme.errorContainer,
              child: Icon(
                enabled ? Icons.child_care_rounded : Icons.lock_rounded,
                color:
                    enabled
                        ? colourScheme.onPrimaryContainer
                        : colourScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enabled
                        ? 'Access open'
                        : 'Access paused — talk to a teacher',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSaving)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(value: enabled, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}