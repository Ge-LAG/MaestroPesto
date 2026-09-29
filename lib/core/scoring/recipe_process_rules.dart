// Phase 10 (extrait en Phase 11) — règles pures partagées par l'analyse
// d'une recette (RecipeAnalysisService) et le moteur de composition
// (recette à l'envers) : mode de cuisson de chaque ligne et notes
// expertes hors base de règles.

import 'package:meta/meta.dart';

import '../../features/recipes/domain/recipe.dart';
import '../models/process_models.dart';
import 'physchem_estimator.dart';
import 'process_step_parser.dart';

/// Mode de cuisson résolu d'une ligne.
typedef LineMethod = ({CookingMethod method, bool inferred});

/// Note experte hors base de règles (bonnes pratiques documentées).
@immutable
class ExpertInsight {
  const ExpertInsight({required this.text, this.warning = false});

  final String text;
  final bool warning;
}

abstract final class RecipeProcessRules {
  /// Mode de cuisson de chaque ligne (index → mode), absent = cru :
  /// explicite > étape citant la ligne > étape au four sans mention
  /// (toute la préparation) > ingrédients de l'étape précédente.
  static Map<int, LineMethod> resolveLineMethods(
    List<RecipeIngredient> ingredients,
    List<ParsedStep> steps,
  ) {
    final out = <int, LineMethod>{};
    final explicit = <int>{};
    for (var i = 0; i < ingredients.length; i++) {
      final m = CookingMethod.fromId(ingredients[i].cookingMethod);
      if (m == null) continue;
      explicit.add(i);
      if (m.isHeated) out[i] = (method: m, inferred: false);
    }
    var previousMentions = <int>[];
    for (final step in steps) {
      final method = step.cookingMethod;
      final mentions = step.mentionedIngredients;
      if (method != null) {
        final List<int> targets;
        if (mentions.isNotEmpty) {
          targets = mentions;
        } else if (step.primary?.opId == 'PROC_ROTIR' ||
            previousMentions.isEmpty) {
          // Enfourner sans précision : toute la préparation.
          targets = [for (var i = 0; i < ingredients.length; i++) i];
        } else {
          targets = previousMentions;
        }
        for (final i in targets) {
          if (explicit.contains(i)) continue;
          out[i] = (method: method, inferred: true);
        }
      }
      if (mentions.isNotEmpty) previousMentions = mentions;
    }
    return out;
  }

  /// Notes expertes (hors règles Phase 4), sources : Damodaran, McGee,
  /// McClements — bonnes pratiques de formulation.
  static List<ExpertInsight> expertInsights(PhysChemState s) {
    final out = <ExpertInsight>[];
    final oilShare = s.totalMassG <= 0 ? 0 : s.liquidOilG / s.totalMassG;
    final emulsifier =
        s.hasComponent('LIP_PHOSPH', minPct: 0.05) ||
        s.hasComponent('LIP_MDG', minPct: 0.05) ||
        s.hasComponent('PROT_OVALB', minPct: 0.3);
    if (oilShare >= 0.15 && s.waterPct >= 8 && !emulsifier) {
      out.add(
        const ExpertInsight(
          text:
              'Émulsion temporaire : sans émulsifiant fort (jaune d\'œuf, '
              'lécithine), l\'huile se sépare en quelques minutes. La '
              'moutarde ou le miel la stabilisent un peu ; émulsionner au '
              'dernier moment.',
        ),
      );
    }
    if (s.hasTag('egg') && !s.hasHeating) {
      out.add(
        const ExpertInsight(
          warning: true,
          text:
              'Œuf cru : préparation à conserver au froid et à consommer '
              'dans les 24 h (déconseillé aux personnes fragiles).',
        ),
      );
    }
    if (s.hasTag('protease_fruit') &&
        s.hasComponent('PROT_GEL', minPct: 0.05) &&
        !s.hasHeating) {
      out.add(
        const ExpertInsight(
          warning: true,
          text:
              'Ananas, kiwi ou papaye crus contiennent des protéases qui '
              'empêchent la gélatine de prendre : cuire le fruit quelques '
              'minutes ou utiliser l\'agar-agar.',
        ),
      );
    }
    if (s.alcoholG > 0 && s.hasHeating) {
      out.add(
        const ExpertInsight(
          text:
              'Alcool : la cuisson n\'en évapore qu\'une partie (≈ 40 % '
              'restent après 15–30 min de mijotage ou de four).',
        ),
      );
    }
    final brix = s.brix;
    if (brix != null && brix >= 65 && s.hasCooling) {
      out.add(
        const ExpertInsight(
          text:
              'Sirop très concentré (≥ 65 % de sucres) : risque de '
              'cristallisation au refroidissement — un peu de glucose, de '
              'miel ou d\'acide limite le masquage.',
        ),
      );
    }
    return out;
  }
}
