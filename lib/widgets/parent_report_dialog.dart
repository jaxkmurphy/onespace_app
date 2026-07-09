import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/parent_report_draft.dart';
import '../models/school_contact.dart';

class ParentReportDialog extends StatefulWidget {
  final ParentReportDraft draft;
  final List<SchoolContact> recipients;
  final Future<void> Function(SchoolContact recipient) onPrepared;

  const ParentReportDialog({
    super.key,
    required this.draft,
    required this.recipients,
    required this.onPrepared,
  });

  @override
  State<ParentReportDialog> createState() => _ParentReportDialogState();
}

class _ParentReportDialogState extends State<ParentReportDialog> {
  late SchoolContact _selectedRecipient = widget.recipients.first;
  bool _isLogging = false;

  Future<void> _copyBody() async {
    await Clipboard.setData(ClipboardData(text: widget.draft.body));
    await _logPrepared();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.parentReportBodyCopied)),
    );
  }

  Future<void> _copyRecipientEmail() async {
    await Clipboard.setData(ClipboardData(text: _selectedRecipient.email));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.parentReportRecipientCopied)),
    );
  }

  Future<void> _copySubject() async {
    await Clipboard.setData(ClipboardData(text: widget.draft.subject));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.parentReportSubjectCopied)),
    );
  }

  Future<void> _logPrepared() async {
    if (_isLogging) return;

    setState(() => _isLogging = true);
    try {
      await widget.onPrepared(_selectedRecipient);
    } finally {
      if (mounted) {
        setState(() => _isLogging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.prepareParentReport),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.parentReportPrivacyNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<SchoolContact>(
                initialValue: _selectedRecipient,
                decoration: InputDecoration(
                  labelText: context.l10n.selectGuardianRecipient,
                  border: const OutlineInputBorder(),
                ),
                items:
                    widget.recipients.map((recipient) {
                      final relationship = recipient.relationship.trim();
                      final label =
                          relationship.isEmpty
                              ? recipient.name
                              : '${recipient.name} • $relationship';

                      return DropdownMenuItem(
                        value: recipient,
                        child: Text(label),
                      );
                    }).toList(),
                onChanged: (recipient) {
                  if (recipient == null) return;
                  setState(() => _selectedRecipient = recipient);
                },
              ),
              const SizedBox(height: 14),
              _ReportField(
                label: context.l10n.email,
                value: _selectedRecipient.email,
              ),
              const SizedBox(height: 10),
              _ReportField(
                label: context.l10n.parentReportEmailSubject,
                value: widget.draft.subject,
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.parentReportPreview,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: SelectableText(widget.draft.body),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLogging ? null : _copyRecipientEmail,
          child: Text(context.l10n.copyRecipientEmail),
        ),
        TextButton(
          onPressed: _isLogging ? null : _copySubject,
          child: Text(context.l10n.copySubject),
        ),
        FilledButton.icon(
          onPressed: _isLogging ? null : _copyBody,
          icon:
              _isLogging
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.content_copy_rounded),
          label: Text(context.l10n.copyEmailBody),
        ),
        TextButton(
          onPressed: _isLogging ? null : () => Navigator.pop(context),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }
}

class _ReportField extends StatelessWidget {
  final String label;
  final String value;

  const _ReportField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    );
  }
}
