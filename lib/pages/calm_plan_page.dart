import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../models/calm_plan_models.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class CalmPlanPage extends StatefulWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const CalmPlanPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  @override
  State<CalmPlanPage> createState() => _CalmPlanPageState();
}

class _CalmPlanPageState extends State<CalmPlanPage> {
  CalmTool? _selectedTool;
  bool _sendingHelpRequest = false;
  bool _helpRequestSent = false;

  _CalmPlanText get _text => _CalmPlanText.of(context);

  Future<void> _requestHelp(CalmTool tool) async {
    if (_sendingHelpRequest) return;

    setState(() {
      _sendingHelpRequest = true;
    });

    try {
      await widget.firestoreService.createCurrentCalmRequest(
        childId: widget.child.id,
        childName: widget.child.name,
        tool: tool,
      );

      if (!mounted) return;

      setState(() {
        _helpRequestSent = true;
        _sendingHelpRequest = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_text.teacherNotified)));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _sendingHelpRequest = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_text.couldNotSendHelp)));
    }
  }

  void _chooseAnotherTool() {
    setState(() {
      _selectedTool = null;
      _helpRequestSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(title: Text(_text.title)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFFFFB), Color(0xFFF3F0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _selectedTool == null
                  ? _buildToolPicker(color)
                  : _buildSelectedTool(color, _selectedTool!),
        ),
      ),
    );
  }

  Widget _buildToolPicker(Color color) {
    return StreamBuilder<List<CalmTool>>(
      stream: widget.firestoreService.getCurrentActiveCalmTools(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(_text.couldNotLoadTools));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tools = snapshot.data!;

        if (tools.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _text.noTools,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          children: [
            _HeaderCard(color: color, text: _text),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 2 : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tools.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final tool = tools[index];

                    return _CalmToolCard(
                      tool: tool,
                      color: color,
                      onTap: () {
                        setState(() {
                          _selectedTool = tool;
                          _helpRequestSent = false;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTool(Color color, CalmTool tool) {
    final description = tool.description.trim();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  appIconForKey(tool.iconName, fallbackKey: 'leaf'),
                  color: color,
                  size: 54,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tool.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _helpRequestSent ? _text.helpIsComing : _text.goodChoice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _helpRequestSent || _sendingHelpRequest
                          ? null
                          : () => _requestHelp(tool),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon:
                      _sendingHelpRequest
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.notifications_active_rounded),
                  label: Text(
                    _helpRequestSent ? _text.teacherNotified : _text.needHelp,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _chooseAnotherTool,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(_text.chooseAnotherTool),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color color;
  final _CalmPlanText text;

  const _HeaderCard({required this.color, required this.text});

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
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text.subtitle,
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

class _CalmToolCard extends StatelessWidget {
  final CalmTool tool;
  final Color color;
  final VoidCallback onTap;

  const _CalmToolCard({
    required this.tool,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = tool.description.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withValues(alpha: 0.16), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  appIconForKey(tool.iconName, fallbackKey: 'leaf'),
                  color: color,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalmPlanText {
  final bool isIrish;

  const _CalmPlanText._(this.isIrish);

  static _CalmPlanText of(BuildContext context) {
    return _CalmPlanText._(
      Localizations.localeOf(context).languageCode == 'ga',
    );
  }

  String get title => isIrish ? 'Mo Uirlisí Suaimhnis' : 'My Calm Tools';

  String get dashboardSubtitle =>
      isIrish ? 'Roghnaigh rud a chabhróidh leat.' : 'Choose what might help.';

  String get subtitle =>
      isIrish
          ? 'Roghnaigh rud a chabhróidh le do chorp mothú níos suaimhní.'
          : 'Choose something to help your body feel calm.';

  String get goodChoice =>
      isIrish ? 'Rogha mhaith. Bain triail as seo.' : 'Good choice. Try this.';

  String get needHelp => isIrish ? 'Teastaíonn cabhair uaim' : 'I need help';

  String get teacherNotified =>
      isIrish ? 'Cuireadh múinteoir ar an eolas.' : 'A teacher has been told.';

  String get helpIsComing =>
      isIrish ? 'Tá cabhair ag teacht.' : 'Help is on the way.';

  String get chooseAnotherTool =>
      isIrish ? 'Roghnaigh uirlis eile' : 'Choose another tool';

  String get couldNotLoadTools =>
      isIrish
          ? 'Níorbh fhéidir na huirlisí suaimhnis a lódáil.'
          : 'Could not load calm tools.';

  String get couldNotSendHelp =>
      isIrish
          ? 'Níorbh fhéidir cabhair a iarraidh anois.'
          : 'Could not ask for help right now.';

  String get noTools =>
      isIrish
          ? 'Níl aon uirlis suaimhnis ar fáil fós.'
          : 'No calm tools are available yet.';
}
