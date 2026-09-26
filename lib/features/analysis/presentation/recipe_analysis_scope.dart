// Phase 10 — portée d'analyse d'une recette.
//
// Lance UNE analyse métier (RecipeAnalysisService) par état de recette
// et la partage avec les cartes descendantes (nutrition, arômes,
// physico-chimie) : pas de recalcul par carte. L'analyse est relancée
// quand le contenu de la recette change (ingrédients, quantités,
// cuissons, étapes, portions).

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

class RecipeAnalysisScope extends StatefulWidget {
  const RecipeAnalysisScope({
    required this.recipe,
    required this.db,
    required this.child,
    super.key,
  });

  final Recipe recipe;
  final AppDatabase? db;
  final Widget child;

  /// Future d'analyse de la portée englobante (null sans base).
  static Future<RecipeAnalysis>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnalysisInherited>()?.future;

  /// Signature du contenu analysé.
  static String signature(Recipe r) => [
    r.servings,
    for (final i in r.ingredients)
      '${i.ingredientId}|${i.quantity}|${i.cookingMethod}|${i.source.name}',
    ...r.steps,
  ].join('§');

  @override
  State<RecipeAnalysisScope> createState() => _RecipeAnalysisScopeState();
}

class _RecipeAnalysisScopeState extends State<RecipeAnalysisScope> {
  Future<RecipeAnalysis>? _future;
  String? _signature;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(covariant RecipeAnalysisScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.db != widget.db ||
        RecipeAnalysisScope.signature(widget.recipe) != _signature) {
      _refresh();
    }
  }

  void _refresh() {
    final db = widget.db;
    _signature = RecipeAnalysisScope.signature(widget.recipe);
    _future = db == null
        ? null
        : RecipeAnalysisService(db).analyze(
            ingredients: widget.recipe.ingredients,
            steps: widget.recipe.steps,
            servings: widget.recipe.servings,
          );
  }

  @override
  Widget build(BuildContext context) =>
      _AnalysisInherited(future: _future, child: widget.child);
}

class _AnalysisInherited extends InheritedWidget {
  const _AnalysisInherited({required this.future, required super.child});

  final Future<RecipeAnalysis>? future;

  @override
  bool updateShouldNotify(_AnalysisInherited oldWidget) =>
      oldWidget.future != future;
}

/// Construit un widget à partir de l'analyse de la portée.
class RecipeAnalysisBuilder extends StatelessWidget {
  const RecipeAnalysisBuilder({
    required this.builder,
    this.placeholder,
    this.showLoading = false,
    super.key,
  });

  final Widget Function(BuildContext context, RecipeAnalysis analysis) builder;

  /// Affiché sans base ou en cas d'erreur.
  final Widget? placeholder;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    final future = RecipeAnalysisScope.of(context);
    if (future == null) return placeholder ?? const SizedBox.shrink();
    return FutureBuilder<RecipeAnalysis>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('RecipeAnalysis failed: ${snapshot.error}');
          return placeholder ?? const SizedBox.shrink();
        }
        final analysis = snapshot.data;
        if (analysis == null) {
          if (!showLoading) return placeholder ?? const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: Text(context.strings.analysisLoading)),
                ],
              ),
            ),
          );
        }
        return builder(context, analysis);
      },
    );
  }
}
