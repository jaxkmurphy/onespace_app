import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../services/firestore_service.dart';
import '../l10n/body_check_localizations.dart';
import '../l10n/l10n.dart';

enum BodyCheckFilter { all, unchecked, checked }

class BodyCheckOverviewPage extends StatefulWidget {
  final String teacherUid;
  final FirestoreService firestoreService;

  const BodyCheckOverviewPage({
    super.key,
    required this.teacherUid,
    required this.firestoreService,
  });

  @override
  State<BodyCheckOverviewPage> createState() => _BodyCheckOverviewPageState();
}

class _BodyCheckOverviewPageState extends State<BodyCheckOverviewPage> {
  BodyCheckFilter _statusFilter = BodyCheckFilter.all;
  String _selectedChild = 'All';

  final Set<String> _busyReports = {};

  String _painLabel(int level) {
    switch (level) {
      case 1:
        return context.l10n.painLittleSore;
      case 2:
        return context.l10n.painHurtsShort;
      case 3:
        return context.l10n.painHurtsALotShort;
      default:
        return context.l10n.painUnknown;
    }
  }

  Color _painColour(int level) {
    switch (level) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();

    final date =
        '${localTime.day.toString().padLeft(2, '0')}/'
        '${localTime.month.toString().padLeft(2, '0')}/'
        '${localTime.year}';
    final clock =
        '${localTime.hour.toString().padLeft(2, '0')}:'
        '${localTime.minute.toString().padLeft(2, '0')}';
    return context.l10n.dateTimeAt(date, clock);
  }

  List<BodyCheckReport> _filterAndSortReports(List<BodyCheckReport> reports) {
    final filtered =
        reports.where((report) {
          final matchesStatus = switch (_statusFilter) {
            BodyCheckFilter.all => true,
            BodyCheckFilter.unchecked => !report.checked,
            BodyCheckFilter.checked => report.checked,
          };

          final matchesChild =
              _selectedChild == 'All' || report.childName == _selectedChild;

          return matchesStatus && matchesChild;
        }).toList();

    filtered.sort((first, second) {
      if (first.checked != second.checked) {
        return first.checked ? 1 : -1;
      }

      if (!first.checked && first.painLevel != second.painLevel) {
        return second.painLevel.compareTo(first.painLevel);
      }

      return second.timestamp.compareTo(first.timestamp);
    });

    return filtered;
  }

