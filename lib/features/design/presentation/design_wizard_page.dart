// Phase 11 Lot C — assistant « Concevoir par objectifs ».
//
// Quatre temps (phase11-recette-inversee, lot C) : cadre (type de plat,
// portions, ingrédients imposés ou exclus, allergènes), objectifs (trois
// cartes facultatives, aides ⓘ en langage courant), priorités (liste à
// réordonner, curseurs avancés), mode (Cuisine cohérente / Pure
// Innovation, avertissement de phase11-cadrage D2). Le moteur tourne
// hors du fil de l'interface ; la proposition retenue revient comme un
// brouillon de recette, enregistré seulement depuis l'éditeur.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/app/widgets/info_hint.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_dataset.dart';
import 'package:maestropesto/core/design/design_engine.dart';
import 'package:maestropesto/core/design/design_metrics.dart';
import 'package:maestropesto/core/models/allergens.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/core/models/process_models.dart';
import 'package:maestropesto/features/design/data/design_repository.dart';
import 'package:maestropesto/features/design/presentation/design_results_page.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:maestropesto/features/ingredients/presentation/ingredients_picker_page.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Ouvre l'assistant ; renvoie le brouillon de la proposition retenue
/// (non enregistré), ou null. [initial] : demande à ajuster ;
/// [recipeId] : identifiant du brouillon (recette existante à refaire).
Future<Recipe?> showDesignWizard(
  BuildContext context, {
  required AppDatabase db,
  DesignBrief? initial,
  String? recipeId,
}) => Navigator.of(context).push<Recipe>(
  MaterialPageRoute<Recipe>(
    fullscreenDialog: true,
    builder: (_) =>
        DesignWizardPage(db: db, initial: initial, recipeId: recipeId),
  ),
);

/// Relance la composition d'une demande enregistrée et affiche les
/// propositions ; renvoie le brouillon retenu, ou null.
Future<Recipe?> regenerateDesign(
  BuildContext context, {
  required AppDatabase db,
  required DesignBrief brief,
  String? recipeId,
}) async {
  final repository = DesignRepository(db);
  final variant = await Navigator.of(context).push<DesignVariant>(
    MaterialPageRoute<DesignVariant>(
      builder: (_) => DesignResultsPage(
        brief: brief,
        result: repository.design(brief),
        dataset: repository.dataset(),
      ),
    ),
  );
  if (variant == null) return null;
  return variant.toRecipe(
    id: recipeId ?? _newRecipeId(),
    brief: brief,
    servings: brief.servings,
  );
}

String _newRecipeId() => 'recipe-${DateTime.now().microsecondsSinceEpoch}';

class DesignWizardPage extends StatefulWidget {
  const DesignWizardPage({
    required this.db,
    this.initial,
    this.recipeId,
    super.key,
  });

  final AppDatabase db;
  final DesignBrief? initial;
  final String? recipeId;

  /// L'avertissement Pure Innovation ne s'affiche qu'une fois par
  /// session (phase11-cadrage D2).
  static bool innovationWarned = false;

  @override
  State<DesignWizardPage> createState() => _DesignWizardPageState();
}

/// Objectif en cours de saisie.
class _TargetDraft {
  _TargetDraft(this.metric)
    : kind = metric.defaultKind == TargetKind.choice
          ? TargetKind.choice
          : metric.defaultKind;

  final DesignMetric metric;
  bool enabled = false;
  TargetKind kind;
  final TextEditingController value = TextEditingController();
  final TextEditingController min = TextEditingController();
  final TextEditingController max = TextEditingController();
  String? choice;

  void dispose() {
    value.dispose();
    min.dispose();
    max.dispose();
  }
}

class _DesignWizardPageState extends State<DesignWizardPage> {
  late final DesignRepository _repository = DesignRepository(widget.db);
  late final Future<DesignDataset> _dataset = _repository.dataset();

