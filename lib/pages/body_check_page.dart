import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/body_map_selector.dart';
import '../l10n/body_check_localizations.dart';
import '../l10n/l10n.dart';

class BodyCheckPage extends StatefulWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const BodyCheckPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  @override
  State<BodyCheckPage> createState() => _BodyCheckPageState();
}

class _BodyCheckPageState extends State<BodyCheckPage> {
  int _currentStep = 0;

  String? _selectedBodyPart;
  int? _selectedPainLevel;
  String? _selectedPainType;

  bool _isSaving = false;

  static const List<_PainLevelInfo> painLevels = [
    _PainLevelInfo(
      level: 1,
      label: 'A little sore',
      description: 'I notice it, but it only hurts a little.',
      icon: Icons.sentiment_neutral_rounded,
      colour: Colors.orange,
    ),
    _PainLevelInfo(
      level: 2,
      label: 'It hurts',
      description: 'It is uncomfortable and I need help.',
      icon: Icons.sentiment_dissatisfied_rounded,
      colour: Colors.deepOrange,
    ),
    _PainLevelInfo(
      level: 3,
      label: 'It hurts a lot',
      description: 'It hurts badly and I need an adult now.',
      icon: Icons.sentiment_very_dissatisfied_rounded,
      colour: Colors.red,
    ),
  ];

