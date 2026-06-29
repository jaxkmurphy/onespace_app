import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';

class AppIconPreview extends StatelessWidget {
  final String iconKey;
  final double size;
  final Color? color;
  final bool showBlankPlaceholder;

  const AppIconPreview({
    super.key,
    required this.iconKey,
    this.size = 24,
    this.color,
    this.showBlankPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    if (iconKey.trim().isEmpty) {
      if (!showBlankPlaceholder) return SizedBox.square(dimension: size);

      return Icon(Icons.block_rounded, size: size, color: color);
    }

    return Icon(appIconForKey(iconKey), size: size, color: color);
  }
}

Future<AppIconOption?> showAppIconPickerDialog({
  required BuildContext context,
  String? selectedKey,
  List<AppIconCategory>? categories,
  String title = 'Choose an icon',
  bool allowNoIcon = false,
  String noIconLabel = 'No icon',
}) {
  return showDialog<AppIconOption>(
    context: context,
    builder: (context) {
      return _AppIconPickerDialog(
        selectedKey: selectedKey,
        categories: categories,
        title: title,
        allowNoIcon: allowNoIcon,
        noIconLabel: noIconLabel,
      );
    },
  );
}

class _AppIconPickerDialog extends StatefulWidget {
  final String? selectedKey;
  final List<AppIconCategory>? categories;
  final String title;
  final bool allowNoIcon;
  final String noIconLabel;

  const _AppIconPickerDialog({
    required this.selectedKey,
    required this.categories,
    required this.title,
    required this.allowNoIcon,
    required this.noIconLabel,
  });

  @override
  State<_AppIconPickerDialog> createState() => _AppIconPickerDialogState();
}

class _AppIconPickerDialogState extends State<_AppIconPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  AppIconCategory? _selectedCategory;

  List<AppIconCategory> get _availableCategories {
    return widget.categories ?? AppIconCategory.values;
  }

  List<AppIconOption> get _filteredIcons {
    final query = _searchController.text.trim();
    final allowedCategories = _availableCategories.toSet();

    return appIconCatalog.where((option) {
      final categoryMatches =
          _selectedCategory == null || option.category == _selectedCategory;
      final allowed = allowedCategories.contains(option.category);
      final searchMatches = option.matches(query);

      return allowed && categoryMatches && searchMatches;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final icons = _filteredIcons;
    final showNoIconCard =
        widget.allowNoIcon &&
        _selectedCategory == null &&
        (widget.noIconLabel.toLowerCase().contains(
              _searchController.text.trim().toLowerCase(),
            ) ||
            _searchController.text.trim().isEmpty);

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search icons',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _searchController.text.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) {
                          setState(() => _selectedCategory = null);
                        },
                      ),
                    ),
                    for (final category in _availableCategories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.label),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child:
                    icons.isEmpty && !showNoIconCard
                        ? Center(
                          child: Text(
                            'No icons found',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: colourScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                        : GridView.builder(
                          itemCount: icons.length + (showNoIconCard ? 1 : 0),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 130,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.95,
                              ),
                          itemBuilder: (context, index) {
                            if (showNoIconCard && index == 0) {
                              return _NoIconChoiceCard(
                                label: widget.noIconLabel,
                                selected:
                                    widget.selectedKey == null ||
                                    widget.selectedKey!.trim().isEmpty,
                                onTap:
                                    () => Navigator.of(context).pop(
                                      const AppIconOption(
                                        key: '',
                                        label: 'No icon',
                                        icon: Icons.block_rounded,
                                        category: AppIconCategory.objects,
                                      ),
                                    ),
                              );
                            }

                            final iconIndex =
                                showNoIconCard ? index - 1 : index;
                            final option = icons[iconIndex];
                            final selected = option.key == widget.selectedKey;

                            return _IconChoiceCard(
                              option: option,
                              selected: selected,
                              onTap: () => Navigator.of(context).pop(option),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoIconChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NoIconChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          selected
              ? colourScheme.primaryContainer
              : colourScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? colourScheme.primary.withValues(alpha: 0.14)
                          : colourScheme.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block_rounded,
                  color:
                      selected
                          ? colourScheme.onPrimaryContainer
                          : colourScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      selected
                          ? colourScheme.onPrimaryContainer
                          : colourScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChoiceCard extends StatelessWidget {
  final AppIconOption option;
  final bool selected;
  final VoidCallback onTap;

  const _IconChoiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          selected
              ? colourScheme.primaryContainer
              : colourScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? colourScheme.primary.withValues(alpha: 0.14)
                          : colourScheme.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color:
                      selected
                          ? colourScheme.onPrimaryContainer
                          : colourScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                option.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      selected
                          ? colourScheme.onPrimaryContainer
                          : colourScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
