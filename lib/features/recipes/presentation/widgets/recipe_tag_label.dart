import 'package:flutter/material.dart';

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
    final background = selected ? colorScheme.primary : _tagColor(label);
    final foreground = selected
        ? colorScheme.onPrimary
        : const Color(0xFF2E332D);

    final tag = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? colorScheme.primary : _tagBorderColor(label),
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

Color _tagColor(String label) {
  final colors = [
    const Color(0xFFE5F0EA),
    const Color(0xFFF3E8D1),
    const Color(0xFFE4ECF4),
    const Color(0xFFF1E2DF),
    const Color(0xFFEAE6F3),
    const Color(0xFFE7EED7),
  ];
  return colors[label.hashCode.abs() % colors.length];
}

Color _tagBorderColor(String label) {
  final colors = [
    const Color(0xFFC7DDD0),
    const Color(0xFFE2CAA0),
    const Color(0xFFC8D7E5),
    const Color(0xFFE2C5BF),
    const Color(0xFFD5CCE8),
    const Color(0xFFD1DEB4),
  ];
  return colors[label.hashCode.abs() % colors.length];
}
