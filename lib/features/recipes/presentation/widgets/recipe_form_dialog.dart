import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_photo.dart';
import 'package:maestropesto/features/ingredients/presentation/ingredients_picker_page.dart';

Future<Recipe?> showRecipeFormDialog({
  required BuildContext context,
  required Recipe recipe,
  required String title,
}) {
  return showDialog<Recipe>(
    context: context,
    builder: (context) => RecipeFormDialog(recipe: recipe, title: title),
  );
}

class RecipeFormDialog extends StatefulWidget {
  const RecipeFormDialog({
    required this.recipe,
    required this.title,
    super.key,
  });

  final Recipe recipe;
  final String title;

  @override
  State<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends State<RecipeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _servingsController;
  late final TextEditingController _prepController;
  late final TextEditingController _cookController;
  late final TextEditingController _energyController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _fiberController;
  late final TextEditingController _saltController;

  late List<_IngredientDraft> _ingredients;
  late List<_ImageDraft> _images;
  late List<TextEditingController> _stepControllers;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe.title);
    _descriptionController = TextEditingController(text: recipe.description);
    _tagsController = TextEditingController(text: recipe.tags.join(', '));
    _servingsController = TextEditingController(
      text: recipe.servings.toString(),
    );
    _prepController = TextEditingController(
      text: recipe.prepMinutes.toString(),
    );
    _cookController = TextEditingController(
      text: recipe.cookMinutes.toString(),
    );
    _energyController = TextEditingController(
      text: recipe.nutrition.energyKcal.toStringAsFixed(0),
    );
    _proteinsController = TextEditingController(
      text: recipe.nutrition.proteins.toString(),
    );
    _carbsController = TextEditingController(
      text: recipe.nutrition.carbs.toString(),
    );
    _fatsController = TextEditingController(
      text: recipe.nutrition.fats.toString(),
    );
    _fiberController = TextEditingController(
      text: recipe.nutrition.fiber.toString(),
    );
    _saltController = TextEditingController(
      text: recipe.nutrition.salt.toString(),
    );
    _ingredients = recipe.ingredients
        .map(_IngredientDraft.fromIngredient)
        .toList();
    _images = recipe.images.map(_ImageDraft.fromImage).toList();
    _stepControllers = recipe.steps
        .map((step) => TextEditingController(text: step))
        .toList();
    if (_ingredients.isEmpty) {
      _ingredients.add(_IngredientDraft.empty());
    }
    if (_stepControllers.isEmpty) {
      _stepControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _servingsController.dispose();
    _prepController.dispose();
    _cookController.dispose();
    _energyController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _fiberController.dispose();
    _saltController.dispose();
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    for (final image in _images) {
      image.dispose();
    }
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ingredients = _ingredients
        .map((ingredient) => ingredient.toIngredient())
        .where((ingredient) => ingredient.label.trim().isNotEmpty)
        .toList();
    final steps = _stepControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    final images = _images
        .map((image) => image.toImage())
        .where((image) => image.path.trim().isNotEmpty)
        .toList();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    Navigator.of(context).pop(
      widget.recipe.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        servings: _intValue(_servingsController, fallback: 1),
        prepMinutes: _intValue(_prepController),
        cookMinutes: _intValue(_cookController),
        ingredients: ingredients,
        steps: steps,
        images: images,
        nutrition: NutritionSummary(
          energyKcal: _doubleValue(_energyController),
          proteins: _doubleValue(_proteinsController),
          carbs: _doubleValue(_carbsController),
          fats: _doubleValue(_fatsController),
          fiber: _doubleValue(_fiberController),
          salt: _doubleValue(_saltController),
        ),
      ),
    );
  }

  int _intValue(TextEditingController controller, {int fallback = 0}) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }

  double _doubleValue(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
  }

  Future<void> _pickPhoto() async {
    const imageTypeGroup = XTypeGroup(
      label: 'Images',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/heic'],
    );
    final file = await openFile(acceptedTypeGroups: const [imageTypeGroup]);
    if (file == null) {
      return;
    }

    setState(() {
      _images.add(_ImageDraft.fromPickedPhoto(file));
    });
  }

  /// Phase 09 Lot F — ouvre le picker ingrédients pour le draft à l'index [index].
  ///
  /// Si l'utilisateur sélectionne un ingrédient Phase 1, on met à jour :
  /// - `draft.label` → canonical name FR
  /// - `draft.ingredientId` → identifiant Phase 1 (FK)
  Future<void> _pickIngredient(int index) async {
    if (index < 0 || index >= _ingredients.length) return;
    final draft = _ingredients[index];

    // Pour Lot F v1, on lit directement via IngredientsRepository
    // si le contexte parent a injecté un picker. Sinon on tombe sur
    // un fallback qui demande juste un label.
    //
    // Le câblage complet avec AppDatabase sera fait dans l'integration
    // RecipeBookPanel (Lot suivant) — ici on garde le slot fonctionnel
    // avec une liste vide par défaut.
    final picked = await showIngredientsPickerFallback(
      context,
      currentLabel: draft.labelController.text,
    );
    if (picked == null) return;

    setState(() {
      draft.labelController.text = picked.label;
      draft.ingredientId = picked.ingredientId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 780),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: context.strings.close,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _BasicsSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      tagsController: _tagsController,
                      servingsController: _servingsController,
                      prepController: _prepController,
                      cookController: _cookController,
                    ),
                    const SizedBox(height: 22),
                    _IngredientsSection(
                      ingredients: _ingredients,
                      onPickIngredient: _pickIngredient,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    _ImagesSection(
                      images: _images,
                      onAddImage: _pickPhoto,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    _StepsSection(
                      controllers: _stepControllers,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    _NutritionSection(
                      energyController: _energyController,
                      proteinsController: _proteinsController,
                      carbsController: _carbsController,
                      fatsController: _fatsController,
                      fiberController: _fiberController,
                      saltController: _saltController,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.strings.cancel),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(context.strings.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicsSection extends StatelessWidget {
  const _BasicsSection({
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
    required this.servingsController,
    required this.prepController,
    required this.cookController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final TextEditingController servingsController;
  final TextEditingController prepController;
  final TextEditingController cookController;

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: context.strings.recipeFormSection,
      icon: Icons.description_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: context.strings.titleField,
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? context.strings.titleRequired
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.strings.descriptionField,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: tagsController,
            decoration: InputDecoration(labelText: context.strings.tagsField),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final children = [
                _NumberField(
                  controller: servingsController,
                  label: context.strings.servingsField,
                  min: 1,
                ),
                _NumberField(
                  controller: prepController,
                  label: context.strings.prepField,
                ),
                _NumberField(
                  controller: cookController,
                  label: context.strings.cookField,
                ),
              ];
              return compact
                  ? Column(
                      children: _withSpacing(children, axis: Axis.vertical),
                    )
                  : Row(children: _withExpandedSpacing(children));
            },
          ),
        ],
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({
    required this.ingredients,
    required this.onChanged,
    required this.onPickIngredient,
  });

  final List<_IngredientDraft> ingredients;
  final VoidCallback onChanged;
  final Future<void> Function(int index) onPickIngredient;

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: context.strings.ingredients,
      icon: Icons.format_list_bulleted,
      trailing: IconButton.filledTonal(
        onPressed: () {
          ingredients.add(_IngredientDraft.empty());
          onChanged();
        },
        icon: const Icon(Icons.add),
        tooltip: context.strings.addIngredient,
      ),
      child: Column(
        children: [
          for (var index = 0; index < ingredients.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == ingredients.length - 1 ? 0 : 10,
              ),
              child: _IngredientEditorRow(
                draft: ingredients[index],
                onPickIngredient: (ctx) => onPickIngredient(index),
                onRemove: ingredients.length == 1
                    ? null
                    : () {
                        ingredients.removeAt(index).dispose();
                        onChanged();
                      },
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagesSection extends StatelessWidget {
  const _ImagesSection({
    required this.images,
    required this.onAddImage,
    required this.onChanged,
  });

  final List<_ImageDraft> images;
  final Future<void> Function() onAddImage;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: context.strings.images,
      icon: Icons.photo_library_outlined,
      trailing: IconButton.filledTonal(
        onPressed: onAddImage,
        icon: const Icon(Icons.add),
        tooltip: context.strings.addImage,
      ),
      child: images.isEmpty
          ? Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(context.strings.choosePhoto),
              ),
            )
          : Column(
              children: [
                for (var index = 0; index < images.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == images.length - 1 ? 0 : 10,
                    ),
                    child: _ImageEditorRow(
                      draft: images[index],
                      onRemove: () {
                        images.removeAt(index).dispose();
                        onChanged();
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.controllers, required this.onChanged});

  final List<TextEditingController> controllers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: context.strings.preparation,
      icon: Icons.checklist,
      trailing: IconButton.filledTonal(
        onPressed: () {
          controllers.add(TextEditingController());
          onChanged();
        },
        icon: const Icon(Icons.add),
        tooltip: context.strings.addStep,
      ),
      child: Column(
        children: [
          for (var index = 0; index < controllers.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == controllers.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CircleAvatar(
                      radius: 14,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: controllers[index],
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.strings.stepField,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controllers.length == 1
                        ? null
                        : () {
                            controllers.removeAt(index).dispose();
                            onChanged();
                          },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: context.strings.deleteAction,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({
    required this.energyController,
    required this.proteinsController,
    required this.carbsController,
    required this.fatsController,
    required this.fiberController,
    required this.saltController,
  });

  final TextEditingController energyController;
  final TextEditingController proteinsController;
  final TextEditingController carbsController;
  final TextEditingController fatsController;
  final TextEditingController fiberController;
  final TextEditingController saltController;

  @override
  Widget build(BuildContext context) {
    final fields = [
      _NumberField(
        controller: energyController,
        label: context.strings.energyKcalField,
        decimal: true,
      ),
      _NumberField(
        controller: proteinsController,
        label: context.strings.proteinsGField,
        decimal: true,
      ),
      _NumberField(
        controller: carbsController,
        label: context.strings.carbsGField,
        decimal: true,
      ),
      _NumberField(
        controller: fatsController,
        label: context.strings.fatsGField,
        decimal: true,
      ),
      _NumberField(
        controller: fiberController,
        label: context.strings.fiberGField,
        decimal: true,
      ),
      _NumberField(
        controller: saltController,
        label: context.strings.saltGField,
        decimal: true,
      ),
    ];

    return _FormSection(
      title: context.strings.nutritionPerServing,
      icon: Icons.monitor_heart_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          return compact
              ? Column(children: _withSpacing(fields, axis: Axis.vertical))
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final field in fields)
                      SizedBox(
                        width: (constraints.maxWidth - 20) / 3,
                        child: field,
                      ),
                  ],
                );
        },
      ),
    );
  }
}

class _IngredientEditorRow extends StatelessWidget {
  const _IngredientEditorRow({
    required this.draft,
    required this.onRemove,
    required this.onPickIngredient,
  });

  final _IngredientDraft draft;
  final VoidCallback? onRemove;

  /// Callback Lot F — ouvre le picker ingrédients (cf. §6.3 du cahier Phase 09).
  final Future<void> Function(BuildContext context) onPickIngredient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;

        Future<void> openPicker() async {
          await onPickIngredient(context);
        }

        final fields = [
          TextFormField(
            controller: draft.quantityController,
            decoration: InputDecoration(
              labelText: context.strings.quantityField,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: draft.labelController,
                  decoration: InputDecoration(
                    labelText: context.strings.ingredientField,
                    // Phase 09 Lot F : affiche l'ID Phase 1 sélectionné
                    // si lié à la DB.
                    helperText: draft.ingredientId != null
                        ? 'Phase 1 : ${draft.ingredientId}'
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => openPicker(),
                icon: const Icon(Icons.search),
                tooltip: 'Choisir depuis le référentiel Phase 1',
              ),
            ],
          ),
          DropdownButtonFormField<IngredientSource>(
            initialValue: draft.source,
            decoration: InputDecoration(labelText: context.strings.sourceField),
            items: [
              DropdownMenuItem(
                value: IngredientSource.ciqual,
                child: Text(context.strings.ciqual),
              ),
              DropdownMenuItem(
                value: IngredientSource.recipe,
                child: Text(context.strings.sourceRecipe),
              ),
              DropdownMenuItem(
                value: IngredientSource.free,
                child: Text(context.strings.sourceFree),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                draft.source = value;
              }
            },
          ),
        ];

        if (compact) {
          return Column(
            children: [
              ..._withSpacing(fields, axis: Axis.vertical),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.strings.deleteAction,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: fields[0]),
            const SizedBox(width: 10),
            Expanded(child: fields[1]),
            const SizedBox(width: 10),
            SizedBox(width: 150, child: fields[2]),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: context.strings.deleteAction,
            ),
          ],
        );
      },
    );
  }
}

class _ImageEditorRow extends StatelessWidget {
  const _ImageEditorRow({required this.draft, required this.onRemove});

  final _ImageDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final fields = [
          TextFormField(
            controller: draft.labelController,
            decoration: InputDecoration(
              labelText: context.strings.imageLabelField,
            ),
          ),
          TextFormField(
            controller: draft.pathController,
            decoration: InputDecoration(
              labelText: context.strings.imagePathField,
              prefixIcon: const Icon(Icons.folder_outlined),
            ),
          ),
        ];
        final preview = _PhotoPreview(controller: draft.pathController);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              preview,
              const SizedBox(height: 10),
              ..._withSpacing(fields, axis: Axis.vertical),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.strings.deleteAction,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 86, height: 86, child: preview),
            const SizedBox(width: 10),
            Expanded(child: fields[0]),
            const SizedBox(width: 10),
            Expanded(child: fields[1]),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: context.strings.deleteAction,
            ),
          ],
        );
      },
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final path = controller.text.trim();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: path.isEmpty
              ? const ColoredBox(
                  color: Color(0xFFE9ECE4),
                  child: Center(child: Icon(Icons.photo_outlined)),
                )
              : buildRecipePhoto(path, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.decimal = false,
    this.min = 0,
  });

  final TextEditingController controller;
  final String label;
  final bool decimal;
  final int min;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final raw = value?.trim().replaceAll(',', '.') ?? '';
        final parsed = decimal ? double.tryParse(raw) : int.tryParse(raw);
        if (parsed == null) {
          return context.strings.numberRequired;
        }
        if (parsed < min) {
          return context.strings.minimumValue(min);
        }
        return null;
      },
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _IngredientDraft {
  _IngredientDraft({
    required this.labelController,
    required this.quantityController,
    required this.source,
    this.ingredientId,
  });

  factory _IngredientDraft.fromIngredient(RecipeIngredient ingredient) {
    return _IngredientDraft(
      labelController: TextEditingController(text: ingredient.label),
      quantityController: TextEditingController(text: ingredient.quantity),
      source: ingredient.source,
      ingredientId: ingredient.ingredientId,
    );
  }

  factory _IngredientDraft.empty() {
    return _IngredientDraft(
      labelController: TextEditingController(),
      quantityController: TextEditingController(),
      source: IngredientSource.free,
    );
  }

  final TextEditingController labelController;
  final TextEditingController quantityController;
  IngredientSource source;

  /// Phase 09 Lot F : identifiant Phase 1 si lié à la DB.
  String? ingredientId;

  RecipeIngredient toIngredient() {
    return RecipeIngredient(
      label: labelController.text.trim(),
      quantity: quantityController.text.trim(),
      source: source,
      ingredientId: ingredientId,
    );
  }

  void dispose() {
    labelController.dispose();
    quantityController.dispose();
  }
}