  Future<void> _markChecked(BodyCheckReport report) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.health_and_safety_rounded, size: 44),
          title: Text(context.l10n.checkChildReport(report.childName)),
          content: SizedBox(
            width: 480,
            child: TextField(
              controller: noteController,
              maxLength: 240,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.optionalStaffNote,
                hintText: context.l10n.staffNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, noteController.text.trim());
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(context.l10n.markChecked),
            ),
          ],
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));

    noteController.dispose();

    if (note == null || !mounted) return;

    setState(() {
      _busyReports.add(report.id);
    });

    try {
      await widget.firestoreService.markCurrentBodyCheckReportChecked(
        reportId: report.id,
        checkedNote: note,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reportMarkedChecked(report.childName)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reportUpdateFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _busyReports.remove(report.id);
        });
      }
    }
  }

  Future<void> _deleteReport(BodyCheckReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.red,
            size: 44,
          ),
          title: Text(context.l10n.deleteReportQuestion),
          content: Text(context.l10n.deleteBodyCheckReport(report.childName)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _busyReports.add(report.id);
    });

    try {
      await widget.firestoreService.deleteCurrentBodyCheckReport(report.id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reportDeleteFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _busyReports.remove(report.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bodyCheckReports)),
      body: SafeArea(
        child: StreamBuilder<List<BodyCheckReport>>(
          stream: widget.firestoreService.getCurrentBodyCheckReports(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildLoadError();
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data!;
            final filteredReports = _filterAndSortReports(reports);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(reports),
                      const SizedBox(height: 18),
                      if (reports.isNotEmpty) ...[
                        _buildFilters(reports),
                        const SizedBox(height: 18),
                      ],
                      _buildResultsHeading(filteredReports.length),
                      const SizedBox(height: 12),
                      if (reports.isEmpty)
                        _buildEmptyState()
                      else if (filteredReports.isEmpty)
                        _buildNoMatches()
                      else
                        ...filteredReports.map(_buildReportCard),
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

  Widget _buildHeader(List<BodyCheckReport> reports) {
    final unchecked = reports.where((report) => !report.checked).length;

    final urgent =
        reports.where((report) {
          return !report.checked && report.painLevel == 3;
        }).length;

    final checked = reports.where((report) => report.checked).length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            final introduction = Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    size: 36,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.classroomBodyChecks,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(context.l10n.classroomBodyChecksIntro),
                    ],
                  ),
                ),
              ],
            );

            final statistics = Wrap(
              alignment: WrapAlignment.end,
              spacing: 9,
              runSpacing: 9,
              children: [
                _buildStatistic(
                  label: context.l10n.urgent,
                  value: urgent,
                  colour: Colors.red,
                  icon: Icons.priority_high_rounded,
                ),
                _buildStatistic(
                  label: context.l10n.unchecked,
                  value: unchecked,
                  colour: Colors.orange,
                  icon: Icons.pending_actions_rounded,
                ),
                _buildStatistic(
                  label: context.l10n.checked,
                  value: checked,
                  colour: Colors.green,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: introduction),
                  const SizedBox(width: 20),
                  statistics,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [introduction, const SizedBox(height: 18), statistics],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatistic({
    required String label,
    required int value,
    required Color colour,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colour, size: 25),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              color: colour,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildFilters(List<BodyCheckReport> reports) {
    final childNames =
        reports
            .map((report) => report.childName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final dropdownItems = ['All', ...childNames];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final statusSelector = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<BodyCheckFilter>(
                segments: [
                  ButtonSegment(
                    value: BodyCheckFilter.all,
                    label: Text(context.l10n.all),
                    icon: const Icon(Icons.list_rounded),
                  ),
                  ButtonSegment(
                    value: BodyCheckFilter.unchecked,
                    label: Text(context.l10n.unchecked),
                    icon: const Icon(Icons.warning_amber_rounded),
                  ),
                  ButtonSegment(
                    value: BodyCheckFilter.checked,
                    label: Text(context.l10n.checked),
                    icon: const Icon(Icons.check_circle_rounded),
                  ),
                ],
                selected: {_statusFilter},
                onSelectionChanged: (selected) {
                  setState(() {
                    _statusFilter = selected.first;
                  });
                },
              ),
            );

            final childSelector = DropdownButtonFormField<String>(
              initialValue:
                  dropdownItems.contains(_selectedChild)
                      ? _selectedChild
                      : 'All',
              decoration: InputDecoration(
                labelText: context.l10n.filterByChild,
                prefixIcon: const Icon(Icons.person_rounded),
                border: const OutlineInputBorder(),
              ),
              items:
                  dropdownItems.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name == 'All' ? context.l10n.all : name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedChild = value;
                });
              },
            );

            if (constraints.maxWidth >= 700) {
              return Row(
                children: [
                  Expanded(child: statusSelector),
                  const SizedBox(width: 16),
                  SizedBox(width: 270, child: childSelector),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statusSelector,
                const SizedBox(height: 14),
                childSelector,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsHeading(int count) {
    return Row(
      children: [
        Text(
          context.l10n.reports,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 9),
        Chip(
          label: Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(BodyCheckReport report) {
    final painColour = _painColour(report.painLevel);
    final isBusy = _busyReports.contains(report.id);
    final urgent = !report.checked && report.painLevel == 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: report.checked ? Colors.green : painColour,
              width: 7,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: painColour.withValues(alpha: 0.15),
                    foregroundColor: painColour,
                    child: Text(
                      report.painLevel.toString(),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.childName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(_formatTime(report.timestamp)),
                      ],
                    ),
                  ),
                  _buildStatusChip(report),
                ],
              ),
              if (urgent) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.priority_high_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.l10n.urgentBodyCheckMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _buildInformationChip(
                    icon: Icons.location_on_rounded,
                    label: localizedBodyPart(context.l10n, report.bodyPart),
                    colour: Colors.blue,
                  ),
                  _buildInformationChip(
                    icon: Icons.sentiment_dissatisfied_rounded,
                    label: _painLabel(report.painLevel),
                    colour: painColour,
                  ),
                  _buildInformationChip(
                    icon: Icons.healing_rounded,
                    label: localizedPainType(context.l10n, report.painType),
                    colour: Colors.deepPurple,
                  ),
                ],
              ),
              if (report.checked) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              report.checkedAt == null
                                  ? context.l10n.checkedByStaff
                                  : context.l10n.checkedAt(
                                    _formatTime(report.checkedAt!),
                                  ),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (report.checkedNote.trim().isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(report.checkedNote),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!report.checked)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : () => _markChecked(report),
                        icon:
                            isBusy
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.check_rounded),
                        label: Text(context.l10n.markChecked),
                      ),
                    ),
                  if (!report.checked) const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: context.l10n.deleteReport,
                    onPressed: isBusy ? null : () => _deleteReport(report),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BodyCheckReport report) {
    final colour = report.checked ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colour.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            report.checked ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: colour,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            report.checked ? context.l10n.checked : context.l10n.needsChecking,
            style: TextStyle(color: colour, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationChip({
    required IconData icon,
    required String label,
    required Color colour,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colour, size: 20),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(38),
        child: Column(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.noBodyCheckReports,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 7),
            Text(
              context.l10n.bodyCheckReportsAppearHere,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatches() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.filter_alt_off_rounded,
              size: 52,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noReportsMatchFilters,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 58,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.bodyCheckReportsLoadFailed,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
