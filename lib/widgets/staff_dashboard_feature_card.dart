import 'package:flutter/material.dart';

class StaffDashboardFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  const StaffDashboardFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final accent = color ?? colourScheme.primary;

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title. $subtitle',
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: accent.withValues(alpha: 0.18),
            width: 1.5,
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
                  accent.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(icon, size: 28, color: accent),
                      ),
                      const Spacer(),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 19,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colourScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}