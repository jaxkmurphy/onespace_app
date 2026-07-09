class ParentReportDraft {
  final String type;
  final String sourceId;
  final String childId;
  final String childName;
  final String subject;
  final String body;

  const ParentReportDraft({
    required this.type,
    required this.sourceId,
    required this.childId,
    required this.childName,
    required this.subject,
    required this.body,
  });
}
