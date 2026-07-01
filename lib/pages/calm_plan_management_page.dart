import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../models/calm_plan_models.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';

class CalmPlanManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const CalmPlanManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<CalmPlanManagementPage> createState() => _CalmPlanManagementPageState();
}

class _CalmPlanManagementPageState extends State<CalmPlanManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _resolveRequest(CalmRequest request) async {
    try {
      await widget.firestoreService.resolveCurrentCalmRequest(
        requestId: request.id,
        staffId: widget.staffProfile.id,
        staffName: widget.staffProfile.name,
      );

      if (!mounted) return;
      _showMessage(context.l10n.calmRequestResolved(request.childName));
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmRequestResolveError(error.toString()));
    }
  }

  Future<void> _seedDefaults() async {
    try {
      await widget.firestoreService.seedCurrentDefaultCalmToolsIfEmpty();
      if (!mounted) return;
      _showMessage(context.l10n.calmDefaultsAdded);
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmDefaultsAddError(error.toString()));
    }
  }

  Future<void> _addTool(List<CalmTool> currentTools) async {
    final draft = await showDialog<_CalmToolDraft>(
      context: context,
      builder: (_) => const _CalmToolDialog(),
    );

    if (draft == null) return;

    final nextSortOrder =
        currentTools.isEmpty
            ? 0
            : currentTools
                    .map((tool) => tool.sortOrder)
                    .reduce((a, b) => a > b ? a : b) +
                1;

    try {
      await widget.firestoreService.addCurrentCalmTool(
        CalmTool(
          id: '',
          name: draft.name,
          description: draft.description,
          iconName: draft.iconName,
          active: true,
          sortOrder: nextSortOrder,
        ),
      );

      if (!mounted) return;
      _showMessage(context.l10n.calmToolAdded);
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmToolAddError(error.toString()));
    }
  }

  Future<void> _editTool(CalmTool tool) async {
    final draft = await showDialog<_CalmToolDraft>(
      context: context,
      builder: (_) => _CalmToolDialog(tool: tool),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentCalmTool(
        tool.copyWith(
          name: draft.name,
          description: draft.description,
          iconName: draft.iconName,
          updatedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      _showMessage(context.l10n.calmToolUpdated);
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmToolUpdateError(error.toString()));
    }
  }

  Future<void> _toggleTool(CalmTool tool) async {
    try {
      await widget.firestoreService.updateCurrentCalmTool(
        tool.copyWith(active: !tool.active, updatedAt: DateTime.now()),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmToolUpdateError(error.toString()));
    }
  }

  Future<void> _deleteTool(CalmTool tool) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(context.l10n.deleteCalmToolQuestion),
            content: Text(context.l10n.deleteCalmToolMessage(tool.name)),
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
          ),
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentCalmTool(tool.id);
      if (!mounted) return;
      _showMessage(context.l10n.calmToolDeleted);
    } catch (error) {
      if (!mounted) return;
      _showMessage(context.l10n.calmToolDeleteError(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calmPlan),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.notifications_active_rounded),
              text: context.l10n.calmRequests,
            ),
            Tab(
              icon: const Icon(Icons.spa_rounded),
              text: context.l10n.calmTools,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RequestsTab(
            firestoreService: widget.firestoreService,
            onResolve: _resolveRequest,
          ),
          _ToolsTab(
            firestoreService: widget.firestoreService,
            onSeedDefaults: _seedDefaults,
            onAddTool: _addTool,
            onEditTool: _editTool,
            onToggleTool: _toggleTool,
            onDeleteTool: _deleteTool,
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final Future<void> Function(CalmRequest request) onResolve;

  const _RequestsTab({required this.firestoreService, required this.onResolve});

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  String _selectedChildId = '';

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF26A69A);

    return StreamBuilder<List<CalmRequest>>(
      stream: widget.firestoreService.getCurrentCalmRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.calmRequestsLoadFailed));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        final childOptions = <String, String>{};
        for (final request in requests) {
          if (request.childId.trim().isEmpty) continue;
          childOptions[request.childId] =
              request.childName.trim().isEmpty
                  ? context.l10n.aChild
                  : request.childName;
        }

        final effectiveChildId =
            childOptions.containsKey(_selectedChildId) ? _selectedChildId : '';

        final filteredRequests =
            effectiveChildId.isEmpty
                ? requests
                : requests
                    .where((request) => request.childId == effectiveChildId)
                    .toList();

        final active =
            filteredRequests
                .where((request) => request.status == CalmRequestStatus.active)
                .toList();
        final history =
            filteredRequests
                .where(
                  (request) => request.status == CalmRequestStatus.resolved,
                )
                .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            _StaffCalmHeader(
              color: color,
              icon: Icons.notifications_active_rounded,
              title: context.l10n.calmSupportRequestsTitle,
              subtitle: context.l10n.calmSupportRequestsSubtitle,
            ),
            const SizedBox(height: 18),
            if (childOptions.isNotEmpty) ...[
              _ChildRequestFilter(
                selectedChildId: effectiveChildId,
                childOptions: childOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
              ),
              const SizedBox(height: 18),
            ],
            _SectionTitle(
              title: context.l10n.activeRequests,
              subtitle:
                  active.isEmpty
                      ? context.l10n.noActiveCalmRequests
                      : context.l10n.calmRequestsWaiting(active.length),
            ),
            const SizedBox(height: 10),
            if (active.isEmpty)
              _EmptyCard(
                icon: Icons.check_circle_rounded,
                text: context.l10n.allCalmRequestsResolved,
              )
            else
              ...active.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RequestCard(
                    request: request,
                    color: color,
                    showResolveButton: true,
                    onResolve: () => widget.onResolve(request),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            _SectionTitle(
              title: context.l10n.recentSupportHistory,
              subtitle:
                  history.isEmpty
                      ? context.l10n.resolvedRequestsAppearHere
                      : context.l10n.resolvedCalmRequestCount(history.length),
            ),
            const SizedBox(height: 10),
            if (history.isEmpty)
              _EmptyCard(
                icon: Icons.history_rounded,
                text: context.l10n.noResolvedCalmRequests,
              )
            else
              ...history.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RequestCard(
                    request: request,
                    color: color,
                    showResolveButton: false,
                    onResolve: null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChildRequestFilter extends StatelessWidget {
  final String selectedChildId;
  final Map<String, String> childOptions;
  final ValueChanged<String> onChanged;

  const _ChildRequestFilter({
    required this.selectedChildId,
    required this.childOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries =
        childOptions.entries.toList()..sort(
          (first, second) =>
              first.value.toLowerCase().compareTo(second.value.toLowerCase()),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedChildId,
        decoration: InputDecoration(
          labelText: context.l10n.classroomHelperFilterByChild,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
            value: '',
            child: Text(context.l10n.classroomHelperAllChildren),
          ),
          ...sortedEntries.map(
            (entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ),
        ],
        onChanged: (value) => onChanged(value ?? ''),
      ),
    );
  }
}

class _ToolsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  final Future<void> Function() onSeedDefaults;
  final Future<void> Function(List<CalmTool> currentTools) onAddTool;
  final Future<void> Function(CalmTool tool) onEditTool;
  final Future<void> Function(CalmTool tool) onToggleTool;
  final Future<void> Function(CalmTool tool) onDeleteTool;

  const _ToolsTab({
    required this.firestoreService,
    required this.onSeedDefaults,
    required this.onAddTool,
    required this.onEditTool,
    required this.onToggleTool,
    required this.onDeleteTool,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF26A69A);

    return StreamBuilder<List<CalmTool>>(
      stream: firestoreService.getCurrentCalmTools(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.calmToolsLoadFailed));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tools = snapshot.data!;
        final previewingDefaultTools =
            tools.isNotEmpty &&
            tools.every(
              (tool) =>
                  tool.createdAt == null &&
                  tool.updatedAt == null &&
                  defaultCalmTools.any(
                    (defaultTool) => defaultTool.id == tool.id,
                  ),
            );

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            _StaffCalmHeader(
              color: color,
              icon: Icons.spa_rounded,
              title: context.l10n.calmToolsTitle,
              subtitle: context.l10n.calmToolsSubtitle,
            ),
            const SizedBox(height: 18),
            if (previewingDefaultTools) ...[
              _PreviewDefaultsBanner(color: color),
              const SizedBox(height: 14),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => onAddTool(tools),
                  style: FilledButton.styleFrom(backgroundColor: color),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.addCalmTool),
                ),
                OutlinedButton.icon(
                  onPressed: onSeedDefaults,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    previewingDefaultTools
                        ? context.l10n.saveDefaultsToClassroom
                        : context.l10n.addDefaultsIfEmpty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tools.isEmpty)
              _EmptyCard(
                icon: Icons.spa_rounded,
                text: context.l10n.noCalmTools,
              )
            else
              ...tools.map(
                (tool) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ToolCard(
                    tool: tool,
                    color: color,
                    actionsEnabled: !previewingDefaultTools,
                    onEdit: () => onEditTool(tool),
                    onToggle: () => onToggleTool(tool),
                    onDelete: () => onDeleteTool(tool),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PreviewDefaultsBanner extends StatelessWidget {
  final Color color;

  const _PreviewDefaultsBanner({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.previewDefaultsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.previewDefaultsMessage,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffCalmHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StaffCalmHeader({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CalmRequest request;
  final Color color;
  final bool showResolveButton;
  final VoidCallback? onResolve;

  const _RequestCard({
    required this.request,
    required this.color,
    required this.showResolveButton,
    required this.onResolve,
  });

  String _timeLabel(BuildContext context, DateTime? date) {
    final l10n = context.l10n;

    if (date == null) return l10n.justNow;

    final minutes = DateTime.now().difference(date).inMinutes;

    if (minutes < 1) return l10n.justNow;
    if (minutes == 1) return l10n.oneMinuteAgo;
    if (minutes < 60) return l10n.minutesAgo(minutes);

    final hours = minutes ~/ 60;
    if (hours == 1) return l10n.oneHourAgo;
    if (hours < 24) return l10n.hoursAgo(hours);

    final days = hours ~/ 24;
    if (days == 1) return l10n.oneDayAgo;
    return l10n.daysAgo(days);
  }

  @override
  Widget build(BuildContext context) {
    final childName =
        request.childName.trim().isEmpty
            ? context.l10n.aChild
            : request.childName;
    final toolName =
        request.toolName.trim().isEmpty
            ? context.l10n.calmSupport
            : request.toolName;
    final resolvedBy =
        request.resolvedByStaffName.trim().isEmpty
            ? context.l10n.notResolvedYet
            : request.resolvedByStaffName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            request.status == CalmRequestStatus.active
                ? color.withValues(alpha: 0.08)
                : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              request.status == CalmRequestStatus.active
                  ? color.withValues(alpha: 0.18)
                  : Colors.grey.shade200,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;

          final icon = Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              appIconForKey(request.toolIconName, fallbackKey: 'leaf'),
              color: color,
              size: 30,
            ),
          );

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.childAskedForHelp(childName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      avatar: Icon(
                        request.status == CalmRequestStatus.active
                            ? Icons.notifications_active_rounded
                            : Icons.check_circle_rounded,
                      ),
                      label: Text(
                        request.status == CalmRequestStatus.active
                            ? context.l10n.active
                            : context.l10n.resolved,
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.spa_rounded),
                      label: Text(toolName),
                    ),
                    Chip(
                      avatar: const Icon(Icons.schedule_rounded),
                      label: Text(_timeLabel(context, request.createdAt)),
                    ),
                    if (request.status == CalmRequestStatus.resolved)
                      Chip(
                        avatar: const Icon(Icons.person_rounded),
                        label: Text(context.l10n.resolvedBy(resolvedBy)),
                      ),
                  ],
                ),
              ],
            ),
          );

          final button =
              showResolveButton
                  ? FilledButton.icon(
                    onPressed: onResolve,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(context.l10n.markResolved),
                  )
                  : null;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, const SizedBox(width: 12), details],
                ),
                if (button != null) ...[const SizedBox(height: 12), button],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 12),
              details,
              if (button != null) ...[const SizedBox(width: 12), button],
            ],
          );
        },
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final CalmTool tool;
  final Color color;
  final bool actionsEnabled;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ToolCard({
    required this.tool,
    required this.color,
    required this.actionsEnabled,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final description = tool.description.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tool.active ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              tool.active
                  ? color.withValues(alpha: 0.18)
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: tool.active ? 1 : 0.45,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                appIconForKey(tool.iconName, fallbackKey: 'leaf'),
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Opacity(
              opacity: tool.active ? 1 : 0.58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Wrap(
            spacing: 4,
            children: [
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: actionsEnabled ? onEdit : null,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip:
                    tool.active ? context.l10n.disable : context.l10n.enable,
                onPressed: actionsEnabled ? onToggle : null,
                icon: Icon(
                  tool.active
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
              IconButton(
                tooltip: context.l10n.delete,
                onPressed: actionsEnabled ? onDelete : null,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF26A69A), size: 46),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CalmToolDialog extends StatefulWidget {
  final CalmTool? tool;

  const _CalmToolDialog({this.tool});

  @override
  State<_CalmToolDialog> createState() => _CalmToolDialogState();
}

class _CalmToolDialogState extends State<_CalmToolDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _iconName;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.tool?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.tool?.description ?? '',
    );
    _iconName = widget.tool?.iconName ?? 'leaf';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _iconName,
      title: context.l10n.chooseCalmToolIcon,
    );

    if (selected == null) return;

    setState(() {
      _iconName = selected.key;
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) return;

    Navigator.pop(
      context,
      _CalmToolDraft(name: name, description: description, iconName: _iconName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.tool != null;

    return AlertDialog(
      title: Text(
        editing ? context.l10n.editCalmTool : context.l10n.addCalmTool,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.calmToolName,
                  hintText: context.l10n.calmToolNameHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  hintText: context.l10n.calmToolDescriptionHint,
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _chooseIcon,
                icon: AppIconPreview(iconKey: _iconName),
                label: Text(context.l10n.chooseIcon),
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
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _CalmToolDraft {
  final String name;
  final String description;
  final String iconName;

  const _CalmToolDraft({
    required this.name,
    required this.description,
    required this.iconName,
  });
}