  static const List<_PainTypeInfo> painTypes = [
    _PainTypeInfo(
      value: 'Sore / Aching',
      label: 'Sore or aching',
      description: 'A dull or heavy pain.',
      icon: Icons.healing_rounded,
      colour: Colors.blue,
    ),
    _PainTypeInfo(
      value: 'Sharp',
      label: 'Sharp',
      description: 'A sudden or pointed pain.',
      icon: Icons.flash_on_rounded,
      colour: Colors.deepOrange,
    ),
    _PainTypeInfo(
      value: 'Burning / Hot',
      label: 'Burning or hot',
      description: 'It feels hot or burning.',
      icon: Icons.local_fire_department_rounded,
      colour: Colors.red,
    ),
    _PainTypeInfo(
      value: 'Itchy',
      label: 'Itchy',
      description: 'I want to scratch it.',
      icon: Icons.back_hand_rounded,
      colour: Colors.green,
    ),
    _PainTypeInfo(
      value: 'Throbbing',
      label: 'Throbbing',
      description: 'It pulses or beats.',
      icon: Icons.monitor_heart_rounded,
      colour: Colors.pink,
    ),
    _PainTypeInfo(
      value: 'Tingly / Numb',
      label: 'Tingly or numb',
      description: 'It feels asleep or strange.',
      icon: Icons.grain_rounded,
      colour: Colors.purple,
    ),
    _PainTypeInfo(
      value: 'Sick / Nauseous',
      label: 'Sick',
      description: 'I feel like I might be sick.',
      icon: Icons.sick_rounded,
      colour: Colors.teal,
    ),
    _PainTypeInfo(
      value: 'Not sure',
      label: 'Not sure',
      description: 'I cannot explain the feeling.',
      icon: Icons.help_outline_rounded,
      colour: Colors.blueGrey,
    ),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _continue() {
    if (_currentStep == 0 && _selectedBodyPart == null) {
      _showMessage(context.l10n.chooseSoreLocation);
      return;
    }

    if (_currentStep == 1 && _selectedPainLevel == null) {
      _showMessage(context.l10n.choosePainAmount);
      return;
    }

    if (_currentStep == 2 && _selectedPainType == null) {
      _showMessage(context.l10n.choosePainFeeling);
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goBack() {
    if (_currentStep == 0 || _isSaving) return;

    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitReport() async {
    if (_selectedBodyPart == null ||
        _selectedPainLevel == null ||
        _selectedPainType == null ||
        _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final report = BodyCheckReport(
      id: '',
      childId: widget.child.id,
      childName: widget.child.name,
      bodyPart: _selectedBodyPart!,
      painLevel: _selectedPainLevel!,
      painType: _selectedPainType!,
      timestamp: DateTime.now(),
      checked: false,
    );

    try {
      await widget.firestoreService.addCurrentBodyCheckReport(report);

      if (!mounted) return;

      await _showSuccessDialog();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(context.l10n.bodyCheckSendFailed);

      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 64,
          ),
          title: Text(
            context.l10n.staffHaveBeenTold,
            textAlign: TextAlign.center,
          ),
          content: Text(
            context.l10n.bodyCheckSentMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(context.l10n.okay),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bodyCheck)),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ),
            ),
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final stepNames = [
      context.l10n.bodyCheckWhere,
      context.l10n.bodyCheckHowMuch,
      context.l10n.bodyCheckWhatFeeling,
      context.l10n.review,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Row(
                children: List.generate(stepNames.length, (index) {
                  final completed = index < _currentStep;
                  final active = index == _currentStep;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  completed || active
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (index < stepNames.length - 1)
                          const SizedBox(width: 6),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 9),
              Text(
                context.l10n.bodyCheckStep(
                  _currentStep + 1,
                  4,
                  stepNames[_currentStep],
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBodyPartStep();
      case 1:
        return _buildPainLevelStep();
      case 2:
        return _buildPainTypeStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBodyPartStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIntroduction(
          icon: Icons.accessibility_new_rounded,
          title: context.l10n.whereDoesItHurt,
          message: context.l10n.tapSoreBodyPart,
          colour: Colors.blue,
        ),
        const SizedBox(height: 18),
        BodyMapSelector(
          selectedBodyPart: _selectedBodyPart,
          enabled: !_isSaving,
          onBodyPartSelected: (bodyPart) {
            setState(() {
              _selectedBodyPart = bodyPart;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPainLevelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIntroduction(
          icon: Icons.sentiment_dissatisfied_rounded,
          title: context.l10n.howMuchDoesItHurt,
          message: context.l10n.choosePainFace,
          colour: Colors.deepOrange,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            if (isWide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int index = 0; index < painLevels.length; index++) ...[
                      Expanded(child: _buildPainLevelCard(painLevels[index])),
                      if (index < painLevels.length - 1)
                        const SizedBox(width: 14),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                for (int index = 0; index < painLevels.length; index++) ...[
                  _buildPainLevelCard(painLevels[index]),
                  if (index < painLevels.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPainLevelCard(_PainLevelInfo pain) {
    final selected = _selectedPainLevel == pain.level;

    return Semantics(
      button: true,
      selected: selected,
      label: localizedPainLevel(context.l10n, pain.level),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: selected ? 7 : 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              _isSaving
                  ? null
                  : () {
                    setState(() {
                      _selectedPainLevel = pain.level;
                    });
                  },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pain.colour.withValues(alpha: selected ? 0.20 : 0.08),
              border: Border.all(
                color:
                    selected
                        ? pain.colour
                        : pain.colour.withValues(alpha: 0.25),
                width: selected ? 4 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(pain.icon, size: 72, color: pain.colour),
                const SizedBox(height: 12),
                Text(
                  localizedPainLevel(context.l10n, pain.level),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 7),
                Text(
                  localizedPainLevelDescription(context.l10n, pain.level),
                  textAlign: TextAlign.center,
                ),
                if (selected) ...[
                  const SizedBox(height: 12),
                  Icon(
                    Icons.check_circle_rounded,
                    color: pain.colour,
                    size: 30,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPainTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIntroduction(
          icon: Icons.psychology_alt_rounded,
          title: context.l10n.whatDoesItFeelLike,
          message: context.l10n.choosePainDescription,
          colour: Colors.purple,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth =
                constraints.maxWidth >= 850
                    ? (constraints.maxWidth - 42) / 4
                    : constraints.maxWidth >= 560
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children:
                  painTypes.map((type) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildPainTypeCard(type),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPainTypeCard(_PainTypeInfo type) {
    final selected = _selectedPainType == type.value;

    return Semantics(
      button: true,
      selected: selected,
      label: localizedPainType(context.l10n, type.value),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: selected ? 6 : 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              _isSaving
                  ? null
                  : () {
                    setState(() {
                      _selectedPainType = type.value;
                    });
                  },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 165),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: type.colour.withValues(alpha: selected ? 0.18 : 0.07),
              border: Border.all(
                color:
                    selected
                        ? type.colour
                        : type.colour.withValues(alpha: 0.24),
                width: selected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(type.icon, size: 42, color: type.colour),
                const SizedBox(height: 9),
                Text(
                  localizedPainType(context.l10n, type.value),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  localizedPainTypeDescription(context.l10n, type.value),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (selected) ...[
                  const SizedBox(height: 7),
                  Icon(Icons.check_circle_rounded, color: type.colour),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final pain = painLevels.firstWhere(
      (item) => item.level == _selectedPainLevel,
    );

    final type = painTypes.firstWhere(
      (item) => item.value == _selectedPainType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIntroduction(
          icon: Icons.fact_check_rounded,
          title: context.l10n.checkYourBodyCheck,
          message: context.l10n.reviewBodyCheckMessage,
          colour: Colors.green,
        ),
        const SizedBox(height: 20),
        _buildReviewItem(
          icon: Icons.location_on_rounded,
          colour: Colors.blue,
          label: context.l10n.bodyCheckWhere,
          value: localizedBodyPart(context.l10n, _selectedBodyPart!),
          onEdit: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildReviewItem(
          icon: pain.icon,
          colour: pain.colour,
          label: context.l10n.bodyCheckHowMuch,
          value: localizedPainLevel(context.l10n, pain.level),
          onEdit: () {
            setState(() {
              _currentStep = 1;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildReviewItem(
          icon: type.icon,
          colour: type.colour,
          label: context.l10n.bodyCheckWhatFeeling,
          value: localizedPainType(context.l10n, type.value),
          onEdit: () {
            setState(() {
              _currentStep = 2;
            });
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.record_voice_over_rounded,
                color: Colors.orange,
                size: 34,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  context.l10n.tellAdultBodyCheck,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required IconData icon,
    required Color colour,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: colour.withValues(alpha: 0.15),
          foregroundColor: colour,
          child: Icon(icon),
        ),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          tooltip: context.l10n.changeBodyCheckAnswer(label),
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
        ),
      ),
    );
  }

  Widget _buildStepIntroduction({
    required IconData icon,
    required String title,
    required String message,
    required Color colour,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 36, color: colour),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(message, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final isReviewStep = _currentStep == 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(context.l10n.back),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isReviewStep ? Colors.green : null,
                    ),
                    onPressed:
                        _isSaving
                            ? null
                            : isReviewStep
                            ? _submitReport
                            : _continue,
                    icon:
                        _isSaving
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(
                              isReviewStep
                                  ? Icons.send_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                    label: Text(
                      _isSaving
                          ? context.l10n.sending
                          : isReviewStep
                          ? context.l10n.tellStaff
                          : context.l10n.continueButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PainLevelInfo {
  final int level;
  final String label;
  final String description;
  final IconData icon;
  final Color colour;

  const _PainLevelInfo({
    required this.level,
    required this.label,
    required this.description,
    required this.icon,
    required this.colour,
  });
}

class _PainTypeInfo {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color colour;

  const _PainTypeInfo({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.colour,
  });
}
