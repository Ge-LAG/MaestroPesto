import 'package:flutter/material.dart';
import 'package:maestropesto/app/theme/app_theme.dart';

class RecipeTagLabel extends StatelessWidget {
  const RecipeTagLabel({
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final tone = label.hashCode.abs() % palette.tagBackgrounds.length;
    final background = selected
        ? colorScheme.primary
        : palette.tagBackgrounds[tone];
    final foreground = selected ? colorScheme.onPrimary : palette.tagText;

    final tag = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? colorScheme.primary : palette.tagBorders[tone],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
        ),
      ),
    );

    if (onTap == null) {
      return tag;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: tag,
    );
  }
}
