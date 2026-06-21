import 'package:flutter/material.dart';
import '../data/when_then_icons.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';

class WhenThenChildPage extends StatefulWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const WhenThenChildPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  @override
  State<WhenThenChildPage> createState() => _WhenThenChildPageState();
}

class _WhenThenChildPageState extends State<WhenThenChildPage> {
  final Set<String> _scheduledAutomaticSelections = {};
  bool _isSelectingReward = false;

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectReward(String rewardId) async {
    if (_isSelectingReward || rewardId.isEmpty) return;

    setState(() {
      _isSelectingReward = true;
    });

    try {
      await widget.firestoreService.selectCurrentWhenThenReward(
        childId: widget.child.id,
        rewardId: rewardId,
      );
    } catch (_) {
      _showMessage('That choice could not be saved. Please try again.');

      _scheduledAutomaticSelections.remove(rewardId);
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingReward = false;
        });
      }
    }
  }

  void _automaticallySelectSingleReward(String rewardId) {
    if (rewardId.isEmpty ||
        _scheduledAutomaticSelections.contains(rewardId)) {
      return;
    }

    _scheduledAutomaticSelections.add(rewardId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _selectReward(rewardId);
      }
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Getting your plan ready...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              Text(
                'We could not load your plan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait a moment and try again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(SimpleLocalizations loc) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF7E57C2)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 58,
                  color: Color(0xFF7E57C2),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'You’re all caught up!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.getString('no_active_when_then'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'A new plan will appear here when it is ready.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard({
    required Map<String, dynamic> board,
    required SimpleLocalizations loc,
  }) {
    final isActive = board['isActive'] == true;

    final rawActivity = board['activity'];
    final activity = rawActivity is Map
        ? Map<String, dynamic>.from(rawActivity)
        : null;

    final rawRewards = board['rewards'];
    final rewards = rawRewards is List
        ? rawRewards
            .whereType<Map>()
            .map((reward) => Map<String, dynamic>.from(reward))
            .toList()
        : <Map<String, dynamic>>[];

    if (!isActive || activity == null || rewards.isEmpty) {
      return _buildEmptyState(loc);
    }

    final selectedRewardId = board['selectedRewardId'] as String?;

    Map<String, dynamic>? selectedReward;

    if (selectedRewardId != null) {
      for (final reward in rewards) {
        if (reward['id'] == selectedRewardId) {
          selectedReward = reward;
          break;
        }
      }
    }

    if (rewards.length == 1 && selectedRewardId == null) {
      final rewardId = rewards.first['id'] as String? ?? '';
      _automaticallySelectSingleReward(rewardId);
    }

    final activityLabel = activity['label'] as String? ?? '';
    final activityIconName =
        activity['iconName'] as String? ?? 'task';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              _GreetingCard(childName: widget.child.name),
              const SizedBox(height: 22),
              _WhenActivityCard(
                label: activityLabel,
                iconName: activityIconName,
                heading: loc.getString('when'),
              ),
              const SizedBox(height: 10),
              const _PlanConnector(),
              const SizedBox(height: 10),
              _ThenRewardsCard(
                rewards: rewards,
                selectedRewardId: selectedRewardId,
                isSelecting: _isSelectingReward,
                onRewardSelected: _selectReward,
                heading: loc.getString('then'),
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: selectedReward == null
                    ? const _EncouragementCard()
                    : _SuccessCard(
                        key: ValueKey(selectedRewardId),
                        reward: selectedReward,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(
      Localizations.localeOf(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.getString('when_then')),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2F7FF),
              Color(0xFFFFF7E8),
              Color(0xFFF7F1FF),
            ],
          ),
        ),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: widget.firestoreService.getCurrentWhenThenStream(
            childId: widget.child.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final board = snapshot.data;

            if (board == null || board.isEmpty) {
              return _buildEmptyState(loc);
            }

            return _buildBoard(
              board: board,
              loc: loc,
            );
          },
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String childName;

  const _GreetingCard({
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFF7E57C2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Here’s your plan, $childName!',
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                ),
                const SizedBox(height: 3),
                Text(
                  'One step at a time — you’ve got this!',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFFB300),
            size: 32,
          ),
        ],
      ),
    );
  }
}

class _WhenActivityCard extends StatelessWidget {
  final String label;
  final String iconName;
  final String heading;

  const _WhenActivityCard({
    required this.label,
    required this.iconName,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final style = whenThenStyleFor(iconName);
    const whenColor = Color(0xFF42A5F5);

    return Semantics(
      label: '$heading $label',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              whenColor,
              whenColor.withValues(alpha: 0.78),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: whenColor.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                heading,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                style.icon,
                color: style.color,
                size: 62,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanConnector extends StatelessWidget {
  const _PlanConnector();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 7,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF7E57C2)
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Icon(
          Icons.keyboard_double_arrow_down_rounded,
          color: Color(0xFF7E57C2),
          size: 44,
        ),
      ],
    );
  }
}

class _ThenRewardsCard extends StatelessWidget {
  final List<Map<String, dynamic>> rewards;
  final String? selectedRewardId;
  final bool isSelecting;
  final ValueChanged<String> onRewardSelected;
  final String heading;

  const _ThenRewardsCard({
    required this.rewards,
    required this.selectedRewardId,
    required this.isSelecting,
    required this.onRewardSelected,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final locked = selectedRewardId != null;
    final singleReward = rewards.length == 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFA726).withValues(alpha: 0.45),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA726)
                .withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              heading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            locked
                ? 'Great choice!'
                : singleReward
                    ? 'This is what comes next'
                    : 'Choose your reward',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          if (!locked && !singleReward)
            Text(
              'Tap the one you would like.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: rewards.map((reward) {
              final rewardId = reward['id'] as String? ?? '';
              final selected = rewardId == selectedRewardId;

              return _RewardChoiceCard(
                label: reward['label'] as String? ?? '',
                iconName:
                    reward['iconName'] as String? ?? 'task',
                selected: selected || singleReward,
                faded: locked && !selected,
                loading: isSelecting &&
                    (selectedRewardId == null || selected),
                onTap: locked || isSelecting || singleReward
                    ? null
                    : () => onRewardSelected(rewardId),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RewardChoiceCard extends StatelessWidget {
  final String label;
  final String iconName;
  final bool selected;
  final bool faded;
  final bool loading;
  final VoidCallback? onTap;

  const _RewardChoiceCard({
    required this.label,
    required this.iconName,
    required this.selected,
    required this.faded,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = whenThenStyleFor(iconName);

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: faded ? 0.35 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 210,
            constraints: const BoxConstraints(minHeight: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected
                  ? style.color.withValues(alpha: 0.14)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? style.color
                    : Colors.grey.shade300,
                width: selected ? 4 : 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: loading
                          ? Padding(
                              padding: const EdgeInsets.all(25),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: style.color,
                              ),
                            )
                          : Icon(
                              style.icon,
                              color: style.color,
                              size: 46,
                            ),
                    ),
                    if (selected && !loading)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
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

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('encouragement'),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            color: Color(0xFFEC407A),
            size: 30,
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              'Finish your WHEN activity, then enjoy your reward!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final Map<String, dynamic> reward;

  const _SuccessCard({
    super.key,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final label = reward['label'] as String? ?? '';
    final style = whenThenStyleFor(
      reward['iconName'] as String? ?? 'task',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF66BB6A),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              children: [
                const Text(
                  'Brilliant choice!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      style.icon,
                      color: Colors.white,
                      size: 25,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFEB3B),
            size: 42,
          ),
        ],
      ),
    );
  }
}