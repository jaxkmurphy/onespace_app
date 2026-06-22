import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class ProfileSelectionCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isChild;

  const ProfileSelectionCard({
    super.key,
    required this.name,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onDelete,
    this.isChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isChild ? 4 : 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isChild ? 26 : 20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: isChild ? 66 : 58,
                height: isChild ? 66 : 58,
                decoration: BoxDecoration(
                  color:
                      isChild
                          ? color.withValues(alpha: 0.9)
                          : color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(isChild ? 24 : 18),
                ),
                child: Icon(
                  icon,
                  size: isChild ? 38 : 30,
                  color: isChild ? Colors.white : color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: context.l10n.deleteProfile,
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: onDelete,
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