class _ImageDraft {
  _ImageDraft({required this.pathController, required this.labelController});

  factory _ImageDraft.fromImage(RecipeImage image) {
    return _ImageDraft(
      pathController: TextEditingController(text: image.path),
      labelController: TextEditingController(text: image.label),
    );
  }

  factory _ImageDraft.fromPickedPhoto(XFile file) {
    return _ImageDraft(
      pathController: TextEditingController(text: file.path),
      labelController: TextEditingController(
        text: _photoLabelFromName(file.name),
      ),
    );
  }

  final TextEditingController pathController;
  final TextEditingController labelController;

  RecipeImage toImage() {
    return RecipeImage(
      path: pathController.text.trim(),
      label: labelController.text.trim(),
    );
  }

  void dispose() {
    pathController.dispose();
    labelController.dispose();
  }
}

String _photoLabelFromName(String name) {
  final withoutExtension = name.replaceFirst(RegExp(r'\.[^.]+$'), '');
  return withoutExtension.replaceAll(RegExp(r'[_-]+'), ' ').trim();
}

List<Widget> _withSpacing(List<Widget> children, {required Axis axis}) {
  final spaced = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    spaced.add(children[index]);
    if (index != children.length - 1) {
      spaced.add(
        SizedBox(
          width: axis == Axis.horizontal ? 10 : 0,
          height: axis == Axis.vertical ? 10 : 0,
        ),
      );
    }
  }
  return spaced;
}

List<Widget> _withExpandedSpacing(List<Widget> children) {
  final spaced = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    spaced.add(Expanded(child: children[index]));
    if (index != children.length - 1) {
      spaced.add(const SizedBox(width: 10));
    }
  }
  return spaced;
}