  int _step = 0;
  String? _familyId;
  int _servings = 4;
  final List<String> _imposed = [];
  final List<String> _excluded = [];
  final Set<String> _allergens = {};
  final Map<String, _TargetDraft> _targets = {
    for (final m in DesignMetrics.all) m.id: _TargetDraft(m),
  };
  List<DesignAspect> _priorities = [...DesignBrief.defaultPriorities];
  Map<DesignAspect, double>? _customWeights;
  DesignMode _mode = DesignMode.coherent;
  String? _error;

  static const _steps = 4;

  /// Allergènes proposés (annexe II, sans doublons d'étiquette).
  static const _allergenTags = [
    'gluten',
    'crustaceans',
    'eggs',
    'fish',
    'peanuts',
    'soy',
    'milk',
    'nuts',
    'celery',
    'mustard',
    'sesame',
    'sulphites',
    'lupin',
    'molluscs',
  ];

  /// Valeurs proposées à l'activation d'un objectif.
  static const Map<String, double> _defaults = {
    'dry_matter': 30,
    'fat_phase': 10,
    'ph': 4.5,
    'aw': 0.9,
    'brix': 20,
    'harmony': 0.7,
    'documented_share': 50,
    'energy': 300,
    'proteins': 10,
    'salt': 1.5,
    'sugars': 15,
    'saturated_fats': 5,
    'fiber': 3,
  };

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    if (b == null) return;
    _familyId = b.familyId;
    _servings = b.servings;
    _imposed.addAll(b.imposedIds);
    _excluded.addAll(b.excludedIds);
    _allergens.addAll(b.excludedAllergens);
    _priorities = b.normalizedPriorities;
    _customWeights = b.customWeights;
    _mode = b.mode;
    // Une demande en Pure Innovation a déjà été confirmée.
    if (_mode == DesignMode.pureInnovation) {
      DesignWizardPage.innovationWarned = true;
    }
    b.targets.forEach((id, t) {
      final d = _targets[id];
      if (d == null) return;
      d.enabled = true;
      d.kind = t.kind;
      d.choice = t.choice;
      if (t.value != null) d.value.text = _fmt(t.value!);
      if (t.min != null) d.min.text = _fmt(t.min!);
      if (t.max != null) d.max.text = _fmt(t.max!);
    });
  }

  @override
  void dispose() {
    for (final d in _targets.values) {
      d.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) {
    final s = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(v.abs() < 1 ? 2 : 1);
    return s.replaceAll('.', ',');
  }

  static double? _parse(String raw) =>
      double.tryParse(raw.trim().replaceAll(' ', '').replaceAll(',', '.'));

  // -------------------------------------------------------------------
  // Demande.
  // -------------------------------------------------------------------

  DesignBrief _brief() {
    final targets = <String, DesignTarget>{};
    for (final d in _targets.values) {
      if (!d.enabled) continue;
      final t = switch (d.kind) {
        TargetKind.choice when d.choice != null => DesignTarget.choice(
          d.choice!,
        ),
        TargetKind.value when _parse(d.value.text) != null =>
          DesignTarget.value(_parse(d.value.text)!),
        TargetKind.min when _parse(d.min.text) != null => DesignTarget.atLeast(
          _parse(d.min.text)!,
        ),
        TargetKind.max when _parse(d.max.text) != null => DesignTarget.atMost(
          _parse(d.max.text)!,
        ),
        TargetKind.range
            when _parse(d.min.text) != null && _parse(d.max.text) != null =>
          DesignTarget.range(
            _parse(d.min.text)! < _parse(d.max.text)!
                ? _parse(d.min.text)!
                : _parse(d.max.text)!,
            _parse(d.min.text)! < _parse(d.max.text)!
                ? _parse(d.max.text)!
                : _parse(d.min.text)!,
          ),
        _ => null,
      };
      if (t != null) targets[d.metric.id] = t;
    }
    return DesignBrief(
      familyId: _familyId,
      servings: _servings,
      imposedIds: [..._imposed],
      excludedIds: [..._excluded],
      excludedAllergens: [..._allergens],
      mode: _mode,
      priorities: [..._priorities],
      customWeights: _customWeights,
      targets: targets,
    );
  }

  String? _validate(DesignBrief brief) {
    if (brief.mode == DesignMode.coherent && brief.familyId == null) {
      return context.strings.designNeedDishType;
    }
    if (brief.mode == DesignMode.pureInnovation &&
        brief.familyId == null &&
        brief.targets.isEmpty &&
        brief.requiredIds.isEmpty) {
      return context.strings.designNeedTarget;
    }
    return null;
  }

  Future<void> _compose() async {
    final brief = _brief();
    final error = _validate(brief);
    if (error != null) {
      setState(() {
        _error = error;
        if (brief.familyId == null && brief.mode == DesignMode.coherent) {
          _step = 0;
        }
      });
      return;
    }
    setState(() => _error = null);
    final variant = await Navigator.of(context).push<DesignVariant>(
      MaterialPageRoute<DesignVariant>(
        builder: (_) => DesignResultsPage(
          brief: brief,
          result: _repository.design(brief),
          dataset: _dataset,
        ),
      ),
    );
    if (variant == null || !mounted) return;
    Navigator.of(context).pop(
      variant.toRecipe(
        id: widget.recipeId ?? _newRecipeId(),
        brief: brief,
        servings: brief.servings,
      ),
    );
  }

  Future<void> _toggleInnovation(bool on) async {
    if (!on) {
      setState(() => _mode = DesignMode.coherent);
      return;
    }
    if (!DesignWizardPage.innovationWarned) {
      final strings = context.strings;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.science_outlined),
          title: Text(strings.designInnovationDialogTitle),
          content: Text(strings.designInnovationDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.designInnovationCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.designInnovationConfirm),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      DesignWizardPage.innovationWarned = true;
    }
    setState(() => _mode = DesignMode.pureInnovation);
  }

  Future<String?> _pickIngredient() async {
    final summaries = await IngredientsRepository(widget.db).allSummaries();
    if (!mounted) return null;
    final picked = await showIngredientsPicker(context, all: summaries);
    return picked?.ingredientId;
  }

  // -------------------------------------------------------------------
  // Construction.
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.designTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<DesignDataset>(
        future: _dataset,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.error_outline,
              text: '${snapshot.error}',
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return _Message(
              icon: Icons.hourglass_top,
              text: strings.designLoading,
              busy: true,
            );
          }
          if (data.catalog.dishFamilies.isEmpty) {
            return _Message(
              icon: Icons.cloud_download_outlined,
              text: strings.designDataMissing,
            );
          }
          return Column(
            children: [
              _StepHeader(step: _step, onTap: (i) => setState(() => _step = i)),
              if (_mode == DesignMode.pureInnovation) const InnovationBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: switch (_step) {
                        0 => _frame(data),
                        1 => _goals(data),
                        2 => _prioritiesStep(),
                        _ => _modeStep(data),
                      },
                    ),
                  ),
                ),
              ),
              _bottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomBar() {
    final strings = context.strings;
    final theme = Theme.of(context);
    final last = _step == _steps - 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: context.palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              Row(
                children: [
                  if (_step > 0)
                    TextButton.icon(
                      onPressed: () => setState(() => _step--),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(strings.designBack),
                    ),
                  const Spacer(),
                  if (!last)
                    FilledButton.icon(
                      onPressed: () => setState(() => _step++),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(strings.designNext),
                    )
                  else
                    Flexible(
                      child: FilledButton.icon(
                        key: const ValueKey('design-compose'),
                        onPressed: _compose,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          MediaQuery.sizeOf(context).width < 420
                              ? strings.designComposeShort
                              : strings.designCompose,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Étape 1 — cadre.
  Widget _frame(DesignDataset data) {
    final strings = context.strings;
    final families = data.catalog.dishFamilies;
    String name(String id) => data[id]?.label ?? id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: strings.designDishType,
          hint: strings.designDishTypeHelp,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in families)
                ChoiceChip(
                  label: Text(f.label),
                  selected: _familyId == f.id,
                  onSelected: (_) => setState(() {
                    _familyId = f.id;
                    _error = null;
                  }),
                ),
              ChoiceChip(
                label: Text(strings.designNoDishType),
                selected: _familyId == null,
                onSelected: (_) => setState(() => _familyId = null),
              ),
            ],
          ),
        ),
        _Section(
          title: strings.designServings,
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: '−',
                onPressed: _servings > 1
                    ? () => setState(() => _servings--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_servings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.outlined(
                tooltip: '+',
                onPressed: _servings < 48
                    ? () => setState(() => _servings++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        _Section(
          title: strings.designImposed,
          hint: strings.designImposedHelp,
          child: _IngredientChips(
            ids: _imposed,
            nameOf: name,
            onAdd: () async {
              final id = await _pickIngredient();
              if (id == null || _imposed.contains(id)) return;
              setState(() {
                _imposed.add(id);
                _excluded.remove(id);
              });
            },
            onRemove: (id) => setState(() => _imposed.remove(id)),
          ),
        ),
        _Section(
          title: strings.designExcluded,
          child: _IngredientChips(
            ids: _excluded,
            nameOf: name,
            onAdd: () async {
              final id = await _pickIngredient();
              if (id == null || _excluded.contains(id)) return;
              setState(() {
                _excluded.add(id);
                _imposed.remove(id);
              });
            },
            onRemove: (id) => setState(() => _excluded.remove(id)),
          ),
        ),
        _Section(
          title: strings.designExcludedAllergens,
          hint: strings.allergensHint,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _allergenTags)
                FilterChip(
                  label: Text(allergenLabelFr(tag)),
                  selected: _allergens.contains(tag),
                  onSelected: (on) => setState(() {
                    on ? _allergens.add(tag) : _allergens.remove(tag);
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Étape 2 — objectifs.
  Widget _goals(DesignDataset data) {
    final strings = context.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(strings.designTargetsIntro),
        ),
        for (final aspect in DesignAspect.values)
          _Section(
            title: aspect.labelFr,
            icon: _aspectIcon(aspect),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final m in DesignMetrics.ofAspect(aspect))
                  _metricEditor(m, data),
              ],
            ),
          ),
      ],
    );
  }

  Widget _metricEditor(DesignMetric m, DesignDataset data) {
    final d = _targets[m.id]!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                key: ValueKey('target-${m.id}'),
                value: d.enabled,
                onChanged: (on) =>
                    setState(() => _enable(d, on ?? false, data)),
              ),
              Expanded(
                child: LabelWithHint(
                  m.labelFr,
                  '${m.help}\n\n${m.coverageRule}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          if (d.enabled)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 6),
              child: m.isChoice ? _choiceEditor(d, data) : _numberEditor(d),
            ),
        ],
      ),
    );
  }

  void _enable(_TargetDraft d, bool on, DesignDataset data) {
    d.enabled = on;
    if (!on) return;
    final m = d.metric;
    final base = _defaults[m.id];
    if (base != null) {
      if (d.value.text.isEmpty) d.value.text = _fmt(base);
      if (d.min.text.isEmpty) d.min.text = _fmt(base);
      if (d.max.text.isEmpty) d.max.text = _fmt(base);
    }
    if (m.isChoice && d.choice == null) {
      d.choice = switch (m.id) {
        'cooking_method' => _methods(data).first.id,
        'nutriscore' => 'B',
        'dominant_family' => DesignMetrics.aromaFamilies.first,
        _ => null,
      };
    }
  }

  Widget _numberEditor(_TargetDraft d) {
    final strings = context.strings;
    final m = d.metric;
    Widget field(TextEditingController c, String label) => SizedBox(
      width: 120,
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          suffixText: m.unit.isEmpty ? null : m.unit,
        ),
      ),
    );
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<TargetKind>(
          value: d.kind,
          onChanged: (k) => setState(() => d.kind = k ?? d.kind),
          items: [
            for (final (k, label) in [
              (TargetKind.value, strings.designKindValue),
              (TargetKind.min, strings.designKindMin),
              (TargetKind.max, strings.designKindMax),
              (TargetKind.range, strings.designKindRange),
            ])
              DropdownMenuItem(value: k, child: Text(label)),
          ],
        ),
        if (d.kind == TargetKind.value) ...[
          field(d.value, 'valeur'),
          Text(
            strings.designTolerance,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (d.kind == TargetKind.min || d.kind == TargetKind.range)
          field(d.min, 'min'),
        if (d.kind == TargetKind.max || d.kind == TargetKind.range)
          field(d.max, 'max'),
      ],
    );
  }

  List<CookingMethod> _methods(DesignDataset data) {
    final family = data.catalog.family(_familyId);
    final methods = _mode == DesignMode.coherent && family != null
        ? family.methods
        : {for (final s in data.catalog.generic) s.process.method};
    return [
      for (final m in CookingMethod.values)
        if (methods.contains(m)) m,
    ];
  }

  Widget _choiceEditor(_TargetDraft d, DesignDataset data) {
    final strings = context.strings;
    switch (d.metric.id) {
      case 'cooking_method':
        final methods = _methods(data);
        final current = methods.any((m) => m.id == d.choice)
            ? d.choice
            : methods.first.id;
        d.choice = current;
        return Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton<String>(
            value: current,
            onChanged: (v) => setState(() => d.choice = v),
            items: [
              for (final m in methods)
                DropdownMenuItem(value: m.id, child: Text(m.labelFr)),
            ],
          ),
        );
      case 'nutriscore':
        return Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              for (final g in DesignMetrics.nutriGrades)
                ButtonSegment(value: g, label: Text(g)),
            ],
            selected: {d.choice ?? 'B'},
            onSelectionChanged: (s) => setState(() => d.choice = s.first),
          ),
        );
      case 'dominant_family':
        return Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton<String>(
            value: d.choice ?? DesignMetrics.aromaFamilies.first,
            onChanged: (v) => setState(() => d.choice = v),
            items: [
              for (final f in DesignMetrics.aromaFamilies)
                DropdownMenuItem(
                  value: f,
                  child: Text(SensoryOntology.label(f)),
                ),
            ],
          ),
        );
      case 'pivot':
        return Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (d.choice != null)
              InputChip(
                label: Text(data[d.choice!]?.label ?? d.choice!),
                onDeleted: () => setState(() => d.choice = null),
              ),
            OutlinedButton.icon(
              onPressed: () async {
                final id = await _pickIngredient();
                if (id != null) setState(() => d.choice = id);
              },
              icon: const Icon(Icons.search),
              label: Text(strings.designChooseIngredient),
            ),
          ],
        );
    }
    return const SizedBox.shrink();
  }

  // Étape 3 — priorités.
  Widget _prioritiesStep() {
    final strings = context.strings;
    final theme = Theme.of(context);
    final weights = _brief().weights;
    int count(DesignAspect a) =>
        _targets.values.where((d) => d.enabled && d.metric.aspect == a).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(strings.designPrioritiesIntro),
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) => setState(() {
            final a = _priorities.removeAt(from);
            _priorities.insert(to, a);
            _customWeights = null;
          }),
          children: [
            for (final (i, a) in _priorities.indexed)
              Card(
                key: ValueKey(a),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(a.labelFr),
                  subtitle: Text(
                    '${strings.designWeightPercent(((weights[a] ?? 0) * 100).round())}'
                    ' · ${strings.designSummaryTargets(count(a))}',
                  ),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: Text(strings.designAdvancedWeights),
          initiallyExpanded: _customWeights != null,
          children: [
            for (final a in DesignAspect.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(a.labelFr, style: theme.textTheme.bodySmall),
                    ),
                    Expanded(
                      child: Slider(
                        value: (_customWeights ?? weights)[a]!.clamp(0.0, 1.0),
                        divisions: 20,
                        label: strings.designWeightPercent(
                          ((weights[a] ?? 0) * 100).round(),
                        ),
                        onChanged: (v) => setState(() {
                          _customWeights = {
                            ...(_customWeights ?? weights),
                            a: v,
                          };
                        }),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        strings.designWeightPercent(
                          ((weights[a] ?? 0) * 100).round(),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            if (_customWeights != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _customWeights = null),
                  child: Text(strings.designResetWeights),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Étape 4 — mode.
  Widget _modeStep(DesignDataset data) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final brief = _brief();
    final family = data.catalog.family(brief.familyId);
    final innovation = _mode == DesignMode.pureInnovation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: SwitchListTile(
            key: const ValueKey('design-innovation'),
            value: innovation,
            onChanged: _toggleInnovation,
            secondary: Icon(
              innovation ? Icons.science_outlined : Icons.restaurant_outlined,
            ),
            title: Text(
              innovation
                  ? strings.designModeInnovation
                  : strings.designModeCoherent,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              innovation
                  ? strings.designModeInnovationHelp
                  : strings.designModeCoherentHelp,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: strings.designSummary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.designDishType} : '
                '${family?.label ?? strings.designNoDishType}',
              ),
              Text('${strings.designServings} : ${brief.servings}'),
              Text(strings.designSummaryTargets(brief.targets.length)),
              if (brief.requiredIds.isNotEmpty)
                Text(
                  '${strings.designImposed} : '
                  '${brief.requiredIds.map((id) => data[id]?.label ?? id).join(', ')}',
                ),
              if (brief.excludedAllergens.isNotEmpty)
                Text(
                  '${strings.designExcludedAllergens} : '
                  '${brief.excludedAllergens.map(allergenLabelFr).join(', ')}',
                ),
              const SizedBox(height: 6),
              Text(
                [
                  for (final a in brief.normalizedPriorities)
                    '${a.labelFr} ${strings.designWeightPercent(((brief.weights[a] ?? 0) * 100).round())}',
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static IconData _aspectIcon(DesignAspect a) => switch (a) {
    DesignAspect.process => Icons.science_outlined,
    DesignAspect.flavor => Icons.spa_outlined,
    DesignAspect.nutrition => Icons.monitor_heart_outlined,
  };
}

/// Bandeau discret du mode Pure Innovation (phase11-cadrage D2).
class InnovationBanner extends StatelessWidget {
  const InnovationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.warnSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.science_outlined, size: 18, color: palette.warn),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.strings.designInnovationBanner,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.onTap});

  final int step;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final labels = [
      strings.designStepFrame,
      strings.designStepTargets,
      strings.designStepPriorities,
      strings.designStepMode,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: (step + 1) / labels.length),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    avatar: CircleAvatar(
                      radius: 10,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    label: Text(labels[i]),
                    selected: i == step,
                    onSelected: (_) => onTap(i),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            strings.designStepOf(step + 1, labels.length),
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.hint,
    this.icon,
  });

  final String title;
  final String? hint;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: hint == null
                      ? Text(title, style: style)
                      : LabelWithHint(title, hint!, style: style),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _IngredientChips extends StatelessWidget {
  const _IngredientChips({
    required this.ids,
    required this.nameOf,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> ids;
  final String Function(String id) nameOf;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final id in ids)
        InputChip(label: Text(nameOf(id)), onDeleted: () => onRemove(id)),
      OutlinedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(context.strings.designAddIngredient),
      ),
    ],
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.busy = false});

  final IconData icon;
  final String text;
  final bool busy;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            const CircularProgressIndicator()
          else
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
