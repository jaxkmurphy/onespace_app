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
    final colourScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: subtitle == null ? name : '$name. $subtitle',
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isChild ? 28 : 24),
          side: BorderSide(
            color: color.withValues(alpha: isChild ? 0.28 : 0.18),
            width: isChild ? 1.8 : 1.4,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colourScheme.surface,
                  color.withValues(alpha: isChild ? 0.11 : 0.07),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: isChild ? 66 : 58,
                    height: isChild ? 66 : 58,
                    decoration: BoxDecoration(
                      gradient:
                          isChild
                              ? LinearGradient(
                                colors: [color, color.withValues(alpha: 0.76)],
                              )
                              : null,
                      color: isChild ? null : color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(isChild ? 24 : 20),
                      boxShadow:
                          isChild
                              ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      icon,
                      size: isChild ? 36 : 30,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: colourScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onDelete != null)
                    IconButton(
                      tooltip: context.l10n.deleteProfile,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: colourScheme.error,
                      onPressed: onDelete,
                    )
                  else
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.11),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: color,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}