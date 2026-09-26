// Aides contextuelles en langage courant pour les termes techniques
// (aw, Brix, % AR…) : bulle au survol ou au clic, et note explicative
// dépliable intégrée aux cartes.

import 'package:flutter/material.dart';

/// Icône ⓘ qui affiche [message] au survol (bureau) ou au clic.
class InfoHint extends StatelessWidget {
  const InfoHint(this.message, {this.size = 15, super.key});

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    triggerMode: TooltipTriggerMode.tap,
    waitDuration: const Duration(milliseconds: 250),
    showDuration: const Duration(seconds: 10),
    constraints: const BoxConstraints(maxWidth: 340),
    child: Semantics(
      label: message,
      child: Icon(
        Icons.info_outline,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

/// Libellé suivi d'une [InfoHint].
class LabelWithHint extends StatelessWidget {
  const LabelWithHint(this.label, this.hint, {this.style, super.key});

  final String label;
  final String hint;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(child: Text(label, style: style)),
      const SizedBox(width: 4),
      InfoHint(hint, size: 14),
    ],
  );
}

/// Note explicative dépliable (« Comment lire ce score ? »), intégrée
/// au fil de la carte plutôt qu'en bulle.
class ExplainerNote extends StatefulWidget {
  const ExplainerNote({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  State<ExplainerNote> createState() => _ExplainerNoteState();
}

class _ExplainerNoteState extends State<ExplainerNote> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DefaultTextStyle.merge(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.children,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
