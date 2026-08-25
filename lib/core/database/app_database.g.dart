// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _prepTimeMinMeta = const VerificationMeta(
    'prepTimeMin',
  );
  @override
  late final GeneratedColumn<int> prepTimeMin = GeneratedColumn<int>(
    'prep_time_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cookTimeMinMeta = const VerificationMeta(
    'cookTimeMin',
  );
  @override
  late final GeneratedColumn<int> cookTimeMin = GeneratedColumn<int>(
    'cook_time_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    servings,
    prepTimeMin,
    cookTimeMin,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('prep_time_min')) {
      context.handle(
        _prepTimeMinMeta,
        prepTimeMin.isAcceptableOrUnknown(
          data['prep_time_min']!,
          _prepTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('cook_time_min')) {
      context.handle(
        _cookTimeMinMeta,
        cookTimeMin.isAcceptableOrUnknown(
          data['cook_time_min']!,
          _cookTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      prepTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time_min'],
      )!,
      cookTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cook_time_min'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String title;
  final String description;
  final int servings;
  final int prepTimeMin;
  final int cookTimeMin;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.servings,
    required this.prepTimeMin,
    required this.cookTimeMin,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['servings'] = Variable<int>(servings);
    map['prep_time_min'] = Variable<int>(prepTimeMin);
    map['cook_time_min'] = Variable<int>(cookTimeMin);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      servings: Value(servings),
      prepTimeMin: Value(prepTimeMin),
      cookTimeMin: Value(cookTimeMin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      servings: serializer.fromJson<int>(json['servings']),
      prepTimeMin: serializer.fromJson<int>(json['prepTimeMin']),
      cookTimeMin: serializer.fromJson<int>(json['cookTimeMin']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'servings': serializer.toJson<int>(servings),
      'prepTimeMin': serializer.toJson<int>(prepTimeMin),
      'cookTimeMin': serializer.toJson<int>(cookTimeMin),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    int? servings,
    int? prepTimeMin,
    int? cookTimeMin,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
  }) => Recipe(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    servings: servings ?? this.servings,
    prepTimeMin: prepTimeMin ?? this.prepTimeMin,
    cookTimeMin: cookTimeMin ?? this.cookTimeMin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      servings: data.servings.present ? data.servings.value : this.servings,
      prepTimeMin: data.prepTimeMin.present
          ? data.prepTimeMin.value
          : this.prepTimeMin,
      cookTimeMin: data.cookTimeMin.present
          ? data.cookTimeMin.value
          : this.cookTimeMin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('servings: $servings, ')
          ..write('prepTimeMin: $prepTimeMin, ')
          ..write('cookTimeMin: $cookTimeMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    servings,
    prepTimeMin,
    cookTimeMin,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.servings == this.servings &&
          other.prepTimeMin == this.prepTimeMin &&
          other.cookTimeMin == this.cookTimeMin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> servings;
  final Value<int> prepTimeMin;
  final Value<int> cookTimeMin;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.servings = const Value.absent(),
    this.prepTimeMin = const Value.absent(),
    this.cookTimeMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.servings = const Value.absent(),
    this.prepTimeMin = const Value.absent(),
    this.cookTimeMin = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? servings,
    Expression<int>? prepTimeMin,
    Expression<int>? cookTimeMin,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (servings != null) 'servings': servings,
      if (prepTimeMin != null) 'prep_time_min': prepTimeMin,
      if (cookTimeMin != null) 'cook_time_min': cookTimeMin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? servings,
    Value<int>? prepTimeMin,
    Value<int>? cookTimeMin,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      prepTimeMin: prepTimeMin ?? this.prepTimeMin,
      cookTimeMin: cookTimeMin ?? this.cookTimeMin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (prepTimeMin.present) {
      map['prep_time_min'] = Variable<int>(prepTimeMin.value);
    }
    if (cookTimeMin.present) {
      map['cook_time_min'] = Variable<int>(cookTimeMin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('servings: $servings, ')
          ..write('prepTimeMin: $prepTimeMin, ')
          ..write('cookTimeMin: $cookTimeMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeImagesTable extends RecipeImages
    with TableInfo<$RecipeImagesTable, RecipeImageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, position, path, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeImageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeImageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeImageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $RecipeImagesTable createAlias(String alias) {
    return $RecipeImagesTable(attachedDatabase, alias);
  }
}

class RecipeImageRow extends DataClass implements Insertable<RecipeImageRow> {
  final String id;
  final String recipeId;
  final int position;
  final String path;
  final String? label;
  const RecipeImageRow({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.path,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  RecipeImagesCompanion toCompanion(bool nullToAbsent) {
    return RecipeImagesCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      path: Value(path),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory RecipeImageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeImageRow(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      path: serializer.fromJson<String>(json['path']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'path': serializer.toJson<String>(path),
      'label': serializer.toJson<String?>(label),
    };
  }

  RecipeImageRow copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? path,
    Value<String?> label = const Value.absent(),
  }) => RecipeImageRow(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    path: path ?? this.path,
    label: label.present ? label.value : this.label,
  );
  RecipeImageRow copyWithCompanion(RecipeImagesCompanion data) {
    return RecipeImageRow(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      path: data.path.present ? data.path.value : this.path,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeImageRow(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('path: $path, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, position, path, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeImageRow &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.path == this.path &&
          other.label == this.label);
}

class RecipeImagesCompanion extends UpdateCompanion<RecipeImageRow> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> path;
  final Value<String?> label;
  final Value<int> rowid;
  const RecipeImagesCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.path = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeImagesCompanion.insert({
    required String id,
    required String recipeId,
    required int position,
    required String path,
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       position = Value(position),
       path = Value(path);
  static Insertable<RecipeImageRow> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? path,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (path != null) 'path': path,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? path,
    Value<String?>? label,
    Value<int>? rowid,
  }) {
    return RecipeImagesCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      path: path ?? this.path,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeImagesCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('path: $path, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeStepsTable extends RecipeSteps
    with TableInfo<$RecipeStepsTable, RecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, position, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $RecipeStepsTable createAlias(String alias) {
    return $RecipeStepsTable(attachedDatabase, alias);
  }
}

class RecipeStep extends DataClass implements Insertable<RecipeStep> {
  final String id;
  final String recipeId;
  final int position;
  final String body;
  const RecipeStep({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['body'] = Variable<String>(body);
    return map;
  }

  RecipeStepsCompanion toCompanion(bool nullToAbsent) {
    return RecipeStepsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      body: Value(body),
    );
  }

  factory RecipeStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeStep(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'body': serializer.toJson<String>(body),
    };
  }

  RecipeStep copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? body,
  }) => RecipeStep(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    body: body ?? this.body,
  );
  RecipeStep copyWithCompanion(RecipeStepsCompanion data) {
    return RecipeStep(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStep(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, position, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeStep &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.body == this.body);
}

class RecipeStepsCompanion extends UpdateCompanion<RecipeStep> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> body;
  final Value<int> rowid;
  const RecipeStepsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeStepsCompanion.insert({
    required String id,
    required String recipeId,
    required int position,
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       position = Value(position),
       body = Value(body);
  static Insertable<RecipeStep> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return RecipeStepsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStepsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CiqualFoodsTable extends CiqualFoods
    with TableInfo<$CiqualFoodsTable, CiqualFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CiqualFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupCodeMeta = const VerificationMeta(
    'groupCode',
  );
  @override
  late final GeneratedColumn<String> groupCode = GeneratedColumn<String>(
    'group_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [code, name, groupCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ciqual_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CiqualFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_code')) {
      context.handle(
        _groupCodeMeta,
        groupCode.isAcceptableOrUnknown(data['group_code']!, _groupCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CiqualFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CiqualFood(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_code'],
      ),
    );
  }

  @override
  $CiqualFoodsTable createAlias(String alias) {
    return $CiqualFoodsTable(attachedDatabase, alias);
  }
}

class CiqualFood extends DataClass implements Insertable<CiqualFood> {
  final String code;
  final String name;
  final String? groupCode;
  const CiqualFood({required this.code, required this.name, this.groupCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || groupCode != null) {
      map['group_code'] = Variable<String>(groupCode);
    }
    return map;
  }

  CiqualFoodsCompanion toCompanion(bool nullToAbsent) {
    return CiqualFoodsCompanion(
      code: Value(code),
      name: Value(name),
      groupCode: groupCode == null && nullToAbsent
          ? const Value.absent()
          : Value(groupCode),
    );
  }

  factory CiqualFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CiqualFood(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      groupCode: serializer.fromJson<String?>(json['groupCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'groupCode': serializer.toJson<String?>(groupCode),
    };
  }

  CiqualFood copyWith({
    String? code,
    String? name,
    Value<String?> groupCode = const Value.absent(),
  }) => CiqualFood(
    code: code ?? this.code,
    name: name ?? this.name,
    groupCode: groupCode.present ? groupCode.value : this.groupCode,
  );
  CiqualFood copyWithCompanion(CiqualFoodsCompanion data) {
    return CiqualFood(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      groupCode: data.groupCode.present ? data.groupCode.value : this.groupCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CiqualFood(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('groupCode: $groupCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, groupCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CiqualFood &&
          other.code == this.code &&
          other.name == this.name &&
          other.groupCode == this.groupCode);
}

class CiqualFoodsCompanion extends UpdateCompanion<CiqualFood> {
  final Value<String> code;
  final Value<String> name;
  final Value<String?> groupCode;
  final Value<int> rowid;
  const CiqualFoodsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.groupCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CiqualFoodsCompanion.insert({
    required String code,
    required String name,
    this.groupCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<CiqualFood> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? groupCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (groupCode != null) 'group_code': groupCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CiqualFoodsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String?>? groupCode,
    Value<int>? rowid,
  }) {
    return CiqualFoodsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      groupCode: groupCode ?? this.groupCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupCode.present) {
      map['group_code'] = Variable<String>(groupCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CiqualFoodsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('groupCode: $groupCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalNameFrMeta = const VerificationMeta(
    'canonicalNameFr',
  );
  @override
  late final GeneratedColumn<String> canonicalNameFr = GeneratedColumn<String>(
    'canonical_name_fr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalNameEnMeta = const VerificationMeta(
    'canonicalNameEn',
  );
  @override
  late final GeneratedColumn<String> canonicalNameEn = GeneratedColumn<String>(
    'canonical_name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasesFrMeta = const VerificationMeta(
    'aliasesFr',
  );
  @override
  late final GeneratedColumn<String> aliasesFr = GeneratedColumn<String>(
    'aliases_fr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasesEnMeta = const VerificationMeta(
    'aliasesEn',
  );
  @override
  late final GeneratedColumn<String> aliasesEn = GeneratedColumn<String>(
    'aliases_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kingdomOrOriginMeta = const VerificationMeta(
    'kingdomOrOrigin',
  );
  @override
  late final GeneratedColumn<String> kingdomOrOrigin = GeneratedColumn<String>(
    'kingdom_or_origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryLevel1Meta = const VerificationMeta(
    'categoryLevel1',
  );
  @override
  late final GeneratedColumn<String> categoryLevel1 = GeneratedColumn<String>(
    'category_level_1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryLevel2Meta = const VerificationMeta(
    'categoryLevel2',
  );
  @override
  late final GeneratedColumn<String> categoryLevel2 = GeneratedColumn<String>(
    'category_level_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryLevel3Meta = const VerificationMeta(
    'categoryLevel3',
  );
  @override
  late final GeneratedColumn<String> categoryLevel3 = GeneratedColumn<String>(
    'category_level_3',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceOrganismMeta = const VerificationMeta(
    'sourceOrganism',
  );
  @override
  late final GeneratedColumn<String> sourceOrganism = GeneratedColumn<String>(
    'source_organism',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anatomicalPartMeta = const VerificationMeta(
    'anatomicalPart',
  );
  @override
  late final GeneratedColumn<String> anatomicalPart = GeneratedColumn<String>(
    'anatomical_part',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientClassMeta = const VerificationMeta(
    'ingredientClass',
  );
  @override
  late final GeneratedColumn<String> ingredientClass = GeneratedColumn<String>(
    'ingredient_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawOrIntermediateMeta = const VerificationMeta(
    'rawOrIntermediate',
  );
  @override
  late final GeneratedColumn<String> rawOrIntermediate =
      GeneratedColumn<String>(
        'raw_or_intermediate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processingStateMeta = const VerificationMeta(
    'processingState',
  );
  @override
  late final GeneratedColumn<String> processingState = GeneratedColumn<String>(
    'processing_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _physicalFormMeta = const VerificationMeta(
    'physicalForm',
  );
  @override
  late final GeneratedColumn<String> physicalForm = GeneratedColumn<String>(
    'physical_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fermentedMeta = const VerificationMeta(
    'fermented',
  );
  @override
  late final GeneratedColumn<bool> fermented = GeneratedColumn<bool>(
    'fermented',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fermented" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _driedMeta = const VerificationMeta('dried');
  @override
  late final GeneratedColumn<bool> dried = GeneratedColumn<bool>(
    'dried',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dried" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smokedMeta = const VerificationMeta('smoked');
  @override
  late final GeneratedColumn<bool> smoked = GeneratedColumn<bool>(
    'smoked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("smoked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roastedMeta = const VerificationMeta(
    'roasted',
  );
  @override
  late final GeneratedColumn<bool> roasted = GeneratedColumn<bool>(
    'roasted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("roasted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _concentratedMeta = const VerificationMeta(
    'concentrated',
  );
  @override
  late final GeneratedColumn<bool> concentrated = GeneratedColumn<bool>(
    'concentrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("concentrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _alcoholicMeta = const VerificationMeta(
    'alcoholic',
  );
  @override
  late final GeneratedColumn<bool> alcoholic = GeneratedColumn<bool>(
    'alcoholic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alcoholic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _genericAbvRangeMeta = const VerificationMeta(
    'genericAbvRange',
  );
  @override
  late final GeneratedColumn<String> genericAbvRange = GeneratedColumn<String>(
    'generic_abv_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryOrRegionRelevanceMeta =
      const VerificationMeta('countryOrRegionRelevance');
  @override
  late final GeneratedColumn<String> countryOrRegionRelevance =
      GeneratedColumn<String>(
        'country_or_region_relevance',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _foodonIdMeta = const VerificationMeta(
    'foodonId',
  );
  @override
  late final GeneratedColumn<String> foodonId = GeneratedColumn<String>(
    'foodon_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _langualIdsMeta = const VerificationMeta(
    'langualIds',
  );
  @override
  late final GeneratedColumn<String> langualIds = GeneratedColumn<String>(
    'langual_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodex2CodeMeta = const VerificationMeta(
    'foodex2Code',
  );
  @override
  late final GeneratedColumn<String> foodex2Code = GeneratedColumn<String>(
    'foodex2_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ciqualIdsMeta = const VerificationMeta(
    'ciqualIds',
  );
  @override
  late final GeneratedColumn<String> ciqualIds = GeneratedColumn<String>(
    'ciqual_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usdaFdcIdsMeta = const VerificationMeta(
    'usdaFdcIds',
  );
  @override
  late final GeneratedColumn<String> usdaFdcIds = GeneratedColumn<String>(
    'usda_fdc_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherExternalIdsMeta = const VerificationMeta(
    'otherExternalIds',
  );
  @override
  late final GeneratedColumn<String> otherExternalIds = GeneratedColumn<String>(
    'other_external_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergenTagsMeta = const VerificationMeta(
    'allergenTags',
  );
  @override
  late final GeneratedColumn<String> allergenTags = GeneratedColumn<String>(
    'allergen_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regulatoryNotesMeta = const VerificationMeta(
    'regulatoryNotes',
  );
  @override
  late final GeneratedColumn<String> regulatoryNotes = GeneratedColumn<String>(
    'regulatory_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceRefsMeta = const VerificationMeta(
    'sourceRefs',
  );
  @override
  late final GeneratedColumn<String> sourceRefs = GeneratedColumn<String>(
    'source_refs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ingredientId,
    canonicalNameFr,
    canonicalNameEn,
    aliasesFr,
    aliasesEn,
    scientificName,
    kingdomOrOrigin,
    categoryLevel1,
    categoryLevel2,
    categoryLevel3,
    sourceOrganism,
    anatomicalPart,
    ingredientClass,
    rawOrIntermediate,
    processingState,
    physicalForm,
    fermented,
    dried,
    smoked,
    roasted,
    concentrated,
    alcoholic,
    genericAbvRange,
    countryOrRegionRelevance,
    foodonId,
    langualIds,
    foodex2Code,
    ciqualIds,
    usdaFdcIds,
    otherExternalIds,
    allergenTags,
    regulatoryNotes,
    sourceRefs,
    confidence,
    reviewStatus,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('canonical_name_fr')) {
      context.handle(
        _canonicalNameFrMeta,
        canonicalNameFr.isAcceptableOrUnknown(
          data['canonical_name_fr']!,
          _canonicalNameFrMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameFrMeta);
    }
    if (data.containsKey('canonical_name_en')) {
      context.handle(
        _canonicalNameEnMeta,
        canonicalNameEn.isAcceptableOrUnknown(
          data['canonical_name_en']!,
          _canonicalNameEnMeta,
        ),
      );
    }
    if (data.containsKey('aliases_fr')) {
      context.handle(
        _aliasesFrMeta,
        aliasesFr.isAcceptableOrUnknown(data['aliases_fr']!, _aliasesFrMeta),
      );
    }
    if (data.containsKey('aliases_en')) {
      context.handle(
        _aliasesEnMeta,
        aliasesEn.isAcceptableOrUnknown(data['aliases_en']!, _aliasesEnMeta),
      );
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    }
    if (data.containsKey('kingdom_or_origin')) {
      context.handle(
        _kingdomOrOriginMeta,
        kingdomOrOrigin.isAcceptableOrUnknown(
          data['kingdom_or_origin']!,
          _kingdomOrOriginMeta,
        ),
      );
    }
    if (data.containsKey('category_level_1')) {
      context.handle(
        _categoryLevel1Meta,
        categoryLevel1.isAcceptableOrUnknown(
          data['category_level_1']!,
          _categoryLevel1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryLevel1Meta);
    }
    if (data.containsKey('category_level_2')) {
      context.handle(
        _categoryLevel2Meta,
        categoryLevel2.isAcceptableOrUnknown(
          data['category_level_2']!,
          _categoryLevel2Meta,
        ),
      );
    }
    if (data.containsKey('category_level_3')) {
      context.handle(
        _categoryLevel3Meta,
        categoryLevel3.isAcceptableOrUnknown(
          data['category_level_3']!,
          _categoryLevel3Meta,
        ),
      );
    }
    if (data.containsKey('source_organism')) {
      context.handle(
        _sourceOrganismMeta,
        sourceOrganism.isAcceptableOrUnknown(
          data['source_organism']!,
          _sourceOrganismMeta,
        ),
      );
    }
    if (data.containsKey('anatomical_part')) {
      context.handle(
        _anatomicalPartMeta,
        anatomicalPart.isAcceptableOrUnknown(
          data['anatomical_part']!,
          _anatomicalPartMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_class')) {
      context.handle(
        _ingredientClassMeta,
        ingredientClass.isAcceptableOrUnknown(
          data['ingredient_class']!,
          _ingredientClassMeta,
        ),
      );
    }
    if (data.containsKey('raw_or_intermediate')) {
      context.handle(
        _rawOrIntermediateMeta,
        rawOrIntermediate.isAcceptableOrUnknown(
          data['raw_or_intermediate']!,
          _rawOrIntermediateMeta,
        ),
      );
    }
    if (data.containsKey('processing_state')) {
      context.handle(
        _processingStateMeta,
        processingState.isAcceptableOrUnknown(
          data['processing_state']!,
          _processingStateMeta,
        ),
      );
    }
    if (data.containsKey('physical_form')) {
      context.handle(
        _physicalFormMeta,
        physicalForm.isAcceptableOrUnknown(
          data['physical_form']!,
          _physicalFormMeta,
        ),
      );
    }
    if (data.containsKey('fermented')) {
      context.handle(
        _fermentedMeta,
        fermented.isAcceptableOrUnknown(data['fermented']!, _fermentedMeta),
      );
    }
    if (data.containsKey('dried')) {
      context.handle(
        _driedMeta,
        dried.isAcceptableOrUnknown(data['dried']!, _driedMeta),
      );
    }
    if (data.containsKey('smoked')) {
      context.handle(
        _smokedMeta,
        smoked.isAcceptableOrUnknown(data['smoked']!, _smokedMeta),
      );
    }
    if (data.containsKey('roasted')) {
      context.handle(
        _roastedMeta,
        roasted.isAcceptableOrUnknown(data['roasted']!, _roastedMeta),
      );
    }
    if (data.containsKey('concentrated')) {
      context.handle(
        _concentratedMeta,
        concentrated.isAcceptableOrUnknown(
          data['concentrated']!,
          _concentratedMeta,
        ),
      );
    }
    if (data.containsKey('alcoholic')) {
      context.handle(
        _alcoholicMeta,
        alcoholic.isAcceptableOrUnknown(data['alcoholic']!, _alcoholicMeta),
      );
    }
    if (data.containsKey('generic_abv_range')) {
      context.handle(
        _genericAbvRangeMeta,
        genericAbvRange.isAcceptableOrUnknown(
          data['generic_abv_range']!,
          _genericAbvRangeMeta,
        ),
      );
    }
    if (data.containsKey('country_or_region_relevance')) {
      context.handle(
        _countryOrRegionRelevanceMeta,
        countryOrRegionRelevance.isAcceptableOrUnknown(
          data['country_or_region_relevance']!,
          _countryOrRegionRelevanceMeta,
        ),
      );
    }
    if (data.containsKey('foodon_id')) {
      context.handle(
        _foodonIdMeta,
        foodonId.isAcceptableOrUnknown(data['foodon_id']!, _foodonIdMeta),
      );
    }
    if (data.containsKey('langual_ids')) {
      context.handle(
        _langualIdsMeta,
        langualIds.isAcceptableOrUnknown(data['langual_ids']!, _langualIdsMeta),
      );
    }
    if (data.containsKey('foodex2_code')) {
      context.handle(
        _foodex2CodeMeta,
        foodex2Code.isAcceptableOrUnknown(
          data['foodex2_code']!,
          _foodex2CodeMeta,
        ),
      );
    }
    if (data.containsKey('ciqual_ids')) {
      context.handle(
        _ciqualIdsMeta,
        ciqualIds.isAcceptableOrUnknown(data['ciqual_ids']!, _ciqualIdsMeta),
      );
    }
    if (data.containsKey('usda_fdc_ids')) {
      context.handle(
        _usdaFdcIdsMeta,
        usdaFdcIds.isAcceptableOrUnknown(
          data['usda_fdc_ids']!,
          _usdaFdcIdsMeta,
        ),
      );
    }
    if (data.containsKey('other_external_ids')) {
      context.handle(
        _otherExternalIdsMeta,
        otherExternalIds.isAcceptableOrUnknown(
          data['other_external_ids']!,
          _otherExternalIdsMeta,
        ),
      );
    }
    if (data.containsKey('allergen_tags')) {
      context.handle(
        _allergenTagsMeta,
        allergenTags.isAcceptableOrUnknown(
          data['allergen_tags']!,
          _allergenTagsMeta,
        ),
      );
    }
    if (data.containsKey('regulatory_notes')) {
      context.handle(
        _regulatoryNotesMeta,
        regulatoryNotes.isAcceptableOrUnknown(
          data['regulatory_notes']!,
          _regulatoryNotesMeta,
        ),
      );
    }
    if (data.containsKey('source_refs')) {
      context.handle(
        _sourceRefsMeta,
        sourceRefs.isAcceptableOrUnknown(data['source_refs']!, _sourceRefsMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ingredientId};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      canonicalNameFr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name_fr'],
      )!,
      canonicalNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name_en'],
      ),
      aliasesFr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases_fr'],
      ),
      aliasesEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases_en'],
      ),
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      ),
      kingdomOrOrigin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kingdom_or_origin'],
      ),
      categoryLevel1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_level_1'],
      )!,
      categoryLevel2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_level_2'],
      ),
      categoryLevel3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_level_3'],
      ),
      sourceOrganism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_organism'],
      ),
      anatomicalPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anatomical_part'],
      ),
      ingredientClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_class'],
      ),
      rawOrIntermediate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_or_intermediate'],
      ),
      processingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_state'],
      ),
      physicalForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_form'],
      ),
      fermented: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fermented'],
      )!,
      dried: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dried'],
      )!,
      smoked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}smoked'],
      )!,
      roasted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}roasted'],
      )!,
      concentrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}concentrated'],
      )!,
      alcoholic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alcoholic'],
      )!,
      genericAbvRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generic_abv_range'],
      ),
      countryOrRegionRelevance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_or_region_relevance'],
      ),
      foodonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foodon_id'],
      ),
      langualIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}langual_ids'],
      ),
      foodex2Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foodex2_code'],
      ),
      ciqualIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ciqual_ids'],
      ),
      usdaFdcIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usda_fdc_ids'],
      ),
      otherExternalIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_external_ids'],
      ),
      allergenTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen_tags'],
      ),
      regulatoryNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regulatory_notes'],
      ),
      sourceRefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_refs'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String ingredientId;
  final String canonicalNameFr;
  final String? canonicalNameEn;
  final String? aliasesFr;
  final String? aliasesEn;
  final String? scientificName;
  final String? kingdomOrOrigin;
  final String categoryLevel1;
  final String? categoryLevel2;
  final String? categoryLevel3;
  final String? sourceOrganism;
  final String? anatomicalPart;
  final String? ingredientClass;
  final String? rawOrIntermediate;
  final String? processingState;
  final String? physicalForm;
  final bool fermented;
  final bool dried;
  final bool smoked;
  final bool roasted;
  final bool concentrated;
  final bool alcoholic;
  final String? genericAbvRange;
  final String? countryOrRegionRelevance;
  final String? foodonId;
  final String? langualIds;
  final String? foodex2Code;
  final String? ciqualIds;
  final String? usdaFdcIds;
  final String? otherExternalIds;
  final String? allergenTags;
  final String? regulatoryNotes;
  final String? sourceRefs;
  final double? confidence;
  final String? reviewStatus;
  final String? notes;
  const Ingredient({
    required this.ingredientId,
    required this.canonicalNameFr,
    this.canonicalNameEn,
    this.aliasesFr,
    this.aliasesEn,
    this.scientificName,
    this.kingdomOrOrigin,
    required this.categoryLevel1,
    this.categoryLevel2,
    this.categoryLevel3,
    this.sourceOrganism,
    this.anatomicalPart,
    this.ingredientClass,
    this.rawOrIntermediate,
    this.processingState,
    this.physicalForm,
    required this.fermented,
    required this.dried,
    required this.smoked,
    required this.roasted,
    required this.concentrated,
    required this.alcoholic,
    this.genericAbvRange,
    this.countryOrRegionRelevance,
    this.foodonId,
    this.langualIds,
    this.foodex2Code,
    this.ciqualIds,
    this.usdaFdcIds,
    this.otherExternalIds,
    this.allergenTags,
    this.regulatoryNotes,
    this.sourceRefs,
    this.confidence,
    this.reviewStatus,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['canonical_name_fr'] = Variable<String>(canonicalNameFr);
    if (!nullToAbsent || canonicalNameEn != null) {
      map['canonical_name_en'] = Variable<String>(canonicalNameEn);
    }
    if (!nullToAbsent || aliasesFr != null) {
      map['aliases_fr'] = Variable<String>(aliasesFr);
    }
    if (!nullToAbsent || aliasesEn != null) {
      map['aliases_en'] = Variable<String>(aliasesEn);
    }
    if (!nullToAbsent || scientificName != null) {
      map['scientific_name'] = Variable<String>(scientificName);
    }
    if (!nullToAbsent || kingdomOrOrigin != null) {
      map['kingdom_or_origin'] = Variable<String>(kingdomOrOrigin);
    }
    map['category_level_1'] = Variable<String>(categoryLevel1);
    if (!nullToAbsent || categoryLevel2 != null) {
      map['category_level_2'] = Variable<String>(categoryLevel2);
    }
    if (!nullToAbsent || categoryLevel3 != null) {
      map['category_level_3'] = Variable<String>(categoryLevel3);
    }
    if (!nullToAbsent || sourceOrganism != null) {
      map['source_organism'] = Variable<String>(sourceOrganism);
    }
    if (!nullToAbsent || anatomicalPart != null) {
      map['anatomical_part'] = Variable<String>(anatomicalPart);
    }
    if (!nullToAbsent || ingredientClass != null) {
      map['ingredient_class'] = Variable<String>(ingredientClass);
    }
    if (!nullToAbsent || rawOrIntermediate != null) {
      map['raw_or_intermediate'] = Variable<String>(rawOrIntermediate);
    }
    if (!nullToAbsent || processingState != null) {
      map['processing_state'] = Variable<String>(processingState);
    }
    if (!nullToAbsent || physicalForm != null) {
      map['physical_form'] = Variable<String>(physicalForm);
    }
    map['fermented'] = Variable<bool>(fermented);
    map['dried'] = Variable<bool>(dried);
    map['smoked'] = Variable<bool>(smoked);
    map['roasted'] = Variable<bool>(roasted);
    map['concentrated'] = Variable<bool>(concentrated);
    map['alcoholic'] = Variable<bool>(alcoholic);
    if (!nullToAbsent || genericAbvRange != null) {
      map['generic_abv_range'] = Variable<String>(genericAbvRange);
    }
    if (!nullToAbsent || countryOrRegionRelevance != null) {
      map['country_or_region_relevance'] = Variable<String>(
        countryOrRegionRelevance,
      );
    }
    if (!nullToAbsent || foodonId != null) {
      map['foodon_id'] = Variable<String>(foodonId);
    }
    if (!nullToAbsent || langualIds != null) {
      map['langual_ids'] = Variable<String>(langualIds);
    }
    if (!nullToAbsent || foodex2Code != null) {
      map['foodex2_code'] = Variable<String>(foodex2Code);
    }
    if (!nullToAbsent || ciqualIds != null) {
      map['ciqual_ids'] = Variable<String>(ciqualIds);
    }
    if (!nullToAbsent || usdaFdcIds != null) {
      map['usda_fdc_ids'] = Variable<String>(usdaFdcIds);
    }
    if (!nullToAbsent || otherExternalIds != null) {
      map['other_external_ids'] = Variable<String>(otherExternalIds);
    }
    if (!nullToAbsent || allergenTags != null) {
      map['allergen_tags'] = Variable<String>(allergenTags);
    }
    if (!nullToAbsent || regulatoryNotes != null) {
      map['regulatory_notes'] = Variable<String>(regulatoryNotes);
    }
    if (!nullToAbsent || sourceRefs != null) {
      map['source_refs'] = Variable<String>(sourceRefs);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || reviewStatus != null) {
      map['review_status'] = Variable<String>(reviewStatus);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      ingredientId: Value(ingredientId),
      canonicalNameFr: Value(canonicalNameFr),
      canonicalNameEn: canonicalNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalNameEn),
      aliasesFr: aliasesFr == null && nullToAbsent
          ? const Value.absent()
          : Value(aliasesFr),
      aliasesEn: aliasesEn == null && nullToAbsent
          ? const Value.absent()
          : Value(aliasesEn),
      scientificName: scientificName == null && nullToAbsent
          ? const Value.absent()
          : Value(scientificName),
      kingdomOrOrigin: kingdomOrOrigin == null && nullToAbsent
          ? const Value.absent()
          : Value(kingdomOrOrigin),
      categoryLevel1: Value(categoryLevel1),
      categoryLevel2: categoryLevel2 == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryLevel2),
      categoryLevel3: categoryLevel3 == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryLevel3),
      sourceOrganism: sourceOrganism == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOrganism),
      anatomicalPart: anatomicalPart == null && nullToAbsent
          ? const Value.absent()
          : Value(anatomicalPart),
      ingredientClass: ingredientClass == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientClass),
      rawOrIntermediate: rawOrIntermediate == null && nullToAbsent
          ? const Value.absent()
          : Value(rawOrIntermediate),
      processingState: processingState == null && nullToAbsent
          ? const Value.absent()
          : Value(processingState),
      physicalForm: physicalForm == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalForm),
      fermented: Value(fermented),
      dried: Value(dried),
      smoked: Value(smoked),
      roasted: Value(roasted),
      concentrated: Value(concentrated),
      alcoholic: Value(alcoholic),
      genericAbvRange: genericAbvRange == null && nullToAbsent
          ? const Value.absent()
          : Value(genericAbvRange),
      countryOrRegionRelevance: countryOrRegionRelevance == null && nullToAbsent
          ? const Value.absent()
          : Value(countryOrRegionRelevance),
      foodonId: foodonId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodonId),
      langualIds: langualIds == null && nullToAbsent
          ? const Value.absent()
          : Value(langualIds),
      foodex2Code: foodex2Code == null && nullToAbsent
          ? const Value.absent()
          : Value(foodex2Code),
      ciqualIds: ciqualIds == null && nullToAbsent
          ? const Value.absent()
          : Value(ciqualIds),
      usdaFdcIds: usdaFdcIds == null && nullToAbsent
          ? const Value.absent()
          : Value(usdaFdcIds),
      otherExternalIds: otherExternalIds == null && nullToAbsent
          ? const Value.absent()
          : Value(otherExternalIds),
      allergenTags: allergenTags == null && nullToAbsent
          ? const Value.absent()
          : Value(allergenTags),
      regulatoryNotes: regulatoryNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(regulatoryNotes),
      sourceRefs: sourceRefs == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRefs),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      reviewStatus: reviewStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewStatus),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      canonicalNameFr: serializer.fromJson<String>(json['canonicalNameFr']),
      canonicalNameEn: serializer.fromJson<String?>(json['canonicalNameEn']),
      aliasesFr: serializer.fromJson<String?>(json['aliasesFr']),
      aliasesEn: serializer.fromJson<String?>(json['aliasesEn']),
      scientificName: serializer.fromJson<String?>(json['scientificName']),
      kingdomOrOrigin: serializer.fromJson<String?>(json['kingdomOrOrigin']),
      categoryLevel1: serializer.fromJson<String>(json['categoryLevel1']),
      categoryLevel2: serializer.fromJson<String?>(json['categoryLevel2']),
      categoryLevel3: serializer.fromJson<String?>(json['categoryLevel3']),
      sourceOrganism: serializer.fromJson<String?>(json['sourceOrganism']),
      anatomicalPart: serializer.fromJson<String?>(json['anatomicalPart']),
      ingredientClass: serializer.fromJson<String?>(json['ingredientClass']),
      rawOrIntermediate: serializer.fromJson<String?>(
        json['rawOrIntermediate'],
      ),
      processingState: serializer.fromJson<String?>(json['processingState']),
      physicalForm: serializer.fromJson<String?>(json['physicalForm']),
      fermented: serializer.fromJson<bool>(json['fermented']),
      dried: serializer.fromJson<bool>(json['dried']),
      smoked: serializer.fromJson<bool>(json['smoked']),
      roasted: serializer.fromJson<bool>(json['roasted']),
      concentrated: serializer.fromJson<bool>(json['concentrated']),
      alcoholic: serializer.fromJson<bool>(json['alcoholic']),
      genericAbvRange: serializer.fromJson<String?>(json['genericAbvRange']),
      countryOrRegionRelevance: serializer.fromJson<String?>(
        json['countryOrRegionRelevance'],
      ),
      foodonId: serializer.fromJson<String?>(json['foodonId']),
      langualIds: serializer.fromJson<String?>(json['langualIds']),
      foodex2Code: serializer.fromJson<String?>(json['foodex2Code']),
      ciqualIds: serializer.fromJson<String?>(json['ciqualIds']),
      usdaFdcIds: serializer.fromJson<String?>(json['usdaFdcIds']),
      otherExternalIds: serializer.fromJson<String?>(json['otherExternalIds']),
      allergenTags: serializer.fromJson<String?>(json['allergenTags']),
      regulatoryNotes: serializer.fromJson<String?>(json['regulatoryNotes']),
      sourceRefs: serializer.fromJson<String?>(json['sourceRefs']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      reviewStatus: serializer.fromJson<String?>(json['reviewStatus']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredientId': serializer.toJson<String>(ingredientId),
      'canonicalNameFr': serializer.toJson<String>(canonicalNameFr),
      'canonicalNameEn': serializer.toJson<String?>(canonicalNameEn),
      'aliasesFr': serializer.toJson<String?>(aliasesFr),
      'aliasesEn': serializer.toJson<String?>(aliasesEn),
      'scientificName': serializer.toJson<String?>(scientificName),
      'kingdomOrOrigin': serializer.toJson<String?>(kingdomOrOrigin),
      'categoryLevel1': serializer.toJson<String>(categoryLevel1),
      'categoryLevel2': serializer.toJson<String?>(categoryLevel2),
      'categoryLevel3': serializer.toJson<String?>(categoryLevel3),
      'sourceOrganism': serializer.toJson<String?>(sourceOrganism),
      'anatomicalPart': serializer.toJson<String?>(anatomicalPart),
      'ingredientClass': serializer.toJson<String?>(ingredientClass),
      'rawOrIntermediate': serializer.toJson<String?>(rawOrIntermediate),
      'processingState': serializer.toJson<String?>(processingState),
      'physicalForm': serializer.toJson<String?>(physicalForm),
      'fermented': serializer.toJson<bool>(fermented),
      'dried': serializer.toJson<bool>(dried),
      'smoked': serializer.toJson<bool>(smoked),
      'roasted': serializer.toJson<bool>(roasted),
      'concentrated': serializer.toJson<bool>(concentrated),
      'alcoholic': serializer.toJson<bool>(alcoholic),
      'genericAbvRange': serializer.toJson<String?>(genericAbvRange),
      'countryOrRegionRelevance': serializer.toJson<String?>(
        countryOrRegionRelevance,
      ),
      'foodonId': serializer.toJson<String?>(foodonId),
      'langualIds': serializer.toJson<String?>(langualIds),
      'foodex2Code': serializer.toJson<String?>(foodex2Code),
      'ciqualIds': serializer.toJson<String?>(ciqualIds),
      'usdaFdcIds': serializer.toJson<String?>(usdaFdcIds),
      'otherExternalIds': serializer.toJson<String?>(otherExternalIds),
      'allergenTags': serializer.toJson<String?>(allergenTags),
      'regulatoryNotes': serializer.toJson<String?>(regulatoryNotes),
      'sourceRefs': serializer.toJson<String?>(sourceRefs),
      'confidence': serializer.toJson<double?>(confidence),
      'reviewStatus': serializer.toJson<String?>(reviewStatus),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Ingredient copyWith({
    String? ingredientId,
    String? canonicalNameFr,
    Value<String?> canonicalNameEn = const Value.absent(),
    Value<String?> aliasesFr = const Value.absent(),
    Value<String?> aliasesEn = const Value.absent(),
    Value<String?> scientificName = const Value.absent(),
    Value<String?> kingdomOrOrigin = const Value.absent(),
    String? categoryLevel1,
    Value<String?> categoryLevel2 = const Value.absent(),
    Value<String?> categoryLevel3 = const Value.absent(),
    Value<String?> sourceOrganism = const Value.absent(),
    Value<String?> anatomicalPart = const Value.absent(),
    Value<String?> ingredientClass = const Value.absent(),
    Value<String?> rawOrIntermediate = const Value.absent(),
    Value<String?> processingState = const Value.absent(),
    Value<String?> physicalForm = const Value.absent(),
    bool? fermented,
    bool? dried,
    bool? smoked,
    bool? roasted,
    bool? concentrated,
    bool? alcoholic,
    Value<String?> genericAbvRange = const Value.absent(),
    Value<String?> countryOrRegionRelevance = const Value.absent(),
    Value<String?> foodonId = const Value.absent(),
    Value<String?> langualIds = const Value.absent(),
    Value<String?> foodex2Code = const Value.absent(),
    Value<String?> ciqualIds = const Value.absent(),
    Value<String?> usdaFdcIds = const Value.absent(),
    Value<String?> otherExternalIds = const Value.absent(),
    Value<String?> allergenTags = const Value.absent(),
    Value<String?> regulatoryNotes = const Value.absent(),
    Value<String?> sourceRefs = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> reviewStatus = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Ingredient(
    ingredientId: ingredientId ?? this.ingredientId,
    canonicalNameFr: canonicalNameFr ?? this.canonicalNameFr,
    canonicalNameEn: canonicalNameEn.present
        ? canonicalNameEn.value
        : this.canonicalNameEn,
    aliasesFr: aliasesFr.present ? aliasesFr.value : this.aliasesFr,
    aliasesEn: aliasesEn.present ? aliasesEn.value : this.aliasesEn,
    scientificName: scientificName.present
        ? scientificName.value
        : this.scientificName,
    kingdomOrOrigin: kingdomOrOrigin.present
        ? kingdomOrOrigin.value
        : this.kingdomOrOrigin,
    categoryLevel1: categoryLevel1 ?? this.categoryLevel1,
    categoryLevel2: categoryLevel2.present
        ? categoryLevel2.value
        : this.categoryLevel2,
    categoryLevel3: categoryLevel3.present
        ? categoryLevel3.value
        : this.categoryLevel3,
    sourceOrganism: sourceOrganism.present
        ? sourceOrganism.value
        : this.sourceOrganism,
    anatomicalPart: anatomicalPart.present
        ? anatomicalPart.value
        : this.anatomicalPart,
    ingredientClass: ingredientClass.present
        ? ingredientClass.value
        : this.ingredientClass,
    rawOrIntermediate: rawOrIntermediate.present
        ? rawOrIntermediate.value
        : this.rawOrIntermediate,
    processingState: processingState.present
        ? processingState.value
        : this.processingState,
    physicalForm: physicalForm.present ? physicalForm.value : this.physicalForm,
    fermented: fermented ?? this.fermented,
    dried: dried ?? this.dried,
    smoked: smoked ?? this.smoked,
    roasted: roasted ?? this.roasted,
    concentrated: concentrated ?? this.concentrated,
    alcoholic: alcoholic ?? this.alcoholic,
    genericAbvRange: genericAbvRange.present
        ? genericAbvRange.value
        : this.genericAbvRange,
    countryOrRegionRelevance: countryOrRegionRelevance.present
        ? countryOrRegionRelevance.value
        : this.countryOrRegionRelevance,
    foodonId: foodonId.present ? foodonId.value : this.foodonId,
    langualIds: langualIds.present ? langualIds.value : this.langualIds,
    foodex2Code: foodex2Code.present ? foodex2Code.value : this.foodex2Code,
    ciqualIds: ciqualIds.present ? ciqualIds.value : this.ciqualIds,
    usdaFdcIds: usdaFdcIds.present ? usdaFdcIds.value : this.usdaFdcIds,
    otherExternalIds: otherExternalIds.present
        ? otherExternalIds.value
        : this.otherExternalIds,
    allergenTags: allergenTags.present ? allergenTags.value : this.allergenTags,
    regulatoryNotes: regulatoryNotes.present
        ? regulatoryNotes.value
        : this.regulatoryNotes,
    sourceRefs: sourceRefs.present ? sourceRefs.value : this.sourceRefs,
    confidence: confidence.present ? confidence.value : this.confidence,
    reviewStatus: reviewStatus.present ? reviewStatus.value : this.reviewStatus,
    notes: notes.present ? notes.value : this.notes,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      canonicalNameFr: data.canonicalNameFr.present
          ? data.canonicalNameFr.value
          : this.canonicalNameFr,
      canonicalNameEn: data.canonicalNameEn.present
          ? data.canonicalNameEn.value
          : this.canonicalNameEn,
      aliasesFr: data.aliasesFr.present ? data.aliasesFr.value : this.aliasesFr,
      aliasesEn: data.aliasesEn.present ? data.aliasesEn.value : this.aliasesEn,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      kingdomOrOrigin: data.kingdomOrOrigin.present
          ? data.kingdomOrOrigin.value
          : this.kingdomOrOrigin,
      categoryLevel1: data.categoryLevel1.present
          ? data.categoryLevel1.value
          : this.categoryLevel1,
      categoryLevel2: data.categoryLevel2.present
          ? data.categoryLevel2.value
          : this.categoryLevel2,
      categoryLevel3: data.categoryLevel3.present
          ? data.categoryLevel3.value
          : this.categoryLevel3,
      sourceOrganism: data.sourceOrganism.present
          ? data.sourceOrganism.value
          : this.sourceOrganism,
      anatomicalPart: data.anatomicalPart.present
          ? data.anatomicalPart.value
          : this.anatomicalPart,
      ingredientClass: data.ingredientClass.present
          ? data.ingredientClass.value
          : this.ingredientClass,
      rawOrIntermediate: data.rawOrIntermediate.present
          ? data.rawOrIntermediate.value
          : this.rawOrIntermediate,
      processingState: data.processingState.present
          ? data.processingState.value
          : this.processingState,
      physicalForm: data.physicalForm.present
          ? data.physicalForm.value
          : this.physicalForm,
      fermented: data.fermented.present ? data.fermented.value : this.fermented,
      dried: data.dried.present ? data.dried.value : this.dried,
      smoked: data.smoked.present ? data.smoked.value : this.smoked,
      roasted: data.roasted.present ? data.roasted.value : this.roasted,
      concentrated: data.concentrated.present
          ? data.concentrated.value
          : this.concentrated,
      alcoholic: data.alcoholic.present ? data.alcoholic.value : this.alcoholic,
      genericAbvRange: data.genericAbvRange.present
          ? data.genericAbvRange.value
          : this.genericAbvRange,
      countryOrRegionRelevance: data.countryOrRegionRelevance.present
          ? data.countryOrRegionRelevance.value
          : this.countryOrRegionRelevance,
      foodonId: data.foodonId.present ? data.foodonId.value : this.foodonId,
      langualIds: data.langualIds.present
          ? data.langualIds.value
          : this.langualIds,
      foodex2Code: data.foodex2Code.present
          ? data.foodex2Code.value
          : this.foodex2Code,
      ciqualIds: data.ciqualIds.present ? data.ciqualIds.value : this.ciqualIds,
      usdaFdcIds: data.usdaFdcIds.present
          ? data.usdaFdcIds.value
          : this.usdaFdcIds,
      otherExternalIds: data.otherExternalIds.present
          ? data.otherExternalIds.value
          : this.otherExternalIds,
      allergenTags: data.allergenTags.present
          ? data.allergenTags.value
          : this.allergenTags,
      regulatoryNotes: data.regulatoryNotes.present
          ? data.regulatoryNotes.value
          : this.regulatoryNotes,
      sourceRefs: data.sourceRefs.present
          ? data.sourceRefs.value
          : this.sourceRefs,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('ingredientId: $ingredientId, ')
          ..write('canonicalNameFr: $canonicalNameFr, ')
          ..write('canonicalNameEn: $canonicalNameEn, ')
          ..write('aliasesFr: $aliasesFr, ')
          ..write('aliasesEn: $aliasesEn, ')
          ..write('scientificName: $scientificName, ')
          ..write('kingdomOrOrigin: $kingdomOrOrigin, ')
          ..write('categoryLevel1: $categoryLevel1, ')
          ..write('categoryLevel2: $categoryLevel2, ')
          ..write('categoryLevel3: $categoryLevel3, ')
          ..write('sourceOrganism: $sourceOrganism, ')
          ..write('anatomicalPart: $anatomicalPart, ')
          ..write('ingredientClass: $ingredientClass, ')
          ..write('rawOrIntermediate: $rawOrIntermediate, ')
          ..write('processingState: $processingState, ')
          ..write('physicalForm: $physicalForm, ')
          ..write('fermented: $fermented, ')
          ..write('dried: $dried, ')
          ..write('smoked: $smoked, ')
          ..write('roasted: $roasted, ')
          ..write('concentrated: $concentrated, ')
          ..write('alcoholic: $alcoholic, ')
          ..write('genericAbvRange: $genericAbvRange, ')
          ..write('countryOrRegionRelevance: $countryOrRegionRelevance, ')
          ..write('foodonId: $foodonId, ')
          ..write('langualIds: $langualIds, ')
          ..write('foodex2Code: $foodex2Code, ')
          ..write('ciqualIds: $ciqualIds, ')
          ..write('usdaFdcIds: $usdaFdcIds, ')
          ..write('otherExternalIds: $otherExternalIds, ')
          ..write('allergenTags: $allergenTags, ')
          ..write('regulatoryNotes: $regulatoryNotes, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('confidence: $confidence, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ingredientId,
    canonicalNameFr,
    canonicalNameEn,
    aliasesFr,
    aliasesEn,
    scientificName,
    kingdomOrOrigin,
    categoryLevel1,
    categoryLevel2,
    categoryLevel3,
    sourceOrganism,
    anatomicalPart,
    ingredientClass,
    rawOrIntermediate,
    processingState,
    physicalForm,
    fermented,
    dried,
    smoked,
    roasted,
    concentrated,
    alcoholic,
    genericAbvRange,
    countryOrRegionRelevance,
    foodonId,
    langualIds,
    foodex2Code,
    ciqualIds,
    usdaFdcIds,
    otherExternalIds,
    allergenTags,
    regulatoryNotes,
    sourceRefs,
    confidence,
    reviewStatus,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.ingredientId == this.ingredientId &&
          other.canonicalNameFr == this.canonicalNameFr &&
          other.canonicalNameEn == this.canonicalNameEn &&
          other.aliasesFr == this.aliasesFr &&
          other.aliasesEn == this.aliasesEn &&
          other.scientificName == this.scientificName &&
          other.kingdomOrOrigin == this.kingdomOrOrigin &&
          other.categoryLevel1 == this.categoryLevel1 &&
          other.categoryLevel2 == this.categoryLevel2 &&
          other.categoryLevel3 == this.categoryLevel3 &&
          other.sourceOrganism == this.sourceOrganism &&
          other.anatomicalPart == this.anatomicalPart &&
          other.ingredientClass == this.ingredientClass &&
          other.rawOrIntermediate == this.rawOrIntermediate &&
          other.processingState == this.processingState &&
          other.physicalForm == this.physicalForm &&
          other.fermented == this.fermented &&
          other.dried == this.dried &&
          other.smoked == this.smoked &&
          other.roasted == this.roasted &&
          other.concentrated == this.concentrated &&
          other.alcoholic == this.alcoholic &&
          other.genericAbvRange == this.genericAbvRange &&
          other.countryOrRegionRelevance == this.countryOrRegionRelevance &&
          other.foodonId == this.foodonId &&
          other.langualIds == this.langualIds &&
          other.foodex2Code == this.foodex2Code &&
          other.ciqualIds == this.ciqualIds &&
          other.usdaFdcIds == this.usdaFdcIds &&
          other.otherExternalIds == this.otherExternalIds &&
          other.allergenTags == this.allergenTags &&
          other.regulatoryNotes == this.regulatoryNotes &&
          other.sourceRefs == this.sourceRefs &&
          other.confidence == this.confidence &&
          other.reviewStatus == this.reviewStatus &&
          other.notes == this.notes);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> ingredientId;
  final Value<String> canonicalNameFr;
  final Value<String?> canonicalNameEn;
  final Value<String?> aliasesFr;
  final Value<String?> aliasesEn;
  final Value<String?> scientificName;
  final Value<String?> kingdomOrOrigin;
  final Value<String> categoryLevel1;
  final Value<String?> categoryLevel2;
  final Value<String?> categoryLevel3;
  final Value<String?> sourceOrganism;
  final Value<String?> anatomicalPart;
  final Value<String?> ingredientClass;
  final Value<String?> rawOrIntermediate;
  final Value<String?> processingState;
  final Value<String?> physicalForm;
  final Value<bool> fermented;
  final Value<bool> dried;
  final Value<bool> smoked;
  final Value<bool> roasted;
  final Value<bool> concentrated;
  final Value<bool> alcoholic;
  final Value<String?> genericAbvRange;
  final Value<String?> countryOrRegionRelevance;
  final Value<String?> foodonId;
  final Value<String?> langualIds;
  final Value<String?> foodex2Code;
  final Value<String?> ciqualIds;
  final Value<String?> usdaFdcIds;
  final Value<String?> otherExternalIds;
  final Value<String?> allergenTags;
  final Value<String?> regulatoryNotes;
  final Value<String?> sourceRefs;
  final Value<double?> confidence;
  final Value<String?> reviewStatus;
  final Value<String?> notes;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.ingredientId = const Value.absent(),
    this.canonicalNameFr = const Value.absent(),
    this.canonicalNameEn = const Value.absent(),
    this.aliasesFr = const Value.absent(),
    this.aliasesEn = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.kingdomOrOrigin = const Value.absent(),
    this.categoryLevel1 = const Value.absent(),
    this.categoryLevel2 = const Value.absent(),
    this.categoryLevel3 = const Value.absent(),
    this.sourceOrganism = const Value.absent(),
    this.anatomicalPart = const Value.absent(),
    this.ingredientClass = const Value.absent(),
    this.rawOrIntermediate = const Value.absent(),
    this.processingState = const Value.absent(),
    this.physicalForm = const Value.absent(),
    this.fermented = const Value.absent(),
    this.dried = const Value.absent(),
    this.smoked = const Value.absent(),
    this.roasted = const Value.absent(),
    this.concentrated = const Value.absent(),
    this.alcoholic = const Value.absent(),
    this.genericAbvRange = const Value.absent(),
    this.countryOrRegionRelevance = const Value.absent(),
    this.foodonId = const Value.absent(),
    this.langualIds = const Value.absent(),
    this.foodex2Code = const Value.absent(),
    this.ciqualIds = const Value.absent(),
    this.usdaFdcIds = const Value.absent(),
    this.otherExternalIds = const Value.absent(),
    this.allergenTags = const Value.absent(),
    this.regulatoryNotes = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String ingredientId,
    required String canonicalNameFr,
    this.canonicalNameEn = const Value.absent(),
    this.aliasesFr = const Value.absent(),
    this.aliasesEn = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.kingdomOrOrigin = const Value.absent(),
    required String categoryLevel1,
    this.categoryLevel2 = const Value.absent(),
    this.categoryLevel3 = const Value.absent(),
    this.sourceOrganism = const Value.absent(),
    this.anatomicalPart = const Value.absent(),
    this.ingredientClass = const Value.absent(),
    this.rawOrIntermediate = const Value.absent(),
    this.processingState = const Value.absent(),
    this.physicalForm = const Value.absent(),
    this.fermented = const Value.absent(),
    this.dried = const Value.absent(),
    this.smoked = const Value.absent(),
    this.roasted = const Value.absent(),
    this.concentrated = const Value.absent(),
    this.alcoholic = const Value.absent(),
    this.genericAbvRange = const Value.absent(),
    this.countryOrRegionRelevance = const Value.absent(),
    this.foodonId = const Value.absent(),
    this.langualIds = const Value.absent(),
    this.foodex2Code = const Value.absent(),
    this.ciqualIds = const Value.absent(),
    this.usdaFdcIds = const Value.absent(),
    this.otherExternalIds = const Value.absent(),
    this.allergenTags = const Value.absent(),
    this.regulatoryNotes = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ingredientId = Value(ingredientId),
       canonicalNameFr = Value(canonicalNameFr),
       categoryLevel1 = Value(categoryLevel1);
  static Insertable<Ingredient> custom({
    Expression<String>? ingredientId,
    Expression<String>? canonicalNameFr,
    Expression<String>? canonicalNameEn,
    Expression<String>? aliasesFr,
    Expression<String>? aliasesEn,
    Expression<String>? scientificName,
    Expression<String>? kingdomOrOrigin,
    Expression<String>? categoryLevel1,
    Expression<String>? categoryLevel2,
    Expression<String>? categoryLevel3,
    Expression<String>? sourceOrganism,
    Expression<String>? anatomicalPart,
    Expression<String>? ingredientClass,
    Expression<String>? rawOrIntermediate,
    Expression<String>? processingState,
    Expression<String>? physicalForm,
    Expression<bool>? fermented,
    Expression<bool>? dried,
    Expression<bool>? smoked,
    Expression<bool>? roasted,
    Expression<bool>? concentrated,
    Expression<bool>? alcoholic,
    Expression<String>? genericAbvRange,
    Expression<String>? countryOrRegionRelevance,
    Expression<String>? foodonId,
    Expression<String>? langualIds,
    Expression<String>? foodex2Code,
    Expression<String>? ciqualIds,
    Expression<String>? usdaFdcIds,
    Expression<String>? otherExternalIds,
    Expression<String>? allergenTags,
    Expression<String>? regulatoryNotes,
    Expression<String>? sourceRefs,
    Expression<double>? confidence,
    Expression<String>? reviewStatus,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (canonicalNameFr != null) 'canonical_name_fr': canonicalNameFr,
      if (canonicalNameEn != null) 'canonical_name_en': canonicalNameEn,
      if (aliasesFr != null) 'aliases_fr': aliasesFr,
      if (aliasesEn != null) 'aliases_en': aliasesEn,
      if (scientificName != null) 'scientific_name': scientificName,
      if (kingdomOrOrigin != null) 'kingdom_or_origin': kingdomOrOrigin,
      if (categoryLevel1 != null) 'category_level_1': categoryLevel1,
      if (categoryLevel2 != null) 'category_level_2': categoryLevel2,
      if (categoryLevel3 != null) 'category_level_3': categoryLevel3,
      if (sourceOrganism != null) 'source_organism': sourceOrganism,
      if (anatomicalPart != null) 'anatomical_part': anatomicalPart,
      if (ingredientClass != null) 'ingredient_class': ingredientClass,
      if (rawOrIntermediate != null) 'raw_or_intermediate': rawOrIntermediate,
      if (processingState != null) 'processing_state': processingState,
      if (physicalForm != null) 'physical_form': physicalForm,
      if (fermented != null) 'fermented': fermented,
      if (dried != null) 'dried': dried,
      if (smoked != null) 'smoked': smoked,
      if (roasted != null) 'roasted': roasted,
      if (concentrated != null) 'concentrated': concentrated,
      if (alcoholic != null) 'alcoholic': alcoholic,
      if (genericAbvRange != null) 'generic_abv_range': genericAbvRange,
      if (countryOrRegionRelevance != null)
        'country_or_region_relevance': countryOrRegionRelevance,
      if (foodonId != null) 'foodon_id': foodonId,
      if (langualIds != null) 'langual_ids': langualIds,
      if (foodex2Code != null) 'foodex2_code': foodex2Code,
      if (ciqualIds != null) 'ciqual_ids': ciqualIds,
      if (usdaFdcIds != null) 'usda_fdc_ids': usdaFdcIds,
      if (otherExternalIds != null) 'other_external_ids': otherExternalIds,
      if (allergenTags != null) 'allergen_tags': allergenTags,
      if (regulatoryNotes != null) 'regulatory_notes': regulatoryNotes,
      if (sourceRefs != null) 'source_refs': sourceRefs,
      if (confidence != null) 'confidence': confidence,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith({
    Value<String>? ingredientId,
    Value<String>? canonicalNameFr,
    Value<String?>? canonicalNameEn,
    Value<String?>? aliasesFr,
    Value<String?>? aliasesEn,
    Value<String?>? scientificName,
    Value<String?>? kingdomOrOrigin,
    Value<String>? categoryLevel1,
    Value<String?>? categoryLevel2,
    Value<String?>? categoryLevel3,
    Value<String?>? sourceOrganism,
    Value<String?>? anatomicalPart,
    Value<String?>? ingredientClass,
    Value<String?>? rawOrIntermediate,
    Value<String?>? processingState,
    Value<String?>? physicalForm,
    Value<bool>? fermented,
    Value<bool>? dried,
    Value<bool>? smoked,
    Value<bool>? roasted,
    Value<bool>? concentrated,
    Value<bool>? alcoholic,
    Value<String?>? genericAbvRange,
    Value<String?>? countryOrRegionRelevance,
    Value<String?>? foodonId,
    Value<String?>? langualIds,
    Value<String?>? foodex2Code,
    Value<String?>? ciqualIds,
    Value<String?>? usdaFdcIds,
    Value<String?>? otherExternalIds,
    Value<String?>? allergenTags,
    Value<String?>? regulatoryNotes,
    Value<String?>? sourceRefs,
    Value<double?>? confidence,
    Value<String?>? reviewStatus,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return IngredientsCompanion(
      ingredientId: ingredientId ?? this.ingredientId,
      canonicalNameFr: canonicalNameFr ?? this.canonicalNameFr,
      canonicalNameEn: canonicalNameEn ?? this.canonicalNameEn,
      aliasesFr: aliasesFr ?? this.aliasesFr,
      aliasesEn: aliasesEn ?? this.aliasesEn,
      scientificName: scientificName ?? this.scientificName,
      kingdomOrOrigin: kingdomOrOrigin ?? this.kingdomOrOrigin,
      categoryLevel1: categoryLevel1 ?? this.categoryLevel1,
      categoryLevel2: categoryLevel2 ?? this.categoryLevel2,
      categoryLevel3: categoryLevel3 ?? this.categoryLevel3,
      sourceOrganism: sourceOrganism ?? this.sourceOrganism,
      anatomicalPart: anatomicalPart ?? this.anatomicalPart,
      ingredientClass: ingredientClass ?? this.ingredientClass,
      rawOrIntermediate: rawOrIntermediate ?? this.rawOrIntermediate,
      processingState: processingState ?? this.processingState,
      physicalForm: physicalForm ?? this.physicalForm,
      fermented: fermented ?? this.fermented,
      dried: dried ?? this.dried,
      smoked: smoked ?? this.smoked,
      roasted: roasted ?? this.roasted,
      concentrated: concentrated ?? this.concentrated,
      alcoholic: alcoholic ?? this.alcoholic,
      genericAbvRange: genericAbvRange ?? this.genericAbvRange,
      countryOrRegionRelevance:
          countryOrRegionRelevance ?? this.countryOrRegionRelevance,
      foodonId: foodonId ?? this.foodonId,
      langualIds: langualIds ?? this.langualIds,
      foodex2Code: foodex2Code ?? this.foodex2Code,
      ciqualIds: ciqualIds ?? this.ciqualIds,
      usdaFdcIds: usdaFdcIds ?? this.usdaFdcIds,
      otherExternalIds: otherExternalIds ?? this.otherExternalIds,
      allergenTags: allergenTags ?? this.allergenTags,
      regulatoryNotes: regulatoryNotes ?? this.regulatoryNotes,
      sourceRefs: sourceRefs ?? this.sourceRefs,
      confidence: confidence ?? this.confidence,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (canonicalNameFr.present) {
      map['canonical_name_fr'] = Variable<String>(canonicalNameFr.value);
    }
    if (canonicalNameEn.present) {
      map['canonical_name_en'] = Variable<String>(canonicalNameEn.value);
    }
    if (aliasesFr.present) {
      map['aliases_fr'] = Variable<String>(aliasesFr.value);
    }
    if (aliasesEn.present) {
      map['aliases_en'] = Variable<String>(aliasesEn.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (kingdomOrOrigin.present) {
      map['kingdom_or_origin'] = Variable<String>(kingdomOrOrigin.value);
    }
    if (categoryLevel1.present) {
      map['category_level_1'] = Variable<String>(categoryLevel1.value);
    }
    if (categoryLevel2.present) {
      map['category_level_2'] = Variable<String>(categoryLevel2.value);
    }
    if (categoryLevel3.present) {
      map['category_level_3'] = Variable<String>(categoryLevel3.value);
    }
    if (sourceOrganism.present) {
      map['source_organism'] = Variable<String>(sourceOrganism.value);
    }
    if (anatomicalPart.present) {
      map['anatomical_part'] = Variable<String>(anatomicalPart.value);
    }
    if (ingredientClass.present) {
      map['ingredient_class'] = Variable<String>(ingredientClass.value);
    }
    if (rawOrIntermediate.present) {
      map['raw_or_intermediate'] = Variable<String>(rawOrIntermediate.value);
    }
    if (processingState.present) {
      map['processing_state'] = Variable<String>(processingState.value);
    }
    if (physicalForm.present) {
      map['physical_form'] = Variable<String>(physicalForm.value);
    }
    if (fermented.present) {
      map['fermented'] = Variable<bool>(fermented.value);
    }
    if (dried.present) {
      map['dried'] = Variable<bool>(dried.value);
    }
    if (smoked.present) {
      map['smoked'] = Variable<bool>(smoked.value);
    }
    if (roasted.present) {
      map['roasted'] = Variable<bool>(roasted.value);
    }
    if (concentrated.present) {
      map['concentrated'] = Variable<bool>(concentrated.value);
    }
    if (alcoholic.present) {
      map['alcoholic'] = Variable<bool>(alcoholic.value);
    }
    if (genericAbvRange.present) {
      map['generic_abv_range'] = Variable<String>(genericAbvRange.value);
    }
    if (countryOrRegionRelevance.present) {
      map['country_or_region_relevance'] = Variable<String>(
        countryOrRegionRelevance.value,
      );
    }
    if (foodonId.present) {
      map['foodon_id'] = Variable<String>(foodonId.value);
    }
    if (langualIds.present) {
      map['langual_ids'] = Variable<String>(langualIds.value);
    }
    if (foodex2Code.present) {
      map['foodex2_code'] = Variable<String>(foodex2Code.value);
    }
    if (ciqualIds.present) {
      map['ciqual_ids'] = Variable<String>(ciqualIds.value);
    }
    if (usdaFdcIds.present) {
      map['usda_fdc_ids'] = Variable<String>(usdaFdcIds.value);
    }
    if (otherExternalIds.present) {
      map['other_external_ids'] = Variable<String>(otherExternalIds.value);
    }
    if (allergenTags.present) {
      map['allergen_tags'] = Variable<String>(allergenTags.value);
    }
    if (regulatoryNotes.present) {
      map['regulatory_notes'] = Variable<String>(regulatoryNotes.value);
    }
    if (sourceRefs.present) {
      map['source_refs'] = Variable<String>(sourceRefs.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('ingredientId: $ingredientId, ')
          ..write('canonicalNameFr: $canonicalNameFr, ')
          ..write('canonicalNameEn: $canonicalNameEn, ')
          ..write('aliasesFr: $aliasesFr, ')
          ..write('aliasesEn: $aliasesEn, ')
          ..write('scientificName: $scientificName, ')
          ..write('kingdomOrOrigin: $kingdomOrOrigin, ')
          ..write('categoryLevel1: $categoryLevel1, ')
          ..write('categoryLevel2: $categoryLevel2, ')
          ..write('categoryLevel3: $categoryLevel3, ')
          ..write('sourceOrganism: $sourceOrganism, ')
          ..write('anatomicalPart: $anatomicalPart, ')
          ..write('ingredientClass: $ingredientClass, ')
          ..write('rawOrIntermediate: $rawOrIntermediate, ')
          ..write('processingState: $processingState, ')
          ..write('physicalForm: $physicalForm, ')
          ..write('fermented: $fermented, ')
          ..write('dried: $dried, ')
          ..write('smoked: $smoked, ')
          ..write('roasted: $roasted, ')
          ..write('concentrated: $concentrated, ')
          ..write('alcoholic: $alcoholic, ')
          ..write('genericAbvRange: $genericAbvRange, ')
          ..write('countryOrRegionRelevance: $countryOrRegionRelevance, ')
          ..write('foodonId: $foodonId, ')
          ..write('langualIds: $langualIds, ')
          ..write('foodex2Code: $foodex2Code, ')
          ..write('ciqualIds: $ciqualIds, ')
          ..write('usdaFdcIds: $usdaFdcIds, ')
          ..write('otherExternalIds: $otherExternalIds, ')
          ..write('allergenTags: $allergenTags, ')
          ..write('regulatoryNotes: $regulatoryNotes, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('confidence: $confidence, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeItemsTable extends RecipeItems
    with TableInfo<$RecipeItemsTable, RecipeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'ciqual\', \'recipe\', \'free\'))',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityGMeta = const VerificationMeta(
    'quantityG',
  );
  @override
  late final GeneratedColumn<double> quantityG = GeneratedColumn<double>(
    'quantity_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ciqualCodeMeta = const VerificationMeta(
    'ciqualCode',
  );
  @override
  late final GeneratedColumn<String> ciqualCode = GeneratedColumn<String>(
    'ciqual_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ciqual_foods (code)',
    ),
  );
  static const VerificationMeta _childRecipeIdMeta = const VerificationMeta(
    'childRecipeId',
  );
  @override
  late final GeneratedColumn<String> childRecipeId = GeneratedColumn<String>(
    'child_recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (ingredient_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    position,
    kind,
    label,
    quantityG,
    ciqualCode,
    childRecipeId,
    ingredientId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('quantity_g')) {
      context.handle(
        _quantityGMeta,
        quantityG.isAcceptableOrUnknown(data['quantity_g']!, _quantityGMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityGMeta);
    }
    if (data.containsKey('ciqual_code')) {
      context.handle(
        _ciqualCodeMeta,
        ciqualCode.isAcceptableOrUnknown(data['ciqual_code']!, _ciqualCodeMeta),
      );
    }
    if (data.containsKey('child_recipe_id')) {
      context.handle(
        _childRecipeIdMeta,
        childRecipeId.isAcceptableOrUnknown(
          data['child_recipe_id']!,
          _childRecipeIdMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      quantityG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_g'],
      )!,
      ciqualCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ciqual_code'],
      ),
      childRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_recipe_id'],
      ),
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      ),
    );
  }

  @override
  $RecipeItemsTable createAlias(String alias) {
    return $RecipeItemsTable(attachedDatabase, alias);
  }
}

class RecipeItem extends DataClass implements Insertable<RecipeItem> {
  final String id;
  final String recipeId;
  final int position;
  final String kind;
  final String label;
  final double quantityG;
  final String? ciqualCode;
  final String? childRecipeId;

  /// Optional Phase 1 ingredient reference (added in v3, Lot D). When the
  /// UI binds an ingredient to a Phase 1 row via autocomplete, this FK is
  /// populated so the recipe detail can resolve the canonical name, the
  /// allergens and the nutrition profile from the 4 metier databases.
  final String? ingredientId;
  const RecipeItem({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.kind,
    required this.label,
    required this.quantityG,
    this.ciqualCode,
    this.childRecipeId,
    this.ingredientId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    map['quantity_g'] = Variable<double>(quantityG);
    if (!nullToAbsent || ciqualCode != null) {
      map['ciqual_code'] = Variable<String>(ciqualCode);
    }
    if (!nullToAbsent || childRecipeId != null) {
      map['child_recipe_id'] = Variable<String>(childRecipeId);
    }
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<String>(ingredientId);
    }
    return map;
  }

  RecipeItemsCompanion toCompanion(bool nullToAbsent) {
    return RecipeItemsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      kind: Value(kind),
      label: Value(label),
      quantityG: Value(quantityG),
      ciqualCode: ciqualCode == null && nullToAbsent
          ? const Value.absent()
          : Value(ciqualCode),
      childRecipeId: childRecipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRecipeId),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
    );
  }

  factory RecipeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeItem(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      quantityG: serializer.fromJson<double>(json['quantityG']),
      ciqualCode: serializer.fromJson<String?>(json['ciqualCode']),
      childRecipeId: serializer.fromJson<String?>(json['childRecipeId']),
      ingredientId: serializer.fromJson<String?>(json['ingredientId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'quantityG': serializer.toJson<double>(quantityG),
      'ciqualCode': serializer.toJson<String?>(ciqualCode),
      'childRecipeId': serializer.toJson<String?>(childRecipeId),
      'ingredientId': serializer.toJson<String?>(ingredientId),
    };
  }

  RecipeItem copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? kind,
    String? label,
    double? quantityG,
    Value<String?> ciqualCode = const Value.absent(),
    Value<String?> childRecipeId = const Value.absent(),
    Value<String?> ingredientId = const Value.absent(),
  }) => RecipeItem(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    quantityG: quantityG ?? this.quantityG,
    ciqualCode: ciqualCode.present ? ciqualCode.value : this.ciqualCode,
    childRecipeId: childRecipeId.present
        ? childRecipeId.value
        : this.childRecipeId,
    ingredientId: ingredientId.present ? ingredientId.value : this.ingredientId,
  );
  RecipeItem copyWithCompanion(RecipeItemsCompanion data) {
    return RecipeItem(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      quantityG: data.quantityG.present ? data.quantityG.value : this.quantityG,
      ciqualCode: data.ciqualCode.present
          ? data.ciqualCode.value
          : this.ciqualCode,
      childRecipeId: data.childRecipeId.present
          ? data.childRecipeId.value
          : this.childRecipeId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItem(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('quantityG: $quantityG, ')
          ..write('ciqualCode: $ciqualCode, ')
          ..write('childRecipeId: $childRecipeId, ')
          ..write('ingredientId: $ingredientId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    position,
    kind,
    label,
    quantityG,
    ciqualCode,
    childRecipeId,
    ingredientId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeItem &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.quantityG == this.quantityG &&
          other.ciqualCode == this.ciqualCode &&
          other.childRecipeId == this.childRecipeId &&
          other.ingredientId == this.ingredientId);
}

class RecipeItemsCompanion extends UpdateCompanion<RecipeItem> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> kind;
  final Value<String> label;
  final Value<double> quantityG;
  final Value<String?> ciqualCode;
  final Value<String?> childRecipeId;
  final Value<String?> ingredientId;
  final Value<int> rowid;
  const RecipeItemsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.quantityG = const Value.absent(),
    this.ciqualCode = const Value.absent(),
    this.childRecipeId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeItemsCompanion.insert({
    required String id,
    required String recipeId,
    required int position,
    required String kind,
    required String label,
    required double quantityG,
    this.ciqualCode = const Value.absent(),
    this.childRecipeId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       position = Value(position),
       kind = Value(kind),
       label = Value(label),
       quantityG = Value(quantityG);
  static Insertable<RecipeItem> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<double>? quantityG,
    Expression<String>? ciqualCode,
    Expression<String>? childRecipeId,
    Expression<String>? ingredientId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (quantityG != null) 'quantity_g': quantityG,
      if (ciqualCode != null) 'ciqual_code': ciqualCode,
      if (childRecipeId != null) 'child_recipe_id': childRecipeId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? kind,
    Value<String>? label,
    Value<double>? quantityG,
    Value<String?>? ciqualCode,
    Value<String?>? childRecipeId,
    Value<String?>? ingredientId,
    Value<int>? rowid,
  }) {
    return RecipeItemsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      quantityG: quantityG ?? this.quantityG,
      ciqualCode: ciqualCode ?? this.ciqualCode,
      childRecipeId: childRecipeId ?? this.childRecipeId,
      ingredientId: ingredientId ?? this.ingredientId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (quantityG.present) {
      map['quantity_g'] = Variable<double>(quantityG.value);
    }
    if (ciqualCode.present) {
      map['ciqual_code'] = Variable<String>(ciqualCode.value);
    }
    if (childRecipeId.present) {
      map['child_recipe_id'] = Variable<String>(childRecipeId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItemsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('quantityG: $quantityG, ')
          ..write('ciqualCode: $ciqualCode, ')
          ..write('childRecipeId: $childRecipeId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String label;
  const Tag({required this.id, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), label: Value(label));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
    };
  }

  Tag copyWith({String? id, String? label}) =>
      Tag(id: id ?? this.id, label: label ?? this.label);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.label == this.label);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String label,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeTagsTable extends RecipeTags
    with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [recipeId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipeId, tagId};
  @override
  RecipeTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeTag(
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $RecipeTagsTable createAlias(String alias) {
    return $RecipeTagsTable(attachedDatabase, alias);
  }
}

class RecipeTag extends DataClass implements Insertable<RecipeTag> {
  final String recipeId;
  final String tagId;
  const RecipeTag({required this.recipeId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_id'] = Variable<String>(recipeId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  RecipeTagsCompanion toCompanion(bool nullToAbsent) {
    return RecipeTagsCompanion(recipeId: Value(recipeId), tagId: Value(tagId));
  }

  factory RecipeTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeTag(
      recipeId: serializer.fromJson<String>(json['recipeId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeId': serializer.toJson<String>(recipeId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  RecipeTag copyWith({String? recipeId, String? tagId}) => RecipeTag(
    recipeId: recipeId ?? this.recipeId,
    tagId: tagId ?? this.tagId,
  );
  RecipeTag copyWithCompanion(RecipeTagsCompanion data) {
    return RecipeTag(
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTag(')
          ..write('recipeId: $recipeId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recipeId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeTag &&
          other.recipeId == this.recipeId &&
          other.tagId == this.tagId);
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<String> recipeId;
  final Value<String> tagId;
  final Value<int> rowid;
  const RecipeTagsCompanion({
    this.recipeId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeTagsCompanion.insert({
    required String recipeId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId),
       tagId = Value(tagId);
  static Insertable<RecipeTag> custom({
    Expression<String>? recipeId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeId != null) 'recipe_id': recipeId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeTagsCompanion copyWith({
    Value<String>? recipeId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return RecipeTagsCompanion(
      recipeId: recipeId ?? this.recipeId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTagsCompanion(')
          ..write('recipeId: $recipeId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CiqualNutrientsTable extends CiqualNutrients
    with TableInfo<$CiqualNutrientsTable, CiqualNutrient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CiqualNutrientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodCodeMeta = const VerificationMeta(
    'foodCode',
  );
  @override
  late final GeneratedColumn<String> foodCode = GeneratedColumn<String>(
    'food_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ciqual_foods (code) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nutrientKeyMeta = const VerificationMeta(
    'nutrientKey',
  );
  @override
  late final GeneratedColumn<String> nutrientKey = GeneratedColumn<String>(
    'nutrient_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuePer100gMeta = const VerificationMeta(
    'valuePer100g',
  );
  @override
  late final GeneratedColumn<double> valuePer100g = GeneratedColumn<double>(
    'value_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [foodCode, nutrientKey, valuePer100g];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ciqual_nutrients';
  @override
  VerificationContext validateIntegrity(
    Insertable<CiqualNutrient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_code')) {
      context.handle(
        _foodCodeMeta,
        foodCode.isAcceptableOrUnknown(data['food_code']!, _foodCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_foodCodeMeta);
    }
    if (data.containsKey('nutrient_key')) {
      context.handle(
        _nutrientKeyMeta,
        nutrientKey.isAcceptableOrUnknown(
          data['nutrient_key']!,
          _nutrientKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nutrientKeyMeta);
    }
    if (data.containsKey('value_per_100g')) {
      context.handle(
        _valuePer100gMeta,
        valuePer100g.isAcceptableOrUnknown(
          data['value_per_100g']!,
          _valuePer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valuePer100gMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {foodCode, nutrientKey};
  @override
  CiqualNutrient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CiqualNutrient(
      foodCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_code'],
      )!,
      nutrientKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutrient_key'],
      )!,
      valuePer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_per_100g'],
      )!,
    );
  }

  @override
  $CiqualNutrientsTable createAlias(String alias) {
    return $CiqualNutrientsTable(attachedDatabase, alias);
  }
}

class CiqualNutrient extends DataClass implements Insertable<CiqualNutrient> {
  final String foodCode;
  final String nutrientKey;
  final double valuePer100g;
  const CiqualNutrient({
    required this.foodCode,
    required this.nutrientKey,
    required this.valuePer100g,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_code'] = Variable<String>(foodCode);
    map['nutrient_key'] = Variable<String>(nutrientKey);
    map['value_per_100g'] = Variable<double>(valuePer100g);
    return map;
  }

  CiqualNutrientsCompanion toCompanion(bool nullToAbsent) {
    return CiqualNutrientsCompanion(
      foodCode: Value(foodCode),
      nutrientKey: Value(nutrientKey),
      valuePer100g: Value(valuePer100g),
    );
  }

  factory CiqualNutrient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CiqualNutrient(
      foodCode: serializer.fromJson<String>(json['foodCode']),
      nutrientKey: serializer.fromJson<String>(json['nutrientKey']),
      valuePer100g: serializer.fromJson<double>(json['valuePer100g']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodCode': serializer.toJson<String>(foodCode),
      'nutrientKey': serializer.toJson<String>(nutrientKey),
      'valuePer100g': serializer.toJson<double>(valuePer100g),
    };
  }

  CiqualNutrient copyWith({
    String? foodCode,
    String? nutrientKey,
    double? valuePer100g,
  }) => CiqualNutrient(
    foodCode: foodCode ?? this.foodCode,
    nutrientKey: nutrientKey ?? this.nutrientKey,
    valuePer100g: valuePer100g ?? this.valuePer100g,
  );
  CiqualNutrient copyWithCompanion(CiqualNutrientsCompanion data) {
    return CiqualNutrient(
      foodCode: data.foodCode.present ? data.foodCode.value : this.foodCode,
      nutrientKey: data.nutrientKey.present
          ? data.nutrientKey.value
          : this.nutrientKey,
      valuePer100g: data.valuePer100g.present
          ? data.valuePer100g.value
          : this.valuePer100g,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CiqualNutrient(')
          ..write('foodCode: $foodCode, ')
          ..write('nutrientKey: $nutrientKey, ')
          ..write('valuePer100g: $valuePer100g')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(foodCode, nutrientKey, valuePer100g);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CiqualNutrient &&
          other.foodCode == this.foodCode &&
          other.nutrientKey == this.nutrientKey &&
          other.valuePer100g == this.valuePer100g);
}

class CiqualNutrientsCompanion extends UpdateCompanion<CiqualNutrient> {
  final Value<String> foodCode;
  final Value<String> nutrientKey;
  final Value<double> valuePer100g;
  final Value<int> rowid;
  const CiqualNutrientsCompanion({
    this.foodCode = const Value.absent(),
    this.nutrientKey = const Value.absent(),
    this.valuePer100g = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CiqualNutrientsCompanion.insert({
    required String foodCode,
    required String nutrientKey,
    required double valuePer100g,
    this.rowid = const Value.absent(),
  }) : foodCode = Value(foodCode),
       nutrientKey = Value(nutrientKey),
       valuePer100g = Value(valuePer100g);
  static Insertable<CiqualNutrient> custom({
    Expression<String>? foodCode,
    Expression<String>? nutrientKey,
    Expression<double>? valuePer100g,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (foodCode != null) 'food_code': foodCode,
      if (nutrientKey != null) 'nutrient_key': nutrientKey,
      if (valuePer100g != null) 'value_per_100g': valuePer100g,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CiqualNutrientsCompanion copyWith({
    Value<String>? foodCode,
    Value<String>? nutrientKey,
    Value<double>? valuePer100g,
    Value<int>? rowid,
  }) {
    return CiqualNutrientsCompanion(
      foodCode: foodCode ?? this.foodCode,
      nutrientKey: nutrientKey ?? this.nutrientKey,
      valuePer100g: valuePer100g ?? this.valuePer100g,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodCode.present) {
      map['food_code'] = Variable<String>(foodCode.value);
    }
    if (nutrientKey.present) {
      map['nutrient_key'] = Variable<String>(nutrientKey.value);
    }
    if (valuePer100g.present) {
      map['value_per_100g'] = Variable<double>(valuePer100g.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CiqualNutrientsCompanion(')
          ..write('foodCode: $foodCode, ')
          ..write('nutrientKey: $nutrientKey, ')
          ..write('valuePer100g: $valuePer100g, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEventsTable extends SyncEvents
    with TableInfo<$SyncEventsTable, SyncEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<String> appliedAt = GeneratedColumn<String>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    appliedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applied_at'],
      ),
    );
  }

  @override
  $SyncEventsTable createAlias(String alias) {
    return $SyncEventsTable(attachedDatabase, alias);
  }
}

class SyncEvent extends DataClass implements Insertable<SyncEvent> {
  final String id;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final String createdAt;
  final String? appliedAt;
  const SyncEvent({
    required this.id,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<String>(appliedAt);
    }
    return map;
  }

  SyncEventsCompanion toCompanion(bool nullToAbsent) {
    return SyncEventsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      appliedAt: appliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedAt),
    );
  }

  factory SyncEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEvent(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      appliedAt: serializer.fromJson<String?>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'appliedAt': serializer.toJson<String?>(appliedAt),
    };
  }

  SyncEvent copyWith({
    String? id,
    String? deviceId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    String? createdAt,
    Value<String?> appliedAt = const Value.absent(),
  }) => SyncEvent(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
  );
  SyncEvent copyWithCompanion(SyncEventsCompanion data) {
    return SyncEvent(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEvent(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    appliedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEvent &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.appliedAt == this.appliedAt);
}

class SyncEventsCompanion extends UpdateCompanion<SyncEvent> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<String> createdAt;
  final Value<String?> appliedAt;
  final Value<int> rowid;
  const SyncEventsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEventsCompanion.insert({
    required String id,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required String createdAt,
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncEvent> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<String>? createdAt,
    Expression<String>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<String>? createdAt,
    Value<String?>? appliedAt,
    Value<int>? rowid,
  }) {
    return SyncEventsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<String>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEventsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientStatesTable extends IngredientStates
    with TableInfo<$IngredientStatesTable, IngredientState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stateIdMeta = const VerificationMeta(
    'stateId',
  );
  @override
  late final GeneratedColumn<String> stateId = GeneratedColumn<String>(
    'ingredient_state_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stateId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_state_id')) {
      context.handle(
        _stateIdMeta,
        stateId.isAcceptableOrUnknown(
          data['ingredient_state_id']!,
          _stateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stateIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stateId};
  @override
  IngredientState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientState(
      stateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_state_id'],
      )!,
    );
  }

  @override
  $IngredientStatesTable createAlias(String alias) {
    return $IngredientStatesTable(attachedDatabase, alias);
  }
}

class IngredientState extends DataClass implements Insertable<IngredientState> {
  final String stateId;
  const IngredientState({required this.stateId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_state_id'] = Variable<String>(stateId);
    return map;
  }

  IngredientStatesCompanion toCompanion(bool nullToAbsent) {
    return IngredientStatesCompanion(stateId: Value(stateId));
  }

  factory IngredientState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientState(
      stateId: serializer.fromJson<String>(json['stateId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'stateId': serializer.toJson<String>(stateId)};
  }

  IngredientState copyWith({String? stateId}) =>
      IngredientState(stateId: stateId ?? this.stateId);
  IngredientState copyWithCompanion(IngredientStatesCompanion data) {
    return IngredientState(
      stateId: data.stateId.present ? data.stateId.value : this.stateId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientState(')
          ..write('stateId: $stateId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => stateId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientState && other.stateId == this.stateId);
}

class IngredientStatesCompanion extends UpdateCompanion<IngredientState> {
  final Value<String> stateId;
  final Value<int> rowid;
  const IngredientStatesCompanion({
    this.stateId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientStatesCompanion.insert({
    required String stateId,
    this.rowid = const Value.absent(),
  }) : stateId = Value(stateId);
  static Insertable<IngredientState> custom({
    Expression<String>? stateId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stateId != null) 'ingredient_state_id': stateId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientStatesCompanion copyWith({
    Value<String>? stateId,
    Value<int>? rowid,
  }) {
    return IngredientStatesCompanion(
      stateId: stateId ?? this.stateId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stateId.present) {
      map['ingredient_state_id'] = Variable<String>(stateId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientStatesCompanion(')
          ..write('stateId: $stateId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionComponentsTable extends NutritionComponents
    with TableInfo<$NutritionComponentsTable, NutritionComponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionComponentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _componentIdMeta = const VerificationMeta(
    'componentId',
  );
  @override
  late final GeneratedColumn<String> componentId = GeneratedColumn<String>(
    'component_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synonymsMeta = const VerificationMeta(
    'synonyms',
  );
  @override
  late final GeneratedColumn<String> synonyms = GeneratedColumn<String>(
    'synonyms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _componentGroupMeta = const VerificationMeta(
    'componentGroup',
  );
  @override
  late final GeneratedColumn<String> componentGroup = GeneratedColumn<String>(
    'component_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canonicalUnitMeta = const VerificationMeta(
    'canonicalUnit',
  );
  @override
  late final GeneratedColumn<String> canonicalUnit = GeneratedColumn<String>(
    'canonical_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _infoodsTagnameMeta = const VerificationMeta(
    'infoodsTagname',
  );
  @override
  late final GeneratedColumn<String> infoodsTagname = GeneratedColumn<String>(
    'infoods_tagname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ciqualComponentIdMeta = const VerificationMeta(
    'ciqualComponentId',
  );
  @override
  late final GeneratedColumn<String> ciqualComponentId =
      GeneratedColumn<String>(
        'ciqual_component_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _usdaNutrientIdMeta = const VerificationMeta(
    'usdaNutrientId',
  );
  @override
  late final GeneratedColumn<String> usdaNutrientId = GeneratedColumn<String>(
    'usda_nutrient_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherIdsMeta = const VerificationMeta(
    'otherIds',
  );
  @override
  late final GeneratedColumn<String> otherIds = GeneratedColumn<String>(
    'other_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversionNotesMeta = const VerificationMeta(
    'conversionNotes',
  );
  @override
  late final GeneratedColumn<String> conversionNotes = GeneratedColumn<String>(
    'conversion_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    componentId,
    canonicalName,
    synonyms,
    componentGroup,
    canonicalUnit,
    infoodsTagname,
    ciqualComponentId,
    usdaNutrientId,
    otherIds,
    definition,
    conversionNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_components';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionComponent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('component_id')) {
      context.handle(
        _componentIdMeta,
        componentId.isAcceptableOrUnknown(
          data['component_id']!,
          _componentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentIdMeta);
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    }
    if (data.containsKey('synonyms')) {
      context.handle(
        _synonymsMeta,
        synonyms.isAcceptableOrUnknown(data['synonyms']!, _synonymsMeta),
      );
    }
    if (data.containsKey('component_group')) {
      context.handle(
        _componentGroupMeta,
        componentGroup.isAcceptableOrUnknown(
          data['component_group']!,
          _componentGroupMeta,
        ),
      );
    }
    if (data.containsKey('canonical_unit')) {
      context.handle(
        _canonicalUnitMeta,
        canonicalUnit.isAcceptableOrUnknown(
          data['canonical_unit']!,
          _canonicalUnitMeta,
        ),
      );
    }
    if (data.containsKey('infoods_tagname')) {
      context.handle(
        _infoodsTagnameMeta,
        infoodsTagname.isAcceptableOrUnknown(
          data['infoods_tagname']!,
          _infoodsTagnameMeta,
        ),
      );
    }
    if (data.containsKey('ciqual_component_id')) {
      context.handle(
        _ciqualComponentIdMeta,
        ciqualComponentId.isAcceptableOrUnknown(
          data['ciqual_component_id']!,
          _ciqualComponentIdMeta,
        ),
      );
    }
    if (data.containsKey('usda_nutrient_id')) {
      context.handle(
        _usdaNutrientIdMeta,
        usdaNutrientId.isAcceptableOrUnknown(
          data['usda_nutrient_id']!,
          _usdaNutrientIdMeta,
        ),
      );
    }
    if (data.containsKey('other_ids')) {
      context.handle(
        _otherIdsMeta,
        otherIds.isAcceptableOrUnknown(data['other_ids']!, _otherIdsMeta),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('conversion_notes')) {
      context.handle(
        _conversionNotesMeta,
        conversionNotes.isAcceptableOrUnknown(
          data['conversion_notes']!,
          _conversionNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {componentId};
  @override
  NutritionComponent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionComponent(
      componentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      ),
      synonyms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonyms'],
      ),
      componentGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_group'],
      ),
      canonicalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_unit'],
      ),
      infoodsTagname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}infoods_tagname'],
      ),
      ciqualComponentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ciqual_component_id'],
      ),
      usdaNutrientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usda_nutrient_id'],
      ),
      otherIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_ids'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      ),
      conversionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversion_notes'],
      ),
    );
  }

  @override
  $NutritionComponentsTable createAlias(String alias) {
    return $NutritionComponentsTable(attachedDatabase, alias);
  }
}

class NutritionComponent extends DataClass
    implements Insertable<NutritionComponent> {
  final String componentId;
  final String? canonicalName;
  final String? synonyms;
  final String? componentGroup;
  final String? canonicalUnit;
  final String? infoodsTagname;
  final String? ciqualComponentId;
  final String? usdaNutrientId;
  final String? otherIds;
  final String? definition;
  final String? conversionNotes;
  const NutritionComponent({
    required this.componentId,
    this.canonicalName,
    this.synonyms,
    this.componentGroup,
    this.canonicalUnit,
    this.infoodsTagname,
    this.ciqualComponentId,
    this.usdaNutrientId,
    this.otherIds,
    this.definition,
    this.conversionNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['component_id'] = Variable<String>(componentId);
    if (!nullToAbsent || canonicalName != null) {
      map['canonical_name'] = Variable<String>(canonicalName);
    }
    if (!nullToAbsent || synonyms != null) {
      map['synonyms'] = Variable<String>(synonyms);
    }
    if (!nullToAbsent || componentGroup != null) {
      map['component_group'] = Variable<String>(componentGroup);
    }
    if (!nullToAbsent || canonicalUnit != null) {
      map['canonical_unit'] = Variable<String>(canonicalUnit);
    }
    if (!nullToAbsent || infoodsTagname != null) {
      map['infoods_tagname'] = Variable<String>(infoodsTagname);
    }
    if (!nullToAbsent || ciqualComponentId != null) {
      map['ciqual_component_id'] = Variable<String>(ciqualComponentId);
    }
    if (!nullToAbsent || usdaNutrientId != null) {
      map['usda_nutrient_id'] = Variable<String>(usdaNutrientId);
    }
    if (!nullToAbsent || otherIds != null) {
      map['other_ids'] = Variable<String>(otherIds);
    }
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || conversionNotes != null) {
      map['conversion_notes'] = Variable<String>(conversionNotes);
    }
    return map;
  }

  NutritionComponentsCompanion toCompanion(bool nullToAbsent) {
    return NutritionComponentsCompanion(
      componentId: Value(componentId),
      canonicalName: canonicalName == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalName),
      synonyms: synonyms == null && nullToAbsent
          ? const Value.absent()
          : Value(synonyms),
      componentGroup: componentGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(componentGroup),
      canonicalUnit: canonicalUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalUnit),
      infoodsTagname: infoodsTagname == null && nullToAbsent
          ? const Value.absent()
          : Value(infoodsTagname),
      ciqualComponentId: ciqualComponentId == null && nullToAbsent
          ? const Value.absent()
          : Value(ciqualComponentId),
      usdaNutrientId: usdaNutrientId == null && nullToAbsent
          ? const Value.absent()
          : Value(usdaNutrientId),
      otherIds: otherIds == null && nullToAbsent
          ? const Value.absent()
          : Value(otherIds),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      conversionNotes: conversionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(conversionNotes),
    );
  }

  factory NutritionComponent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionComponent(
      componentId: serializer.fromJson<String>(json['componentId']),
      canonicalName: serializer.fromJson<String?>(json['canonicalName']),
      synonyms: serializer.fromJson<String?>(json['synonyms']),
      componentGroup: serializer.fromJson<String?>(json['componentGroup']),
      canonicalUnit: serializer.fromJson<String?>(json['canonicalUnit']),
      infoodsTagname: serializer.fromJson<String?>(json['infoodsTagname']),
      ciqualComponentId: serializer.fromJson<String?>(
        json['ciqualComponentId'],
      ),
      usdaNutrientId: serializer.fromJson<String?>(json['usdaNutrientId']),
      otherIds: serializer.fromJson<String?>(json['otherIds']),
      definition: serializer.fromJson<String?>(json['definition']),
      conversionNotes: serializer.fromJson<String?>(json['conversionNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'componentId': serializer.toJson<String>(componentId),
      'canonicalName': serializer.toJson<String?>(canonicalName),
      'synonyms': serializer.toJson<String?>(synonyms),
      'componentGroup': serializer.toJson<String?>(componentGroup),
      'canonicalUnit': serializer.toJson<String?>(canonicalUnit),
      'infoodsTagname': serializer.toJson<String?>(infoodsTagname),
      'ciqualComponentId': serializer.toJson<String?>(ciqualComponentId),
      'usdaNutrientId': serializer.toJson<String?>(usdaNutrientId),
      'otherIds': serializer.toJson<String?>(otherIds),
      'definition': serializer.toJson<String?>(definition),
      'conversionNotes': serializer.toJson<String?>(conversionNotes),
    };
  }

  NutritionComponent copyWith({
    String? componentId,
    Value<String?> canonicalName = const Value.absent(),
    Value<String?> synonyms = const Value.absent(),
    Value<String?> componentGroup = const Value.absent(),
    Value<String?> canonicalUnit = const Value.absent(),
    Value<String?> infoodsTagname = const Value.absent(),
    Value<String?> ciqualComponentId = const Value.absent(),
    Value<String?> usdaNutrientId = const Value.absent(),
    Value<String?> otherIds = const Value.absent(),
    Value<String?> definition = const Value.absent(),
    Value<String?> conversionNotes = const Value.absent(),
  }) => NutritionComponent(
    componentId: componentId ?? this.componentId,
    canonicalName: canonicalName.present
        ? canonicalName.value
        : this.canonicalName,
    synonyms: synonyms.present ? synonyms.value : this.synonyms,
    componentGroup: componentGroup.present
        ? componentGroup.value
        : this.componentGroup,
    canonicalUnit: canonicalUnit.present
        ? canonicalUnit.value
        : this.canonicalUnit,
    infoodsTagname: infoodsTagname.present
        ? infoodsTagname.value
        : this.infoodsTagname,
    ciqualComponentId: ciqualComponentId.present
        ? ciqualComponentId.value
        : this.ciqualComponentId,
    usdaNutrientId: usdaNutrientId.present
        ? usdaNutrientId.value
        : this.usdaNutrientId,
    otherIds: otherIds.present ? otherIds.value : this.otherIds,
    definition: definition.present ? definition.value : this.definition,
    conversionNotes: conversionNotes.present
        ? conversionNotes.value
        : this.conversionNotes,
  );
  NutritionComponent copyWithCompanion(NutritionComponentsCompanion data) {
    return NutritionComponent(
      componentId: data.componentId.present
          ? data.componentId.value
          : this.componentId,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      synonyms: data.synonyms.present ? data.synonyms.value : this.synonyms,
      componentGroup: data.componentGroup.present
          ? data.componentGroup.value
          : this.componentGroup,
      canonicalUnit: data.canonicalUnit.present
          ? data.canonicalUnit.value
          : this.canonicalUnit,
      infoodsTagname: data.infoodsTagname.present
          ? data.infoodsTagname.value
          : this.infoodsTagname,
      ciqualComponentId: data.ciqualComponentId.present
          ? data.ciqualComponentId.value
          : this.ciqualComponentId,
      usdaNutrientId: data.usdaNutrientId.present
          ? data.usdaNutrientId.value
          : this.usdaNutrientId,
      otherIds: data.otherIds.present ? data.otherIds.value : this.otherIds,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      conversionNotes: data.conversionNotes.present
          ? data.conversionNotes.value
          : this.conversionNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionComponent(')
          ..write('componentId: $componentId, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('synonyms: $synonyms, ')
          ..write('componentGroup: $componentGroup, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('infoodsTagname: $infoodsTagname, ')
          ..write('ciqualComponentId: $ciqualComponentId, ')
          ..write('usdaNutrientId: $usdaNutrientId, ')
          ..write('otherIds: $otherIds, ')
          ..write('definition: $definition, ')
          ..write('conversionNotes: $conversionNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    componentId,
    canonicalName,
    synonyms,
    componentGroup,
    canonicalUnit,
    infoodsTagname,
    ciqualComponentId,
    usdaNutrientId,
    otherIds,
    definition,
    conversionNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionComponent &&
          other.componentId == this.componentId &&
          other.canonicalName == this.canonicalName &&
          other.synonyms == this.synonyms &&
          other.componentGroup == this.componentGroup &&
          other.canonicalUnit == this.canonicalUnit &&
          other.infoodsTagname == this.infoodsTagname &&
          other.ciqualComponentId == this.ciqualComponentId &&
          other.usdaNutrientId == this.usdaNutrientId &&
          other.otherIds == this.otherIds &&
          other.definition == this.definition &&
          other.conversionNotes == this.conversionNotes);
}

class NutritionComponentsCompanion extends UpdateCompanion<NutritionComponent> {
  final Value<String> componentId;
  final Value<String?> canonicalName;
  final Value<String?> synonyms;
  final Value<String?> componentGroup;
  final Value<String?> canonicalUnit;
  final Value<String?> infoodsTagname;
  final Value<String?> ciqualComponentId;
  final Value<String?> usdaNutrientId;
  final Value<String?> otherIds;
  final Value<String?> definition;
  final Value<String?> conversionNotes;
  final Value<int> rowid;
  const NutritionComponentsCompanion({
    this.componentId = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.synonyms = const Value.absent(),
    this.componentGroup = const Value.absent(),
    this.canonicalUnit = const Value.absent(),
    this.infoodsTagname = const Value.absent(),
    this.ciqualComponentId = const Value.absent(),
    this.usdaNutrientId = const Value.absent(),
    this.otherIds = const Value.absent(),
    this.definition = const Value.absent(),
    this.conversionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionComponentsCompanion.insert({
    required String componentId,
    this.canonicalName = const Value.absent(),
    this.synonyms = const Value.absent(),
    this.componentGroup = const Value.absent(),
    this.canonicalUnit = const Value.absent(),
    this.infoodsTagname = const Value.absent(),
    this.ciqualComponentId = const Value.absent(),
    this.usdaNutrientId = const Value.absent(),
    this.otherIds = const Value.absent(),
    this.definition = const Value.absent(),
    this.conversionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : componentId = Value(componentId);
  static Insertable<NutritionComponent> custom({
    Expression<String>? componentId,
    Expression<String>? canonicalName,
    Expression<String>? synonyms,
    Expression<String>? componentGroup,
    Expression<String>? canonicalUnit,
    Expression<String>? infoodsTagname,
    Expression<String>? ciqualComponentId,
    Expression<String>? usdaNutrientId,
    Expression<String>? otherIds,
    Expression<String>? definition,
    Expression<String>? conversionNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (componentId != null) 'component_id': componentId,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (synonyms != null) 'synonyms': synonyms,
      if (componentGroup != null) 'component_group': componentGroup,
      if (canonicalUnit != null) 'canonical_unit': canonicalUnit,
      if (infoodsTagname != null) 'infoods_tagname': infoodsTagname,
      if (ciqualComponentId != null) 'ciqual_component_id': ciqualComponentId,
      if (usdaNutrientId != null) 'usda_nutrient_id': usdaNutrientId,
      if (otherIds != null) 'other_ids': otherIds,
      if (definition != null) 'definition': definition,
      if (conversionNotes != null) 'conversion_notes': conversionNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionComponentsCompanion copyWith({
    Value<String>? componentId,
    Value<String?>? canonicalName,
    Value<String?>? synonyms,
    Value<String?>? componentGroup,
    Value<String?>? canonicalUnit,
    Value<String?>? infoodsTagname,
    Value<String?>? ciqualComponentId,
    Value<String?>? usdaNutrientId,
    Value<String?>? otherIds,
    Value<String?>? definition,
    Value<String?>? conversionNotes,
    Value<int>? rowid,
  }) {
    return NutritionComponentsCompanion(
      componentId: componentId ?? this.componentId,
      canonicalName: canonicalName ?? this.canonicalName,
      synonyms: synonyms ?? this.synonyms,
      componentGroup: componentGroup ?? this.componentGroup,
      canonicalUnit: canonicalUnit ?? this.canonicalUnit,
      infoodsTagname: infoodsTagname ?? this.infoodsTagname,
      ciqualComponentId: ciqualComponentId ?? this.ciqualComponentId,
      usdaNutrientId: usdaNutrientId ?? this.usdaNutrientId,
      otherIds: otherIds ?? this.otherIds,
      definition: definition ?? this.definition,
      conversionNotes: conversionNotes ?? this.conversionNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (componentId.present) {
      map['component_id'] = Variable<String>(componentId.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (synonyms.present) {
      map['synonyms'] = Variable<String>(synonyms.value);
    }
    if (componentGroup.present) {
      map['component_group'] = Variable<String>(componentGroup.value);
    }
    if (canonicalUnit.present) {
      map['canonical_unit'] = Variable<String>(canonicalUnit.value);
    }
    if (infoodsTagname.present) {
      map['infoods_tagname'] = Variable<String>(infoodsTagname.value);
    }
    if (ciqualComponentId.present) {
      map['ciqual_component_id'] = Variable<String>(ciqualComponentId.value);
    }
    if (usdaNutrientId.present) {
      map['usda_nutrient_id'] = Variable<String>(usdaNutrientId.value);
    }
    if (otherIds.present) {
      map['other_ids'] = Variable<String>(otherIds.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (conversionNotes.present) {
      map['conversion_notes'] = Variable<String>(conversionNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionComponentsCompanion(')
          ..write('componentId: $componentId, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('synonyms: $synonyms, ')
          ..write('componentGroup: $componentGroup, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('infoodsTagname: $infoodsTagname, ')
          ..write('ciqualComponentId: $ciqualComponentId, ')
          ..write('usdaNutrientId: $usdaNutrientId, ')
          ..write('otherIds: $otherIds, ')
          ..write('definition: $definition, ')
          ..write('conversionNotes: $conversionNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionRecordsTable extends NutritionRecords
    with TableInfo<$NutritionRecordsTable, NutritionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nutritionRecordIdMeta = const VerificationMeta(
    'nutritionRecordId',
  );
  @override
  late final GeneratedColumn<String> nutritionRecordId =
      GeneratedColumn<String>(
        'nutrition_record_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (ingredient_id)',
    ),
  );
  static const VerificationMeta _ingredientStateIdMeta = const VerificationMeta(
    'ingredientStateId',
  );
  @override
  late final GeneratedColumn<String> ingredientStateId =
      GeneratedColumn<String>(
        'ingredient_state_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceFoodIdMeta = const VerificationMeta(
    'sourceFoodId',
  );
  @override
  late final GeneratedColumn<String> sourceFoodId = GeneratedColumn<String>(
    'source_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceFoodNameMeta = const VerificationMeta(
    'sourceFoodName',
  );
  @override
  late final GeneratedColumn<String> sourceFoodName = GeneratedColumn<String>(
    'source_food_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<String> sourceVersion = GeneratedColumn<String>(
    'source_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceCountryMeta = const VerificationMeta(
    'sourceCountry',
  );
  @override
  late final GeneratedColumn<String> sourceCountry = GeneratedColumn<String>(
    'source_country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _componentIdMeta = const VerificationMeta(
    'componentId',
  );
  @override
  late final GeneratedColumn<String> componentId = GeneratedColumn<String>(
    'component_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _componentNameMeta = const VerificationMeta(
    'componentName',
  );
  @override
  late final GeneratedColumn<String> componentName = GeneratedColumn<String>(
    'component_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _componentGroupMeta = const VerificationMeta(
    'componentGroup',
  );
  @override
  late final GeneratedColumn<String> componentGroup = GeneratedColumn<String>(
    'component_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalValueMeta = const VerificationMeta(
    'originalValue',
  );
  @override
  late final GeneratedColumn<double> originalValue = GeneratedColumn<double>(
    'original_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalUnitMeta = const VerificationMeta(
    'originalUnit',
  );
  @override
  late final GeneratedColumn<String> originalUnit = GeneratedColumn<String>(
    'original_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedValueMeta = const VerificationMeta(
    'normalizedValue',
  );
  @override
  late final GeneratedColumn<double> normalizedValue = GeneratedColumn<double>(
    'normalized_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedUnitMeta = const VerificationMeta(
    'normalizedUnit',
  );
  @override
  late final GeneratedColumn<String> normalizedUnit = GeneratedColumn<String>(
    'normalized_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _basisMeta = const VerificationMeta('basis');
  @override
  late final GeneratedColumn<String> basis = GeneratedColumn<String>(
    'basis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueQualifierMeta = const VerificationMeta(
    'valueQualifier',
  );
  @override
  late final GeneratedColumn<String> valueQualifier = GeneratedColumn<String>(
    'value_qualifier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _analyticalMethodMeta = const VerificationMeta(
    'analyticalMethod',
  );
  @override
  late final GeneratedColumn<String> analyticalMethod = GeneratedColumn<String>(
    'analytical_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _derivationMethodMeta = const VerificationMeta(
    'derivationMethod',
  );
  @override
  late final GeneratedColumn<String> derivationMethod = GeneratedColumn<String>(
    'derivation_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataDateMeta = const VerificationMeta(
    'dataDate',
  );
  @override
  late final GeneratedColumn<String> dataDate = GeneratedColumn<String>(
    'data_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retrievalDateMeta = const VerificationMeta(
    'retrievalDate',
  );
  @override
  late final GeneratedColumn<String> retrievalDate = GeneratedColumn<String>(
    'retrieval_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mappingConfidenceMeta = const VerificationMeta(
    'mappingConfidence',
  );
  @override
  late final GeneratedColumn<double> mappingConfidence =
      GeneratedColumn<double>(
        'mapping_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    nutritionRecordId,
    ingredientId,
    ingredientStateId,
    sourceId,
    sourceFoodId,
    sourceFoodName,
    sourceVersion,
    sourceCountry,
    componentId,
    componentName,
    componentGroup,
    originalValue,
    originalUnit,
    normalizedValue,
    normalizedUnit,
    basis,
    valueQualifier,
    valueType,
    minValue,
    maxValue,
    sampleCount,
    analyticalMethod,
    derivationMethod,
    dataDate,
    retrievalDate,
    sourceUrl,
    confidence,
    mappingConfidence,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('nutrition_record_id')) {
      context.handle(
        _nutritionRecordIdMeta,
        nutritionRecordId.isAcceptableOrUnknown(
          data['nutrition_record_id']!,
          _nutritionRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nutritionRecordIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('ingredient_state_id')) {
      context.handle(
        _ingredientStateIdMeta,
        ingredientStateId.isAcceptableOrUnknown(
          data['ingredient_state_id']!,
          _ingredientStateIdMeta,
        ),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('source_food_id')) {
      context.handle(
        _sourceFoodIdMeta,
        sourceFoodId.isAcceptableOrUnknown(
          data['source_food_id']!,
          _sourceFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('source_food_name')) {
      context.handle(
        _sourceFoodNameMeta,
        sourceFoodName.isAcceptableOrUnknown(
          data['source_food_name']!,
          _sourceFoodNameMeta,
        ),
      );
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    }
    if (data.containsKey('source_country')) {
      context.handle(
        _sourceCountryMeta,
        sourceCountry.isAcceptableOrUnknown(
          data['source_country']!,
          _sourceCountryMeta,
        ),
      );
    }
    if (data.containsKey('component_id')) {
      context.handle(
        _componentIdMeta,
        componentId.isAcceptableOrUnknown(
          data['component_id']!,
          _componentIdMeta,
        ),
      );
    }
    if (data.containsKey('component_name')) {
      context.handle(
        _componentNameMeta,
        componentName.isAcceptableOrUnknown(
          data['component_name']!,
          _componentNameMeta,
        ),
      );
    }
    if (data.containsKey('component_group')) {
      context.handle(
        _componentGroupMeta,
        componentGroup.isAcceptableOrUnknown(
          data['component_group']!,
          _componentGroupMeta,
        ),
      );
    }
    if (data.containsKey('original_value')) {
      context.handle(
        _originalValueMeta,
        originalValue.isAcceptableOrUnknown(
          data['original_value']!,
          _originalValueMeta,
        ),
      );
    }
    if (data.containsKey('original_unit')) {
      context.handle(
        _originalUnitMeta,
        originalUnit.isAcceptableOrUnknown(
          data['original_unit']!,
          _originalUnitMeta,
        ),
      );
    }
    if (data.containsKey('normalized_value')) {
      context.handle(
        _normalizedValueMeta,
        normalizedValue.isAcceptableOrUnknown(
          data['normalized_value']!,
          _normalizedValueMeta,
        ),
      );
    }
    if (data.containsKey('normalized_unit')) {
      context.handle(
        _normalizedUnitMeta,
        normalizedUnit.isAcceptableOrUnknown(
          data['normalized_unit']!,
          _normalizedUnitMeta,
        ),
      );
    }
    if (data.containsKey('basis')) {
      context.handle(
        _basisMeta,
        basis.isAcceptableOrUnknown(data['basis']!, _basisMeta),
      );
    }
    if (data.containsKey('value_qualifier')) {
      context.handle(
        _valueQualifierMeta,
        valueQualifier.isAcceptableOrUnknown(
          data['value_qualifier']!,
          _valueQualifierMeta,
        ),
      );
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    }
    if (data.containsKey('analytical_method')) {
      context.handle(
        _analyticalMethodMeta,
        analyticalMethod.isAcceptableOrUnknown(
          data['analytical_method']!,
          _analyticalMethodMeta,
        ),
      );
    }
    if (data.containsKey('derivation_method')) {
      context.handle(
        _derivationMethodMeta,
        derivationMethod.isAcceptableOrUnknown(
          data['derivation_method']!,
          _derivationMethodMeta,
        ),
      );
    }
    if (data.containsKey('data_date')) {
      context.handle(
        _dataDateMeta,
        dataDate.isAcceptableOrUnknown(data['data_date']!, _dataDateMeta),
      );
    }
    if (data.containsKey('retrieval_date')) {
      context.handle(
        _retrievalDateMeta,
        retrievalDate.isAcceptableOrUnknown(
          data['retrieval_date']!,
          _retrievalDateMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('mapping_confidence')) {
      context.handle(
        _mappingConfidenceMeta,
        mappingConfidence.isAcceptableOrUnknown(
          data['mapping_confidence']!,
          _mappingConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nutritionRecordId};
  @override
  NutritionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionRecord(
      nutritionRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutrition_record_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      ingredientStateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_state_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      sourceFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_food_id'],
      ),
      sourceFoodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_food_name'],
      ),
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_version'],
      ),
      sourceCountry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_country'],
      ),
      componentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_id'],
      ),
      componentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_name'],
      ),
      componentGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_group'],
      ),
      originalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_value'],
      ),
      originalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_unit'],
      ),
      normalizedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_value'],
      ),
      normalizedUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_unit'],
      ),
      basis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis'],
      ),
      valueQualifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_qualifier'],
      ),
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      ),
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      ),
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      ),
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      ),
      analyticalMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analytical_method'],
      ),
      derivationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derivation_method'],
      ),
      dataDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_date'],
      ),
      retrievalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retrieval_date'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      mappingConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mapping_confidence'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $NutritionRecordsTable createAlias(String alias) {
    return $NutritionRecordsTable(attachedDatabase, alias);
  }
}

class NutritionRecord extends DataClass implements Insertable<NutritionRecord> {
  final String nutritionRecordId;
  final String ingredientId;
  final String? ingredientStateId;
  final String? sourceId;
  final String? sourceFoodId;
  final String? sourceFoodName;
  final String? sourceVersion;
  final String? sourceCountry;
  final String? componentId;
  final String? componentName;
  final String? componentGroup;
  final double? originalValue;
  final String? originalUnit;
  final double? normalizedValue;
  final String? normalizedUnit;
  final String? basis;
  final String? valueQualifier;
  final String? valueType;
  final double? minValue;
  final double? maxValue;
  final int? sampleCount;
  final String? analyticalMethod;
  final String? derivationMethod;
  final String? dataDate;
  final String? retrievalDate;
  final String? sourceUrl;
  final double? confidence;
  final double? mappingConfidence;
  final String? notes;
  const NutritionRecord({
    required this.nutritionRecordId,
    required this.ingredientId,
    this.ingredientStateId,
    this.sourceId,
    this.sourceFoodId,
    this.sourceFoodName,
    this.sourceVersion,
    this.sourceCountry,
    this.componentId,
    this.componentName,
    this.componentGroup,
    this.originalValue,
    this.originalUnit,
    this.normalizedValue,
    this.normalizedUnit,
    this.basis,
    this.valueQualifier,
    this.valueType,
    this.minValue,
    this.maxValue,
    this.sampleCount,
    this.analyticalMethod,
    this.derivationMethod,
    this.dataDate,
    this.retrievalDate,
    this.sourceUrl,
    this.confidence,
    this.mappingConfidence,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['nutrition_record_id'] = Variable<String>(nutritionRecordId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    if (!nullToAbsent || ingredientStateId != null) {
      map['ingredient_state_id'] = Variable<String>(ingredientStateId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || sourceFoodId != null) {
      map['source_food_id'] = Variable<String>(sourceFoodId);
    }
    if (!nullToAbsent || sourceFoodName != null) {
      map['source_food_name'] = Variable<String>(sourceFoodName);
    }
    if (!nullToAbsent || sourceVersion != null) {
      map['source_version'] = Variable<String>(sourceVersion);
    }
    if (!nullToAbsent || sourceCountry != null) {
      map['source_country'] = Variable<String>(sourceCountry);
    }
    if (!nullToAbsent || componentId != null) {
      map['component_id'] = Variable<String>(componentId);
    }
    if (!nullToAbsent || componentName != null) {
      map['component_name'] = Variable<String>(componentName);
    }
    if (!nullToAbsent || componentGroup != null) {
      map['component_group'] = Variable<String>(componentGroup);
    }
    if (!nullToAbsent || originalValue != null) {
      map['original_value'] = Variable<double>(originalValue);
    }
    if (!nullToAbsent || originalUnit != null) {
      map['original_unit'] = Variable<String>(originalUnit);
    }
    if (!nullToAbsent || normalizedValue != null) {
      map['normalized_value'] = Variable<double>(normalizedValue);
    }
    if (!nullToAbsent || normalizedUnit != null) {
      map['normalized_unit'] = Variable<String>(normalizedUnit);
    }
    if (!nullToAbsent || basis != null) {
      map['basis'] = Variable<String>(basis);
    }
    if (!nullToAbsent || valueQualifier != null) {
      map['value_qualifier'] = Variable<String>(valueQualifier);
    }
    if (!nullToAbsent || valueType != null) {
      map['value_type'] = Variable<String>(valueType);
    }
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<double>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<double>(maxValue);
    }
    if (!nullToAbsent || sampleCount != null) {
      map['sample_count'] = Variable<int>(sampleCount);
    }
    if (!nullToAbsent || analyticalMethod != null) {
      map['analytical_method'] = Variable<String>(analyticalMethod);
    }
    if (!nullToAbsent || derivationMethod != null) {
      map['derivation_method'] = Variable<String>(derivationMethod);
    }
    if (!nullToAbsent || dataDate != null) {
      map['data_date'] = Variable<String>(dataDate);
    }
    if (!nullToAbsent || retrievalDate != null) {
      map['retrieval_date'] = Variable<String>(retrievalDate);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || mappingConfidence != null) {
      map['mapping_confidence'] = Variable<double>(mappingConfidence);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  NutritionRecordsCompanion toCompanion(bool nullToAbsent) {
    return NutritionRecordsCompanion(
      nutritionRecordId: Value(nutritionRecordId),
      ingredientId: Value(ingredientId),
      ingredientStateId: ingredientStateId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientStateId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      sourceFoodId: sourceFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFoodId),
      sourceFoodName: sourceFoodName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFoodName),
      sourceVersion: sourceVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceVersion),
      sourceCountry: sourceCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceCountry),
      componentId: componentId == null && nullToAbsent
          ? const Value.absent()
          : Value(componentId),
      componentName: componentName == null && nullToAbsent
          ? const Value.absent()
          : Value(componentName),
      componentGroup: componentGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(componentGroup),
      originalValue: originalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(originalValue),
      originalUnit: originalUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(originalUnit),
      normalizedValue: normalizedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedValue),
      normalizedUnit: normalizedUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedUnit),
      basis: basis == null && nullToAbsent
          ? const Value.absent()
          : Value(basis),
      valueQualifier: valueQualifier == null && nullToAbsent
          ? const Value.absent()
          : Value(valueQualifier),
      valueType: valueType == null && nullToAbsent
          ? const Value.absent()
          : Value(valueType),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      sampleCount: sampleCount == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleCount),
      analyticalMethod: analyticalMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(analyticalMethod),
      derivationMethod: derivationMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(derivationMethod),
      dataDate: dataDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dataDate),
      retrievalDate: retrievalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retrievalDate),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      mappingConfidence: mappingConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(mappingConfidence),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory NutritionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionRecord(
      nutritionRecordId: serializer.fromJson<String>(json['nutritionRecordId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      ingredientStateId: serializer.fromJson<String?>(
        json['ingredientStateId'],
      ),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      sourceFoodId: serializer.fromJson<String?>(json['sourceFoodId']),
      sourceFoodName: serializer.fromJson<String?>(json['sourceFoodName']),
      sourceVersion: serializer.fromJson<String?>(json['sourceVersion']),
      sourceCountry: serializer.fromJson<String?>(json['sourceCountry']),
      componentId: serializer.fromJson<String?>(json['componentId']),
      componentName: serializer.fromJson<String?>(json['componentName']),
      componentGroup: serializer.fromJson<String?>(json['componentGroup']),
      originalValue: serializer.fromJson<double?>(json['originalValue']),
      originalUnit: serializer.fromJson<String?>(json['originalUnit']),
      normalizedValue: serializer.fromJson<double?>(json['normalizedValue']),
      normalizedUnit: serializer.fromJson<String?>(json['normalizedUnit']),
      basis: serializer.fromJson<String?>(json['basis']),
      valueQualifier: serializer.fromJson<String?>(json['valueQualifier']),
      valueType: serializer.fromJson<String?>(json['valueType']),
      minValue: serializer.fromJson<double?>(json['minValue']),
      maxValue: serializer.fromJson<double?>(json['maxValue']),
      sampleCount: serializer.fromJson<int?>(json['sampleCount']),
      analyticalMethod: serializer.fromJson<String?>(json['analyticalMethod']),
      derivationMethod: serializer.fromJson<String?>(json['derivationMethod']),
      dataDate: serializer.fromJson<String?>(json['dataDate']),
      retrievalDate: serializer.fromJson<String?>(json['retrievalDate']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      mappingConfidence: serializer.fromJson<double?>(
        json['mappingConfidence'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nutritionRecordId': serializer.toJson<String>(nutritionRecordId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'ingredientStateId': serializer.toJson<String?>(ingredientStateId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'sourceFoodId': serializer.toJson<String?>(sourceFoodId),
      'sourceFoodName': serializer.toJson<String?>(sourceFoodName),
      'sourceVersion': serializer.toJson<String?>(sourceVersion),
      'sourceCountry': serializer.toJson<String?>(sourceCountry),
      'componentId': serializer.toJson<String?>(componentId),
      'componentName': serializer.toJson<String?>(componentName),
      'componentGroup': serializer.toJson<String?>(componentGroup),
      'originalValue': serializer.toJson<double?>(originalValue),
      'originalUnit': serializer.toJson<String?>(originalUnit),
      'normalizedValue': serializer.toJson<double?>(normalizedValue),
      'normalizedUnit': serializer.toJson<String?>(normalizedUnit),
      'basis': serializer.toJson<String?>(basis),
      'valueQualifier': serializer.toJson<String?>(valueQualifier),
      'valueType': serializer.toJson<String?>(valueType),
      'minValue': serializer.toJson<double?>(minValue),
      'maxValue': serializer.toJson<double?>(maxValue),
      'sampleCount': serializer.toJson<int?>(sampleCount),
      'analyticalMethod': serializer.toJson<String?>(analyticalMethod),
      'derivationMethod': serializer.toJson<String?>(derivationMethod),
      'dataDate': serializer.toJson<String?>(dataDate),
      'retrievalDate': serializer.toJson<String?>(retrievalDate),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'confidence': serializer.toJson<double?>(confidence),
      'mappingConfidence': serializer.toJson<double?>(mappingConfidence),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  NutritionRecord copyWith({
    String? nutritionRecordId,
    String? ingredientId,
    Value<String?> ingredientStateId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<String?> sourceFoodId = const Value.absent(),
    Value<String?> sourceFoodName = const Value.absent(),
    Value<String?> sourceVersion = const Value.absent(),
    Value<String?> sourceCountry = const Value.absent(),
    Value<String?> componentId = const Value.absent(),
    Value<String?> componentName = const Value.absent(),
    Value<String?> componentGroup = const Value.absent(),
    Value<double?> originalValue = const Value.absent(),
    Value<String?> originalUnit = const Value.absent(),
    Value<double?> normalizedValue = const Value.absent(),
    Value<String?> normalizedUnit = const Value.absent(),
    Value<String?> basis = const Value.absent(),
    Value<String?> valueQualifier = const Value.absent(),
    Value<String?> valueType = const Value.absent(),
    Value<double?> minValue = const Value.absent(),
    Value<double?> maxValue = const Value.absent(),
    Value<int?> sampleCount = const Value.absent(),
    Value<String?> analyticalMethod = const Value.absent(),
    Value<String?> derivationMethod = const Value.absent(),
    Value<String?> dataDate = const Value.absent(),
    Value<String?> retrievalDate = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<double?> mappingConfidence = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => NutritionRecord(
    nutritionRecordId: nutritionRecordId ?? this.nutritionRecordId,
    ingredientId: ingredientId ?? this.ingredientId,
    ingredientStateId: ingredientStateId.present
        ? ingredientStateId.value
        : this.ingredientStateId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    sourceFoodId: sourceFoodId.present ? sourceFoodId.value : this.sourceFoodId,
    sourceFoodName: sourceFoodName.present
        ? sourceFoodName.value
        : this.sourceFoodName,
    sourceVersion: sourceVersion.present
        ? sourceVersion.value
        : this.sourceVersion,
    sourceCountry: sourceCountry.present
        ? sourceCountry.value
        : this.sourceCountry,
    componentId: componentId.present ? componentId.value : this.componentId,
    componentName: componentName.present
        ? componentName.value
        : this.componentName,
    componentGroup: componentGroup.present
        ? componentGroup.value
        : this.componentGroup,
    originalValue: originalValue.present
        ? originalValue.value
        : this.originalValue,
    originalUnit: originalUnit.present ? originalUnit.value : this.originalUnit,
    normalizedValue: normalizedValue.present
        ? normalizedValue.value
        : this.normalizedValue,
    normalizedUnit: normalizedUnit.present
        ? normalizedUnit.value
        : this.normalizedUnit,
    basis: basis.present ? basis.value : this.basis,
    valueQualifier: valueQualifier.present
        ? valueQualifier.value
        : this.valueQualifier,
    valueType: valueType.present ? valueType.value : this.valueType,
    minValue: minValue.present ? minValue.value : this.minValue,
    maxValue: maxValue.present ? maxValue.value : this.maxValue,
    sampleCount: sampleCount.present ? sampleCount.value : this.sampleCount,
    analyticalMethod: analyticalMethod.present
        ? analyticalMethod.value
        : this.analyticalMethod,
    derivationMethod: derivationMethod.present
        ? derivationMethod.value
        : this.derivationMethod,
    dataDate: dataDate.present ? dataDate.value : this.dataDate,
    retrievalDate: retrievalDate.present
        ? retrievalDate.value
        : this.retrievalDate,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    confidence: confidence.present ? confidence.value : this.confidence,
    mappingConfidence: mappingConfidence.present
        ? mappingConfidence.value
        : this.mappingConfidence,
    notes: notes.present ? notes.value : this.notes,
  );
  NutritionRecord copyWithCompanion(NutritionRecordsCompanion data) {
    return NutritionRecord(
      nutritionRecordId: data.nutritionRecordId.present
          ? data.nutritionRecordId.value
          : this.nutritionRecordId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingredientStateId: data.ingredientStateId.present
          ? data.ingredientStateId.value
          : this.ingredientStateId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceFoodId: data.sourceFoodId.present
          ? data.sourceFoodId.value
          : this.sourceFoodId,
      sourceFoodName: data.sourceFoodName.present
          ? data.sourceFoodName.value
          : this.sourceFoodName,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      sourceCountry: data.sourceCountry.present
          ? data.sourceCountry.value
          : this.sourceCountry,
      componentId: data.componentId.present
          ? data.componentId.value
          : this.componentId,
      componentName: data.componentName.present
          ? data.componentName.value
          : this.componentName,
      componentGroup: data.componentGroup.present
          ? data.componentGroup.value
          : this.componentGroup,
      originalValue: data.originalValue.present
          ? data.originalValue.value
          : this.originalValue,
      originalUnit: data.originalUnit.present
          ? data.originalUnit.value
          : this.originalUnit,
      normalizedValue: data.normalizedValue.present
          ? data.normalizedValue.value
          : this.normalizedValue,
      normalizedUnit: data.normalizedUnit.present
          ? data.normalizedUnit.value
          : this.normalizedUnit,
      basis: data.basis.present ? data.basis.value : this.basis,
      valueQualifier: data.valueQualifier.present
          ? data.valueQualifier.value
          : this.valueQualifier,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      analyticalMethod: data.analyticalMethod.present
          ? data.analyticalMethod.value
          : this.analyticalMethod,
      derivationMethod: data.derivationMethod.present
          ? data.derivationMethod.value
          : this.derivationMethod,
      dataDate: data.dataDate.present ? data.dataDate.value : this.dataDate,
      retrievalDate: data.retrievalDate.present
          ? data.retrievalDate.value
          : this.retrievalDate,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      mappingConfidence: data.mappingConfidence.present
          ? data.mappingConfidence.value
          : this.mappingConfidence,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionRecord(')
          ..write('nutritionRecordId: $nutritionRecordId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceFoodId: $sourceFoodId, ')
          ..write('sourceFoodName: $sourceFoodName, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceCountry: $sourceCountry, ')
          ..write('componentId: $componentId, ')
          ..write('componentName: $componentName, ')
          ..write('componentGroup: $componentGroup, ')
          ..write('originalValue: $originalValue, ')
          ..write('originalUnit: $originalUnit, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('normalizedUnit: $normalizedUnit, ')
          ..write('basis: $basis, ')
          ..write('valueQualifier: $valueQualifier, ')
          ..write('valueType: $valueType, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('analyticalMethod: $analyticalMethod, ')
          ..write('derivationMethod: $derivationMethod, ')
          ..write('dataDate: $dataDate, ')
          ..write('retrievalDate: $retrievalDate, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('confidence: $confidence, ')
          ..write('mappingConfidence: $mappingConfidence, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    nutritionRecordId,
    ingredientId,
    ingredientStateId,
    sourceId,
    sourceFoodId,
    sourceFoodName,
    sourceVersion,
    sourceCountry,
    componentId,
    componentName,
    componentGroup,
    originalValue,
    originalUnit,
    normalizedValue,
    normalizedUnit,
    basis,
    valueQualifier,
    valueType,
    minValue,
    maxValue,
    sampleCount,
    analyticalMethod,
    derivationMethod,
    dataDate,
    retrievalDate,
    sourceUrl,
    confidence,
    mappingConfidence,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionRecord &&
          other.nutritionRecordId == this.nutritionRecordId &&
          other.ingredientId == this.ingredientId &&
          other.ingredientStateId == this.ingredientStateId &&
          other.sourceId == this.sourceId &&
          other.sourceFoodId == this.sourceFoodId &&
          other.sourceFoodName == this.sourceFoodName &&
          other.sourceVersion == this.sourceVersion &&
          other.sourceCountry == this.sourceCountry &&
          other.componentId == this.componentId &&
          other.componentName == this.componentName &&
          other.componentGroup == this.componentGroup &&
          other.originalValue == this.originalValue &&
          other.originalUnit == this.originalUnit &&
          other.normalizedValue == this.normalizedValue &&
          other.normalizedUnit == this.normalizedUnit &&
          other.basis == this.basis &&
          other.valueQualifier == this.valueQualifier &&
          other.valueType == this.valueType &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.sampleCount == this.sampleCount &&
          other.analyticalMethod == this.analyticalMethod &&
          other.derivationMethod == this.derivationMethod &&
          other.dataDate == this.dataDate &&
          other.retrievalDate == this.retrievalDate &&
          other.sourceUrl == this.sourceUrl &&
          other.confidence == this.confidence &&
          other.mappingConfidence == this.mappingConfidence &&
          other.notes == this.notes);
}

class NutritionRecordsCompanion extends UpdateCompanion<NutritionRecord> {
  final Value<String> nutritionRecordId;
  final Value<String> ingredientId;
  final Value<String?> ingredientStateId;
  final Value<String?> sourceId;
  final Value<String?> sourceFoodId;
  final Value<String?> sourceFoodName;
  final Value<String?> sourceVersion;
  final Value<String?> sourceCountry;
  final Value<String?> componentId;
  final Value<String?> componentName;
  final Value<String?> componentGroup;
  final Value<double?> originalValue;
  final Value<String?> originalUnit;
  final Value<double?> normalizedValue;
  final Value<String?> normalizedUnit;
  final Value<String?> basis;
  final Value<String?> valueQualifier;
  final Value<String?> valueType;
  final Value<double?> minValue;
  final Value<double?> maxValue;
  final Value<int?> sampleCount;
  final Value<String?> analyticalMethod;
  final Value<String?> derivationMethod;
  final Value<String?> dataDate;
  final Value<String?> retrievalDate;
  final Value<String?> sourceUrl;
  final Value<double?> confidence;
  final Value<double?> mappingConfidence;
  final Value<String?> notes;
  final Value<int> rowid;
  const NutritionRecordsCompanion({
    this.nutritionRecordId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.ingredientStateId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceFoodId = const Value.absent(),
    this.sourceFoodName = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.sourceCountry = const Value.absent(),
    this.componentId = const Value.absent(),
    this.componentName = const Value.absent(),
    this.componentGroup = const Value.absent(),
    this.originalValue = const Value.absent(),
    this.originalUnit = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.normalizedUnit = const Value.absent(),
    this.basis = const Value.absent(),
    this.valueQualifier = const Value.absent(),
    this.valueType = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.analyticalMethod = const Value.absent(),
    this.derivationMethod = const Value.absent(),
    this.dataDate = const Value.absent(),
    this.retrievalDate = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.confidence = const Value.absent(),
    this.mappingConfidence = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionRecordsCompanion.insert({
    required String nutritionRecordId,
    required String ingredientId,
    this.ingredientStateId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceFoodId = const Value.absent(),
    this.sourceFoodName = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.sourceCountry = const Value.absent(),
    this.componentId = const Value.absent(),
    this.componentName = const Value.absent(),
    this.componentGroup = const Value.absent(),
    this.originalValue = const Value.absent(),
    this.originalUnit = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.normalizedUnit = const Value.absent(),
    this.basis = const Value.absent(),
    this.valueQualifier = const Value.absent(),
    this.valueType = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.analyticalMethod = const Value.absent(),
    this.derivationMethod = const Value.absent(),
    this.dataDate = const Value.absent(),
    this.retrievalDate = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.confidence = const Value.absent(),
    this.mappingConfidence = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nutritionRecordId = Value(nutritionRecordId),
       ingredientId = Value(ingredientId);
  static Insertable<NutritionRecord> custom({
    Expression<String>? nutritionRecordId,
    Expression<String>? ingredientId,
    Expression<String>? ingredientStateId,
    Expression<String>? sourceId,
    Expression<String>? sourceFoodId,
    Expression<String>? sourceFoodName,
    Expression<String>? sourceVersion,
    Expression<String>? sourceCountry,
    Expression<String>? componentId,
    Expression<String>? componentName,
    Expression<String>? componentGroup,
    Expression<double>? originalValue,
    Expression<String>? originalUnit,
    Expression<double>? normalizedValue,
    Expression<String>? normalizedUnit,
    Expression<String>? basis,
    Expression<String>? valueQualifier,
    Expression<String>? valueType,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<int>? sampleCount,
    Expression<String>? analyticalMethod,
    Expression<String>? derivationMethod,
    Expression<String>? dataDate,
    Expression<String>? retrievalDate,
    Expression<String>? sourceUrl,
    Expression<double>? confidence,
    Expression<double>? mappingConfidence,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nutritionRecordId != null) 'nutrition_record_id': nutritionRecordId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingredientStateId != null) 'ingredient_state_id': ingredientStateId,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceFoodId != null) 'source_food_id': sourceFoodId,
      if (sourceFoodName != null) 'source_food_name': sourceFoodName,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (sourceCountry != null) 'source_country': sourceCountry,
      if (componentId != null) 'component_id': componentId,
      if (componentName != null) 'component_name': componentName,
      if (componentGroup != null) 'component_group': componentGroup,
      if (originalValue != null) 'original_value': originalValue,
      if (originalUnit != null) 'original_unit': originalUnit,
      if (normalizedValue != null) 'normalized_value': normalizedValue,
      if (normalizedUnit != null) 'normalized_unit': normalizedUnit,
      if (basis != null) 'basis': basis,
      if (valueQualifier != null) 'value_qualifier': valueQualifier,
      if (valueType != null) 'value_type': valueType,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (analyticalMethod != null) 'analytical_method': analyticalMethod,
      if (derivationMethod != null) 'derivation_method': derivationMethod,
      if (dataDate != null) 'data_date': dataDate,
      if (retrievalDate != null) 'retrieval_date': retrievalDate,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (confidence != null) 'confidence': confidence,
      if (mappingConfidence != null) 'mapping_confidence': mappingConfidence,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionRecordsCompanion copyWith({
    Value<String>? nutritionRecordId,
    Value<String>? ingredientId,
    Value<String?>? ingredientStateId,
    Value<String?>? sourceId,
    Value<String?>? sourceFoodId,
    Value<String?>? sourceFoodName,
    Value<String?>? sourceVersion,
    Value<String?>? sourceCountry,
    Value<String?>? componentId,
    Value<String?>? componentName,
    Value<String?>? componentGroup,
    Value<double?>? originalValue,
    Value<String?>? originalUnit,
    Value<double?>? normalizedValue,
    Value<String?>? normalizedUnit,
    Value<String?>? basis,
    Value<String?>? valueQualifier,
    Value<String?>? valueType,
    Value<double?>? minValue,
    Value<double?>? maxValue,
    Value<int?>? sampleCount,
    Value<String?>? analyticalMethod,
    Value<String?>? derivationMethod,
    Value<String?>? dataDate,
    Value<String?>? retrievalDate,
    Value<String?>? sourceUrl,
    Value<double?>? confidence,
    Value<double?>? mappingConfidence,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return NutritionRecordsCompanion(
      nutritionRecordId: nutritionRecordId ?? this.nutritionRecordId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientStateId: ingredientStateId ?? this.ingredientStateId,
      sourceId: sourceId ?? this.sourceId,
      sourceFoodId: sourceFoodId ?? this.sourceFoodId,
      sourceFoodName: sourceFoodName ?? this.sourceFoodName,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      sourceCountry: sourceCountry ?? this.sourceCountry,
      componentId: componentId ?? this.componentId,
      componentName: componentName ?? this.componentName,
      componentGroup: componentGroup ?? this.componentGroup,
      originalValue: originalValue ?? this.originalValue,
      originalUnit: originalUnit ?? this.originalUnit,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      normalizedUnit: normalizedUnit ?? this.normalizedUnit,
      basis: basis ?? this.basis,
      valueQualifier: valueQualifier ?? this.valueQualifier,
      valueType: valueType ?? this.valueType,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      sampleCount: sampleCount ?? this.sampleCount,
      analyticalMethod: analyticalMethod ?? this.analyticalMethod,
      derivationMethod: derivationMethod ?? this.derivationMethod,
      dataDate: dataDate ?? this.dataDate,
      retrievalDate: retrievalDate ?? this.retrievalDate,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      confidence: confidence ?? this.confidence,
      mappingConfidence: mappingConfidence ?? this.mappingConfidence,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nutritionRecordId.present) {
      map['nutrition_record_id'] = Variable<String>(nutritionRecordId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (ingredientStateId.present) {
      map['ingredient_state_id'] = Variable<String>(ingredientStateId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceFoodId.present) {
      map['source_food_id'] = Variable<String>(sourceFoodId.value);
    }
    if (sourceFoodName.present) {
      map['source_food_name'] = Variable<String>(sourceFoodName.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<String>(sourceVersion.value);
    }
    if (sourceCountry.present) {
      map['source_country'] = Variable<String>(sourceCountry.value);
    }
    if (componentId.present) {
      map['component_id'] = Variable<String>(componentId.value);
    }
    if (componentName.present) {
      map['component_name'] = Variable<String>(componentName.value);
    }
    if (componentGroup.present) {
      map['component_group'] = Variable<String>(componentGroup.value);
    }
    if (originalValue.present) {
      map['original_value'] = Variable<double>(originalValue.value);
    }
    if (originalUnit.present) {
      map['original_unit'] = Variable<String>(originalUnit.value);
    }
    if (normalizedValue.present) {
      map['normalized_value'] = Variable<double>(normalizedValue.value);
    }
    if (normalizedUnit.present) {
      map['normalized_unit'] = Variable<String>(normalizedUnit.value);
    }
    if (basis.present) {
      map['basis'] = Variable<String>(basis.value);
    }
    if (valueQualifier.present) {
      map['value_qualifier'] = Variable<String>(valueQualifier.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (analyticalMethod.present) {
      map['analytical_method'] = Variable<String>(analyticalMethod.value);
    }
    if (derivationMethod.present) {
      map['derivation_method'] = Variable<String>(derivationMethod.value);
    }
    if (dataDate.present) {
      map['data_date'] = Variable<String>(dataDate.value);
    }
    if (retrievalDate.present) {
      map['retrieval_date'] = Variable<String>(retrievalDate.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (mappingConfidence.present) {
      map['mapping_confidence'] = Variable<double>(mappingConfidence.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionRecordsCompanion(')
          ..write('nutritionRecordId: $nutritionRecordId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceFoodId: $sourceFoodId, ')
          ..write('sourceFoodName: $sourceFoodName, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceCountry: $sourceCountry, ')
          ..write('componentId: $componentId, ')
          ..write('componentName: $componentName, ')
          ..write('componentGroup: $componentGroup, ')
          ..write('originalValue: $originalValue, ')
          ..write('originalUnit: $originalUnit, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('normalizedUnit: $normalizedUnit, ')
          ..write('basis: $basis, ')
          ..write('valueQualifier: $valueQualifier, ')
          ..write('valueType: $valueType, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('analyticalMethod: $analyticalMethod, ')
          ..write('derivationMethod: $derivationMethod, ')
          ..write('dataDate: $dataDate, ')
          ..write('retrievalDate: $retrievalDate, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('confidence: $confidence, ')
          ..write('mappingConfidence: $mappingConfidence, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientAromaCompoundsTable extends IngredientAromaCompounds
    with TableInfo<$IngredientAromaCompoundsTable, IngredientAromaCompound> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientAromaCompoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (ingredient_id)',
    ),
  );
  static const VerificationMeta _ingredientStateIdMeta = const VerificationMeta(
    'ingredientStateId',
  );
  @override
  late final GeneratedColumn<String> ingredientStateId =
      GeneratedColumn<String>(
        'ingredient_state_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _compoundIdMeta = const VerificationMeta(
    'compoundId',
  );
  @override
  late final GeneratedColumn<String> compoundId = GeneratedColumn<String>(
    'compound_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presenceStatusMeta = const VerificationMeta(
    'presenceStatus',
  );
  @override
  late final GeneratedColumn<String> presenceStatus = GeneratedColumn<String>(
    'presence_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concentrationMeta = const VerificationMeta(
    'concentration',
  );
  @override
  late final GeneratedColumn<double> concentration = GeneratedColumn<double>(
    'concentration',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concentrationUnitMeta = const VerificationMeta(
    'concentrationUnit',
  );
  @override
  late final GeneratedColumn<String> concentrationUnit =
      GeneratedColumn<String>(
        'concentration_unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _concentrationMinMeta = const VerificationMeta(
    'concentrationMin',
  );
  @override
  late final GeneratedColumn<double> concentrationMin = GeneratedColumn<double>(
    'concentration_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concentrationMaxMeta = const VerificationMeta(
    'concentrationMax',
  );
  @override
  late final GeneratedColumn<double> concentrationMax = GeneratedColumn<double>(
    'concentration_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _analyticalMethodMeta = const VerificationMeta(
    'analyticalMethod',
  );
  @override
  late final GeneratedColumn<String> analyticalMethod = GeneratedColumn<String>(
    'analytical_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matrixMeta = const VerificationMeta('matrix');
  @override
  late final GeneratedColumn<String> matrix = GeneratedColumn<String>(
    'matrix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processStateMeta = const VerificationMeta(
    'processState',
  );
  @override
  late final GeneratedColumn<String> processState = GeneratedColumn<String>(
    'process_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceTypeMeta = const VerificationMeta(
    'evidenceType',
  );
  @override
  late final GeneratedColumn<String> evidenceType = GeneratedColumn<String>(
    'evidence_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ingredientId,
    ingredientStateId,
    compoundId,
    presenceStatus,
    concentration,
    concentrationUnit,
    concentrationMin,
    concentrationMax,
    analyticalMethod,
    matrix,
    processState,
    sourceRef,
    evidenceType,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_aroma_compounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientAromaCompound> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('ingredient_state_id')) {
      context.handle(
        _ingredientStateIdMeta,
        ingredientStateId.isAcceptableOrUnknown(
          data['ingredient_state_id']!,
          _ingredientStateIdMeta,
        ),
      );
    }
    if (data.containsKey('compound_id')) {
      context.handle(
        _compoundIdMeta,
        compoundId.isAcceptableOrUnknown(data['compound_id']!, _compoundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compoundIdMeta);
    }
    if (data.containsKey('presence_status')) {
      context.handle(
        _presenceStatusMeta,
        presenceStatus.isAcceptableOrUnknown(
          data['presence_status']!,
          _presenceStatusMeta,
        ),
      );
    }
    if (data.containsKey('concentration')) {
      context.handle(
        _concentrationMeta,
        concentration.isAcceptableOrUnknown(
          data['concentration']!,
          _concentrationMeta,
        ),
      );
    }
    if (data.containsKey('concentration_unit')) {
      context.handle(
        _concentrationUnitMeta,
        concentrationUnit.isAcceptableOrUnknown(
          data['concentration_unit']!,
          _concentrationUnitMeta,
        ),
      );
    }
    if (data.containsKey('concentration_min')) {
      context.handle(
        _concentrationMinMeta,
        concentrationMin.isAcceptableOrUnknown(
          data['concentration_min']!,
          _concentrationMinMeta,
        ),
      );
    }
    if (data.containsKey('concentration_max')) {
      context.handle(
        _concentrationMaxMeta,
        concentrationMax.isAcceptableOrUnknown(
          data['concentration_max']!,
          _concentrationMaxMeta,
        ),
      );
    }
    if (data.containsKey('analytical_method')) {
      context.handle(
        _analyticalMethodMeta,
        analyticalMethod.isAcceptableOrUnknown(
          data['analytical_method']!,
          _analyticalMethodMeta,
        ),
      );
    }
    if (data.containsKey('matrix')) {
      context.handle(
        _matrixMeta,
        matrix.isAcceptableOrUnknown(data['matrix']!, _matrixMeta),
      );
    }
    if (data.containsKey('process_state')) {
      context.handle(
        _processStateMeta,
        processState.isAcceptableOrUnknown(
          data['process_state']!,
          _processStateMeta,
        ),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('evidence_type')) {
      context.handle(
        _evidenceTypeMeta,
        evidenceType.isAcceptableOrUnknown(
          data['evidence_type']!,
          _evidenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    ingredientId,
    ingredientStateId,
    compoundId,
  };
  @override
  IngredientAromaCompound map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientAromaCompound(
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      ingredientStateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_state_id'],
      ),
      compoundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_id'],
      )!,
      presenceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_status'],
      ),
      concentration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentration'],
      ),
      concentrationUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concentration_unit'],
      ),
      concentrationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentration_min'],
      ),
      concentrationMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentration_max'],
      ),
      analyticalMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analytical_method'],
      ),
      matrix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matrix'],
      ),
      processState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_state'],
      ),
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      evidenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_type'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
    );
  }

  @override
  $IngredientAromaCompoundsTable createAlias(String alias) {
    return $IngredientAromaCompoundsTable(attachedDatabase, alias);
  }
}

class IngredientAromaCompound extends DataClass
    implements Insertable<IngredientAromaCompound> {
  final String ingredientId;
  final String? ingredientStateId;
  final String compoundId;
  final String? presenceStatus;
  final double? concentration;
  final String? concentrationUnit;
  final double? concentrationMin;
  final double? concentrationMax;
  final String? analyticalMethod;
  final String? matrix;
  final String? processState;
  final String? sourceRef;
  final String? evidenceType;
  final double? confidence;
  const IngredientAromaCompound({
    required this.ingredientId,
    this.ingredientStateId,
    required this.compoundId,
    this.presenceStatus,
    this.concentration,
    this.concentrationUnit,
    this.concentrationMin,
    this.concentrationMax,
    this.analyticalMethod,
    this.matrix,
    this.processState,
    this.sourceRef,
    this.evidenceType,
    this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_id'] = Variable<String>(ingredientId);
    if (!nullToAbsent || ingredientStateId != null) {
      map['ingredient_state_id'] = Variable<String>(ingredientStateId);
    }
    map['compound_id'] = Variable<String>(compoundId);
    if (!nullToAbsent || presenceStatus != null) {
      map['presence_status'] = Variable<String>(presenceStatus);
    }
    if (!nullToAbsent || concentration != null) {
      map['concentration'] = Variable<double>(concentration);
    }
    if (!nullToAbsent || concentrationUnit != null) {
      map['concentration_unit'] = Variable<String>(concentrationUnit);
    }
    if (!nullToAbsent || concentrationMin != null) {
      map['concentration_min'] = Variable<double>(concentrationMin);
    }
    if (!nullToAbsent || concentrationMax != null) {
      map['concentration_max'] = Variable<double>(concentrationMax);
    }
    if (!nullToAbsent || analyticalMethod != null) {
      map['analytical_method'] = Variable<String>(analyticalMethod);
    }
    if (!nullToAbsent || matrix != null) {
      map['matrix'] = Variable<String>(matrix);
    }
    if (!nullToAbsent || processState != null) {
      map['process_state'] = Variable<String>(processState);
    }
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    if (!nullToAbsent || evidenceType != null) {
      map['evidence_type'] = Variable<String>(evidenceType);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    return map;
  }

  IngredientAromaCompoundsCompanion toCompanion(bool nullToAbsent) {
    return IngredientAromaCompoundsCompanion(
      ingredientId: Value(ingredientId),
      ingredientStateId: ingredientStateId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientStateId),
      compoundId: Value(compoundId),
      presenceStatus: presenceStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(presenceStatus),
      concentration: concentration == null && nullToAbsent
          ? const Value.absent()
          : Value(concentration),
      concentrationUnit: concentrationUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(concentrationUnit),
      concentrationMin: concentrationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(concentrationMin),
      concentrationMax: concentrationMax == null && nullToAbsent
          ? const Value.absent()
          : Value(concentrationMax),
      analyticalMethod: analyticalMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(analyticalMethod),
      matrix: matrix == null && nullToAbsent
          ? const Value.absent()
          : Value(matrix),
      processState: processState == null && nullToAbsent
          ? const Value.absent()
          : Value(processState),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      evidenceType: evidenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceType),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
    );
  }

  factory IngredientAromaCompound.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientAromaCompound(
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      ingredientStateId: serializer.fromJson<String?>(
        json['ingredientStateId'],
      ),
      compoundId: serializer.fromJson<String>(json['compoundId']),
      presenceStatus: serializer.fromJson<String?>(json['presenceStatus']),
      concentration: serializer.fromJson<double?>(json['concentration']),
      concentrationUnit: serializer.fromJson<String?>(
        json['concentrationUnit'],
      ),
      concentrationMin: serializer.fromJson<double?>(json['concentrationMin']),
      concentrationMax: serializer.fromJson<double?>(json['concentrationMax']),
      analyticalMethod: serializer.fromJson<String?>(json['analyticalMethod']),
      matrix: serializer.fromJson<String?>(json['matrix']),
      processState: serializer.fromJson<String?>(json['processState']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      evidenceType: serializer.fromJson<String?>(json['evidenceType']),
      confidence: serializer.fromJson<double?>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredientId': serializer.toJson<String>(ingredientId),
      'ingredientStateId': serializer.toJson<String?>(ingredientStateId),
      'compoundId': serializer.toJson<String>(compoundId),
      'presenceStatus': serializer.toJson<String?>(presenceStatus),
      'concentration': serializer.toJson<double?>(concentration),
      'concentrationUnit': serializer.toJson<String?>(concentrationUnit),
      'concentrationMin': serializer.toJson<double?>(concentrationMin),
      'concentrationMax': serializer.toJson<double?>(concentrationMax),
      'analyticalMethod': serializer.toJson<String?>(analyticalMethod),
      'matrix': serializer.toJson<String?>(matrix),
      'processState': serializer.toJson<String?>(processState),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'evidenceType': serializer.toJson<String?>(evidenceType),
      'confidence': serializer.toJson<double?>(confidence),
    };
  }

  IngredientAromaCompound copyWith({
    String? ingredientId,
    Value<String?> ingredientStateId = const Value.absent(),
    String? compoundId,
    Value<String?> presenceStatus = const Value.absent(),
    Value<double?> concentration = const Value.absent(),
    Value<String?> concentrationUnit = const Value.absent(),
    Value<double?> concentrationMin = const Value.absent(),
    Value<double?> concentrationMax = const Value.absent(),
    Value<String?> analyticalMethod = const Value.absent(),
    Value<String?> matrix = const Value.absent(),
    Value<String?> processState = const Value.absent(),
    Value<String?> sourceRef = const Value.absent(),
    Value<String?> evidenceType = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
  }) => IngredientAromaCompound(
    ingredientId: ingredientId ?? this.ingredientId,
    ingredientStateId: ingredientStateId.present
        ? ingredientStateId.value
        : this.ingredientStateId,
    compoundId: compoundId ?? this.compoundId,
    presenceStatus: presenceStatus.present
        ? presenceStatus.value
        : this.presenceStatus,
    concentration: concentration.present
        ? concentration.value
        : this.concentration,
    concentrationUnit: concentrationUnit.present
        ? concentrationUnit.value
        : this.concentrationUnit,
    concentrationMin: concentrationMin.present
        ? concentrationMin.value
        : this.concentrationMin,
    concentrationMax: concentrationMax.present
        ? concentrationMax.value
        : this.concentrationMax,
    analyticalMethod: analyticalMethod.present
        ? analyticalMethod.value
        : this.analyticalMethod,
    matrix: matrix.present ? matrix.value : this.matrix,
    processState: processState.present ? processState.value : this.processState,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    evidenceType: evidenceType.present ? evidenceType.value : this.evidenceType,
    confidence: confidence.present ? confidence.value : this.confidence,
  );
  IngredientAromaCompound copyWithCompanion(
    IngredientAromaCompoundsCompanion data,
  ) {
    return IngredientAromaCompound(
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingredientStateId: data.ingredientStateId.present
          ? data.ingredientStateId.value
          : this.ingredientStateId,
      compoundId: data.compoundId.present
          ? data.compoundId.value
          : this.compoundId,
      presenceStatus: data.presenceStatus.present
          ? data.presenceStatus.value
          : this.presenceStatus,
      concentration: data.concentration.present
          ? data.concentration.value
          : this.concentration,
      concentrationUnit: data.concentrationUnit.present
          ? data.concentrationUnit.value
          : this.concentrationUnit,
      concentrationMin: data.concentrationMin.present
          ? data.concentrationMin.value
          : this.concentrationMin,
      concentrationMax: data.concentrationMax.present
          ? data.concentrationMax.value
          : this.concentrationMax,
      analyticalMethod: data.analyticalMethod.present
          ? data.analyticalMethod.value
          : this.analyticalMethod,
      matrix: data.matrix.present ? data.matrix.value : this.matrix,
      processState: data.processState.present
          ? data.processState.value
          : this.processState,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      evidenceType: data.evidenceType.present
          ? data.evidenceType.value
          : this.evidenceType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAromaCompound(')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('compoundId: $compoundId, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('concentration: $concentration, ')
          ..write('concentrationUnit: $concentrationUnit, ')
          ..write('concentrationMin: $concentrationMin, ')
          ..write('concentrationMax: $concentrationMax, ')
          ..write('analyticalMethod: $analyticalMethod, ')
          ..write('matrix: $matrix, ')
          ..write('processState: $processState, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ingredientId,
    ingredientStateId,
    compoundId,
    presenceStatus,
    concentration,
    concentrationUnit,
    concentrationMin,
    concentrationMax,
    analyticalMethod,
    matrix,
    processState,
    sourceRef,
    evidenceType,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientAromaCompound &&
          other.ingredientId == this.ingredientId &&
          other.ingredientStateId == this.ingredientStateId &&
          other.compoundId == this.compoundId &&
          other.presenceStatus == this.presenceStatus &&
          other.concentration == this.concentration &&
          other.concentrationUnit == this.concentrationUnit &&
          other.concentrationMin == this.concentrationMin &&
          other.concentrationMax == this.concentrationMax &&
          other.analyticalMethod == this.analyticalMethod &&
          other.matrix == this.matrix &&
          other.processState == this.processState &&
          other.sourceRef == this.sourceRef &&
          other.evidenceType == this.evidenceType &&
          other.confidence == this.confidence);
}

class IngredientAromaCompoundsCompanion
    extends UpdateCompanion<IngredientAromaCompound> {
  final Value<String> ingredientId;
  final Value<String?> ingredientStateId;
  final Value<String> compoundId;
  final Value<String?> presenceStatus;
  final Value<double?> concentration;
  final Value<String?> concentrationUnit;
  final Value<double?> concentrationMin;
  final Value<double?> concentrationMax;
  final Value<String?> analyticalMethod;
  final Value<String?> matrix;
  final Value<String?> processState;
  final Value<String?> sourceRef;
  final Value<String?> evidenceType;
  final Value<double?> confidence;
  final Value<int> rowid;
  const IngredientAromaCompoundsCompanion({
    this.ingredientId = const Value.absent(),
    this.ingredientStateId = const Value.absent(),
    this.compoundId = const Value.absent(),
    this.presenceStatus = const Value.absent(),
    this.concentration = const Value.absent(),
    this.concentrationUnit = const Value.absent(),
    this.concentrationMin = const Value.absent(),
    this.concentrationMax = const Value.absent(),
    this.analyticalMethod = const Value.absent(),
    this.matrix = const Value.absent(),
    this.processState = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientAromaCompoundsCompanion.insert({
    required String ingredientId,
    this.ingredientStateId = const Value.absent(),
    required String compoundId,
    this.presenceStatus = const Value.absent(),
    this.concentration = const Value.absent(),
    this.concentrationUnit = const Value.absent(),
    this.concentrationMin = const Value.absent(),
    this.concentrationMax = const Value.absent(),
    this.analyticalMethod = const Value.absent(),
    this.matrix = const Value.absent(),
    this.processState = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ingredientId = Value(ingredientId),
       compoundId = Value(compoundId);
  static Insertable<IngredientAromaCompound> custom({
    Expression<String>? ingredientId,
    Expression<String>? ingredientStateId,
    Expression<String>? compoundId,
    Expression<String>? presenceStatus,
    Expression<double>? concentration,
    Expression<String>? concentrationUnit,
    Expression<double>? concentrationMin,
    Expression<double>? concentrationMax,
    Expression<String>? analyticalMethod,
    Expression<String>? matrix,
    Expression<String>? processState,
    Expression<String>? sourceRef,
    Expression<String>? evidenceType,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingredientStateId != null) 'ingredient_state_id': ingredientStateId,
      if (compoundId != null) 'compound_id': compoundId,
      if (presenceStatus != null) 'presence_status': presenceStatus,
      if (concentration != null) 'concentration': concentration,
      if (concentrationUnit != null) 'concentration_unit': concentrationUnit,
      if (concentrationMin != null) 'concentration_min': concentrationMin,
      if (concentrationMax != null) 'concentration_max': concentrationMax,
      if (analyticalMethod != null) 'analytical_method': analyticalMethod,
      if (matrix != null) 'matrix': matrix,
      if (processState != null) 'process_state': processState,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (evidenceType != null) 'evidence_type': evidenceType,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientAromaCompoundsCompanion copyWith({
    Value<String>? ingredientId,
    Value<String?>? ingredientStateId,
    Value<String>? compoundId,
    Value<String?>? presenceStatus,
    Value<double?>? concentration,
    Value<String?>? concentrationUnit,
    Value<double?>? concentrationMin,
    Value<double?>? concentrationMax,
    Value<String?>? analyticalMethod,
    Value<String?>? matrix,
    Value<String?>? processState,
    Value<String?>? sourceRef,
    Value<String?>? evidenceType,
    Value<double?>? confidence,
    Value<int>? rowid,
  }) {
    return IngredientAromaCompoundsCompanion(
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientStateId: ingredientStateId ?? this.ingredientStateId,
      compoundId: compoundId ?? this.compoundId,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      concentration: concentration ?? this.concentration,
      concentrationUnit: concentrationUnit ?? this.concentrationUnit,
      concentrationMin: concentrationMin ?? this.concentrationMin,
      concentrationMax: concentrationMax ?? this.concentrationMax,
      analyticalMethod: analyticalMethod ?? this.analyticalMethod,
      matrix: matrix ?? this.matrix,
      processState: processState ?? this.processState,
      sourceRef: sourceRef ?? this.sourceRef,
      evidenceType: evidenceType ?? this.evidenceType,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (ingredientStateId.present) {
      map['ingredient_state_id'] = Variable<String>(ingredientStateId.value);
    }
    if (compoundId.present) {
      map['compound_id'] = Variable<String>(compoundId.value);
    }
    if (presenceStatus.present) {
      map['presence_status'] = Variable<String>(presenceStatus.value);
    }
    if (concentration.present) {
      map['concentration'] = Variable<double>(concentration.value);
    }
    if (concentrationUnit.present) {
      map['concentration_unit'] = Variable<String>(concentrationUnit.value);
    }
    if (concentrationMin.present) {
      map['concentration_min'] = Variable<double>(concentrationMin.value);
    }
    if (concentrationMax.present) {
      map['concentration_max'] = Variable<double>(concentrationMax.value);
    }
    if (analyticalMethod.present) {
      map['analytical_method'] = Variable<String>(analyticalMethod.value);
    }
    if (matrix.present) {
      map['matrix'] = Variable<String>(matrix.value);
    }
    if (processState.present) {
      map['process_state'] = Variable<String>(processState.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (evidenceType.present) {
      map['evidence_type'] = Variable<String>(evidenceType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientAromaCompoundsCompanion(')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('compoundId: $compoundId, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('concentration: $concentration, ')
          ..write('concentrationUnit: $concentrationUnit, ')
          ..write('concentrationMin: $concentrationMin, ')
          ..write('concentrationMax: $concentrationMax, ')
          ..write('analyticalMethod: $analyticalMethod, ')
          ..write('matrix: $matrix, ')
          ..write('processState: $processState, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlavorCompatibilityTable extends FlavorCompatibility
    with TableInfo<$FlavorCompatibilityTable, FlavorCompatibilityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlavorCompatibilityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _combinationSizeMeta = const VerificationMeta(
    'combinationSize',
  );
  @override
  late final GeneratedColumn<int> combinationSize = GeneratedColumn<int>(
    'combination_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientIdsMeta = const VerificationMeta(
    'ingredientIds',
  );
  @override
  late final GeneratedColumn<String> ingredientIds = GeneratedColumn<String>(
    'ingredient_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientNamesMeta = const VerificationMeta(
    'ingredientNames',
  );
  @override
  late final GeneratedColumn<String> ingredientNames = GeneratedColumn<String>(
    'ingredient_names',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processContextMeta = const VerificationMeta(
    'processContext',
  );
  @override
  late final GeneratedColumn<String> processContext = GeneratedColumn<String>(
    'process_context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observedOrPredictedMeta =
      const VerificationMeta('observedOrPredicted');
  @override
  late final GeneratedColumn<String> observedOrPredicted =
      GeneratedColumn<String>(
        'observed_or_predicted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _aromaSimilarityMeta = const VerificationMeta(
    'aromaSimilarity',
  );
  @override
  late final GeneratedColumn<double> aromaSimilarity = GeneratedColumn<double>(
    'aroma_similarity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aromaComplementMeta = const VerificationMeta(
    'aromaComplement',
  );
  @override
  late final GeneratedColumn<double> aromaComplement = GeneratedColumn<double>(
    'aroma_complement',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aromaContrastMeta = const VerificationMeta(
    'aromaContrast',
  );
  @override
  late final GeneratedColumn<double> aromaContrast = GeneratedColumn<double>(
    'aroma_contrast',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tasteBalanceMeta = const VerificationMeta(
    'tasteBalance',
  );
  @override
  late final GeneratedColumn<double> tasteBalance = GeneratedColumn<double>(
    'taste_balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _culinarySupportMeta = const VerificationMeta(
    'culinarySupport',
  );
  @override
  late final GeneratedColumn<double> culinarySupport = GeneratedColumn<double>(
    'culinary_support',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensorySupportMeta = const VerificationMeta(
    'sensorySupport',
  );
  @override
  late final GeneratedColumn<double> sensorySupport = GeneratedColumn<double>(
    'sensory_support',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dominanceRiskMeta = const VerificationMeta(
    'dominanceRisk',
  );
  @override
  late final GeneratedColumn<double> dominanceRisk = GeneratedColumn<double>(
    'dominance_risk',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maskingRiskMeta = const VerificationMeta(
    'maskingRisk',
  );
  @override
  late final GeneratedColumn<double> maskingRisk = GeneratedColumn<double>(
    'masking_risk',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noveltyScoreMeta = const VerificationMeta(
    'noveltyScore',
  );
  @override
  late final GeneratedColumn<double> noveltyScore = GeneratedColumn<double>(
    'novelty_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyCompoundsMeta = const VerificationMeta(
    'keyCompounds',
  );
  @override
  late final GeneratedColumn<String> keyCompounds = GeneratedColumn<String>(
    'key_compounds',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyDescriptorsMeta = const VerificationMeta(
    'keyDescriptors',
  );
  @override
  late final GeneratedColumn<String> keyDescriptors = GeneratedColumn<String>(
    'key_descriptors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bridgeIngredientsMeta = const VerificationMeta(
    'bridgeIngredients',
  );
  @override
  late final GeneratedColumn<String> bridgeIngredients =
      GeneratedColumn<String>(
        'bridge_ingredients',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _evidenceRefsMeta = const VerificationMeta(
    'evidenceRefs',
  );
  @override
  late final GeneratedColumn<String> evidenceRefs = GeneratedColumn<String>(
    'evidence_refs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recordId,
    combinationSize,
    ingredientIds,
    ingredientNames,
    context,
    processContext,
    observedOrPredicted,
    aromaSimilarity,
    aromaComplement,
    aromaContrast,
    tasteBalance,
    culinarySupport,
    sensorySupport,
    dominanceRisk,
    maskingRisk,
    noveltyScore,
    overallScore,
    confidence,
    keyCompounds,
    keyDescriptors,
    bridgeIngredients,
    evidenceRefs,
    modelVersion,
    explanation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flavor_compatibility';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlavorCompatibilityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('combination_size')) {
      context.handle(
        _combinationSizeMeta,
        combinationSize.isAcceptableOrUnknown(
          data['combination_size']!,
          _combinationSizeMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_ids')) {
      context.handle(
        _ingredientIdsMeta,
        ingredientIds.isAcceptableOrUnknown(
          data['ingredient_ids']!,
          _ingredientIdsMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_names')) {
      context.handle(
        _ingredientNamesMeta,
        ingredientNames.isAcceptableOrUnknown(
          data['ingredient_names']!,
          _ingredientNamesMeta,
        ),
      );
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    if (data.containsKey('process_context')) {
      context.handle(
        _processContextMeta,
        processContext.isAcceptableOrUnknown(
          data['process_context']!,
          _processContextMeta,
        ),
      );
    }
    if (data.containsKey('observed_or_predicted')) {
      context.handle(
        _observedOrPredictedMeta,
        observedOrPredicted.isAcceptableOrUnknown(
          data['observed_or_predicted']!,
          _observedOrPredictedMeta,
        ),
      );
    }
    if (data.containsKey('aroma_similarity')) {
      context.handle(
        _aromaSimilarityMeta,
        aromaSimilarity.isAcceptableOrUnknown(
          data['aroma_similarity']!,
          _aromaSimilarityMeta,
        ),
      );
    }
    if (data.containsKey('aroma_complement')) {
      context.handle(
        _aromaComplementMeta,
        aromaComplement.isAcceptableOrUnknown(
          data['aroma_complement']!,
          _aromaComplementMeta,
        ),
      );
    }
    if (data.containsKey('aroma_contrast')) {
      context.handle(
        _aromaContrastMeta,
        aromaContrast.isAcceptableOrUnknown(
          data['aroma_contrast']!,
          _aromaContrastMeta,
        ),
      );
    }
    if (data.containsKey('taste_balance')) {
      context.handle(
        _tasteBalanceMeta,
        tasteBalance.isAcceptableOrUnknown(
          data['taste_balance']!,
          _tasteBalanceMeta,
        ),
      );
    }
    if (data.containsKey('culinary_support')) {
      context.handle(
        _culinarySupportMeta,
        culinarySupport.isAcceptableOrUnknown(
          data['culinary_support']!,
          _culinarySupportMeta,
        ),
      );
    }
    if (data.containsKey('sensory_support')) {
      context.handle(
        _sensorySupportMeta,
        sensorySupport.isAcceptableOrUnknown(
          data['sensory_support']!,
          _sensorySupportMeta,
        ),
      );
    }
    if (data.containsKey('dominance_risk')) {
      context.handle(
        _dominanceRiskMeta,
        dominanceRisk.isAcceptableOrUnknown(
          data['dominance_risk']!,
          _dominanceRiskMeta,
        ),
      );
    }
    if (data.containsKey('masking_risk')) {
      context.handle(
        _maskingRiskMeta,
        maskingRisk.isAcceptableOrUnknown(
          data['masking_risk']!,
          _maskingRiskMeta,
        ),
      );
    }
    if (data.containsKey('novelty_score')) {
      context.handle(
        _noveltyScoreMeta,
        noveltyScore.isAcceptableOrUnknown(
          data['novelty_score']!,
          _noveltyScoreMeta,
        ),
      );
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('key_compounds')) {
      context.handle(
        _keyCompoundsMeta,
        keyCompounds.isAcceptableOrUnknown(
          data['key_compounds']!,
          _keyCompoundsMeta,
        ),
      );
    }
    if (data.containsKey('key_descriptors')) {
      context.handle(
        _keyDescriptorsMeta,
        keyDescriptors.isAcceptableOrUnknown(
          data['key_descriptors']!,
          _keyDescriptorsMeta,
        ),
      );
    }
    if (data.containsKey('bridge_ingredients')) {
      context.handle(
        _bridgeIngredientsMeta,
        bridgeIngredients.isAcceptableOrUnknown(
          data['bridge_ingredients']!,
          _bridgeIngredientsMeta,
        ),
      );
    }
    if (data.containsKey('evidence_refs')) {
      context.handle(
        _evidenceRefsMeta,
        evidenceRefs.isAcceptableOrUnknown(
          data['evidence_refs']!,
          _evidenceRefsMeta,
        ),
      );
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recordId};
  @override
  FlavorCompatibilityData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlavorCompatibilityData(
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      combinationSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}combination_size'],
      ),
      ingredientIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_ids'],
      ),
      ingredientNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_names'],
      ),
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      ),
      processContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_context'],
      ),
      observedOrPredicted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_or_predicted'],
      ),
      aromaSimilarity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aroma_similarity'],
      ),
      aromaComplement: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aroma_complement'],
      ),
      aromaContrast: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aroma_contrast'],
      ),
      tasteBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taste_balance'],
      ),
      culinarySupport: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}culinary_support'],
      ),
      sensorySupport: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensory_support'],
      ),
      dominanceRisk: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dominance_risk'],
      ),
      maskingRisk: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}masking_risk'],
      ),
      noveltyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}novelty_score'],
      ),
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      keyCompounds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_compounds'],
      ),
      keyDescriptors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_descriptors'],
      ),
      bridgeIngredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bridge_ingredients'],
      ),
      evidenceRefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_refs'],
      ),
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
    );
  }

  @override
  $FlavorCompatibilityTable createAlias(String alias) {
    return $FlavorCompatibilityTable(attachedDatabase, alias);
  }
}

class FlavorCompatibilityData extends DataClass
    implements Insertable<FlavorCompatibilityData> {
  final String recordId;
  final int? combinationSize;
  final String? ingredientIds;
  final String? ingredientNames;
  final String? context;
  final String? processContext;
  final String? observedOrPredicted;
  final double? aromaSimilarity;
  final double? aromaComplement;
  final double? aromaContrast;
  final double? tasteBalance;
  final double? culinarySupport;
  final double? sensorySupport;
  final double? dominanceRisk;
  final double? maskingRisk;
  final double? noveltyScore;
  final double? overallScore;
  final double? confidence;
  final String? keyCompounds;
  final String? keyDescriptors;
  final String? bridgeIngredients;
  final String? evidenceRefs;
  final String? modelVersion;
  final String? explanation;
  const FlavorCompatibilityData({
    required this.recordId,
    this.combinationSize,
    this.ingredientIds,
    this.ingredientNames,
    this.context,
    this.processContext,
    this.observedOrPredicted,
    this.aromaSimilarity,
    this.aromaComplement,
    this.aromaContrast,
    this.tasteBalance,
    this.culinarySupport,
    this.sensorySupport,
    this.dominanceRisk,
    this.maskingRisk,
    this.noveltyScore,
    this.overallScore,
    this.confidence,
    this.keyCompounds,
    this.keyDescriptors,
    this.bridgeIngredients,
    this.evidenceRefs,
    this.modelVersion,
    this.explanation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['record_id'] = Variable<String>(recordId);
    if (!nullToAbsent || combinationSize != null) {
      map['combination_size'] = Variable<int>(combinationSize);
    }
    if (!nullToAbsent || ingredientIds != null) {
      map['ingredient_ids'] = Variable<String>(ingredientIds);
    }
    if (!nullToAbsent || ingredientNames != null) {
      map['ingredient_names'] = Variable<String>(ingredientNames);
    }
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<String>(context);
    }
    if (!nullToAbsent || processContext != null) {
      map['process_context'] = Variable<String>(processContext);
    }
    if (!nullToAbsent || observedOrPredicted != null) {
      map['observed_or_predicted'] = Variable<String>(observedOrPredicted);
    }
    if (!nullToAbsent || aromaSimilarity != null) {
      map['aroma_similarity'] = Variable<double>(aromaSimilarity);
    }
    if (!nullToAbsent || aromaComplement != null) {
      map['aroma_complement'] = Variable<double>(aromaComplement);
    }
    if (!nullToAbsent || aromaContrast != null) {
      map['aroma_contrast'] = Variable<double>(aromaContrast);
    }
    if (!nullToAbsent || tasteBalance != null) {
      map['taste_balance'] = Variable<double>(tasteBalance);
    }
    if (!nullToAbsent || culinarySupport != null) {
      map['culinary_support'] = Variable<double>(culinarySupport);
    }
    if (!nullToAbsent || sensorySupport != null) {
      map['sensory_support'] = Variable<double>(sensorySupport);
    }
    if (!nullToAbsent || dominanceRisk != null) {
      map['dominance_risk'] = Variable<double>(dominanceRisk);
    }
    if (!nullToAbsent || maskingRisk != null) {
      map['masking_risk'] = Variable<double>(maskingRisk);
    }
    if (!nullToAbsent || noveltyScore != null) {
      map['novelty_score'] = Variable<double>(noveltyScore);
    }
    if (!nullToAbsent || overallScore != null) {
      map['overall_score'] = Variable<double>(overallScore);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || keyCompounds != null) {
      map['key_compounds'] = Variable<String>(keyCompounds);
    }
    if (!nullToAbsent || keyDescriptors != null) {
      map['key_descriptors'] = Variable<String>(keyDescriptors);
    }
    if (!nullToAbsent || bridgeIngredients != null) {
      map['bridge_ingredients'] = Variable<String>(bridgeIngredients);
    }
    if (!nullToAbsent || evidenceRefs != null) {
      map['evidence_refs'] = Variable<String>(evidenceRefs);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    return map;
  }

  FlavorCompatibilityCompanion toCompanion(bool nullToAbsent) {
    return FlavorCompatibilityCompanion(
      recordId: Value(recordId),
      combinationSize: combinationSize == null && nullToAbsent
          ? const Value.absent()
          : Value(combinationSize),
      ingredientIds: ingredientIds == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientIds),
      ingredientNames: ingredientNames == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientNames),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      processContext: processContext == null && nullToAbsent
          ? const Value.absent()
          : Value(processContext),
      observedOrPredicted: observedOrPredicted == null && nullToAbsent
          ? const Value.absent()
          : Value(observedOrPredicted),
      aromaSimilarity: aromaSimilarity == null && nullToAbsent
          ? const Value.absent()
          : Value(aromaSimilarity),
      aromaComplement: aromaComplement == null && nullToAbsent
          ? const Value.absent()
          : Value(aromaComplement),
      aromaContrast: aromaContrast == null && nullToAbsent
          ? const Value.absent()
          : Value(aromaContrast),
      tasteBalance: tasteBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(tasteBalance),
      culinarySupport: culinarySupport == null && nullToAbsent
          ? const Value.absent()
          : Value(culinarySupport),
      sensorySupport: sensorySupport == null && nullToAbsent
          ? const Value.absent()
          : Value(sensorySupport),
      dominanceRisk: dominanceRisk == null && nullToAbsent
          ? const Value.absent()
          : Value(dominanceRisk),
      maskingRisk: maskingRisk == null && nullToAbsent
          ? const Value.absent()
          : Value(maskingRisk),
      noveltyScore: noveltyScore == null && nullToAbsent
          ? const Value.absent()
          : Value(noveltyScore),
      overallScore: overallScore == null && nullToAbsent
          ? const Value.absent()
          : Value(overallScore),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      keyCompounds: keyCompounds == null && nullToAbsent
          ? const Value.absent()
          : Value(keyCompounds),
      keyDescriptors: keyDescriptors == null && nullToAbsent
          ? const Value.absent()
          : Value(keyDescriptors),
      bridgeIngredients: bridgeIngredients == null && nullToAbsent
          ? const Value.absent()
          : Value(bridgeIngredients),
      evidenceRefs: evidenceRefs == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceRefs),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
    );
  }

  factory FlavorCompatibilityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlavorCompatibilityData(
      recordId: serializer.fromJson<String>(json['recordId']),
      combinationSize: serializer.fromJson<int?>(json['combinationSize']),
      ingredientIds: serializer.fromJson<String?>(json['ingredientIds']),
      ingredientNames: serializer.fromJson<String?>(json['ingredientNames']),
      context: serializer.fromJson<String?>(json['context']),
      processContext: serializer.fromJson<String?>(json['processContext']),
      observedOrPredicted: serializer.fromJson<String?>(
        json['observedOrPredicted'],
      ),
      aromaSimilarity: serializer.fromJson<double?>(json['aromaSimilarity']),
      aromaComplement: serializer.fromJson<double?>(json['aromaComplement']),
      aromaContrast: serializer.fromJson<double?>(json['aromaContrast']),
      tasteBalance: serializer.fromJson<double?>(json['tasteBalance']),
      culinarySupport: serializer.fromJson<double?>(json['culinarySupport']),
      sensorySupport: serializer.fromJson<double?>(json['sensorySupport']),
      dominanceRisk: serializer.fromJson<double?>(json['dominanceRisk']),
      maskingRisk: serializer.fromJson<double?>(json['maskingRisk']),
      noveltyScore: serializer.fromJson<double?>(json['noveltyScore']),
      overallScore: serializer.fromJson<double?>(json['overallScore']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      keyCompounds: serializer.fromJson<String?>(json['keyCompounds']),
      keyDescriptors: serializer.fromJson<String?>(json['keyDescriptors']),
      bridgeIngredients: serializer.fromJson<String?>(
        json['bridgeIngredients'],
      ),
      evidenceRefs: serializer.fromJson<String?>(json['evidenceRefs']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      explanation: serializer.fromJson<String?>(json['explanation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recordId': serializer.toJson<String>(recordId),
      'combinationSize': serializer.toJson<int?>(combinationSize),
      'ingredientIds': serializer.toJson<String?>(ingredientIds),
      'ingredientNames': serializer.toJson<String?>(ingredientNames),
      'context': serializer.toJson<String?>(context),
      'processContext': serializer.toJson<String?>(processContext),
      'observedOrPredicted': serializer.toJson<String?>(observedOrPredicted),
      'aromaSimilarity': serializer.toJson<double?>(aromaSimilarity),
      'aromaComplement': serializer.toJson<double?>(aromaComplement),
      'aromaContrast': serializer.toJson<double?>(aromaContrast),
      'tasteBalance': serializer.toJson<double?>(tasteBalance),
      'culinarySupport': serializer.toJson<double?>(culinarySupport),
      'sensorySupport': serializer.toJson<double?>(sensorySupport),
      'dominanceRisk': serializer.toJson<double?>(dominanceRisk),
      'maskingRisk': serializer.toJson<double?>(maskingRisk),
      'noveltyScore': serializer.toJson<double?>(noveltyScore),
      'overallScore': serializer.toJson<double?>(overallScore),
      'confidence': serializer.toJson<double?>(confidence),
      'keyCompounds': serializer.toJson<String?>(keyCompounds),
      'keyDescriptors': serializer.toJson<String?>(keyDescriptors),
      'bridgeIngredients': serializer.toJson<String?>(bridgeIngredients),
      'evidenceRefs': serializer.toJson<String?>(evidenceRefs),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'explanation': serializer.toJson<String?>(explanation),
    };
  }

  FlavorCompatibilityData copyWith({
    String? recordId,
    Value<int?> combinationSize = const Value.absent(),
    Value<String?> ingredientIds = const Value.absent(),
    Value<String?> ingredientNames = const Value.absent(),
    Value<String?> context = const Value.absent(),
    Value<String?> processContext = const Value.absent(),
    Value<String?> observedOrPredicted = const Value.absent(),
    Value<double?> aromaSimilarity = const Value.absent(),
    Value<double?> aromaComplement = const Value.absent(),
    Value<double?> aromaContrast = const Value.absent(),
    Value<double?> tasteBalance = const Value.absent(),
    Value<double?> culinarySupport = const Value.absent(),
    Value<double?> sensorySupport = const Value.absent(),
    Value<double?> dominanceRisk = const Value.absent(),
    Value<double?> maskingRisk = const Value.absent(),
    Value<double?> noveltyScore = const Value.absent(),
    Value<double?> overallScore = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> keyCompounds = const Value.absent(),
    Value<String?> keyDescriptors = const Value.absent(),
    Value<String?> bridgeIngredients = const Value.absent(),
    Value<String?> evidenceRefs = const Value.absent(),
    Value<String?> modelVersion = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
  }) => FlavorCompatibilityData(
    recordId: recordId ?? this.recordId,
    combinationSize: combinationSize.present
        ? combinationSize.value
        : this.combinationSize,
    ingredientIds: ingredientIds.present
        ? ingredientIds.value
        : this.ingredientIds,
    ingredientNames: ingredientNames.present
        ? ingredientNames.value
        : this.ingredientNames,
    context: context.present ? context.value : this.context,
    processContext: processContext.present
        ? processContext.value
        : this.processContext,
    observedOrPredicted: observedOrPredicted.present
        ? observedOrPredicted.value
        : this.observedOrPredicted,
    aromaSimilarity: aromaSimilarity.present
        ? aromaSimilarity.value
        : this.aromaSimilarity,
    aromaComplement: aromaComplement.present
        ? aromaComplement.value
        : this.aromaComplement,
    aromaContrast: aromaContrast.present
        ? aromaContrast.value
        : this.aromaContrast,
    tasteBalance: tasteBalance.present ? tasteBalance.value : this.tasteBalance,
    culinarySupport: culinarySupport.present
        ? culinarySupport.value
        : this.culinarySupport,
    sensorySupport: sensorySupport.present
        ? sensorySupport.value
        : this.sensorySupport,
    dominanceRisk: dominanceRisk.present
        ? dominanceRisk.value
        : this.dominanceRisk,
    maskingRisk: maskingRisk.present ? maskingRisk.value : this.maskingRisk,
    noveltyScore: noveltyScore.present ? noveltyScore.value : this.noveltyScore,
    overallScore: overallScore.present ? overallScore.value : this.overallScore,
    confidence: confidence.present ? confidence.value : this.confidence,
    keyCompounds: keyCompounds.present ? keyCompounds.value : this.keyCompounds,
    keyDescriptors: keyDescriptors.present
        ? keyDescriptors.value
        : this.keyDescriptors,
    bridgeIngredients: bridgeIngredients.present
        ? bridgeIngredients.value
        : this.bridgeIngredients,
    evidenceRefs: evidenceRefs.present ? evidenceRefs.value : this.evidenceRefs,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
    explanation: explanation.present ? explanation.value : this.explanation,
  );
  FlavorCompatibilityData copyWithCompanion(FlavorCompatibilityCompanion data) {
    return FlavorCompatibilityData(
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      combinationSize: data.combinationSize.present
          ? data.combinationSize.value
          : this.combinationSize,
      ingredientIds: data.ingredientIds.present
          ? data.ingredientIds.value
          : this.ingredientIds,
      ingredientNames: data.ingredientNames.present
          ? data.ingredientNames.value
          : this.ingredientNames,
      context: data.context.present ? data.context.value : this.context,
      processContext: data.processContext.present
          ? data.processContext.value
          : this.processContext,
      observedOrPredicted: data.observedOrPredicted.present
          ? data.observedOrPredicted.value
          : this.observedOrPredicted,
      aromaSimilarity: data.aromaSimilarity.present
          ? data.aromaSimilarity.value
          : this.aromaSimilarity,
      aromaComplement: data.aromaComplement.present
          ? data.aromaComplement.value
          : this.aromaComplement,
      aromaContrast: data.aromaContrast.present
          ? data.aromaContrast.value
          : this.aromaContrast,
      tasteBalance: data.tasteBalance.present
          ? data.tasteBalance.value
          : this.tasteBalance,
      culinarySupport: data.culinarySupport.present
          ? data.culinarySupport.value
          : this.culinarySupport,
      sensorySupport: data.sensorySupport.present
          ? data.sensorySupport.value
          : this.sensorySupport,
      dominanceRisk: data.dominanceRisk.present
          ? data.dominanceRisk.value
          : this.dominanceRisk,
      maskingRisk: data.maskingRisk.present
          ? data.maskingRisk.value
          : this.maskingRisk,
      noveltyScore: data.noveltyScore.present
          ? data.noveltyScore.value
          : this.noveltyScore,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      keyCompounds: data.keyCompounds.present
          ? data.keyCompounds.value
          : this.keyCompounds,
      keyDescriptors: data.keyDescriptors.present
          ? data.keyDescriptors.value
          : this.keyDescriptors,
      bridgeIngredients: data.bridgeIngredients.present
          ? data.bridgeIngredients.value
          : this.bridgeIngredients,
      evidenceRefs: data.evidenceRefs.present
          ? data.evidenceRefs.value
          : this.evidenceRefs,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlavorCompatibilityData(')
          ..write('recordId: $recordId, ')
          ..write('combinationSize: $combinationSize, ')
          ..write('ingredientIds: $ingredientIds, ')
          ..write('ingredientNames: $ingredientNames, ')
          ..write('context: $context, ')
          ..write('processContext: $processContext, ')
          ..write('observedOrPredicted: $observedOrPredicted, ')
          ..write('aromaSimilarity: $aromaSimilarity, ')
          ..write('aromaComplement: $aromaComplement, ')
          ..write('aromaContrast: $aromaContrast, ')
          ..write('tasteBalance: $tasteBalance, ')
          ..write('culinarySupport: $culinarySupport, ')
          ..write('sensorySupport: $sensorySupport, ')
          ..write('dominanceRisk: $dominanceRisk, ')
          ..write('maskingRisk: $maskingRisk, ')
          ..write('noveltyScore: $noveltyScore, ')
          ..write('overallScore: $overallScore, ')
          ..write('confidence: $confidence, ')
          ..write('keyCompounds: $keyCompounds, ')
          ..write('keyDescriptors: $keyDescriptors, ')
          ..write('bridgeIngredients: $bridgeIngredients, ')
          ..write('evidenceRefs: $evidenceRefs, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    recordId,
    combinationSize,
    ingredientIds,
    ingredientNames,
    context,
    processContext,
    observedOrPredicted,
    aromaSimilarity,
    aromaComplement,
    aromaContrast,
    tasteBalance,
    culinarySupport,
    sensorySupport,
    dominanceRisk,
    maskingRisk,
    noveltyScore,
    overallScore,
    confidence,
    keyCompounds,
    keyDescriptors,
    bridgeIngredients,
    evidenceRefs,
    modelVersion,
    explanation,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlavorCompatibilityData &&
          other.recordId == this.recordId &&
          other.combinationSize == this.combinationSize &&
          other.ingredientIds == this.ingredientIds &&
          other.ingredientNames == this.ingredientNames &&
          other.context == this.context &&
          other.processContext == this.processContext &&
          other.observedOrPredicted == this.observedOrPredicted &&
          other.aromaSimilarity == this.aromaSimilarity &&
          other.aromaComplement == this.aromaComplement &&
          other.aromaContrast == this.aromaContrast &&
          other.tasteBalance == this.tasteBalance &&
          other.culinarySupport == this.culinarySupport &&
          other.sensorySupport == this.sensorySupport &&
          other.dominanceRisk == this.dominanceRisk &&
          other.maskingRisk == this.maskingRisk &&
          other.noveltyScore == this.noveltyScore &&
          other.overallScore == this.overallScore &&
          other.confidence == this.confidence &&
          other.keyCompounds == this.keyCompounds &&
          other.keyDescriptors == this.keyDescriptors &&
          other.bridgeIngredients == this.bridgeIngredients &&
          other.evidenceRefs == this.evidenceRefs &&
          other.modelVersion == this.modelVersion &&
          other.explanation == this.explanation);
}

class FlavorCompatibilityCompanion
    extends UpdateCompanion<FlavorCompatibilityData> {
  final Value<String> recordId;
  final Value<int?> combinationSize;
  final Value<String?> ingredientIds;
  final Value<String?> ingredientNames;
  final Value<String?> context;
  final Value<String?> processContext;
  final Value<String?> observedOrPredicted;
  final Value<double?> aromaSimilarity;
  final Value<double?> aromaComplement;
  final Value<double?> aromaContrast;
  final Value<double?> tasteBalance;
  final Value<double?> culinarySupport;
  final Value<double?> sensorySupport;
  final Value<double?> dominanceRisk;
  final Value<double?> maskingRisk;
  final Value<double?> noveltyScore;
  final Value<double?> overallScore;
  final Value<double?> confidence;
  final Value<String?> keyCompounds;
  final Value<String?> keyDescriptors;
  final Value<String?> bridgeIngredients;
  final Value<String?> evidenceRefs;
  final Value<String?> modelVersion;
  final Value<String?> explanation;
  final Value<int> rowid;
  const FlavorCompatibilityCompanion({
    this.recordId = const Value.absent(),
    this.combinationSize = const Value.absent(),
    this.ingredientIds = const Value.absent(),
    this.ingredientNames = const Value.absent(),
    this.context = const Value.absent(),
    this.processContext = const Value.absent(),
    this.observedOrPredicted = const Value.absent(),
    this.aromaSimilarity = const Value.absent(),
    this.aromaComplement = const Value.absent(),
    this.aromaContrast = const Value.absent(),
    this.tasteBalance = const Value.absent(),
    this.culinarySupport = const Value.absent(),
    this.sensorySupport = const Value.absent(),
    this.dominanceRisk = const Value.absent(),
    this.maskingRisk = const Value.absent(),
    this.noveltyScore = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.confidence = const Value.absent(),
    this.keyCompounds = const Value.absent(),
    this.keyDescriptors = const Value.absent(),
    this.bridgeIngredients = const Value.absent(),
    this.evidenceRefs = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.explanation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlavorCompatibilityCompanion.insert({
    required String recordId,
    this.combinationSize = const Value.absent(),
    this.ingredientIds = const Value.absent(),
    this.ingredientNames = const Value.absent(),
    this.context = const Value.absent(),
    this.processContext = const Value.absent(),
    this.observedOrPredicted = const Value.absent(),
    this.aromaSimilarity = const Value.absent(),
    this.aromaComplement = const Value.absent(),
    this.aromaContrast = const Value.absent(),
    this.tasteBalance = const Value.absent(),
    this.culinarySupport = const Value.absent(),
    this.sensorySupport = const Value.absent(),
    this.dominanceRisk = const Value.absent(),
    this.maskingRisk = const Value.absent(),
    this.noveltyScore = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.confidence = const Value.absent(),
    this.keyCompounds = const Value.absent(),
    this.keyDescriptors = const Value.absent(),
    this.bridgeIngredients = const Value.absent(),
    this.evidenceRefs = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.explanation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recordId = Value(recordId);
  static Insertable<FlavorCompatibilityData> custom({
    Expression<String>? recordId,
    Expression<int>? combinationSize,
    Expression<String>? ingredientIds,
    Expression<String>? ingredientNames,
    Expression<String>? context,
    Expression<String>? processContext,
    Expression<String>? observedOrPredicted,
    Expression<double>? aromaSimilarity,
    Expression<double>? aromaComplement,
    Expression<double>? aromaContrast,
    Expression<double>? tasteBalance,
    Expression<double>? culinarySupport,
    Expression<double>? sensorySupport,
    Expression<double>? dominanceRisk,
    Expression<double>? maskingRisk,
    Expression<double>? noveltyScore,
    Expression<double>? overallScore,
    Expression<double>? confidence,
    Expression<String>? keyCompounds,
    Expression<String>? keyDescriptors,
    Expression<String>? bridgeIngredients,
    Expression<String>? evidenceRefs,
    Expression<String>? modelVersion,
    Expression<String>? explanation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recordId != null) 'record_id': recordId,
      if (combinationSize != null) 'combination_size': combinationSize,
      if (ingredientIds != null) 'ingredient_ids': ingredientIds,
      if (ingredientNames != null) 'ingredient_names': ingredientNames,
      if (context != null) 'context': context,
      if (processContext != null) 'process_context': processContext,
      if (observedOrPredicted != null)
        'observed_or_predicted': observedOrPredicted,
      if (aromaSimilarity != null) 'aroma_similarity': aromaSimilarity,
      if (aromaComplement != null) 'aroma_complement': aromaComplement,
      if (aromaContrast != null) 'aroma_contrast': aromaContrast,
      if (tasteBalance != null) 'taste_balance': tasteBalance,
      if (culinarySupport != null) 'culinary_support': culinarySupport,
      if (sensorySupport != null) 'sensory_support': sensorySupport,
      if (dominanceRisk != null) 'dominance_risk': dominanceRisk,
      if (maskingRisk != null) 'masking_risk': maskingRisk,
      if (noveltyScore != null) 'novelty_score': noveltyScore,
      if (overallScore != null) 'overall_score': overallScore,
      if (confidence != null) 'confidence': confidence,
      if (keyCompounds != null) 'key_compounds': keyCompounds,
      if (keyDescriptors != null) 'key_descriptors': keyDescriptors,
      if (bridgeIngredients != null) 'bridge_ingredients': bridgeIngredients,
      if (evidenceRefs != null) 'evidence_refs': evidenceRefs,
      if (modelVersion != null) 'model_version': modelVersion,
      if (explanation != null) 'explanation': explanation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlavorCompatibilityCompanion copyWith({
    Value<String>? recordId,
    Value<int?>? combinationSize,
    Value<String?>? ingredientIds,
    Value<String?>? ingredientNames,
    Value<String?>? context,
    Value<String?>? processContext,
    Value<String?>? observedOrPredicted,
    Value<double?>? aromaSimilarity,
    Value<double?>? aromaComplement,
    Value<double?>? aromaContrast,
    Value<double?>? tasteBalance,
    Value<double?>? culinarySupport,
    Value<double?>? sensorySupport,
    Value<double?>? dominanceRisk,
    Value<double?>? maskingRisk,
    Value<double?>? noveltyScore,
    Value<double?>? overallScore,
    Value<double?>? confidence,
    Value<String?>? keyCompounds,
    Value<String?>? keyDescriptors,
    Value<String?>? bridgeIngredients,
    Value<String?>? evidenceRefs,
    Value<String?>? modelVersion,
    Value<String?>? explanation,
    Value<int>? rowid,
  }) {
    return FlavorCompatibilityCompanion(
      recordId: recordId ?? this.recordId,
      combinationSize: combinationSize ?? this.combinationSize,
      ingredientIds: ingredientIds ?? this.ingredientIds,
      ingredientNames: ingredientNames ?? this.ingredientNames,
      context: context ?? this.context,
      processContext: processContext ?? this.processContext,
      observedOrPredicted: observedOrPredicted ?? this.observedOrPredicted,
      aromaSimilarity: aromaSimilarity ?? this.aromaSimilarity,
      aromaComplement: aromaComplement ?? this.aromaComplement,
      aromaContrast: aromaContrast ?? this.aromaContrast,
      tasteBalance: tasteBalance ?? this.tasteBalance,
      culinarySupport: culinarySupport ?? this.culinarySupport,
      sensorySupport: sensorySupport ?? this.sensorySupport,
      dominanceRisk: dominanceRisk ?? this.dominanceRisk,
      maskingRisk: maskingRisk ?? this.maskingRisk,
      noveltyScore: noveltyScore ?? this.noveltyScore,
      overallScore: overallScore ?? this.overallScore,
      confidence: confidence ?? this.confidence,
      keyCompounds: keyCompounds ?? this.keyCompounds,
      keyDescriptors: keyDescriptors ?? this.keyDescriptors,
      bridgeIngredients: bridgeIngredients ?? this.bridgeIngredients,
      evidenceRefs: evidenceRefs ?? this.evidenceRefs,
      modelVersion: modelVersion ?? this.modelVersion,
      explanation: explanation ?? this.explanation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (combinationSize.present) {
      map['combination_size'] = Variable<int>(combinationSize.value);
    }
    if (ingredientIds.present) {
      map['ingredient_ids'] = Variable<String>(ingredientIds.value);
    }
    if (ingredientNames.present) {
      map['ingredient_names'] = Variable<String>(ingredientNames.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (processContext.present) {
      map['process_context'] = Variable<String>(processContext.value);
    }
    if (observedOrPredicted.present) {
      map['observed_or_predicted'] = Variable<String>(
        observedOrPredicted.value,
      );
    }
    if (aromaSimilarity.present) {
      map['aroma_similarity'] = Variable<double>(aromaSimilarity.value);
    }
    if (aromaComplement.present) {
      map['aroma_complement'] = Variable<double>(aromaComplement.value);
    }
    if (aromaContrast.present) {
      map['aroma_contrast'] = Variable<double>(aromaContrast.value);
    }
    if (tasteBalance.present) {
      map['taste_balance'] = Variable<double>(tasteBalance.value);
    }
    if (culinarySupport.present) {
      map['culinary_support'] = Variable<double>(culinarySupport.value);
    }
    if (sensorySupport.present) {
      map['sensory_support'] = Variable<double>(sensorySupport.value);
    }
    if (dominanceRisk.present) {
      map['dominance_risk'] = Variable<double>(dominanceRisk.value);
    }
    if (maskingRisk.present) {
      map['masking_risk'] = Variable<double>(maskingRisk.value);
    }
    if (noveltyScore.present) {
      map['novelty_score'] = Variable<double>(noveltyScore.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (keyCompounds.present) {
      map['key_compounds'] = Variable<String>(keyCompounds.value);
    }
    if (keyDescriptors.present) {
      map['key_descriptors'] = Variable<String>(keyDescriptors.value);
    }
    if (bridgeIngredients.present) {
      map['bridge_ingredients'] = Variable<String>(bridgeIngredients.value);
    }
    if (evidenceRefs.present) {
      map['evidence_refs'] = Variable<String>(evidenceRefs.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlavorCompatibilityCompanion(')
          ..write('recordId: $recordId, ')
          ..write('combinationSize: $combinationSize, ')
          ..write('ingredientIds: $ingredientIds, ')
          ..write('ingredientNames: $ingredientNames, ')
          ..write('context: $context, ')
          ..write('processContext: $processContext, ')
          ..write('observedOrPredicted: $observedOrPredicted, ')
          ..write('aromaSimilarity: $aromaSimilarity, ')
          ..write('aromaComplement: $aromaComplement, ')
          ..write('aromaContrast: $aromaContrast, ')
          ..write('tasteBalance: $tasteBalance, ')
          ..write('culinarySupport: $culinarySupport, ')
          ..write('sensorySupport: $sensorySupport, ')
          ..write('dominanceRisk: $dominanceRisk, ')
          ..write('maskingRisk: $maskingRisk, ')
          ..write('noveltyScore: $noveltyScore, ')
          ..write('overallScore: $overallScore, ')
          ..write('confidence: $confidence, ')
          ..write('keyCompounds: $keyCompounds, ')
          ..write('keyDescriptors: $keyDescriptors, ')
          ..write('bridgeIngredients: $bridgeIngredients, ')
          ..write('evidenceRefs: $evidenceRefs, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('explanation: $explanation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FunctionalIngredientsTable extends FunctionalIngredients
    with TableInfo<$FunctionalIngredientsTable, FunctionalIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FunctionalIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (ingredient_id)',
    ),
  );
  static const VerificationMeta _ingredientStateIdMeta = const VerificationMeta(
    'ingredientStateId',
  );
  @override
  late final GeneratedColumn<String> ingredientStateId =
      GeneratedColumn<String>(
        'ingredient_state_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _temperatureReferenceCMeta =
      const VerificationMeta('temperatureReferenceC');
  @override
  late final GeneratedColumn<double> temperatureReferenceC =
      GeneratedColumn<double>(
        'temperature_reference_C',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _waterContentMeta = const VerificationMeta(
    'waterContent',
  );
  @override
  late final GeneratedColumn<double> waterContent = GeneratedColumn<double>(
    'water_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatContentMeta = const VerificationMeta(
    'fatContent',
  );
  @override
  late final GeneratedColumn<double> fatContent = GeneratedColumn<double>(
    'fat_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinContentMeta = const VerificationMeta(
    'proteinContent',
  );
  @override
  late final GeneratedColumn<double> proteinContent = GeneratedColumn<double>(
    'protein_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _starchContentMeta = const VerificationMeta(
    'starchContent',
  );
  @override
  late final GeneratedColumn<double> starchContent = GeneratedColumn<double>(
    'starch_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarContentMeta = const VerificationMeta(
    'sugarContent',
  );
  @override
  late final GeneratedColumn<double> sugarContent = GeneratedColumn<double>(
    'sugar_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberContentMeta = const VerificationMeta(
    'fiberContent',
  );
  @override
  late final GeneratedColumn<double> fiberContent = GeneratedColumn<double>(
    'fiber_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pectinContentMeta = const VerificationMeta(
    'pectinContent',
  );
  @override
  late final GeneratedColumn<double> pectinContent = GeneratedColumn<double>(
    'pectin_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alcoholContentMeta = const VerificationMeta(
    'alcoholContent',
  );
  @override
  late final GeneratedColumn<double> alcoholContent = GeneratedColumn<double>(
    'alcohol_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saltContentMeta = const VerificationMeta(
    'saltContent',
  );
  @override
  late final GeneratedColumn<double> saltContent = GeneratedColumn<double>(
    'salt_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mineralContentMeta = const VerificationMeta(
    'mineralContent',
  );
  @override
  late final GeneratedColumn<double> mineralContent = GeneratedColumn<double>(
    'mineral_content',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phMeta = const VerificationMeta('ph');
  @override
  late final GeneratedColumn<double> ph = GeneratedColumn<double>(
    'ph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titratableAcidityMeta = const VerificationMeta(
    'titratableAcidity',
  );
  @override
  late final GeneratedColumn<double> titratableAcidity =
      GeneratedColumn<double>(
        'titratable_acidity',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _waterActivityMeta = const VerificationMeta(
    'waterActivity',
  );
  @override
  late final GeneratedColumn<double> waterActivity = GeneratedColumn<double>(
    'water_activity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brixMeta = const VerificationMeta('brix');
  @override
  late final GeneratedColumn<double> brix = GeneratedColumn<double>(
    'brix',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _densityGPerMlMeta = const VerificationMeta(
    'densityGPerMl',
  );
  @override
  late final GeneratedColumn<double> densityGPerMl = GeneratedColumn<double>(
    'density_g_per_mL',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _particleSizeUmMeta = const VerificationMeta(
    'particleSizeUm',
  );
  @override
  late final GeneratedColumn<double> particleSizeUm = GeneratedColumn<double>(
    'particle_size_um',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _solubilityMeta = const VerificationMeta(
    'solubility',
  );
  @override
  late final GeneratedColumn<String> solubility = GeneratedColumn<String>(
    'solubility',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilHoldingCapacityGGMeta =
      const VerificationMeta('oilHoldingCapacityGG');
  @override
  late final GeneratedColumn<double> oilHoldingCapacityGG =
      GeneratedColumn<double>(
        'oil_holding_capacity_g_g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _waterHoldingCapacityGGMeta =
      const VerificationMeta('waterHoldingCapacityGG');
  @override
  late final GeneratedColumn<double> waterHoldingCapacityGG =
      GeneratedColumn<double>(
        'water_holding_capacity_g_g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _emulsifyingCapacityMeta =
      const VerificationMeta('emulsifyingCapacity');
  @override
  late final GeneratedColumn<String> emulsifyingCapacity =
      GeneratedColumn<String>(
        'emulsifying_capacity',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _foamingCapacityMeta = const VerificationMeta(
    'foamingCapacity',
  );
  @override
  late final GeneratedColumn<String> foamingCapacity = GeneratedColumn<String>(
    'foaming_capacity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gelationCapabilityMeta =
      const VerificationMeta('gelationCapability');
  @override
  late final GeneratedColumn<String> gelationCapability =
      GeneratedColumn<String>(
        'gelation_capability',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _thickeningCapabilityMeta =
      const VerificationMeta('thickeningCapability');
  @override
  late final GeneratedColumn<String> thickeningCapability =
      GeneratedColumn<String>(
        'thickening_capability',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hygroscopicityMeta = const VerificationMeta(
    'hygroscopicity',
  );
  @override
  late final GeneratedColumn<String> hygroscopicity = GeneratedColumn<String>(
    'hygroscopicity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thermalStabilityMeta = const VerificationMeta(
    'thermalStability',
  );
  @override
  late final GeneratedColumn<String> thermalStability = GeneratedColumn<String>(
    'thermal_stability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freezeThawStabilityMeta =
      const VerificationMeta('freezeThawStability');
  @override
  late final GeneratedColumn<String> freezeThawStability =
      GeneratedColumn<String>(
        'freeze_thaw_stability',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _oxidationSensitivityMeta =
      const VerificationMeta('oxidationSensitivity');
  @override
  late final GeneratedColumn<String> oxidationSensitivity =
      GeneratedColumn<String>(
        'oxidation_sensitivity',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceRefsMeta = const VerificationMeta(
    'sourceRefs',
  );
  @override
  late final GeneratedColumn<String> sourceRefs = GeneratedColumn<String>(
    'source_refs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceTypeMeta = const VerificationMeta(
    'evidenceType',
  );
  @override
  late final GeneratedColumn<String> evidenceType = GeneratedColumn<String>(
    'evidence_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validityConditionsMeta =
      const VerificationMeta('validityConditions');
  @override
  late final GeneratedColumn<String> validityConditions =
      GeneratedColumn<String>(
        'validity_conditions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    ingredientId,
    ingredientStateId,
    temperatureReferenceC,
    waterContent,
    fatContent,
    proteinContent,
    starchContent,
    sugarContent,
    fiberContent,
    pectinContent,
    alcoholContent,
    saltContent,
    mineralContent,
    ph,
    titratableAcidity,
    waterActivity,
    brix,
    densityGPerMl,
    particleSizeUm,
    solubility,
    oilHoldingCapacityGG,
    waterHoldingCapacityGG,
    emulsifyingCapacity,
    foamingCapacity,
    gelationCapability,
    thickeningCapability,
    hygroscopicity,
    thermalStability,
    freezeThawStability,
    oxidationSensitivity,
    sourceRefs,
    evidenceType,
    confidence,
    validityConditions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'functional_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<FunctionalIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('ingredient_state_id')) {
      context.handle(
        _ingredientStateIdMeta,
        ingredientStateId.isAcceptableOrUnknown(
          data['ingredient_state_id']!,
          _ingredientStateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientStateIdMeta);
    }
    if (data.containsKey('temperature_reference_C')) {
      context.handle(
        _temperatureReferenceCMeta,
        temperatureReferenceC.isAcceptableOrUnknown(
          data['temperature_reference_C']!,
          _temperatureReferenceCMeta,
        ),
      );
    }
    if (data.containsKey('water_content')) {
      context.handle(
        _waterContentMeta,
        waterContent.isAcceptableOrUnknown(
          data['water_content']!,
          _waterContentMeta,
        ),
      );
    }
    if (data.containsKey('fat_content')) {
      context.handle(
        _fatContentMeta,
        fatContent.isAcceptableOrUnknown(data['fat_content']!, _fatContentMeta),
      );
    }
    if (data.containsKey('protein_content')) {
      context.handle(
        _proteinContentMeta,
        proteinContent.isAcceptableOrUnknown(
          data['protein_content']!,
          _proteinContentMeta,
        ),
      );
    }
    if (data.containsKey('starch_content')) {
      context.handle(
        _starchContentMeta,
        starchContent.isAcceptableOrUnknown(
          data['starch_content']!,
          _starchContentMeta,
        ),
      );
    }
    if (data.containsKey('sugar_content')) {
      context.handle(
        _sugarContentMeta,
        sugarContent.isAcceptableOrUnknown(
          data['sugar_content']!,
          _sugarContentMeta,
        ),
      );
    }
    if (data.containsKey('fiber_content')) {
      context.handle(
        _fiberContentMeta,
        fiberContent.isAcceptableOrUnknown(
          data['fiber_content']!,
          _fiberContentMeta,
        ),
      );
    }
    if (data.containsKey('pectin_content')) {
      context.handle(
        _pectinContentMeta,
        pectinContent.isAcceptableOrUnknown(
          data['pectin_content']!,
          _pectinContentMeta,
        ),
      );
    }
    if (data.containsKey('alcohol_content')) {
      context.handle(
        _alcoholContentMeta,
        alcoholContent.isAcceptableOrUnknown(
          data['alcohol_content']!,
          _alcoholContentMeta,
        ),
      );
    }
    if (data.containsKey('salt_content')) {
      context.handle(
        _saltContentMeta,
        saltContent.isAcceptableOrUnknown(
          data['salt_content']!,
          _saltContentMeta,
        ),
      );
    }
    if (data.containsKey('mineral_content')) {
      context.handle(
        _mineralContentMeta,
        mineralContent.isAcceptableOrUnknown(
          data['mineral_content']!,
          _mineralContentMeta,
        ),
      );
    }
    if (data.containsKey('ph')) {
      context.handle(_phMeta, ph.isAcceptableOrUnknown(data['ph']!, _phMeta));
    }
    if (data.containsKey('titratable_acidity')) {
      context.handle(
        _titratableAcidityMeta,
        titratableAcidity.isAcceptableOrUnknown(
          data['titratable_acidity']!,
          _titratableAcidityMeta,
        ),
      );
    }
    if (data.containsKey('water_activity')) {
      context.handle(
        _waterActivityMeta,
        waterActivity.isAcceptableOrUnknown(
          data['water_activity']!,
          _waterActivityMeta,
        ),
      );
    }
    if (data.containsKey('brix')) {
      context.handle(
        _brixMeta,
        brix.isAcceptableOrUnknown(data['brix']!, _brixMeta),
      );
    }
    if (data.containsKey('density_g_per_mL')) {
      context.handle(
        _densityGPerMlMeta,
        densityGPerMl.isAcceptableOrUnknown(
          data['density_g_per_mL']!,
          _densityGPerMlMeta,
        ),
      );
    }
    if (data.containsKey('particle_size_um')) {
      context.handle(
        _particleSizeUmMeta,
        particleSizeUm.isAcceptableOrUnknown(
          data['particle_size_um']!,
          _particleSizeUmMeta,
        ),
      );
    }
    if (data.containsKey('solubility')) {
      context.handle(
        _solubilityMeta,
        solubility.isAcceptableOrUnknown(data['solubility']!, _solubilityMeta),
      );
    }
    if (data.containsKey('oil_holding_capacity_g_g')) {
      context.handle(
        _oilHoldingCapacityGGMeta,
        oilHoldingCapacityGG.isAcceptableOrUnknown(
          data['oil_holding_capacity_g_g']!,
          _oilHoldingCapacityGGMeta,
        ),
      );
    }
    if (data.containsKey('water_holding_capacity_g_g')) {
      context.handle(
        _waterHoldingCapacityGGMeta,
        waterHoldingCapacityGG.isAcceptableOrUnknown(
          data['water_holding_capacity_g_g']!,
          _waterHoldingCapacityGGMeta,
        ),
      );
    }
    if (data.containsKey('emulsifying_capacity')) {
      context.handle(
        _emulsifyingCapacityMeta,
        emulsifyingCapacity.isAcceptableOrUnknown(
          data['emulsifying_capacity']!,
          _emulsifyingCapacityMeta,
        ),
      );
    }
    if (data.containsKey('foaming_capacity')) {
      context.handle(
        _foamingCapacityMeta,
        foamingCapacity.isAcceptableOrUnknown(
          data['foaming_capacity']!,
          _foamingCapacityMeta,
        ),
      );
    }
    if (data.containsKey('gelation_capability')) {
      context.handle(
        _gelationCapabilityMeta,
        gelationCapability.isAcceptableOrUnknown(
          data['gelation_capability']!,
          _gelationCapabilityMeta,
        ),
      );
    }
    if (data.containsKey('thickening_capability')) {
      context.handle(
        _thickeningCapabilityMeta,
        thickeningCapability.isAcceptableOrUnknown(
          data['thickening_capability']!,
          _thickeningCapabilityMeta,
        ),
      );
    }
    if (data.containsKey('hygroscopicity')) {
      context.handle(
        _hygroscopicityMeta,
        hygroscopicity.isAcceptableOrUnknown(
          data['hygroscopicity']!,
          _hygroscopicityMeta,
        ),
      );
    }
    if (data.containsKey('thermal_stability')) {
      context.handle(
        _thermalStabilityMeta,
        thermalStability.isAcceptableOrUnknown(
          data['thermal_stability']!,
          _thermalStabilityMeta,
        ),
      );
    }
    if (data.containsKey('freeze_thaw_stability')) {
      context.handle(
        _freezeThawStabilityMeta,
        freezeThawStability.isAcceptableOrUnknown(
          data['freeze_thaw_stability']!,
          _freezeThawStabilityMeta,
        ),
      );
    }
    if (data.containsKey('oxidation_sensitivity')) {
      context.handle(
        _oxidationSensitivityMeta,
        oxidationSensitivity.isAcceptableOrUnknown(
          data['oxidation_sensitivity']!,
          _oxidationSensitivityMeta,
        ),
      );
    }
    if (data.containsKey('source_refs')) {
      context.handle(
        _sourceRefsMeta,
        sourceRefs.isAcceptableOrUnknown(data['source_refs']!, _sourceRefsMeta),
      );
    }
    if (data.containsKey('evidence_type')) {
      context.handle(
        _evidenceTypeMeta,
        evidenceType.isAcceptableOrUnknown(
          data['evidence_type']!,
          _evidenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('validity_conditions')) {
      context.handle(
        _validityConditionsMeta,
        validityConditions.isAcceptableOrUnknown(
          data['validity_conditions']!,
          _validityConditionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ingredientId, ingredientStateId};
  @override
  FunctionalIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FunctionalIngredient(
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      ingredientStateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_state_id'],
      )!,
      temperatureReferenceC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_reference_C'],
      ),
      waterContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_content'],
      ),
      fatContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_content'],
      ),
      proteinContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_content'],
      ),
      starchContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}starch_content'],
      ),
      sugarContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar_content'],
      ),
      fiberContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_content'],
      ),
      pectinContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pectin_content'],
      ),
      alcoholContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alcohol_content'],
      ),
      saltContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt_content'],
      ),
      mineralContent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mineral_content'],
      ),
      ph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph'],
      ),
      titratableAcidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}titratable_acidity'],
      ),
      waterActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_activity'],
      ),
      brix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brix'],
      ),
      densityGPerMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}density_g_per_mL'],
      ),
      particleSizeUm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}particle_size_um'],
      ),
      solubility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solubility'],
      ),
      oilHoldingCapacityGG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}oil_holding_capacity_g_g'],
      ),
      waterHoldingCapacityGG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_holding_capacity_g_g'],
      ),
      emulsifyingCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulsifying_capacity'],
      ),
      foamingCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foaming_capacity'],
      ),
      gelationCapability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gelation_capability'],
      ),
      thickeningCapability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thickening_capability'],
      ),
      hygroscopicity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hygroscopicity'],
      ),
      thermalStability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thermal_stability'],
      ),
      freezeThawStability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freeze_thaw_stability'],
      ),
      oxidationSensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oxidation_sensitivity'],
      ),
      sourceRefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_refs'],
      ),
      evidenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_type'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      validityConditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validity_conditions'],
      ),
    );
  }

  @override
  $FunctionalIngredientsTable createAlias(String alias) {
    return $FunctionalIngredientsTable(attachedDatabase, alias);
  }
}

class FunctionalIngredient extends DataClass
    implements Insertable<FunctionalIngredient> {
  final String ingredientId;
  final String ingredientStateId;
  final double? temperatureReferenceC;
  final double? waterContent;
  final double? fatContent;
  final double? proteinContent;
  final double? starchContent;
  final double? sugarContent;
  final double? fiberContent;
  final double? pectinContent;
  final double? alcoholContent;
  final double? saltContent;
  final double? mineralContent;
  final double? ph;
  final double? titratableAcidity;
  final double? waterActivity;
  final double? brix;
  final double? densityGPerMl;
  final double? particleSizeUm;
  final String? solubility;
  final double? oilHoldingCapacityGG;
  final double? waterHoldingCapacityGG;
  final String? emulsifyingCapacity;
  final String? foamingCapacity;
  final String? gelationCapability;
  final String? thickeningCapability;
  final String? hygroscopicity;
  final String? thermalStability;
  final String? freezeThawStability;
  final String? oxidationSensitivity;
  final String? sourceRefs;
  final String? evidenceType;
  final double? confidence;
  final String? validityConditions;
  const FunctionalIngredient({
    required this.ingredientId,
    required this.ingredientStateId,
    this.temperatureReferenceC,
    this.waterContent,
    this.fatContent,
    this.proteinContent,
    this.starchContent,
    this.sugarContent,
    this.fiberContent,
    this.pectinContent,
    this.alcoholContent,
    this.saltContent,
    this.mineralContent,
    this.ph,
    this.titratableAcidity,
    this.waterActivity,
    this.brix,
    this.densityGPerMl,
    this.particleSizeUm,
    this.solubility,
    this.oilHoldingCapacityGG,
    this.waterHoldingCapacityGG,
    this.emulsifyingCapacity,
    this.foamingCapacity,
    this.gelationCapability,
    this.thickeningCapability,
    this.hygroscopicity,
    this.thermalStability,
    this.freezeThawStability,
    this.oxidationSensitivity,
    this.sourceRefs,
    this.evidenceType,
    this.confidence,
    this.validityConditions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['ingredient_state_id'] = Variable<String>(ingredientStateId);
    if (!nullToAbsent || temperatureReferenceC != null) {
      map['temperature_reference_C'] = Variable<double>(temperatureReferenceC);
    }
    if (!nullToAbsent || waterContent != null) {
      map['water_content'] = Variable<double>(waterContent);
    }
    if (!nullToAbsent || fatContent != null) {
      map['fat_content'] = Variable<double>(fatContent);
    }
    if (!nullToAbsent || proteinContent != null) {
      map['protein_content'] = Variable<double>(proteinContent);
    }
    if (!nullToAbsent || starchContent != null) {
      map['starch_content'] = Variable<double>(starchContent);
    }
    if (!nullToAbsent || sugarContent != null) {
      map['sugar_content'] = Variable<double>(sugarContent);
    }
    if (!nullToAbsent || fiberContent != null) {
      map['fiber_content'] = Variable<double>(fiberContent);
    }
    if (!nullToAbsent || pectinContent != null) {
      map['pectin_content'] = Variable<double>(pectinContent);
    }
    if (!nullToAbsent || alcoholContent != null) {
      map['alcohol_content'] = Variable<double>(alcoholContent);
    }
    if (!nullToAbsent || saltContent != null) {
      map['salt_content'] = Variable<double>(saltContent);
    }
    if (!nullToAbsent || mineralContent != null) {
      map['mineral_content'] = Variable<double>(mineralContent);
    }
    if (!nullToAbsent || ph != null) {
      map['ph'] = Variable<double>(ph);
    }
    if (!nullToAbsent || titratableAcidity != null) {
      map['titratable_acidity'] = Variable<double>(titratableAcidity);
    }
    if (!nullToAbsent || waterActivity != null) {
      map['water_activity'] = Variable<double>(waterActivity);
    }
    if (!nullToAbsent || brix != null) {
      map['brix'] = Variable<double>(brix);
    }
    if (!nullToAbsent || densityGPerMl != null) {
      map['density_g_per_mL'] = Variable<double>(densityGPerMl);
    }
    if (!nullToAbsent || particleSizeUm != null) {
      map['particle_size_um'] = Variable<double>(particleSizeUm);
    }
    if (!nullToAbsent || solubility != null) {
      map['solubility'] = Variable<String>(solubility);
    }
    if (!nullToAbsent || oilHoldingCapacityGG != null) {
      map['oil_holding_capacity_g_g'] = Variable<double>(oilHoldingCapacityGG);
    }
    if (!nullToAbsent || waterHoldingCapacityGG != null) {
      map['water_holding_capacity_g_g'] = Variable<double>(
        waterHoldingCapacityGG,
      );
    }
    if (!nullToAbsent || emulsifyingCapacity != null) {
      map['emulsifying_capacity'] = Variable<String>(emulsifyingCapacity);
    }
    if (!nullToAbsent || foamingCapacity != null) {
      map['foaming_capacity'] = Variable<String>(foamingCapacity);
    }
    if (!nullToAbsent || gelationCapability != null) {
      map['gelation_capability'] = Variable<String>(gelationCapability);
    }
    if (!nullToAbsent || thickeningCapability != null) {
      map['thickening_capability'] = Variable<String>(thickeningCapability);
    }
    if (!nullToAbsent || hygroscopicity != null) {
      map['hygroscopicity'] = Variable<String>(hygroscopicity);
    }
    if (!nullToAbsent || thermalStability != null) {
      map['thermal_stability'] = Variable<String>(thermalStability);
    }
    if (!nullToAbsent || freezeThawStability != null) {
      map['freeze_thaw_stability'] = Variable<String>(freezeThawStability);
    }
    if (!nullToAbsent || oxidationSensitivity != null) {
      map['oxidation_sensitivity'] = Variable<String>(oxidationSensitivity);
    }
    if (!nullToAbsent || sourceRefs != null) {
      map['source_refs'] = Variable<String>(sourceRefs);
    }
    if (!nullToAbsent || evidenceType != null) {
      map['evidence_type'] = Variable<String>(evidenceType);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || validityConditions != null) {
      map['validity_conditions'] = Variable<String>(validityConditions);
    }
    return map;
  }

  FunctionalIngredientsCompanion toCompanion(bool nullToAbsent) {
    return FunctionalIngredientsCompanion(
      ingredientId: Value(ingredientId),
      ingredientStateId: Value(ingredientStateId),
      temperatureReferenceC: temperatureReferenceC == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureReferenceC),
      waterContent: waterContent == null && nullToAbsent
          ? const Value.absent()
          : Value(waterContent),
      fatContent: fatContent == null && nullToAbsent
          ? const Value.absent()
          : Value(fatContent),
      proteinContent: proteinContent == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinContent),
      starchContent: starchContent == null && nullToAbsent
          ? const Value.absent()
          : Value(starchContent),
      sugarContent: sugarContent == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarContent),
      fiberContent: fiberContent == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberContent),
      pectinContent: pectinContent == null && nullToAbsent
          ? const Value.absent()
          : Value(pectinContent),
      alcoholContent: alcoholContent == null && nullToAbsent
          ? const Value.absent()
          : Value(alcoholContent),
      saltContent: saltContent == null && nullToAbsent
          ? const Value.absent()
          : Value(saltContent),
      mineralContent: mineralContent == null && nullToAbsent
          ? const Value.absent()
          : Value(mineralContent),
      ph: ph == null && nullToAbsent ? const Value.absent() : Value(ph),
      titratableAcidity: titratableAcidity == null && nullToAbsent
          ? const Value.absent()
          : Value(titratableAcidity),
      waterActivity: waterActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(waterActivity),
      brix: brix == null && nullToAbsent ? const Value.absent() : Value(brix),
      densityGPerMl: densityGPerMl == null && nullToAbsent
          ? const Value.absent()
          : Value(densityGPerMl),
      particleSizeUm: particleSizeUm == null && nullToAbsent
          ? const Value.absent()
          : Value(particleSizeUm),
      solubility: solubility == null && nullToAbsent
          ? const Value.absent()
          : Value(solubility),
      oilHoldingCapacityGG: oilHoldingCapacityGG == null && nullToAbsent
          ? const Value.absent()
          : Value(oilHoldingCapacityGG),
      waterHoldingCapacityGG: waterHoldingCapacityGG == null && nullToAbsent
          ? const Value.absent()
          : Value(waterHoldingCapacityGG),
      emulsifyingCapacity: emulsifyingCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(emulsifyingCapacity),
      foamingCapacity: foamingCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(foamingCapacity),
      gelationCapability: gelationCapability == null && nullToAbsent
          ? const Value.absent()
          : Value(gelationCapability),
      thickeningCapability: thickeningCapability == null && nullToAbsent
          ? const Value.absent()
          : Value(thickeningCapability),
      hygroscopicity: hygroscopicity == null && nullToAbsent
          ? const Value.absent()
          : Value(hygroscopicity),
      thermalStability: thermalStability == null && nullToAbsent
          ? const Value.absent()
          : Value(thermalStability),
      freezeThawStability: freezeThawStability == null && nullToAbsent
          ? const Value.absent()
          : Value(freezeThawStability),
      oxidationSensitivity: oxidationSensitivity == null && nullToAbsent
          ? const Value.absent()
          : Value(oxidationSensitivity),
      sourceRefs: sourceRefs == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRefs),
      evidenceType: evidenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceType),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      validityConditions: validityConditions == null && nullToAbsent
          ? const Value.absent()
          : Value(validityConditions),
    );
  }

  factory FunctionalIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FunctionalIngredient(
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      ingredientStateId: serializer.fromJson<String>(json['ingredientStateId']),
      temperatureReferenceC: serializer.fromJson<double?>(
        json['temperatureReferenceC'],
      ),
      waterContent: serializer.fromJson<double?>(json['waterContent']),
      fatContent: serializer.fromJson<double?>(json['fatContent']),
      proteinContent: serializer.fromJson<double?>(json['proteinContent']),
      starchContent: serializer.fromJson<double?>(json['starchContent']),
      sugarContent: serializer.fromJson<double?>(json['sugarContent']),
      fiberContent: serializer.fromJson<double?>(json['fiberContent']),
      pectinContent: serializer.fromJson<double?>(json['pectinContent']),
      alcoholContent: serializer.fromJson<double?>(json['alcoholContent']),
      saltContent: serializer.fromJson<double?>(json['saltContent']),
      mineralContent: serializer.fromJson<double?>(json['mineralContent']),
      ph: serializer.fromJson<double?>(json['ph']),
      titratableAcidity: serializer.fromJson<double?>(
        json['titratableAcidity'],
      ),
      waterActivity: serializer.fromJson<double?>(json['waterActivity']),
      brix: serializer.fromJson<double?>(json['brix']),
      densityGPerMl: serializer.fromJson<double?>(json['densityGPerMl']),
      particleSizeUm: serializer.fromJson<double?>(json['particleSizeUm']),
      solubility: serializer.fromJson<String?>(json['solubility']),
      oilHoldingCapacityGG: serializer.fromJson<double?>(
        json['oilHoldingCapacityGG'],
      ),
      waterHoldingCapacityGG: serializer.fromJson<double?>(
        json['waterHoldingCapacityGG'],
      ),
      emulsifyingCapacity: serializer.fromJson<String?>(
        json['emulsifyingCapacity'],
      ),
      foamingCapacity: serializer.fromJson<String?>(json['foamingCapacity']),
      gelationCapability: serializer.fromJson<String?>(
        json['gelationCapability'],
      ),
      thickeningCapability: serializer.fromJson<String?>(
        json['thickeningCapability'],
      ),
      hygroscopicity: serializer.fromJson<String?>(json['hygroscopicity']),
      thermalStability: serializer.fromJson<String?>(json['thermalStability']),
      freezeThawStability: serializer.fromJson<String?>(
        json['freezeThawStability'],
      ),
      oxidationSensitivity: serializer.fromJson<String?>(
        json['oxidationSensitivity'],
      ),
      sourceRefs: serializer.fromJson<String?>(json['sourceRefs']),
      evidenceType: serializer.fromJson<String?>(json['evidenceType']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      validityConditions: serializer.fromJson<String?>(
        json['validityConditions'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredientId': serializer.toJson<String>(ingredientId),
      'ingredientStateId': serializer.toJson<String>(ingredientStateId),
      'temperatureReferenceC': serializer.toJson<double?>(
        temperatureReferenceC,
      ),
      'waterContent': serializer.toJson<double?>(waterContent),
      'fatContent': serializer.toJson<double?>(fatContent),
      'proteinContent': serializer.toJson<double?>(proteinContent),
      'starchContent': serializer.toJson<double?>(starchContent),
      'sugarContent': serializer.toJson<double?>(sugarContent),
      'fiberContent': serializer.toJson<double?>(fiberContent),
      'pectinContent': serializer.toJson<double?>(pectinContent),
      'alcoholContent': serializer.toJson<double?>(alcoholContent),
      'saltContent': serializer.toJson<double?>(saltContent),
      'mineralContent': serializer.toJson<double?>(mineralContent),
      'ph': serializer.toJson<double?>(ph),
      'titratableAcidity': serializer.toJson<double?>(titratableAcidity),
      'waterActivity': serializer.toJson<double?>(waterActivity),
      'brix': serializer.toJson<double?>(brix),
      'densityGPerMl': serializer.toJson<double?>(densityGPerMl),
      'particleSizeUm': serializer.toJson<double?>(particleSizeUm),
      'solubility': serializer.toJson<String?>(solubility),
      'oilHoldingCapacityGG': serializer.toJson<double?>(oilHoldingCapacityGG),
      'waterHoldingCapacityGG': serializer.toJson<double?>(
        waterHoldingCapacityGG,
      ),
      'emulsifyingCapacity': serializer.toJson<String?>(emulsifyingCapacity),
      'foamingCapacity': serializer.toJson<String?>(foamingCapacity),
      'gelationCapability': serializer.toJson<String?>(gelationCapability),
      'thickeningCapability': serializer.toJson<String?>(thickeningCapability),
      'hygroscopicity': serializer.toJson<String?>(hygroscopicity),
      'thermalStability': serializer.toJson<String?>(thermalStability),
      'freezeThawStability': serializer.toJson<String?>(freezeThawStability),
      'oxidationSensitivity': serializer.toJson<String?>(oxidationSensitivity),
      'sourceRefs': serializer.toJson<String?>(sourceRefs),
      'evidenceType': serializer.toJson<String?>(evidenceType),
      'confidence': serializer.toJson<double?>(confidence),
      'validityConditions': serializer.toJson<String?>(validityConditions),
    };
  }

  FunctionalIngredient copyWith({
    String? ingredientId,
    String? ingredientStateId,
    Value<double?> temperatureReferenceC = const Value.absent(),
    Value<double?> waterContent = const Value.absent(),
    Value<double?> fatContent = const Value.absent(),
    Value<double?> proteinContent = const Value.absent(),
    Value<double?> starchContent = const Value.absent(),
    Value<double?> sugarContent = const Value.absent(),
    Value<double?> fiberContent = const Value.absent(),
    Value<double?> pectinContent = const Value.absent(),
    Value<double?> alcoholContent = const Value.absent(),
    Value<double?> saltContent = const Value.absent(),
    Value<double?> mineralContent = const Value.absent(),
    Value<double?> ph = const Value.absent(),
    Value<double?> titratableAcidity = const Value.absent(),
    Value<double?> waterActivity = const Value.absent(),
    Value<double?> brix = const Value.absent(),
    Value<double?> densityGPerMl = const Value.absent(),
    Value<double?> particleSizeUm = const Value.absent(),
    Value<String?> solubility = const Value.absent(),
    Value<double?> oilHoldingCapacityGG = const Value.absent(),
    Value<double?> waterHoldingCapacityGG = const Value.absent(),
    Value<String?> emulsifyingCapacity = const Value.absent(),
    Value<String?> foamingCapacity = const Value.absent(),
    Value<String?> gelationCapability = const Value.absent(),
    Value<String?> thickeningCapability = const Value.absent(),
    Value<String?> hygroscopicity = const Value.absent(),
    Value<String?> thermalStability = const Value.absent(),
    Value<String?> freezeThawStability = const Value.absent(),
    Value<String?> oxidationSensitivity = const Value.absent(),
    Value<String?> sourceRefs = const Value.absent(),
    Value<String?> evidenceType = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> validityConditions = const Value.absent(),
  }) => FunctionalIngredient(
    ingredientId: ingredientId ?? this.ingredientId,
    ingredientStateId: ingredientStateId ?? this.ingredientStateId,
    temperatureReferenceC: temperatureReferenceC.present
        ? temperatureReferenceC.value
        : this.temperatureReferenceC,
    waterContent: waterContent.present ? waterContent.value : this.waterContent,
    fatContent: fatContent.present ? fatContent.value : this.fatContent,
    proteinContent: proteinContent.present
        ? proteinContent.value
        : this.proteinContent,
    starchContent: starchContent.present
        ? starchContent.value
        : this.starchContent,
    sugarContent: sugarContent.present ? sugarContent.value : this.sugarContent,
    fiberContent: fiberContent.present ? fiberContent.value : this.fiberContent,
    pectinContent: pectinContent.present
        ? pectinContent.value
        : this.pectinContent,
    alcoholContent: alcoholContent.present
        ? alcoholContent.value
        : this.alcoholContent,
    saltContent: saltContent.present ? saltContent.value : this.saltContent,
    mineralContent: mineralContent.present
        ? mineralContent.value
        : this.mineralContent,
    ph: ph.present ? ph.value : this.ph,
    titratableAcidity: titratableAcidity.present
        ? titratableAcidity.value
        : this.titratableAcidity,
    waterActivity: waterActivity.present
        ? waterActivity.value
        : this.waterActivity,
    brix: brix.present ? brix.value : this.brix,
    densityGPerMl: densityGPerMl.present
        ? densityGPerMl.value
        : this.densityGPerMl,
    particleSizeUm: particleSizeUm.present
        ? particleSizeUm.value
        : this.particleSizeUm,
    solubility: solubility.present ? solubility.value : this.solubility,
    oilHoldingCapacityGG: oilHoldingCapacityGG.present
        ? oilHoldingCapacityGG.value
        : this.oilHoldingCapacityGG,
    waterHoldingCapacityGG: waterHoldingCapacityGG.present
        ? waterHoldingCapacityGG.value
        : this.waterHoldingCapacityGG,
    emulsifyingCapacity: emulsifyingCapacity.present
        ? emulsifyingCapacity.value
        : this.emulsifyingCapacity,
    foamingCapacity: foamingCapacity.present
        ? foamingCapacity.value
        : this.foamingCapacity,
    gelationCapability: gelationCapability.present
        ? gelationCapability.value
        : this.gelationCapability,
    thickeningCapability: thickeningCapability.present
        ? thickeningCapability.value
        : this.thickeningCapability,
    hygroscopicity: hygroscopicity.present
        ? hygroscopicity.value
        : this.hygroscopicity,
    thermalStability: thermalStability.present
        ? thermalStability.value
        : this.thermalStability,
    freezeThawStability: freezeThawStability.present
        ? freezeThawStability.value
        : this.freezeThawStability,
    oxidationSensitivity: oxidationSensitivity.present
        ? oxidationSensitivity.value
        : this.oxidationSensitivity,
    sourceRefs: sourceRefs.present ? sourceRefs.value : this.sourceRefs,
    evidenceType: evidenceType.present ? evidenceType.value : this.evidenceType,
    confidence: confidence.present ? confidence.value : this.confidence,
    validityConditions: validityConditions.present
        ? validityConditions.value
        : this.validityConditions,
  );
  FunctionalIngredient copyWithCompanion(FunctionalIngredientsCompanion data) {
    return FunctionalIngredient(
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingredientStateId: data.ingredientStateId.present
          ? data.ingredientStateId.value
          : this.ingredientStateId,
      temperatureReferenceC: data.temperatureReferenceC.present
          ? data.temperatureReferenceC.value
          : this.temperatureReferenceC,
      waterContent: data.waterContent.present
          ? data.waterContent.value
          : this.waterContent,
      fatContent: data.fatContent.present
          ? data.fatContent.value
          : this.fatContent,
      proteinContent: data.proteinContent.present
          ? data.proteinContent.value
          : this.proteinContent,
      starchContent: data.starchContent.present
          ? data.starchContent.value
          : this.starchContent,
      sugarContent: data.sugarContent.present
          ? data.sugarContent.value
          : this.sugarContent,
      fiberContent: data.fiberContent.present
          ? data.fiberContent.value
          : this.fiberContent,
      pectinContent: data.pectinContent.present
          ? data.pectinContent.value
          : this.pectinContent,
      alcoholContent: data.alcoholContent.present
          ? data.alcoholContent.value
          : this.alcoholContent,
      saltContent: data.saltContent.present
          ? data.saltContent.value
          : this.saltContent,
      mineralContent: data.mineralContent.present
          ? data.mineralContent.value
          : this.mineralContent,
      ph: data.ph.present ? data.ph.value : this.ph,
      titratableAcidity: data.titratableAcidity.present
          ? data.titratableAcidity.value
          : this.titratableAcidity,
      waterActivity: data.waterActivity.present
          ? data.waterActivity.value
          : this.waterActivity,
      brix: data.brix.present ? data.brix.value : this.brix,
      densityGPerMl: data.densityGPerMl.present
          ? data.densityGPerMl.value
          : this.densityGPerMl,
      particleSizeUm: data.particleSizeUm.present
          ? data.particleSizeUm.value
          : this.particleSizeUm,
      solubility: data.solubility.present
          ? data.solubility.value
          : this.solubility,
      oilHoldingCapacityGG: data.oilHoldingCapacityGG.present
          ? data.oilHoldingCapacityGG.value
          : this.oilHoldingCapacityGG,
      waterHoldingCapacityGG: data.waterHoldingCapacityGG.present
          ? data.waterHoldingCapacityGG.value
          : this.waterHoldingCapacityGG,
      emulsifyingCapacity: data.emulsifyingCapacity.present
          ? data.emulsifyingCapacity.value
          : this.emulsifyingCapacity,
      foamingCapacity: data.foamingCapacity.present
          ? data.foamingCapacity.value
          : this.foamingCapacity,
      gelationCapability: data.gelationCapability.present
          ? data.gelationCapability.value
          : this.gelationCapability,
      thickeningCapability: data.thickeningCapability.present
          ? data.thickeningCapability.value
          : this.thickeningCapability,
      hygroscopicity: data.hygroscopicity.present
          ? data.hygroscopicity.value
          : this.hygroscopicity,
      thermalStability: data.thermalStability.present
          ? data.thermalStability.value
          : this.thermalStability,
      freezeThawStability: data.freezeThawStability.present
          ? data.freezeThawStability.value
          : this.freezeThawStability,
      oxidationSensitivity: data.oxidationSensitivity.present
          ? data.oxidationSensitivity.value
          : this.oxidationSensitivity,
      sourceRefs: data.sourceRefs.present
          ? data.sourceRefs.value
          : this.sourceRefs,
      evidenceType: data.evidenceType.present
          ? data.evidenceType.value
          : this.evidenceType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      validityConditions: data.validityConditions.present
          ? data.validityConditions.value
          : this.validityConditions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FunctionalIngredient(')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('temperatureReferenceC: $temperatureReferenceC, ')
          ..write('waterContent: $waterContent, ')
          ..write('fatContent: $fatContent, ')
          ..write('proteinContent: $proteinContent, ')
          ..write('starchContent: $starchContent, ')
          ..write('sugarContent: $sugarContent, ')
          ..write('fiberContent: $fiberContent, ')
          ..write('pectinContent: $pectinContent, ')
          ..write('alcoholContent: $alcoholContent, ')
          ..write('saltContent: $saltContent, ')
          ..write('mineralContent: $mineralContent, ')
          ..write('ph: $ph, ')
          ..write('titratableAcidity: $titratableAcidity, ')
          ..write('waterActivity: $waterActivity, ')
          ..write('brix: $brix, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('particleSizeUm: $particleSizeUm, ')
          ..write('solubility: $solubility, ')
          ..write('oilHoldingCapacityGG: $oilHoldingCapacityGG, ')
          ..write('waterHoldingCapacityGG: $waterHoldingCapacityGG, ')
          ..write('emulsifyingCapacity: $emulsifyingCapacity, ')
          ..write('foamingCapacity: $foamingCapacity, ')
          ..write('gelationCapability: $gelationCapability, ')
          ..write('thickeningCapability: $thickeningCapability, ')
          ..write('hygroscopicity: $hygroscopicity, ')
          ..write('thermalStability: $thermalStability, ')
          ..write('freezeThawStability: $freezeThawStability, ')
          ..write('oxidationSensitivity: $oxidationSensitivity, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence, ')
          ..write('validityConditions: $validityConditions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ingredientId,
    ingredientStateId,
    temperatureReferenceC,
    waterContent,
    fatContent,
    proteinContent,
    starchContent,
    sugarContent,
    fiberContent,
    pectinContent,
    alcoholContent,
    saltContent,
    mineralContent,
    ph,
    titratableAcidity,
    waterActivity,
    brix,
    densityGPerMl,
    particleSizeUm,
    solubility,
    oilHoldingCapacityGG,
    waterHoldingCapacityGG,
    emulsifyingCapacity,
    foamingCapacity,
    gelationCapability,
    thickeningCapability,
    hygroscopicity,
    thermalStability,
    freezeThawStability,
    oxidationSensitivity,
    sourceRefs,
    evidenceType,
    confidence,
    validityConditions,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FunctionalIngredient &&
          other.ingredientId == this.ingredientId &&
          other.ingredientStateId == this.ingredientStateId &&
          other.temperatureReferenceC == this.temperatureReferenceC &&
          other.waterContent == this.waterContent &&
          other.fatContent == this.fatContent &&
          other.proteinContent == this.proteinContent &&
          other.starchContent == this.starchContent &&
          other.sugarContent == this.sugarContent &&
          other.fiberContent == this.fiberContent &&
          other.pectinContent == this.pectinContent &&
          other.alcoholContent == this.alcoholContent &&
          other.saltContent == this.saltContent &&
          other.mineralContent == this.mineralContent &&
          other.ph == this.ph &&
          other.titratableAcidity == this.titratableAcidity &&
          other.waterActivity == this.waterActivity &&
          other.brix == this.brix &&
          other.densityGPerMl == this.densityGPerMl &&
          other.particleSizeUm == this.particleSizeUm &&
          other.solubility == this.solubility &&
          other.oilHoldingCapacityGG == this.oilHoldingCapacityGG &&
          other.waterHoldingCapacityGG == this.waterHoldingCapacityGG &&
          other.emulsifyingCapacity == this.emulsifyingCapacity &&
          other.foamingCapacity == this.foamingCapacity &&
          other.gelationCapability == this.gelationCapability &&
          other.thickeningCapability == this.thickeningCapability &&
          other.hygroscopicity == this.hygroscopicity &&
          other.thermalStability == this.thermalStability &&
          other.freezeThawStability == this.freezeThawStability &&
          other.oxidationSensitivity == this.oxidationSensitivity &&
          other.sourceRefs == this.sourceRefs &&
          other.evidenceType == this.evidenceType &&
          other.confidence == this.confidence &&
          other.validityConditions == this.validityConditions);
}

class FunctionalIngredientsCompanion
    extends UpdateCompanion<FunctionalIngredient> {
  final Value<String> ingredientId;
  final Value<String> ingredientStateId;
  final Value<double?> temperatureReferenceC;
  final Value<double?> waterContent;
  final Value<double?> fatContent;
  final Value<double?> proteinContent;
  final Value<double?> starchContent;
  final Value<double?> sugarContent;
  final Value<double?> fiberContent;
  final Value<double?> pectinContent;
  final Value<double?> alcoholContent;
  final Value<double?> saltContent;
  final Value<double?> mineralContent;
  final Value<double?> ph;
  final Value<double?> titratableAcidity;
  final Value<double?> waterActivity;
  final Value<double?> brix;
  final Value<double?> densityGPerMl;
  final Value<double?> particleSizeUm;
  final Value<String?> solubility;
  final Value<double?> oilHoldingCapacityGG;
  final Value<double?> waterHoldingCapacityGG;
  final Value<String?> emulsifyingCapacity;
  final Value<String?> foamingCapacity;
  final Value<String?> gelationCapability;
  final Value<String?> thickeningCapability;
  final Value<String?> hygroscopicity;
  final Value<String?> thermalStability;
  final Value<String?> freezeThawStability;
  final Value<String?> oxidationSensitivity;
  final Value<String?> sourceRefs;
  final Value<String?> evidenceType;
  final Value<double?> confidence;
  final Value<String?> validityConditions;
  final Value<int> rowid;
  const FunctionalIngredientsCompanion({
    this.ingredientId = const Value.absent(),
    this.ingredientStateId = const Value.absent(),
    this.temperatureReferenceC = const Value.absent(),
    this.waterContent = const Value.absent(),
    this.fatContent = const Value.absent(),
    this.proteinContent = const Value.absent(),
    this.starchContent = const Value.absent(),
    this.sugarContent = const Value.absent(),
    this.fiberContent = const Value.absent(),
    this.pectinContent = const Value.absent(),
    this.alcoholContent = const Value.absent(),
    this.saltContent = const Value.absent(),
    this.mineralContent = const Value.absent(),
    this.ph = const Value.absent(),
    this.titratableAcidity = const Value.absent(),
    this.waterActivity = const Value.absent(),
    this.brix = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.particleSizeUm = const Value.absent(),
    this.solubility = const Value.absent(),
    this.oilHoldingCapacityGG = const Value.absent(),
    this.waterHoldingCapacityGG = const Value.absent(),
    this.emulsifyingCapacity = const Value.absent(),
    this.foamingCapacity = const Value.absent(),
    this.gelationCapability = const Value.absent(),
    this.thickeningCapability = const Value.absent(),
    this.hygroscopicity = const Value.absent(),
    this.thermalStability = const Value.absent(),
    this.freezeThawStability = const Value.absent(),
    this.oxidationSensitivity = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.validityConditions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FunctionalIngredientsCompanion.insert({
    required String ingredientId,
    required String ingredientStateId,
    this.temperatureReferenceC = const Value.absent(),
    this.waterContent = const Value.absent(),
    this.fatContent = const Value.absent(),
    this.proteinContent = const Value.absent(),
    this.starchContent = const Value.absent(),
    this.sugarContent = const Value.absent(),
    this.fiberContent = const Value.absent(),
    this.pectinContent = const Value.absent(),
    this.alcoholContent = const Value.absent(),
    this.saltContent = const Value.absent(),
    this.mineralContent = const Value.absent(),
    this.ph = const Value.absent(),
    this.titratableAcidity = const Value.absent(),
    this.waterActivity = const Value.absent(),
    this.brix = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.particleSizeUm = const Value.absent(),
    this.solubility = const Value.absent(),
    this.oilHoldingCapacityGG = const Value.absent(),
    this.waterHoldingCapacityGG = const Value.absent(),
    this.emulsifyingCapacity = const Value.absent(),
    this.foamingCapacity = const Value.absent(),
    this.gelationCapability = const Value.absent(),
    this.thickeningCapability = const Value.absent(),
    this.hygroscopicity = const Value.absent(),
    this.thermalStability = const Value.absent(),
    this.freezeThawStability = const Value.absent(),
    this.oxidationSensitivity = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.validityConditions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ingredientId = Value(ingredientId),
       ingredientStateId = Value(ingredientStateId);
  static Insertable<FunctionalIngredient> custom({
    Expression<String>? ingredientId,
    Expression<String>? ingredientStateId,
    Expression<double>? temperatureReferenceC,
    Expression<double>? waterContent,
    Expression<double>? fatContent,
    Expression<double>? proteinContent,
    Expression<double>? starchContent,
    Expression<double>? sugarContent,
    Expression<double>? fiberContent,
    Expression<double>? pectinContent,
    Expression<double>? alcoholContent,
    Expression<double>? saltContent,
    Expression<double>? mineralContent,
    Expression<double>? ph,
    Expression<double>? titratableAcidity,
    Expression<double>? waterActivity,
    Expression<double>? brix,
    Expression<double>? densityGPerMl,
    Expression<double>? particleSizeUm,
    Expression<String>? solubility,
    Expression<double>? oilHoldingCapacityGG,
    Expression<double>? waterHoldingCapacityGG,
    Expression<String>? emulsifyingCapacity,
    Expression<String>? foamingCapacity,
    Expression<String>? gelationCapability,
    Expression<String>? thickeningCapability,
    Expression<String>? hygroscopicity,
    Expression<String>? thermalStability,
    Expression<String>? freezeThawStability,
    Expression<String>? oxidationSensitivity,
    Expression<String>? sourceRefs,
    Expression<String>? evidenceType,
    Expression<double>? confidence,
    Expression<String>? validityConditions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingredientStateId != null) 'ingredient_state_id': ingredientStateId,
      if (temperatureReferenceC != null)
        'temperature_reference_C': temperatureReferenceC,
      if (waterContent != null) 'water_content': waterContent,
      if (fatContent != null) 'fat_content': fatContent,
      if (proteinContent != null) 'protein_content': proteinContent,
      if (starchContent != null) 'starch_content': starchContent,
      if (sugarContent != null) 'sugar_content': sugarContent,
      if (fiberContent != null) 'fiber_content': fiberContent,
      if (pectinContent != null) 'pectin_content': pectinContent,
      if (alcoholContent != null) 'alcohol_content': alcoholContent,
      if (saltContent != null) 'salt_content': saltContent,
      if (mineralContent != null) 'mineral_content': mineralContent,
      if (ph != null) 'ph': ph,
      if (titratableAcidity != null) 'titratable_acidity': titratableAcidity,
      if (waterActivity != null) 'water_activity': waterActivity,
      if (brix != null) 'brix': brix,
      if (densityGPerMl != null) 'density_g_per_mL': densityGPerMl,
      if (particleSizeUm != null) 'particle_size_um': particleSizeUm,
      if (solubility != null) 'solubility': solubility,
      if (oilHoldingCapacityGG != null)
        'oil_holding_capacity_g_g': oilHoldingCapacityGG,
      if (waterHoldingCapacityGG != null)
        'water_holding_capacity_g_g': waterHoldingCapacityGG,
      if (emulsifyingCapacity != null)
        'emulsifying_capacity': emulsifyingCapacity,
      if (foamingCapacity != null) 'foaming_capacity': foamingCapacity,
      if (gelationCapability != null) 'gelation_capability': gelationCapability,
      if (thickeningCapability != null)
        'thickening_capability': thickeningCapability,
      if (hygroscopicity != null) 'hygroscopicity': hygroscopicity,
      if (thermalStability != null) 'thermal_stability': thermalStability,
      if (freezeThawStability != null)
        'freeze_thaw_stability': freezeThawStability,
      if (oxidationSensitivity != null)
        'oxidation_sensitivity': oxidationSensitivity,
      if (sourceRefs != null) 'source_refs': sourceRefs,
      if (evidenceType != null) 'evidence_type': evidenceType,
      if (confidence != null) 'confidence': confidence,
      if (validityConditions != null) 'validity_conditions': validityConditions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FunctionalIngredientsCompanion copyWith({
    Value<String>? ingredientId,
    Value<String>? ingredientStateId,
    Value<double?>? temperatureReferenceC,
    Value<double?>? waterContent,
    Value<double?>? fatContent,
    Value<double?>? proteinContent,
    Value<double?>? starchContent,
    Value<double?>? sugarContent,
    Value<double?>? fiberContent,
    Value<double?>? pectinContent,
    Value<double?>? alcoholContent,
    Value<double?>? saltContent,
    Value<double?>? mineralContent,
    Value<double?>? ph,
    Value<double?>? titratableAcidity,
    Value<double?>? waterActivity,
    Value<double?>? brix,
    Value<double?>? densityGPerMl,
    Value<double?>? particleSizeUm,
    Value<String?>? solubility,
    Value<double?>? oilHoldingCapacityGG,
    Value<double?>? waterHoldingCapacityGG,
    Value<String?>? emulsifyingCapacity,
    Value<String?>? foamingCapacity,
    Value<String?>? gelationCapability,
    Value<String?>? thickeningCapability,
    Value<String?>? hygroscopicity,
    Value<String?>? thermalStability,
    Value<String?>? freezeThawStability,
    Value<String?>? oxidationSensitivity,
    Value<String?>? sourceRefs,
    Value<String?>? evidenceType,
    Value<double?>? confidence,
    Value<String?>? validityConditions,
    Value<int>? rowid,
  }) {
    return FunctionalIngredientsCompanion(
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientStateId: ingredientStateId ?? this.ingredientStateId,
      temperatureReferenceC:
          temperatureReferenceC ?? this.temperatureReferenceC,
      waterContent: waterContent ?? this.waterContent,
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      starchContent: starchContent ?? this.starchContent,
      sugarContent: sugarContent ?? this.sugarContent,
      fiberContent: fiberContent ?? this.fiberContent,
      pectinContent: pectinContent ?? this.pectinContent,
      alcoholContent: alcoholContent ?? this.alcoholContent,
      saltContent: saltContent ?? this.saltContent,
      mineralContent: mineralContent ?? this.mineralContent,
      ph: ph ?? this.ph,
      titratableAcidity: titratableAcidity ?? this.titratableAcidity,
      waterActivity: waterActivity ?? this.waterActivity,
      brix: brix ?? this.brix,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      particleSizeUm: particleSizeUm ?? this.particleSizeUm,
      solubility: solubility ?? this.solubility,
      oilHoldingCapacityGG: oilHoldingCapacityGG ?? this.oilHoldingCapacityGG,
      waterHoldingCapacityGG:
          waterHoldingCapacityGG ?? this.waterHoldingCapacityGG,
      emulsifyingCapacity: emulsifyingCapacity ?? this.emulsifyingCapacity,
      foamingCapacity: foamingCapacity ?? this.foamingCapacity,
      gelationCapability: gelationCapability ?? this.gelationCapability,
      thickeningCapability: thickeningCapability ?? this.thickeningCapability,
      hygroscopicity: hygroscopicity ?? this.hygroscopicity,
      thermalStability: thermalStability ?? this.thermalStability,
      freezeThawStability: freezeThawStability ?? this.freezeThawStability,
      oxidationSensitivity: oxidationSensitivity ?? this.oxidationSensitivity,
      sourceRefs: sourceRefs ?? this.sourceRefs,
      evidenceType: evidenceType ?? this.evidenceType,
      confidence: confidence ?? this.confidence,
      validityConditions: validityConditions ?? this.validityConditions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (ingredientStateId.present) {
      map['ingredient_state_id'] = Variable<String>(ingredientStateId.value);
    }
    if (temperatureReferenceC.present) {
      map['temperature_reference_C'] = Variable<double>(
        temperatureReferenceC.value,
      );
    }
    if (waterContent.present) {
      map['water_content'] = Variable<double>(waterContent.value);
    }
    if (fatContent.present) {
      map['fat_content'] = Variable<double>(fatContent.value);
    }
    if (proteinContent.present) {
      map['protein_content'] = Variable<double>(proteinContent.value);
    }
    if (starchContent.present) {
      map['starch_content'] = Variable<double>(starchContent.value);
    }
    if (sugarContent.present) {
      map['sugar_content'] = Variable<double>(sugarContent.value);
    }
    if (fiberContent.present) {
      map['fiber_content'] = Variable<double>(fiberContent.value);
    }
    if (pectinContent.present) {
      map['pectin_content'] = Variable<double>(pectinContent.value);
    }
    if (alcoholContent.present) {
      map['alcohol_content'] = Variable<double>(alcoholContent.value);
    }
    if (saltContent.present) {
      map['salt_content'] = Variable<double>(saltContent.value);
    }
    if (mineralContent.present) {
      map['mineral_content'] = Variable<double>(mineralContent.value);
    }
    if (ph.present) {
      map['ph'] = Variable<double>(ph.value);
    }
    if (titratableAcidity.present) {
      map['titratable_acidity'] = Variable<double>(titratableAcidity.value);
    }
    if (waterActivity.present) {
      map['water_activity'] = Variable<double>(waterActivity.value);
    }
    if (brix.present) {
      map['brix'] = Variable<double>(brix.value);
    }
    if (densityGPerMl.present) {
      map['density_g_per_mL'] = Variable<double>(densityGPerMl.value);
    }
    if (particleSizeUm.present) {
      map['particle_size_um'] = Variable<double>(particleSizeUm.value);
    }
    if (solubility.present) {
      map['solubility'] = Variable<String>(solubility.value);
    }
    if (oilHoldingCapacityGG.present) {
      map['oil_holding_capacity_g_g'] = Variable<double>(
        oilHoldingCapacityGG.value,
      );
    }
    if (waterHoldingCapacityGG.present) {
      map['water_holding_capacity_g_g'] = Variable<double>(
        waterHoldingCapacityGG.value,
      );
    }
    if (emulsifyingCapacity.present) {
      map['emulsifying_capacity'] = Variable<String>(emulsifyingCapacity.value);
    }
    if (foamingCapacity.present) {
      map['foaming_capacity'] = Variable<String>(foamingCapacity.value);
    }
    if (gelationCapability.present) {
      map['gelation_capability'] = Variable<String>(gelationCapability.value);
    }
    if (thickeningCapability.present) {
      map['thickening_capability'] = Variable<String>(
        thickeningCapability.value,
      );
    }
    if (hygroscopicity.present) {
      map['hygroscopicity'] = Variable<String>(hygroscopicity.value);
    }
    if (thermalStability.present) {
      map['thermal_stability'] = Variable<String>(thermalStability.value);
    }
    if (freezeThawStability.present) {
      map['freeze_thaw_stability'] = Variable<String>(
        freezeThawStability.value,
      );
    }
    if (oxidationSensitivity.present) {
      map['oxidation_sensitivity'] = Variable<String>(
        oxidationSensitivity.value,
      );
    }
    if (sourceRefs.present) {
      map['source_refs'] = Variable<String>(sourceRefs.value);
    }
    if (evidenceType.present) {
      map['evidence_type'] = Variable<String>(evidenceType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (validityConditions.present) {
      map['validity_conditions'] = Variable<String>(validityConditions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FunctionalIngredientsCompanion(')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientStateId: $ingredientStateId, ')
          ..write('temperatureReferenceC: $temperatureReferenceC, ')
          ..write('waterContent: $waterContent, ')
          ..write('fatContent: $fatContent, ')
          ..write('proteinContent: $proteinContent, ')
          ..write('starchContent: $starchContent, ')
          ..write('sugarContent: $sugarContent, ')
          ..write('fiberContent: $fiberContent, ')
          ..write('pectinContent: $pectinContent, ')
          ..write('alcoholContent: $alcoholContent, ')
          ..write('saltContent: $saltContent, ')
          ..write('mineralContent: $mineralContent, ')
          ..write('ph: $ph, ')
          ..write('titratableAcidity: $titratableAcidity, ')
          ..write('waterActivity: $waterActivity, ')
          ..write('brix: $brix, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('particleSizeUm: $particleSizeUm, ')
          ..write('solubility: $solubility, ')
          ..write('oilHoldingCapacityGG: $oilHoldingCapacityGG, ')
          ..write('waterHoldingCapacityGG: $waterHoldingCapacityGG, ')
          ..write('emulsifyingCapacity: $emulsifyingCapacity, ')
          ..write('foamingCapacity: $foamingCapacity, ')
          ..write('gelationCapability: $gelationCapability, ')
          ..write('thickeningCapability: $thickeningCapability, ')
          ..write('hygroscopicity: $hygroscopicity, ')
          ..write('thermalStability: $thermalStability, ')
          ..write('freezeThawStability: $freezeThawStability, ')
          ..write('oxidationSensitivity: $oxidationSensitivity, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence, ')
          ..write('validityConditions: $validityConditions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionRulesTable extends InteractionRules
    with TableInfo<$InteractionRulesTable, InteractionRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleFamilyMeta = const VerificationMeta(
    'ruleFamily',
  );
  @override
  late final GeneratedColumn<String> ruleFamily = GeneratedColumn<String>(
    'rule_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactantOrComponentIdsMeta =
      const VerificationMeta('reactantOrComponentIds');
  @override
  late final GeneratedColumn<String> reactantOrComponentIds =
      GeneratedColumn<String>(
        'reactant_or_component_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ingredientConstraintsMeta =
      const VerificationMeta('ingredientConstraints');
  @override
  late final GeneratedColumn<String> ingredientConstraints =
      GeneratedColumn<String>(
        'ingredient_constraints',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _compositionConstraintsMeta =
      const VerificationMeta('compositionConstraints');
  @override
  late final GeneratedColumn<String> compositionConstraints =
      GeneratedColumn<String>(
        'composition_constraints',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processConstraintsMeta =
      const VerificationMeta('processConstraints');
  @override
  late final GeneratedColumn<String> processConstraints =
      GeneratedColumn<String>(
        'process_constraints',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phMinMeta = const VerificationMeta('phMin');
  @override
  late final GeneratedColumn<double> phMin = GeneratedColumn<double>(
    'ph_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phMaxMeta = const VerificationMeta('phMax');
  @override
  late final GeneratedColumn<double> phMax = GeneratedColumn<double>(
    'ph_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMinMeta = const VerificationMeta(
    'temperatureMin',
  );
  @override
  late final GeneratedColumn<double> temperatureMin = GeneratedColumn<double>(
    'temperature_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMaxMeta = const VerificationMeta(
    'temperatureMax',
  );
  @override
  late final GeneratedColumn<double> temperatureMax = GeneratedColumn<double>(
    'temperature_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeMinMeta = const VerificationMeta(
    'timeMin',
  );
  @override
  late final GeneratedColumn<double> timeMin = GeneratedColumn<double>(
    'time_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeMaxMeta = const VerificationMeta(
    'timeMax',
  );
  @override
  late final GeneratedColumn<double> timeMax = GeneratedColumn<double>(
    'time_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterActivityMinMeta = const VerificationMeta(
    'waterActivityMin',
  );
  @override
  late final GeneratedColumn<double> waterActivityMin = GeneratedColumn<double>(
    'water_activity_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterActivityMaxMeta = const VerificationMeta(
    'waterActivityMax',
  );
  @override
  late final GeneratedColumn<double> waterActivityMax = GeneratedColumn<double>(
    'water_activity_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shearConstraintsMeta = const VerificationMeta(
    'shearConstraints',
  );
  @override
  late final GeneratedColumn<String> shearConstraints = GeneratedColumn<String>(
    'shear_constraints',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderConstraintsMeta = const VerificationMeta(
    'orderConstraints',
  );
  @override
  late final GeneratedColumn<String> orderConstraints = GeneratedColumn<String>(
    'order_constraints',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _predictedEffectMeta = const VerificationMeta(
    'predictedEffect',
  );
  @override
  late final GeneratedColumn<String> predictedEffect = GeneratedColumn<String>(
    'predicted_effect',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectDirectionMeta = const VerificationMeta(
    'effectDirection',
  );
  @override
  late final GeneratedColumn<String> effectDirection = GeneratedColumn<String>(
    'effect_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectMagnitudeMeta = const VerificationMeta(
    'effectMagnitude',
  );
  @override
  late final GeneratedColumn<String> effectMagnitude = GeneratedColumn<String>(
    'effect_magnitude',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputPropertyMeta = const VerificationMeta(
    'outputProperty',
  );
  @override
  late final GeneratedColumn<String> outputProperty = GeneratedColumn<String>(
    'output_property',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equationOrLogicMeta = const VerificationMeta(
    'equationOrLogic',
  );
  @override
  late final GeneratedColumn<String> equationOrLogic = GeneratedColumn<String>(
    'equation_or_logic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceRefsMeta = const VerificationMeta(
    'sourceRefs',
  );
  @override
  late final GeneratedColumn<String> sourceRefs = GeneratedColumn<String>(
    'source_refs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceTypeMeta = const VerificationMeta(
    'evidenceType',
  );
  @override
  late final GeneratedColumn<String> evidenceType = GeneratedColumn<String>(
    'evidence_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrapolationAllowedMeta =
      const VerificationMeta('extrapolationAllowed');
  @override
  late final GeneratedColumn<bool> extrapolationAllowed = GeneratedColumn<bool>(
    'extrapolation_allowed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("extrapolation_allowed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ruleId,
    ruleFamily,
    reactantOrComponentIds,
    ingredientConstraints,
    compositionConstraints,
    processConstraints,
    phMin,
    phMax,
    temperatureMin,
    temperatureMax,
    timeMin,
    timeMax,
    waterActivityMin,
    waterActivityMax,
    shearConstraints,
    orderConstraints,
    predictedEffect,
    effectDirection,
    effectMagnitude,
    outputProperty,
    equationOrLogic,
    sourceRefs,
    evidenceType,
    confidence,
    extrapolationAllowed,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interaction_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<InteractionRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('rule_family')) {
      context.handle(
        _ruleFamilyMeta,
        ruleFamily.isAcceptableOrUnknown(data['rule_family']!, _ruleFamilyMeta),
      );
    }
    if (data.containsKey('reactant_or_component_ids')) {
      context.handle(
        _reactantOrComponentIdsMeta,
        reactantOrComponentIds.isAcceptableOrUnknown(
          data['reactant_or_component_ids']!,
          _reactantOrComponentIdsMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_constraints')) {
      context.handle(
        _ingredientConstraintsMeta,
        ingredientConstraints.isAcceptableOrUnknown(
          data['ingredient_constraints']!,
          _ingredientConstraintsMeta,
        ),
      );
    }
    if (data.containsKey('composition_constraints')) {
      context.handle(
        _compositionConstraintsMeta,
        compositionConstraints.isAcceptableOrUnknown(
          data['composition_constraints']!,
          _compositionConstraintsMeta,
        ),
      );
    }
    if (data.containsKey('process_constraints')) {
      context.handle(
        _processConstraintsMeta,
        processConstraints.isAcceptableOrUnknown(
          data['process_constraints']!,
          _processConstraintsMeta,
        ),
      );
    }
    if (data.containsKey('ph_min')) {
      context.handle(
        _phMinMeta,
        phMin.isAcceptableOrUnknown(data['ph_min']!, _phMinMeta),
      );
    }
    if (data.containsKey('ph_max')) {
      context.handle(
        _phMaxMeta,
        phMax.isAcceptableOrUnknown(data['ph_max']!, _phMaxMeta),
      );
    }
    if (data.containsKey('temperature_min')) {
      context.handle(
        _temperatureMinMeta,
        temperatureMin.isAcceptableOrUnknown(
          data['temperature_min']!,
          _temperatureMinMeta,
        ),
      );
    }
    if (data.containsKey('temperature_max')) {
      context.handle(
        _temperatureMaxMeta,
        temperatureMax.isAcceptableOrUnknown(
          data['temperature_max']!,
          _temperatureMaxMeta,
        ),
      );
    }
    if (data.containsKey('time_min')) {
      context.handle(
        _timeMinMeta,
        timeMin.isAcceptableOrUnknown(data['time_min']!, _timeMinMeta),
      );
    }
    if (data.containsKey('time_max')) {
      context.handle(
        _timeMaxMeta,
        timeMax.isAcceptableOrUnknown(data['time_max']!, _timeMaxMeta),
      );
    }
    if (data.containsKey('water_activity_min')) {
      context.handle(
        _waterActivityMinMeta,
        waterActivityMin.isAcceptableOrUnknown(
          data['water_activity_min']!,
          _waterActivityMinMeta,
        ),
      );
    }
    if (data.containsKey('water_activity_max')) {
      context.handle(
        _waterActivityMaxMeta,
        waterActivityMax.isAcceptableOrUnknown(
          data['water_activity_max']!,
          _waterActivityMaxMeta,
        ),
      );
    }
    if (data.containsKey('shear_constraints')) {
      context.handle(
        _shearConstraintsMeta,
        shearConstraints.isAcceptableOrUnknown(
          data['shear_constraints']!,
          _shearConstraintsMeta,
        ),
      );
    }
    if (data.containsKey('order_constraints')) {
      context.handle(
        _orderConstraintsMeta,
        orderConstraints.isAcceptableOrUnknown(
          data['order_constraints']!,
          _orderConstraintsMeta,
        ),
      );
    }
    if (data.containsKey('predicted_effect')) {
      context.handle(
        _predictedEffectMeta,
        predictedEffect.isAcceptableOrUnknown(
          data['predicted_effect']!,
          _predictedEffectMeta,
        ),
      );
    }
    if (data.containsKey('effect_direction')) {
      context.handle(
        _effectDirectionMeta,
        effectDirection.isAcceptableOrUnknown(
          data['effect_direction']!,
          _effectDirectionMeta,
        ),
      );
    }
    if (data.containsKey('effect_magnitude')) {
      context.handle(
        _effectMagnitudeMeta,
        effectMagnitude.isAcceptableOrUnknown(
          data['effect_magnitude']!,
          _effectMagnitudeMeta,
        ),
      );
    }
    if (data.containsKey('output_property')) {
      context.handle(
        _outputPropertyMeta,
        outputProperty.isAcceptableOrUnknown(
          data['output_property']!,
          _outputPropertyMeta,
        ),
      );
    }
    if (data.containsKey('equation_or_logic')) {
      context.handle(
        _equationOrLogicMeta,
        equationOrLogic.isAcceptableOrUnknown(
          data['equation_or_logic']!,
          _equationOrLogicMeta,
        ),
      );
    }
    if (data.containsKey('source_refs')) {
      context.handle(
        _sourceRefsMeta,
        sourceRefs.isAcceptableOrUnknown(data['source_refs']!, _sourceRefsMeta),
      );
    }
    if (data.containsKey('evidence_type')) {
      context.handle(
        _evidenceTypeMeta,
        evidenceType.isAcceptableOrUnknown(
          data['evidence_type']!,
          _evidenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('extrapolation_allowed')) {
      context.handle(
        _extrapolationAllowedMeta,
        extrapolationAllowed.isAcceptableOrUnknown(
          data['extrapolation_allowed']!,
          _extrapolationAllowedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ruleId};
  @override
  InteractionRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InteractionRule(
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      ruleFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_family'],
      ),
      reactantOrComponentIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reactant_or_component_ids'],
      ),
      ingredientConstraints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_constraints'],
      ),
      compositionConstraints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composition_constraints'],
      ),
      processConstraints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_constraints'],
      ),
      phMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_min'],
      ),
      phMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_max'],
      ),
      temperatureMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_min'],
      ),
      temperatureMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_max'],
      ),
      timeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}time_min'],
      ),
      timeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}time_max'],
      ),
      waterActivityMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_activity_min'],
      ),
      waterActivityMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_activity_max'],
      ),
      shearConstraints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shear_constraints'],
      ),
      orderConstraints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_constraints'],
      ),
      predictedEffect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predicted_effect'],
      ),
      effectDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_direction'],
      ),
      effectMagnitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_magnitude'],
      ),
      outputProperty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_property'],
      ),
      equationOrLogic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equation_or_logic'],
      ),
      sourceRefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_refs'],
      ),
      evidenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_type'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      extrapolationAllowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}extrapolation_allowed'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InteractionRulesTable createAlias(String alias) {
    return $InteractionRulesTable(attachedDatabase, alias);
  }
}

class InteractionRule extends DataClass implements Insertable<InteractionRule> {
  final String ruleId;
  final String? ruleFamily;
  final String? reactantOrComponentIds;
  final String? ingredientConstraints;
  final String? compositionConstraints;
  final String? processConstraints;
  final double? phMin;
  final double? phMax;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? timeMin;
  final double? timeMax;
  final double? waterActivityMin;
  final double? waterActivityMax;
  final String? shearConstraints;
  final String? orderConstraints;
  final String? predictedEffect;
  final String? effectDirection;
  final String? effectMagnitude;
  final String? outputProperty;
  final String? equationOrLogic;
  final String? sourceRefs;
  final String? evidenceType;
  final double? confidence;
  final bool? extrapolationAllowed;
  final String? notes;
  const InteractionRule({
    required this.ruleId,
    this.ruleFamily,
    this.reactantOrComponentIds,
    this.ingredientConstraints,
    this.compositionConstraints,
    this.processConstraints,
    this.phMin,
    this.phMax,
    this.temperatureMin,
    this.temperatureMax,
    this.timeMin,
    this.timeMax,
    this.waterActivityMin,
    this.waterActivityMax,
    this.shearConstraints,
    this.orderConstraints,
    this.predictedEffect,
    this.effectDirection,
    this.effectMagnitude,
    this.outputProperty,
    this.equationOrLogic,
    this.sourceRefs,
    this.evidenceType,
    this.confidence,
    this.extrapolationAllowed,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rule_id'] = Variable<String>(ruleId);
    if (!nullToAbsent || ruleFamily != null) {
      map['rule_family'] = Variable<String>(ruleFamily);
    }
    if (!nullToAbsent || reactantOrComponentIds != null) {
      map['reactant_or_component_ids'] = Variable<String>(
        reactantOrComponentIds,
      );
    }
    if (!nullToAbsent || ingredientConstraints != null) {
      map['ingredient_constraints'] = Variable<String>(ingredientConstraints);
    }
    if (!nullToAbsent || compositionConstraints != null) {
      map['composition_constraints'] = Variable<String>(compositionConstraints);
    }
    if (!nullToAbsent || processConstraints != null) {
      map['process_constraints'] = Variable<String>(processConstraints);
    }
    if (!nullToAbsent || phMin != null) {
      map['ph_min'] = Variable<double>(phMin);
    }
    if (!nullToAbsent || phMax != null) {
      map['ph_max'] = Variable<double>(phMax);
    }
    if (!nullToAbsent || temperatureMin != null) {
      map['temperature_min'] = Variable<double>(temperatureMin);
    }
    if (!nullToAbsent || temperatureMax != null) {
      map['temperature_max'] = Variable<double>(temperatureMax);
    }
    if (!nullToAbsent || timeMin != null) {
      map['time_min'] = Variable<double>(timeMin);
    }
    if (!nullToAbsent || timeMax != null) {
      map['time_max'] = Variable<double>(timeMax);
    }
    if (!nullToAbsent || waterActivityMin != null) {
      map['water_activity_min'] = Variable<double>(waterActivityMin);
    }
    if (!nullToAbsent || waterActivityMax != null) {
      map['water_activity_max'] = Variable<double>(waterActivityMax);
    }
    if (!nullToAbsent || shearConstraints != null) {
      map['shear_constraints'] = Variable<String>(shearConstraints);
    }
    if (!nullToAbsent || orderConstraints != null) {
      map['order_constraints'] = Variable<String>(orderConstraints);
    }
    if (!nullToAbsent || predictedEffect != null) {
      map['predicted_effect'] = Variable<String>(predictedEffect);
    }
    if (!nullToAbsent || effectDirection != null) {
      map['effect_direction'] = Variable<String>(effectDirection);
    }
    if (!nullToAbsent || effectMagnitude != null) {
      map['effect_magnitude'] = Variable<String>(effectMagnitude);
    }
    if (!nullToAbsent || outputProperty != null) {
      map['output_property'] = Variable<String>(outputProperty);
    }
    if (!nullToAbsent || equationOrLogic != null) {
      map['equation_or_logic'] = Variable<String>(equationOrLogic);
    }
    if (!nullToAbsent || sourceRefs != null) {
      map['source_refs'] = Variable<String>(sourceRefs);
    }
    if (!nullToAbsent || evidenceType != null) {
      map['evidence_type'] = Variable<String>(evidenceType);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || extrapolationAllowed != null) {
      map['extrapolation_allowed'] = Variable<bool>(extrapolationAllowed);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InteractionRulesCompanion toCompanion(bool nullToAbsent) {
    return InteractionRulesCompanion(
      ruleId: Value(ruleId),
      ruleFamily: ruleFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleFamily),
      reactantOrComponentIds: reactantOrComponentIds == null && nullToAbsent
          ? const Value.absent()
          : Value(reactantOrComponentIds),
      ingredientConstraints: ingredientConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientConstraints),
      compositionConstraints: compositionConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(compositionConstraints),
      processConstraints: processConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(processConstraints),
      phMin: phMin == null && nullToAbsent
          ? const Value.absent()
          : Value(phMin),
      phMax: phMax == null && nullToAbsent
          ? const Value.absent()
          : Value(phMax),
      temperatureMin: temperatureMin == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureMin),
      temperatureMax: temperatureMax == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureMax),
      timeMin: timeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(timeMin),
      timeMax: timeMax == null && nullToAbsent
          ? const Value.absent()
          : Value(timeMax),
      waterActivityMin: waterActivityMin == null && nullToAbsent
          ? const Value.absent()
          : Value(waterActivityMin),
      waterActivityMax: waterActivityMax == null && nullToAbsent
          ? const Value.absent()
          : Value(waterActivityMax),
      shearConstraints: shearConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(shearConstraints),
      orderConstraints: orderConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(orderConstraints),
      predictedEffect: predictedEffect == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedEffect),
      effectDirection: effectDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(effectDirection),
      effectMagnitude: effectMagnitude == null && nullToAbsent
          ? const Value.absent()
          : Value(effectMagnitude),
      outputProperty: outputProperty == null && nullToAbsent
          ? const Value.absent()
          : Value(outputProperty),
      equationOrLogic: equationOrLogic == null && nullToAbsent
          ? const Value.absent()
          : Value(equationOrLogic),
      sourceRefs: sourceRefs == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRefs),
      evidenceType: evidenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceType),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      extrapolationAllowed: extrapolationAllowed == null && nullToAbsent
          ? const Value.absent()
          : Value(extrapolationAllowed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InteractionRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InteractionRule(
      ruleId: serializer.fromJson<String>(json['ruleId']),
      ruleFamily: serializer.fromJson<String?>(json['ruleFamily']),
      reactantOrComponentIds: serializer.fromJson<String?>(
        json['reactantOrComponentIds'],
      ),
      ingredientConstraints: serializer.fromJson<String?>(
        json['ingredientConstraints'],
      ),
      compositionConstraints: serializer.fromJson<String?>(
        json['compositionConstraints'],
      ),
      processConstraints: serializer.fromJson<String?>(
        json['processConstraints'],
      ),
      phMin: serializer.fromJson<double?>(json['phMin']),
      phMax: serializer.fromJson<double?>(json['phMax']),
      temperatureMin: serializer.fromJson<double?>(json['temperatureMin']),
      temperatureMax: serializer.fromJson<double?>(json['temperatureMax']),
      timeMin: serializer.fromJson<double?>(json['timeMin']),
      timeMax: serializer.fromJson<double?>(json['timeMax']),
      waterActivityMin: serializer.fromJson<double?>(json['waterActivityMin']),
      waterActivityMax: serializer.fromJson<double?>(json['waterActivityMax']),
      shearConstraints: serializer.fromJson<String?>(json['shearConstraints']),
      orderConstraints: serializer.fromJson<String?>(json['orderConstraints']),
      predictedEffect: serializer.fromJson<String?>(json['predictedEffect']),
      effectDirection: serializer.fromJson<String?>(json['effectDirection']),
      effectMagnitude: serializer.fromJson<String?>(json['effectMagnitude']),
      outputProperty: serializer.fromJson<String?>(json['outputProperty']),
      equationOrLogic: serializer.fromJson<String?>(json['equationOrLogic']),
      sourceRefs: serializer.fromJson<String?>(json['sourceRefs']),
      evidenceType: serializer.fromJson<String?>(json['evidenceType']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      extrapolationAllowed: serializer.fromJson<bool?>(
        json['extrapolationAllowed'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ruleId': serializer.toJson<String>(ruleId),
      'ruleFamily': serializer.toJson<String?>(ruleFamily),
      'reactantOrComponentIds': serializer.toJson<String?>(
        reactantOrComponentIds,
      ),
      'ingredientConstraints': serializer.toJson<String?>(
        ingredientConstraints,
      ),
      'compositionConstraints': serializer.toJson<String?>(
        compositionConstraints,
      ),
      'processConstraints': serializer.toJson<String?>(processConstraints),
      'phMin': serializer.toJson<double?>(phMin),
      'phMax': serializer.toJson<double?>(phMax),
      'temperatureMin': serializer.toJson<double?>(temperatureMin),
      'temperatureMax': serializer.toJson<double?>(temperatureMax),
      'timeMin': serializer.toJson<double?>(timeMin),
      'timeMax': serializer.toJson<double?>(timeMax),
      'waterActivityMin': serializer.toJson<double?>(waterActivityMin),
      'waterActivityMax': serializer.toJson<double?>(waterActivityMax),
      'shearConstraints': serializer.toJson<String?>(shearConstraints),
      'orderConstraints': serializer.toJson<String?>(orderConstraints),
      'predictedEffect': serializer.toJson<String?>(predictedEffect),
      'effectDirection': serializer.toJson<String?>(effectDirection),
      'effectMagnitude': serializer.toJson<String?>(effectMagnitude),
      'outputProperty': serializer.toJson<String?>(outputProperty),
      'equationOrLogic': serializer.toJson<String?>(equationOrLogic),
      'sourceRefs': serializer.toJson<String?>(sourceRefs),
      'evidenceType': serializer.toJson<String?>(evidenceType),
      'confidence': serializer.toJson<double?>(confidence),
      'extrapolationAllowed': serializer.toJson<bool?>(extrapolationAllowed),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InteractionRule copyWith({
    String? ruleId,
    Value<String?> ruleFamily = const Value.absent(),
    Value<String?> reactantOrComponentIds = const Value.absent(),
    Value<String?> ingredientConstraints = const Value.absent(),
    Value<String?> compositionConstraints = const Value.absent(),
    Value<String?> processConstraints = const Value.absent(),
    Value<double?> phMin = const Value.absent(),
    Value<double?> phMax = const Value.absent(),
    Value<double?> temperatureMin = const Value.absent(),
    Value<double?> temperatureMax = const Value.absent(),
    Value<double?> timeMin = const Value.absent(),
    Value<double?> timeMax = const Value.absent(),
    Value<double?> waterActivityMin = const Value.absent(),
    Value<double?> waterActivityMax = const Value.absent(),
    Value<String?> shearConstraints = const Value.absent(),
    Value<String?> orderConstraints = const Value.absent(),
    Value<String?> predictedEffect = const Value.absent(),
    Value<String?> effectDirection = const Value.absent(),
    Value<String?> effectMagnitude = const Value.absent(),
    Value<String?> outputProperty = const Value.absent(),
    Value<String?> equationOrLogic = const Value.absent(),
    Value<String?> sourceRefs = const Value.absent(),
    Value<String?> evidenceType = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<bool?> extrapolationAllowed = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => InteractionRule(
    ruleId: ruleId ?? this.ruleId,
    ruleFamily: ruleFamily.present ? ruleFamily.value : this.ruleFamily,
    reactantOrComponentIds: reactantOrComponentIds.present
        ? reactantOrComponentIds.value
        : this.reactantOrComponentIds,
    ingredientConstraints: ingredientConstraints.present
        ? ingredientConstraints.value
        : this.ingredientConstraints,
    compositionConstraints: compositionConstraints.present
        ? compositionConstraints.value
        : this.compositionConstraints,
    processConstraints: processConstraints.present
        ? processConstraints.value
        : this.processConstraints,
    phMin: phMin.present ? phMin.value : this.phMin,
    phMax: phMax.present ? phMax.value : this.phMax,
    temperatureMin: temperatureMin.present
        ? temperatureMin.value
        : this.temperatureMin,
    temperatureMax: temperatureMax.present
        ? temperatureMax.value
        : this.temperatureMax,
    timeMin: timeMin.present ? timeMin.value : this.timeMin,
    timeMax: timeMax.present ? timeMax.value : this.timeMax,
    waterActivityMin: waterActivityMin.present
        ? waterActivityMin.value
        : this.waterActivityMin,
    waterActivityMax: waterActivityMax.present
        ? waterActivityMax.value
        : this.waterActivityMax,
    shearConstraints: shearConstraints.present
        ? shearConstraints.value
        : this.shearConstraints,
    orderConstraints: orderConstraints.present
        ? orderConstraints.value
        : this.orderConstraints,
    predictedEffect: predictedEffect.present
        ? predictedEffect.value
        : this.predictedEffect,
    effectDirection: effectDirection.present
        ? effectDirection.value
        : this.effectDirection,
    effectMagnitude: effectMagnitude.present
        ? effectMagnitude.value
        : this.effectMagnitude,
    outputProperty: outputProperty.present
        ? outputProperty.value
        : this.outputProperty,
    equationOrLogic: equationOrLogic.present
        ? equationOrLogic.value
        : this.equationOrLogic,
    sourceRefs: sourceRefs.present ? sourceRefs.value : this.sourceRefs,
    evidenceType: evidenceType.present ? evidenceType.value : this.evidenceType,
    confidence: confidence.present ? confidence.value : this.confidence,
    extrapolationAllowed: extrapolationAllowed.present
        ? extrapolationAllowed.value
        : this.extrapolationAllowed,
    notes: notes.present ? notes.value : this.notes,
  );
  InteractionRule copyWithCompanion(InteractionRulesCompanion data) {
    return InteractionRule(
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      ruleFamily: data.ruleFamily.present
          ? data.ruleFamily.value
          : this.ruleFamily,
      reactantOrComponentIds: data.reactantOrComponentIds.present
          ? data.reactantOrComponentIds.value
          : this.reactantOrComponentIds,
      ingredientConstraints: data.ingredientConstraints.present
          ? data.ingredientConstraints.value
          : this.ingredientConstraints,
      compositionConstraints: data.compositionConstraints.present
          ? data.compositionConstraints.value
          : this.compositionConstraints,
      processConstraints: data.processConstraints.present
          ? data.processConstraints.value
          : this.processConstraints,
      phMin: data.phMin.present ? data.phMin.value : this.phMin,
      phMax: data.phMax.present ? data.phMax.value : this.phMax,
      temperatureMin: data.temperatureMin.present
          ? data.temperatureMin.value
          : this.temperatureMin,
      temperatureMax: data.temperatureMax.present
          ? data.temperatureMax.value
          : this.temperatureMax,
      timeMin: data.timeMin.present ? data.timeMin.value : this.timeMin,
      timeMax: data.timeMax.present ? data.timeMax.value : this.timeMax,
      waterActivityMin: data.waterActivityMin.present
          ? data.waterActivityMin.value
          : this.waterActivityMin,
      waterActivityMax: data.waterActivityMax.present
          ? data.waterActivityMax.value
          : this.waterActivityMax,
      shearConstraints: data.shearConstraints.present
          ? data.shearConstraints.value
          : this.shearConstraints,
      orderConstraints: data.orderConstraints.present
          ? data.orderConstraints.value
          : this.orderConstraints,
      predictedEffect: data.predictedEffect.present
          ? data.predictedEffect.value
          : this.predictedEffect,
      effectDirection: data.effectDirection.present
          ? data.effectDirection.value
          : this.effectDirection,
      effectMagnitude: data.effectMagnitude.present
          ? data.effectMagnitude.value
          : this.effectMagnitude,
      outputProperty: data.outputProperty.present
          ? data.outputProperty.value
          : this.outputProperty,
      equationOrLogic: data.equationOrLogic.present
          ? data.equationOrLogic.value
          : this.equationOrLogic,
      sourceRefs: data.sourceRefs.present
          ? data.sourceRefs.value
          : this.sourceRefs,
      evidenceType: data.evidenceType.present
          ? data.evidenceType.value
          : this.evidenceType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      extrapolationAllowed: data.extrapolationAllowed.present
          ? data.extrapolationAllowed.value
          : this.extrapolationAllowed,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InteractionRule(')
          ..write('ruleId: $ruleId, ')
          ..write('ruleFamily: $ruleFamily, ')
          ..write('reactantOrComponentIds: $reactantOrComponentIds, ')
          ..write('ingredientConstraints: $ingredientConstraints, ')
          ..write('compositionConstraints: $compositionConstraints, ')
          ..write('processConstraints: $processConstraints, ')
          ..write('phMin: $phMin, ')
          ..write('phMax: $phMax, ')
          ..write('temperatureMin: $temperatureMin, ')
          ..write('temperatureMax: $temperatureMax, ')
          ..write('timeMin: $timeMin, ')
          ..write('timeMax: $timeMax, ')
          ..write('waterActivityMin: $waterActivityMin, ')
          ..write('waterActivityMax: $waterActivityMax, ')
          ..write('shearConstraints: $shearConstraints, ')
          ..write('orderConstraints: $orderConstraints, ')
          ..write('predictedEffect: $predictedEffect, ')
          ..write('effectDirection: $effectDirection, ')
          ..write('effectMagnitude: $effectMagnitude, ')
          ..write('outputProperty: $outputProperty, ')
          ..write('equationOrLogic: $equationOrLogic, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence, ')
          ..write('extrapolationAllowed: $extrapolationAllowed, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ruleId,
    ruleFamily,
    reactantOrComponentIds,
    ingredientConstraints,
    compositionConstraints,
    processConstraints,
    phMin,
    phMax,
    temperatureMin,
    temperatureMax,
    timeMin,
    timeMax,
    waterActivityMin,
    waterActivityMax,
    shearConstraints,
    orderConstraints,
    predictedEffect,
    effectDirection,
    effectMagnitude,
    outputProperty,
    equationOrLogic,
    sourceRefs,
    evidenceType,
    confidence,
    extrapolationAllowed,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractionRule &&
          other.ruleId == this.ruleId &&
          other.ruleFamily == this.ruleFamily &&
          other.reactantOrComponentIds == this.reactantOrComponentIds &&
          other.ingredientConstraints == this.ingredientConstraints &&
          other.compositionConstraints == this.compositionConstraints &&
          other.processConstraints == this.processConstraints &&
          other.phMin == this.phMin &&
          other.phMax == this.phMax &&
          other.temperatureMin == this.temperatureMin &&
          other.temperatureMax == this.temperatureMax &&
          other.timeMin == this.timeMin &&
          other.timeMax == this.timeMax &&
          other.waterActivityMin == this.waterActivityMin &&
          other.waterActivityMax == this.waterActivityMax &&
          other.shearConstraints == this.shearConstraints &&
          other.orderConstraints == this.orderConstraints &&
          other.predictedEffect == this.predictedEffect &&
          other.effectDirection == this.effectDirection &&
          other.effectMagnitude == this.effectMagnitude &&
          other.outputProperty == this.outputProperty &&
          other.equationOrLogic == this.equationOrLogic &&
          other.sourceRefs == this.sourceRefs &&
          other.evidenceType == this.evidenceType &&
          other.confidence == this.confidence &&
          other.extrapolationAllowed == this.extrapolationAllowed &&
          other.notes == this.notes);
}

class InteractionRulesCompanion extends UpdateCompanion<InteractionRule> {
  final Value<String> ruleId;
  final Value<String?> ruleFamily;
  final Value<String?> reactantOrComponentIds;
  final Value<String?> ingredientConstraints;
  final Value<String?> compositionConstraints;
  final Value<String?> processConstraints;
  final Value<double?> phMin;
  final Value<double?> phMax;
  final Value<double?> temperatureMin;
  final Value<double?> temperatureMax;
  final Value<double?> timeMin;
  final Value<double?> timeMax;
  final Value<double?> waterActivityMin;
  final Value<double?> waterActivityMax;
  final Value<String?> shearConstraints;
  final Value<String?> orderConstraints;
  final Value<String?> predictedEffect;
  final Value<String?> effectDirection;
  final Value<String?> effectMagnitude;
  final Value<String?> outputProperty;
  final Value<String?> equationOrLogic;
  final Value<String?> sourceRefs;
  final Value<String?> evidenceType;
  final Value<double?> confidence;
  final Value<bool?> extrapolationAllowed;
  final Value<String?> notes;
  final Value<int> rowid;
  const InteractionRulesCompanion({
    this.ruleId = const Value.absent(),
    this.ruleFamily = const Value.absent(),
    this.reactantOrComponentIds = const Value.absent(),
    this.ingredientConstraints = const Value.absent(),
    this.compositionConstraints = const Value.absent(),
    this.processConstraints = const Value.absent(),
    this.phMin = const Value.absent(),
    this.phMax = const Value.absent(),
    this.temperatureMin = const Value.absent(),
    this.temperatureMax = const Value.absent(),
    this.timeMin = const Value.absent(),
    this.timeMax = const Value.absent(),
    this.waterActivityMin = const Value.absent(),
    this.waterActivityMax = const Value.absent(),
    this.shearConstraints = const Value.absent(),
    this.orderConstraints = const Value.absent(),
    this.predictedEffect = const Value.absent(),
    this.effectDirection = const Value.absent(),
    this.effectMagnitude = const Value.absent(),
    this.outputProperty = const Value.absent(),
    this.equationOrLogic = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.extrapolationAllowed = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InteractionRulesCompanion.insert({
    required String ruleId,
    this.ruleFamily = const Value.absent(),
    this.reactantOrComponentIds = const Value.absent(),
    this.ingredientConstraints = const Value.absent(),
    this.compositionConstraints = const Value.absent(),
    this.processConstraints = const Value.absent(),
    this.phMin = const Value.absent(),
    this.phMax = const Value.absent(),
    this.temperatureMin = const Value.absent(),
    this.temperatureMax = const Value.absent(),
    this.timeMin = const Value.absent(),
    this.timeMax = const Value.absent(),
    this.waterActivityMin = const Value.absent(),
    this.waterActivityMax = const Value.absent(),
    this.shearConstraints = const Value.absent(),
    this.orderConstraints = const Value.absent(),
    this.predictedEffect = const Value.absent(),
    this.effectDirection = const Value.absent(),
    this.effectMagnitude = const Value.absent(),
    this.outputProperty = const Value.absent(),
    this.equationOrLogic = const Value.absent(),
    this.sourceRefs = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.extrapolationAllowed = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ruleId = Value(ruleId);
  static Insertable<InteractionRule> custom({
    Expression<String>? ruleId,
    Expression<String>? ruleFamily,
    Expression<String>? reactantOrComponentIds,
    Expression<String>? ingredientConstraints,
    Expression<String>? compositionConstraints,
    Expression<String>? processConstraints,
    Expression<double>? phMin,
    Expression<double>? phMax,
    Expression<double>? temperatureMin,
    Expression<double>? temperatureMax,
    Expression<double>? timeMin,
    Expression<double>? timeMax,
    Expression<double>? waterActivityMin,
    Expression<double>? waterActivityMax,
    Expression<String>? shearConstraints,
    Expression<String>? orderConstraints,
    Expression<String>? predictedEffect,
    Expression<String>? effectDirection,
    Expression<String>? effectMagnitude,
    Expression<String>? outputProperty,
    Expression<String>? equationOrLogic,
    Expression<String>? sourceRefs,
    Expression<String>? evidenceType,
    Expression<double>? confidence,
    Expression<bool>? extrapolationAllowed,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ruleId != null) 'rule_id': ruleId,
      if (ruleFamily != null) 'rule_family': ruleFamily,
      if (reactantOrComponentIds != null)
        'reactant_or_component_ids': reactantOrComponentIds,
      if (ingredientConstraints != null)
        'ingredient_constraints': ingredientConstraints,
      if (compositionConstraints != null)
        'composition_constraints': compositionConstraints,
      if (processConstraints != null) 'process_constraints': processConstraints,
      if (phMin != null) 'ph_min': phMin,
      if (phMax != null) 'ph_max': phMax,
      if (temperatureMin != null) 'temperature_min': temperatureMin,
      if (temperatureMax != null) 'temperature_max': temperatureMax,
      if (timeMin != null) 'time_min': timeMin,
      if (timeMax != null) 'time_max': timeMax,
      if (waterActivityMin != null) 'water_activity_min': waterActivityMin,
      if (waterActivityMax != null) 'water_activity_max': waterActivityMax,
      if (shearConstraints != null) 'shear_constraints': shearConstraints,
      if (orderConstraints != null) 'order_constraints': orderConstraints,
      if (predictedEffect != null) 'predicted_effect': predictedEffect,
      if (effectDirection != null) 'effect_direction': effectDirection,
      if (effectMagnitude != null) 'effect_magnitude': effectMagnitude,
      if (outputProperty != null) 'output_property': outputProperty,
      if (equationOrLogic != null) 'equation_or_logic': equationOrLogic,
      if (sourceRefs != null) 'source_refs': sourceRefs,
      if (evidenceType != null) 'evidence_type': evidenceType,
      if (confidence != null) 'confidence': confidence,
      if (extrapolationAllowed != null)
        'extrapolation_allowed': extrapolationAllowed,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InteractionRulesCompanion copyWith({
    Value<String>? ruleId,
    Value<String?>? ruleFamily,
    Value<String?>? reactantOrComponentIds,
    Value<String?>? ingredientConstraints,
    Value<String?>? compositionConstraints,
    Value<String?>? processConstraints,
    Value<double?>? phMin,
    Value<double?>? phMax,
    Value<double?>? temperatureMin,
    Value<double?>? temperatureMax,
    Value<double?>? timeMin,
    Value<double?>? timeMax,
    Value<double?>? waterActivityMin,
    Value<double?>? waterActivityMax,
    Value<String?>? shearConstraints,
    Value<String?>? orderConstraints,
    Value<String?>? predictedEffect,
    Value<String?>? effectDirection,
    Value<String?>? effectMagnitude,
    Value<String?>? outputProperty,
    Value<String?>? equationOrLogic,
    Value<String?>? sourceRefs,
    Value<String?>? evidenceType,
    Value<double?>? confidence,
    Value<bool?>? extrapolationAllowed,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return InteractionRulesCompanion(
      ruleId: ruleId ?? this.ruleId,
      ruleFamily: ruleFamily ?? this.ruleFamily,
      reactantOrComponentIds:
          reactantOrComponentIds ?? this.reactantOrComponentIds,
      ingredientConstraints:
          ingredientConstraints ?? this.ingredientConstraints,
      compositionConstraints:
          compositionConstraints ?? this.compositionConstraints,
      processConstraints: processConstraints ?? this.processConstraints,
      phMin: phMin ?? this.phMin,
      phMax: phMax ?? this.phMax,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      timeMin: timeMin ?? this.timeMin,
      timeMax: timeMax ?? this.timeMax,
      waterActivityMin: waterActivityMin ?? this.waterActivityMin,
      waterActivityMax: waterActivityMax ?? this.waterActivityMax,
      shearConstraints: shearConstraints ?? this.shearConstraints,
      orderConstraints: orderConstraints ?? this.orderConstraints,
      predictedEffect: predictedEffect ?? this.predictedEffect,
      effectDirection: effectDirection ?? this.effectDirection,
      effectMagnitude: effectMagnitude ?? this.effectMagnitude,
      outputProperty: outputProperty ?? this.outputProperty,
      equationOrLogic: equationOrLogic ?? this.equationOrLogic,
      sourceRefs: sourceRefs ?? this.sourceRefs,
      evidenceType: evidenceType ?? this.evidenceType,
      confidence: confidence ?? this.confidence,
      extrapolationAllowed: extrapolationAllowed ?? this.extrapolationAllowed,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (ruleFamily.present) {
      map['rule_family'] = Variable<String>(ruleFamily.value);
    }
    if (reactantOrComponentIds.present) {
      map['reactant_or_component_ids'] = Variable<String>(
        reactantOrComponentIds.value,
      );
    }
    if (ingredientConstraints.present) {
      map['ingredient_constraints'] = Variable<String>(
        ingredientConstraints.value,
      );
    }
    if (compositionConstraints.present) {
      map['composition_constraints'] = Variable<String>(
        compositionConstraints.value,
      );
    }
    if (processConstraints.present) {
      map['process_constraints'] = Variable<String>(processConstraints.value);
    }
    if (phMin.present) {
      map['ph_min'] = Variable<double>(phMin.value);
    }
    if (phMax.present) {
      map['ph_max'] = Variable<double>(phMax.value);
    }
    if (temperatureMin.present) {
      map['temperature_min'] = Variable<double>(temperatureMin.value);
    }
    if (temperatureMax.present) {
      map['temperature_max'] = Variable<double>(temperatureMax.value);
    }
    if (timeMin.present) {
      map['time_min'] = Variable<double>(timeMin.value);
    }
    if (timeMax.present) {
      map['time_max'] = Variable<double>(timeMax.value);
    }
    if (waterActivityMin.present) {
      map['water_activity_min'] = Variable<double>(waterActivityMin.value);
    }
    if (waterActivityMax.present) {
      map['water_activity_max'] = Variable<double>(waterActivityMax.value);
    }
    if (shearConstraints.present) {
      map['shear_constraints'] = Variable<String>(shearConstraints.value);
    }
    if (orderConstraints.present) {
      map['order_constraints'] = Variable<String>(orderConstraints.value);
    }
    if (predictedEffect.present) {
      map['predicted_effect'] = Variable<String>(predictedEffect.value);
    }
    if (effectDirection.present) {
      map['effect_direction'] = Variable<String>(effectDirection.value);
    }
    if (effectMagnitude.present) {
      map['effect_magnitude'] = Variable<String>(effectMagnitude.value);
    }
    if (outputProperty.present) {
      map['output_property'] = Variable<String>(outputProperty.value);
    }
    if (equationOrLogic.present) {
      map['equation_or_logic'] = Variable<String>(equationOrLogic.value);
    }
    if (sourceRefs.present) {
      map['source_refs'] = Variable<String>(sourceRefs.value);
    }
    if (evidenceType.present) {
      map['evidence_type'] = Variable<String>(evidenceType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (extrapolationAllowed.present) {
      map['extrapolation_allowed'] = Variable<bool>(extrapolationAllowed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionRulesCompanion(')
          ..write('ruleId: $ruleId, ')
          ..write('ruleFamily: $ruleFamily, ')
          ..write('reactantOrComponentIds: $reactantOrComponentIds, ')
          ..write('ingredientConstraints: $ingredientConstraints, ')
          ..write('compositionConstraints: $compositionConstraints, ')
          ..write('processConstraints: $processConstraints, ')
          ..write('phMin: $phMin, ')
          ..write('phMax: $phMax, ')
          ..write('temperatureMin: $temperatureMin, ')
          ..write('temperatureMax: $temperatureMax, ')
          ..write('timeMin: $timeMin, ')
          ..write('timeMax: $timeMax, ')
          ..write('waterActivityMin: $waterActivityMin, ')
          ..write('waterActivityMax: $waterActivityMax, ')
          ..write('shearConstraints: $shearConstraints, ')
          ..write('orderConstraints: $orderConstraints, ')
          ..write('predictedEffect: $predictedEffect, ')
          ..write('effectDirection: $effectDirection, ')
          ..write('effectMagnitude: $effectMagnitude, ')
          ..write('outputProperty: $outputProperty, ')
          ..write('equationOrLogic: $equationOrLogic, ')
          ..write('sourceRefs: $sourceRefs, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('confidence: $confidence, ')
          ..write('extrapolationAllowed: $extrapolationAllowed, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessOperationsTable extends ProcessOperations
    with TableInfo<$ProcessOperationsTable, ProcessOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tMinCMeta = const VerificationMeta('tMinC');
  @override
  late final GeneratedColumn<double> tMinC = GeneratedColumn<double>(
    'T_min_C',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tMaxCMeta = const VerificationMeta('tMaxC');
  @override
  late final GeneratedColumn<double> tMaxC = GeneratedColumn<double>(
    'T_max_C',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<double> durationMin = GeneratedColumn<double>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pressureMeta = const VerificationMeta(
    'pressure',
  );
  @override
  late final GeneratedColumn<String> pressure = GeneratedColumn<String>(
    'pressure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shearRateS1Meta = const VerificationMeta(
    'shearRateS1',
  );
  @override
  late final GeneratedColumn<double> shearRateS1 = GeneratedColumn<double>(
    'shear_rate_s-1',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mixingRpmMeta = const VerificationMeta(
    'mixingRpm',
  );
  @override
  late final GeneratedColumn<String> mixingRpm = GeneratedColumn<String>(
    'mixing_rpm',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyInputMeta = const VerificationMeta(
    'energyInput',
  );
  @override
  late final GeneratedColumn<double> energyInput = GeneratedColumn<double>(
    'energy_input',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coolingRateMeta = const VerificationMeta(
    'coolingRate',
  );
  @override
  late final GeneratedColumn<double> coolingRate = GeneratedColumn<double>(
    'cooling_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heatingRateMeta = const VerificationMeta(
    'heatingRate',
  );
  @override
  late final GeneratedColumn<double> heatingRate = GeneratedColumn<double>(
    'heating_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPhMeta = const VerificationMeta(
    'targetPh',
  );
  @override
  late final GeneratedColumn<double> targetPh = GeneratedColumn<double>(
    'target_ph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetAwMeta = const VerificationMeta(
    'targetAw',
  );
  @override
  late final GeneratedColumn<double> targetAw = GeneratedColumn<double>(
    'target_aw',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetBrixMeta = const VerificationMeta(
    'targetBrix',
  );
  @override
  late final GeneratedColumn<double> targetBrix = GeneratedColumn<double>(
    'target_brix',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _particleSizeTargetUmMeta =
      const VerificationMeta('particleSizeTargetUm');
  @override
  late final GeneratedColumn<double> particleSizeTargetUm =
      GeneratedColumn<double>(
        'particle_size_target_um',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _oxygenExposureMeta = const VerificationMeta(
    'oxygenExposure',
  );
  @override
  late final GeneratedColumn<String> oxygenExposure = GeneratedColumn<String>(
    'oxygen_exposure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atmosphereMeta = const VerificationMeta(
    'atmosphere',
  );
  @override
  late final GeneratedColumn<String> atmosphere = GeneratedColumn<String>(
    'atmosphere',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionModeMeta = const VerificationMeta(
    'additionMode',
  );
  @override
  late final GeneratedColumn<String> additionMode = GeneratedColumn<String>(
    'addition_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restTimeMeta = const VerificationMeta(
    'restTime',
  );
  @override
  late final GeneratedColumn<double> restTime = GeneratedColumn<double>(
    'rest_time',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    family,
    name,
    tMinC,
    tMaxC,
    durationMin,
    pressure,
    shearRateS1,
    mixingRpm,
    energyInput,
    coolingRate,
    heatingRate,
    targetPh,
    targetAw,
    targetBrix,
    particleSizeTargetUm,
    oxygenExposure,
    atmosphere,
    orderIndex,
    additionMode,
    restTime,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'process_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('T_min_C')) {
      context.handle(
        _tMinCMeta,
        tMinC.isAcceptableOrUnknown(data['T_min_C']!, _tMinCMeta),
      );
    }
    if (data.containsKey('T_max_C')) {
      context.handle(
        _tMaxCMeta,
        tMaxC.isAcceptableOrUnknown(data['T_max_C']!, _tMaxCMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('pressure')) {
      context.handle(
        _pressureMeta,
        pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta),
      );
    }
    if (data.containsKey('shear_rate_s-1')) {
      context.handle(
        _shearRateS1Meta,
        shearRateS1.isAcceptableOrUnknown(
          data['shear_rate_s-1']!,
          _shearRateS1Meta,
        ),
      );
    }
    if (data.containsKey('mixing_rpm')) {
      context.handle(
        _mixingRpmMeta,
        mixingRpm.isAcceptableOrUnknown(data['mixing_rpm']!, _mixingRpmMeta),
      );
    }
    if (data.containsKey('energy_input')) {
      context.handle(
        _energyInputMeta,
        energyInput.isAcceptableOrUnknown(
          data['energy_input']!,
          _energyInputMeta,
        ),
      );
    }
    if (data.containsKey('cooling_rate')) {
      context.handle(
        _coolingRateMeta,
        coolingRate.isAcceptableOrUnknown(
          data['cooling_rate']!,
          _coolingRateMeta,
        ),
      );
    }
    if (data.containsKey('heating_rate')) {
      context.handle(
        _heatingRateMeta,
        heatingRate.isAcceptableOrUnknown(
          data['heating_rate']!,
          _heatingRateMeta,
        ),
      );
    }
    if (data.containsKey('target_ph')) {
      context.handle(
        _targetPhMeta,
        targetPh.isAcceptableOrUnknown(data['target_ph']!, _targetPhMeta),
      );
    }
    if (data.containsKey('target_aw')) {
      context.handle(
        _targetAwMeta,
        targetAw.isAcceptableOrUnknown(data['target_aw']!, _targetAwMeta),
      );
    }
    if (data.containsKey('target_brix')) {
      context.handle(
        _targetBrixMeta,
        targetBrix.isAcceptableOrUnknown(data['target_brix']!, _targetBrixMeta),
      );
    }
    if (data.containsKey('particle_size_target_um')) {
      context.handle(
        _particleSizeTargetUmMeta,
        particleSizeTargetUm.isAcceptableOrUnknown(
          data['particle_size_target_um']!,
          _particleSizeTargetUmMeta,
        ),
      );
    }
    if (data.containsKey('oxygen_exposure')) {
      context.handle(
        _oxygenExposureMeta,
        oxygenExposure.isAcceptableOrUnknown(
          data['oxygen_exposure']!,
          _oxygenExposureMeta,
        ),
      );
    }
    if (data.containsKey('atmosphere')) {
      context.handle(
        _atmosphereMeta,
        atmosphere.isAcceptableOrUnknown(data['atmosphere']!, _atmosphereMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('addition_mode')) {
      context.handle(
        _additionModeMeta,
        additionMode.isAcceptableOrUnknown(
          data['addition_mode']!,
          _additionModeMeta,
        ),
      );
    }
    if (data.containsKey('rest_time')) {
      context.handle(
        _restTimeMeta,
        restTime.isAcceptableOrUnknown(data['rest_time']!, _restTimeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  ProcessOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessOperation(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      tMinC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}T_min_C'],
      ),
      tMaxC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}T_max_C'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_min'],
      ),
      pressure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pressure'],
      ),
      shearRateS1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shear_rate_s-1'],
      ),
      mixingRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mixing_rpm'],
      ),
      energyInput: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_input'],
      ),
      coolingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cooling_rate'],
      ),
      heatingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heating_rate'],
      ),
      targetPh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_ph'],
      ),
      targetAw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_aw'],
      ),
      targetBrix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_brix'],
      ),
      particleSizeTargetUm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}particle_size_target_um'],
      ),
      oxygenExposure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oxygen_exposure'],
      ),
      atmosphere: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}atmosphere'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      ),
      additionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}addition_mode'],
      ),
      restTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rest_time'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ProcessOperationsTable createAlias(String alias) {
    return $ProcessOperationsTable(attachedDatabase, alias);
  }
}

class ProcessOperation extends DataClass
    implements Insertable<ProcessOperation> {
  final String opId;
  final String? family;
  final String? name;
  final double? tMinC;
  final double? tMaxC;
  final double? durationMin;
  final String? pressure;
  final double? shearRateS1;
  final String? mixingRpm;
  final double? energyInput;
  final double? coolingRate;
  final double? heatingRate;
  final double? targetPh;
  final double? targetAw;
  final double? targetBrix;
  final double? particleSizeTargetUm;
  final String? oxygenExposure;
  final String? atmosphere;
  final int? orderIndex;
  final String? additionMode;
  final double? restTime;
  final String? notes;
  const ProcessOperation({
    required this.opId,
    this.family,
    this.name,
    this.tMinC,
    this.tMaxC,
    this.durationMin,
    this.pressure,
    this.shearRateS1,
    this.mixingRpm,
    this.energyInput,
    this.coolingRate,
    this.heatingRate,
    this.targetPh,
    this.targetAw,
    this.targetBrix,
    this.particleSizeTargetUm,
    this.oxygenExposure,
    this.atmosphere,
    this.orderIndex,
    this.additionMode,
    this.restTime,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    if (!nullToAbsent || family != null) {
      map['family'] = Variable<String>(family);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || tMinC != null) {
      map['T_min_C'] = Variable<double>(tMinC);
    }
    if (!nullToAbsent || tMaxC != null) {
      map['T_max_C'] = Variable<double>(tMaxC);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<double>(durationMin);
    }
    if (!nullToAbsent || pressure != null) {
      map['pressure'] = Variable<String>(pressure);
    }
    if (!nullToAbsent || shearRateS1 != null) {
      map['shear_rate_s-1'] = Variable<double>(shearRateS1);
    }
    if (!nullToAbsent || mixingRpm != null) {
      map['mixing_rpm'] = Variable<String>(mixingRpm);
    }
    if (!nullToAbsent || energyInput != null) {
      map['energy_input'] = Variable<double>(energyInput);
    }
    if (!nullToAbsent || coolingRate != null) {
      map['cooling_rate'] = Variable<double>(coolingRate);
    }
    if (!nullToAbsent || heatingRate != null) {
      map['heating_rate'] = Variable<double>(heatingRate);
    }
    if (!nullToAbsent || targetPh != null) {
      map['target_ph'] = Variable<double>(targetPh);
    }
    if (!nullToAbsent || targetAw != null) {
      map['target_aw'] = Variable<double>(targetAw);
    }
    if (!nullToAbsent || targetBrix != null) {
      map['target_brix'] = Variable<double>(targetBrix);
    }
    if (!nullToAbsent || particleSizeTargetUm != null) {
      map['particle_size_target_um'] = Variable<double>(particleSizeTargetUm);
    }
    if (!nullToAbsent || oxygenExposure != null) {
      map['oxygen_exposure'] = Variable<String>(oxygenExposure);
    }
    if (!nullToAbsent || atmosphere != null) {
      map['atmosphere'] = Variable<String>(atmosphere);
    }
    if (!nullToAbsent || orderIndex != null) {
      map['order_index'] = Variable<int>(orderIndex);
    }
    if (!nullToAbsent || additionMode != null) {
      map['addition_mode'] = Variable<String>(additionMode);
    }
    if (!nullToAbsent || restTime != null) {
      map['rest_time'] = Variable<double>(restTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ProcessOperationsCompanion toCompanion(bool nullToAbsent) {
    return ProcessOperationsCompanion(
      opId: Value(opId),
      family: family == null && nullToAbsent
          ? const Value.absent()
          : Value(family),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      tMinC: tMinC == null && nullToAbsent
          ? const Value.absent()
          : Value(tMinC),
      tMaxC: tMaxC == null && nullToAbsent
          ? const Value.absent()
          : Value(tMaxC),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      pressure: pressure == null && nullToAbsent
          ? const Value.absent()
          : Value(pressure),
      shearRateS1: shearRateS1 == null && nullToAbsent
          ? const Value.absent()
          : Value(shearRateS1),
      mixingRpm: mixingRpm == null && nullToAbsent
          ? const Value.absent()
          : Value(mixingRpm),
      energyInput: energyInput == null && nullToAbsent
          ? const Value.absent()
          : Value(energyInput),
      coolingRate: coolingRate == null && nullToAbsent
          ? const Value.absent()
          : Value(coolingRate),
      heatingRate: heatingRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heatingRate),
      targetPh: targetPh == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPh),
      targetAw: targetAw == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAw),
      targetBrix: targetBrix == null && nullToAbsent
          ? const Value.absent()
          : Value(targetBrix),
      particleSizeTargetUm: particleSizeTargetUm == null && nullToAbsent
          ? const Value.absent()
          : Value(particleSizeTargetUm),
      oxygenExposure: oxygenExposure == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygenExposure),
      atmosphere: atmosphere == null && nullToAbsent
          ? const Value.absent()
          : Value(atmosphere),
      orderIndex: orderIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(orderIndex),
      additionMode: additionMode == null && nullToAbsent
          ? const Value.absent()
          : Value(additionMode),
      restTime: restTime == null && nullToAbsent
          ? const Value.absent()
          : Value(restTime),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ProcessOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessOperation(
      opId: serializer.fromJson<String>(json['opId']),
      family: serializer.fromJson<String?>(json['family']),
      name: serializer.fromJson<String?>(json['name']),
      tMinC: serializer.fromJson<double?>(json['tMinC']),
      tMaxC: serializer.fromJson<double?>(json['tMaxC']),
      durationMin: serializer.fromJson<double?>(json['durationMin']),
      pressure: serializer.fromJson<String?>(json['pressure']),
      shearRateS1: serializer.fromJson<double?>(json['shearRateS1']),
      mixingRpm: serializer.fromJson<String?>(json['mixingRpm']),
      energyInput: serializer.fromJson<double?>(json['energyInput']),
      coolingRate: serializer.fromJson<double?>(json['coolingRate']),
      heatingRate: serializer.fromJson<double?>(json['heatingRate']),
      targetPh: serializer.fromJson<double?>(json['targetPh']),
      targetAw: serializer.fromJson<double?>(json['targetAw']),
      targetBrix: serializer.fromJson<double?>(json['targetBrix']),
      particleSizeTargetUm: serializer.fromJson<double?>(
        json['particleSizeTargetUm'],
      ),
      oxygenExposure: serializer.fromJson<String?>(json['oxygenExposure']),
      atmosphere: serializer.fromJson<String?>(json['atmosphere']),
      orderIndex: serializer.fromJson<int?>(json['orderIndex']),
      additionMode: serializer.fromJson<String?>(json['additionMode']),
      restTime: serializer.fromJson<double?>(json['restTime']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'family': serializer.toJson<String?>(family),
      'name': serializer.toJson<String?>(name),
      'tMinC': serializer.toJson<double?>(tMinC),
      'tMaxC': serializer.toJson<double?>(tMaxC),
      'durationMin': serializer.toJson<double?>(durationMin),
      'pressure': serializer.toJson<String?>(pressure),
      'shearRateS1': serializer.toJson<double?>(shearRateS1),
      'mixingRpm': serializer.toJson<String?>(mixingRpm),
      'energyInput': serializer.toJson<double?>(energyInput),
      'coolingRate': serializer.toJson<double?>(coolingRate),
      'heatingRate': serializer.toJson<double?>(heatingRate),
      'targetPh': serializer.toJson<double?>(targetPh),
      'targetAw': serializer.toJson<double?>(targetAw),
      'targetBrix': serializer.toJson<double?>(targetBrix),
      'particleSizeTargetUm': serializer.toJson<double?>(particleSizeTargetUm),
      'oxygenExposure': serializer.toJson<String?>(oxygenExposure),
      'atmosphere': serializer.toJson<String?>(atmosphere),
      'orderIndex': serializer.toJson<int?>(orderIndex),
      'additionMode': serializer.toJson<String?>(additionMode),
      'restTime': serializer.toJson<double?>(restTime),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ProcessOperation copyWith({
    String? opId,
    Value<String?> family = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<double?> tMinC = const Value.absent(),
    Value<double?> tMaxC = const Value.absent(),
    Value<double?> durationMin = const Value.absent(),
    Value<String?> pressure = const Value.absent(),
    Value<double?> shearRateS1 = const Value.absent(),
    Value<String?> mixingRpm = const Value.absent(),
    Value<double?> energyInput = const Value.absent(),
    Value<double?> coolingRate = const Value.absent(),
    Value<double?> heatingRate = const Value.absent(),
    Value<double?> targetPh = const Value.absent(),
    Value<double?> targetAw = const Value.absent(),
    Value<double?> targetBrix = const Value.absent(),
    Value<double?> particleSizeTargetUm = const Value.absent(),
    Value<String?> oxygenExposure = const Value.absent(),
    Value<String?> atmosphere = const Value.absent(),
    Value<int?> orderIndex = const Value.absent(),
    Value<String?> additionMode = const Value.absent(),
    Value<double?> restTime = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ProcessOperation(
    opId: opId ?? this.opId,
    family: family.present ? family.value : this.family,
    name: name.present ? name.value : this.name,
    tMinC: tMinC.present ? tMinC.value : this.tMinC,
    tMaxC: tMaxC.present ? tMaxC.value : this.tMaxC,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    pressure: pressure.present ? pressure.value : this.pressure,
    shearRateS1: shearRateS1.present ? shearRateS1.value : this.shearRateS1,
    mixingRpm: mixingRpm.present ? mixingRpm.value : this.mixingRpm,
    energyInput: energyInput.present ? energyInput.value : this.energyInput,
    coolingRate: coolingRate.present ? coolingRate.value : this.coolingRate,
    heatingRate: heatingRate.present ? heatingRate.value : this.heatingRate,
    targetPh: targetPh.present ? targetPh.value : this.targetPh,
    targetAw: targetAw.present ? targetAw.value : this.targetAw,
    targetBrix: targetBrix.present ? targetBrix.value : this.targetBrix,
    particleSizeTargetUm: particleSizeTargetUm.present
        ? particleSizeTargetUm.value
        : this.particleSizeTargetUm,
    oxygenExposure: oxygenExposure.present
        ? oxygenExposure.value
        : this.oxygenExposure,
    atmosphere: atmosphere.present ? atmosphere.value : this.atmosphere,
    orderIndex: orderIndex.present ? orderIndex.value : this.orderIndex,
    additionMode: additionMode.present ? additionMode.value : this.additionMode,
    restTime: restTime.present ? restTime.value : this.restTime,
    notes: notes.present ? notes.value : this.notes,
  );
  ProcessOperation copyWithCompanion(ProcessOperationsCompanion data) {
    return ProcessOperation(
      opId: data.opId.present ? data.opId.value : this.opId,
      family: data.family.present ? data.family.value : this.family,
      name: data.name.present ? data.name.value : this.name,
      tMinC: data.tMinC.present ? data.tMinC.value : this.tMinC,
      tMaxC: data.tMaxC.present ? data.tMaxC.value : this.tMaxC,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      shearRateS1: data.shearRateS1.present
          ? data.shearRateS1.value
          : this.shearRateS1,
      mixingRpm: data.mixingRpm.present ? data.mixingRpm.value : this.mixingRpm,
      energyInput: data.energyInput.present
          ? data.energyInput.value
          : this.energyInput,
      coolingRate: data.coolingRate.present
          ? data.coolingRate.value
          : this.coolingRate,
      heatingRate: data.heatingRate.present
          ? data.heatingRate.value
          : this.heatingRate,
      targetPh: data.targetPh.present ? data.targetPh.value : this.targetPh,
      targetAw: data.targetAw.present ? data.targetAw.value : this.targetAw,
      targetBrix: data.targetBrix.present
          ? data.targetBrix.value
          : this.targetBrix,
      particleSizeTargetUm: data.particleSizeTargetUm.present
          ? data.particleSizeTargetUm.value
          : this.particleSizeTargetUm,
      oxygenExposure: data.oxygenExposure.present
          ? data.oxygenExposure.value
          : this.oxygenExposure,
      atmosphere: data.atmosphere.present
          ? data.atmosphere.value
          : this.atmosphere,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      additionMode: data.additionMode.present
          ? data.additionMode.value
          : this.additionMode,
      restTime: data.restTime.present ? data.restTime.value : this.restTime,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessOperation(')
          ..write('opId: $opId, ')
          ..write('family: $family, ')
          ..write('name: $name, ')
          ..write('tMinC: $tMinC, ')
          ..write('tMaxC: $tMaxC, ')
          ..write('durationMin: $durationMin, ')
          ..write('pressure: $pressure, ')
          ..write('shearRateS1: $shearRateS1, ')
          ..write('mixingRpm: $mixingRpm, ')
          ..write('energyInput: $energyInput, ')
          ..write('coolingRate: $coolingRate, ')
          ..write('heatingRate: $heatingRate, ')
          ..write('targetPh: $targetPh, ')
          ..write('targetAw: $targetAw, ')
          ..write('targetBrix: $targetBrix, ')
          ..write('particleSizeTargetUm: $particleSizeTargetUm, ')
          ..write('oxygenExposure: $oxygenExposure, ')
          ..write('atmosphere: $atmosphere, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('additionMode: $additionMode, ')
          ..write('restTime: $restTime, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    opId,
    family,
    name,
    tMinC,
    tMaxC,
    durationMin,
    pressure,
    shearRateS1,
    mixingRpm,
    energyInput,
    coolingRate,
    heatingRate,
    targetPh,
    targetAw,
    targetBrix,
    particleSizeTargetUm,
    oxygenExposure,
    atmosphere,
    orderIndex,
    additionMode,
    restTime,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessOperation &&
          other.opId == this.opId &&
          other.family == this.family &&
          other.name == this.name &&
          other.tMinC == this.tMinC &&
          other.tMaxC == this.tMaxC &&
          other.durationMin == this.durationMin &&
          other.pressure == this.pressure &&
          other.shearRateS1 == this.shearRateS1 &&
          other.mixingRpm == this.mixingRpm &&
          other.energyInput == this.energyInput &&
          other.coolingRate == this.coolingRate &&
          other.heatingRate == this.heatingRate &&
          other.targetPh == this.targetPh &&
          other.targetAw == this.targetAw &&
          other.targetBrix == this.targetBrix &&
          other.particleSizeTargetUm == this.particleSizeTargetUm &&
          other.oxygenExposure == this.oxygenExposure &&
          other.atmosphere == this.atmosphere &&
          other.orderIndex == this.orderIndex &&
          other.additionMode == this.additionMode &&
          other.restTime == this.restTime &&
          other.notes == this.notes);
}

class ProcessOperationsCompanion extends UpdateCompanion<ProcessOperation> {
  final Value<String> opId;
  final Value<String?> family;
  final Value<String?> name;
  final Value<double?> tMinC;
  final Value<double?> tMaxC;
  final Value<double?> durationMin;
  final Value<String?> pressure;
  final Value<double?> shearRateS1;
  final Value<String?> mixingRpm;
  final Value<double?> energyInput;
  final Value<double?> coolingRate;
  final Value<double?> heatingRate;
  final Value<double?> targetPh;
  final Value<double?> targetAw;
  final Value<double?> targetBrix;
  final Value<double?> particleSizeTargetUm;
  final Value<String?> oxygenExposure;
  final Value<String?> atmosphere;
  final Value<int?> orderIndex;
  final Value<String?> additionMode;
  final Value<double?> restTime;
  final Value<String?> notes;
  final Value<int> rowid;
  const ProcessOperationsCompanion({
    this.opId = const Value.absent(),
    this.family = const Value.absent(),
    this.name = const Value.absent(),
    this.tMinC = const Value.absent(),
    this.tMaxC = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.pressure = const Value.absent(),
    this.shearRateS1 = const Value.absent(),
    this.mixingRpm = const Value.absent(),
    this.energyInput = const Value.absent(),
    this.coolingRate = const Value.absent(),
    this.heatingRate = const Value.absent(),
    this.targetPh = const Value.absent(),
    this.targetAw = const Value.absent(),
    this.targetBrix = const Value.absent(),
    this.particleSizeTargetUm = const Value.absent(),
    this.oxygenExposure = const Value.absent(),
    this.atmosphere = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.additionMode = const Value.absent(),
    this.restTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessOperationsCompanion.insert({
    required String opId,
    this.family = const Value.absent(),
    this.name = const Value.absent(),
    this.tMinC = const Value.absent(),
    this.tMaxC = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.pressure = const Value.absent(),
    this.shearRateS1 = const Value.absent(),
    this.mixingRpm = const Value.absent(),
    this.energyInput = const Value.absent(),
    this.coolingRate = const Value.absent(),
    this.heatingRate = const Value.absent(),
    this.targetPh = const Value.absent(),
    this.targetAw = const Value.absent(),
    this.targetBrix = const Value.absent(),
    this.particleSizeTargetUm = const Value.absent(),
    this.oxygenExposure = const Value.absent(),
    this.atmosphere = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.additionMode = const Value.absent(),
    this.restTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId);
  static Insertable<ProcessOperation> custom({
    Expression<String>? opId,
    Expression<String>? family,
    Expression<String>? name,
    Expression<double>? tMinC,
    Expression<double>? tMaxC,
    Expression<double>? durationMin,
    Expression<String>? pressure,
    Expression<double>? shearRateS1,
    Expression<String>? mixingRpm,
    Expression<double>? energyInput,
    Expression<double>? coolingRate,
    Expression<double>? heatingRate,
    Expression<double>? targetPh,
    Expression<double>? targetAw,
    Expression<double>? targetBrix,
    Expression<double>? particleSizeTargetUm,
    Expression<String>? oxygenExposure,
    Expression<String>? atmosphere,
    Expression<int>? orderIndex,
    Expression<String>? additionMode,
    Expression<double>? restTime,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (family != null) 'family': family,
      if (name != null) 'name': name,
      if (tMinC != null) 'T_min_C': tMinC,
      if (tMaxC != null) 'T_max_C': tMaxC,
      if (durationMin != null) 'duration_min': durationMin,
      if (pressure != null) 'pressure': pressure,
      if (shearRateS1 != null) 'shear_rate_s-1': shearRateS1,
      if (mixingRpm != null) 'mixing_rpm': mixingRpm,
      if (energyInput != null) 'energy_input': energyInput,
      if (coolingRate != null) 'cooling_rate': coolingRate,
      if (heatingRate != null) 'heating_rate': heatingRate,
      if (targetPh != null) 'target_ph': targetPh,
      if (targetAw != null) 'target_aw': targetAw,
      if (targetBrix != null) 'target_brix': targetBrix,
      if (particleSizeTargetUm != null)
        'particle_size_target_um': particleSizeTargetUm,
      if (oxygenExposure != null) 'oxygen_exposure': oxygenExposure,
      if (atmosphere != null) 'atmosphere': atmosphere,
      if (orderIndex != null) 'order_index': orderIndex,
      if (additionMode != null) 'addition_mode': additionMode,
      if (restTime != null) 'rest_time': restTime,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessOperationsCompanion copyWith({
    Value<String>? opId,
    Value<String?>? family,
    Value<String?>? name,
    Value<double?>? tMinC,
    Value<double?>? tMaxC,
    Value<double?>? durationMin,
    Value<String?>? pressure,
    Value<double?>? shearRateS1,
    Value<String?>? mixingRpm,
    Value<double?>? energyInput,
    Value<double?>? coolingRate,
    Value<double?>? heatingRate,
    Value<double?>? targetPh,
    Value<double?>? targetAw,
    Value<double?>? targetBrix,
    Value<double?>? particleSizeTargetUm,
    Value<String?>? oxygenExposure,
    Value<String?>? atmosphere,
    Value<int?>? orderIndex,
    Value<String?>? additionMode,
    Value<double?>? restTime,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ProcessOperationsCompanion(
      opId: opId ?? this.opId,
      family: family ?? this.family,
      name: name ?? this.name,
      tMinC: tMinC ?? this.tMinC,
      tMaxC: tMaxC ?? this.tMaxC,
      durationMin: durationMin ?? this.durationMin,
      pressure: pressure ?? this.pressure,
      shearRateS1: shearRateS1 ?? this.shearRateS1,
      mixingRpm: mixingRpm ?? this.mixingRpm,
      energyInput: energyInput ?? this.energyInput,
      coolingRate: coolingRate ?? this.coolingRate,
      heatingRate: heatingRate ?? this.heatingRate,
      targetPh: targetPh ?? this.targetPh,
      targetAw: targetAw ?? this.targetAw,
      targetBrix: targetBrix ?? this.targetBrix,
      particleSizeTargetUm: particleSizeTargetUm ?? this.particleSizeTargetUm,
      oxygenExposure: oxygenExposure ?? this.oxygenExposure,
      atmosphere: atmosphere ?? this.atmosphere,
      orderIndex: orderIndex ?? this.orderIndex,
      additionMode: additionMode ?? this.additionMode,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tMinC.present) {
      map['T_min_C'] = Variable<double>(tMinC.value);
    }
    if (tMaxC.present) {
      map['T_max_C'] = Variable<double>(tMaxC.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<double>(durationMin.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<String>(pressure.value);
    }
    if (shearRateS1.present) {
      map['shear_rate_s-1'] = Variable<double>(shearRateS1.value);
    }
    if (mixingRpm.present) {
      map['mixing_rpm'] = Variable<String>(mixingRpm.value);
    }
    if (energyInput.present) {
      map['energy_input'] = Variable<double>(energyInput.value);
    }
    if (coolingRate.present) {
      map['cooling_rate'] = Variable<double>(coolingRate.value);
    }
    if (heatingRate.present) {
      map['heating_rate'] = Variable<double>(heatingRate.value);
    }
    if (targetPh.present) {
      map['target_ph'] = Variable<double>(targetPh.value);
    }
    if (targetAw.present) {
      map['target_aw'] = Variable<double>(targetAw.value);
    }
    if (targetBrix.present) {
      map['target_brix'] = Variable<double>(targetBrix.value);
    }
    if (particleSizeTargetUm.present) {
      map['particle_size_target_um'] = Variable<double>(
        particleSizeTargetUm.value,
      );
    }
    if (oxygenExposure.present) {
      map['oxygen_exposure'] = Variable<String>(oxygenExposure.value);
    }
    if (atmosphere.present) {
      map['atmosphere'] = Variable<String>(atmosphere.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (additionMode.present) {
      map['addition_mode'] = Variable<String>(additionMode.value);
    }
    if (restTime.present) {
      map['rest_time'] = Variable<double>(restTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessOperationsCompanion(')
          ..write('opId: $opId, ')
          ..write('family: $family, ')
          ..write('name: $name, ')
          ..write('tMinC: $tMinC, ')
          ..write('tMaxC: $tMaxC, ')
          ..write('durationMin: $durationMin, ')
          ..write('pressure: $pressure, ')
          ..write('shearRateS1: $shearRateS1, ')
          ..write('mixingRpm: $mixingRpm, ')
          ..write('energyInput: $energyInput, ')
          ..write('coolingRate: $coolingRate, ')
          ..write('heatingRate: $heatingRate, ')
          ..write('targetPh: $targetPh, ')
          ..write('targetAw: $targetAw, ')
          ..write('targetBrix: $targetBrix, ')
          ..write('particleSizeTargetUm: $particleSizeTargetUm, ')
          ..write('oxygenExposure: $oxygenExposure, ')
          ..write('atmosphere: $atmosphere, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('additionMode: $additionMode, ')
          ..write('restTime: $restTime, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeImagesTable recipeImages = $RecipeImagesTable(this);
  late final $RecipeStepsTable recipeSteps = $RecipeStepsTable(this);
  late final $CiqualFoodsTable ciqualFoods = $CiqualFoodsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $RecipeItemsTable recipeItems = $RecipeItemsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  late final $CiqualNutrientsTable ciqualNutrients = $CiqualNutrientsTable(
    this,
  );
  late final $SyncEventsTable syncEvents = $SyncEventsTable(this);
  late final $IngredientStatesTable ingredientStates = $IngredientStatesTable(
    this,
  );
  late final $NutritionComponentsTable nutritionComponents =
      $NutritionComponentsTable(this);
  late final $NutritionRecordsTable nutritionRecords = $NutritionRecordsTable(
    this,
  );
  late final $IngredientAromaCompoundsTable ingredientAromaCompounds =
      $IngredientAromaCompoundsTable(this);
  late final $FlavorCompatibilityTable flavorCompatibility =
      $FlavorCompatibilityTable(this);
  late final $FunctionalIngredientsTable functionalIngredients =
      $FunctionalIngredientsTable(this);
  late final $InteractionRulesTable interactionRules = $InteractionRulesTable(
    this,
  );
  late final $ProcessOperationsTable processOperations =
      $ProcessOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recipes,
    recipeImages,
    recipeSteps,
    ciqualFoods,
    ingredients,
    recipeItems,
    tags,
    recipeTags,
    ciqualNutrients,
    syncEvents,
    ingredientStates,
    nutritionComponents,
    nutritionRecords,
    ingredientAromaCompounds,
    flavorCompatibility,
    functionalIngredients,
    interactionRules,
    processOperations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_steps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ciqual_foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ciqual_nutrients', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<int> servings,
  Value<int> prepTimeMin,
  Value<int> cookTimeMin,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> servings,
  Value<int> prepTimeMin,
  Value<int> cookTimeMin,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeImagesTable, List<RecipeImageRow>>
  _recipe_photosTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeImages,
    aliasName: 'recipes__id__recipe_images__recipe_id',
  );

  $$RecipeImagesTableProcessedTableManager get recipe_photos {
    final manager = $$RecipeImagesTableTableManager(
      $_db,
      $_db.recipeImages,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipe_photosTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeStepsTable, List<RecipeStep>>
  _recipeStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeSteps,
    aliasName: 'recipes__id__recipe_steps__recipe_id',
  );

  $$RecipeStepsTableProcessedTableManager get recipeStepsRefs {
    final manager = $$RecipeStepsTableTableManager(
      $_db,
      $_db.recipeSteps,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipe_itemsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: 'recipes__id__recipe_items__recipe_id',
  );

  $$RecipeItemsTableProcessedTableManager get recipe_items {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipe_itemsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipeItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: 'recipes__id__recipe_items__child_recipe_id',
  );

  $$RecipeItemsTableProcessedTableManager get recipeItemsRefs {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.childRecipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeTagsTable, List<RecipeTag>>
  _recipeTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeTags,
    aliasName: 'recipes__id__recipe_tags__recipe_id',
  );

  $$RecipeTagsTableProcessedTableManager get recipeTagsRefs {
    final manager = $$RecipeTagsTableTableManager(
      $_db,
      $_db.recipeTags,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTimeMin => $composableBuilder(
    column: $table.prepTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cookTimeMin => $composableBuilder(
    column: $table.cookTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipe_photos(
    Expression<bool> Function($$RecipeImagesTableFilterComposer f) f,
  ) {
    final $$RecipeImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeImages,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeImagesTableFilterComposer(
            $db: $db,
            $table: $db.recipeImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeStepsRefs(
    Expression<bool> Function($$RecipeStepsTableFilterComposer f) f,
  ) {
    final $$RecipeStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeSteps,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeStepsTableFilterComposer(
            $db: $db,
            $table: $db.recipeSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipe_items(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeItemsRefs(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.childRecipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeTagsRefs(
    Expression<bool> Function($$RecipeTagsTableFilterComposer f) f,
  ) {
    final $$RecipeTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableFilterComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTimeMin => $composableBuilder(
    column: $table.prepTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cookTimeMin => $composableBuilder(
    column: $table.cookTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<int> get prepTimeMin => $composableBuilder(
    column: $table.prepTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cookTimeMin => $composableBuilder(
    column: $table.cookTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> recipe_photos<T extends Object>(
    Expression<T> Function($$RecipeImagesTableAnnotationComposer a) f,
  ) {
    final $$RecipeImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeImages,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeStepsRefs<T extends Object>(
    Expression<T> Function($$RecipeStepsTableAnnotationComposer a) f,
  ) {
    final $$RecipeStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeSteps,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipe_items<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeItemsRefs<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.childRecipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeTagsRefs<T extends Object>(
    Expression<T> Function($$RecipeTagsTableAnnotationComposer a) f,
  ) {
    final $$RecipeTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({
            bool recipe_photos,
            bool recipeStepsRefs,
            bool recipe_items,
            bool recipeItemsRefs,
            bool recipeTagsRefs,
          })
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<int> prepTimeMin = const Value.absent(),
                Value<int> cookTimeMin = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                title: title,
                description: description,
                servings: servings,
                prepTimeMin: prepTimeMin,
                cookTimeMin: cookTimeMin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<int> prepTimeMin = const Value.absent(),
                Value<int> cookTimeMin = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                title: title,
                description: description,
                servings: servings,
                prepTimeMin: prepTimeMin,
                cookTimeMin: cookTimeMin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recipe_photos = false,
                recipeStepsRefs = false,
                recipe_items = false,
                recipeItemsRefs = false,
                recipeTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipe_photos) db.recipeImages,
                    if (recipeStepsRefs) db.recipeSteps,
                    if (recipe_items) db.recipeItems,
                    if (recipeItemsRefs) db.recipeItems,
                    if (recipeTagsRefs) db.recipeTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipe_photos)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeImageRow
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipe_photosTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipe_photos,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeStepsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeStep
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipe_items)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipe_itemsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipe_items,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeItemsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childRecipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeTagsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeTag
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({
        bool recipe_photos,
        bool recipeStepsRefs,
        bool recipe_items,
        bool recipeItemsRefs,
        bool recipeTagsRefs,
      })
    >;
typedef $$RecipeImagesTableCreateCompanionBuilder =
    RecipeImagesCompanion Function({
      required String id,
      required String recipeId,
      required int position,
      required String path,
      Value<String?> label,
      Value<int> rowid,
    });
typedef $$RecipeImagesTableUpdateCompanionBuilder =
    RecipeImagesCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> path,
      Value<String?> label,
      Value<int> rowid,
    });

final class $$RecipeImagesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeImagesTable, RecipeImageRow> {
  $$RecipeImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_images__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeImagesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeImagesTable> {
  $$RecipeImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeImagesTable> {
  $$RecipeImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeImagesTable> {
  $$RecipeImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeImagesTable,
          RecipeImageRow,
          $$RecipeImagesTableFilterComposer,
          $$RecipeImagesTableOrderingComposer,
          $$RecipeImagesTableAnnotationComposer,
          $$RecipeImagesTableCreateCompanionBuilder,
          $$RecipeImagesTableUpdateCompanionBuilder,
          (RecipeImageRow, $$RecipeImagesTableReferences),
          RecipeImageRow,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeImagesTableTableManager(_$AppDatabase db, $RecipeImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeImagesCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                path: path,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int position,
                required String path,
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeImagesCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                path: path,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$RecipeImagesTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$RecipeImagesTableReferences
                            ._recipeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeImagesTable,
      RecipeImageRow,
      $$RecipeImagesTableFilterComposer,
      $$RecipeImagesTableOrderingComposer,
      $$RecipeImagesTableAnnotationComposer,
      $$RecipeImagesTableCreateCompanionBuilder,
      $$RecipeImagesTableUpdateCompanionBuilder,
      (RecipeImageRow, $$RecipeImagesTableReferences),
      RecipeImageRow,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$RecipeStepsTableCreateCompanionBuilder =
    RecipeStepsCompanion Function({
      required String id,
      required String recipeId,
      required int position,
      required String body,
      Value<int> rowid,
    });
typedef $$RecipeStepsTableUpdateCompanionBuilder =
    RecipeStepsCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> body,
      Value<int> rowid,
    });

final class $$RecipeStepsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeStepsTable, RecipeStep> {
  $$RecipeStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_steps__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeStepsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeStepsTable,
          RecipeStep,
          $$RecipeStepsTableFilterComposer,
          $$RecipeStepsTableOrderingComposer,
          $$RecipeStepsTableAnnotationComposer,
          $$RecipeStepsTableCreateCompanionBuilder,
          $$RecipeStepsTableUpdateCompanionBuilder,
          (RecipeStep, $$RecipeStepsTableReferences),
          RecipeStep,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeStepsTableTableManager(_$AppDatabase db, $RecipeStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int position,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$RecipeStepsTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$RecipeStepsTableReferences
                            ._recipeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeStepsTable,
      RecipeStep,
      $$RecipeStepsTableFilterComposer,
      $$RecipeStepsTableOrderingComposer,
      $$RecipeStepsTableAnnotationComposer,
      $$RecipeStepsTableCreateCompanionBuilder,
      $$RecipeStepsTableUpdateCompanionBuilder,
      (RecipeStep, $$RecipeStepsTableReferences),
      RecipeStep,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$CiqualFoodsTableCreateCompanionBuilder =
    CiqualFoodsCompanion Function({
      required String code,
      required String name,
      Value<String?> groupCode,
      Value<int> rowid,
    });
typedef $$CiqualFoodsTableUpdateCompanionBuilder =
    CiqualFoodsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String?> groupCode,
      Value<int> rowid,
    });

final class $$CiqualFoodsTableReferences
    extends BaseReferences<_$AppDatabase, $CiqualFoodsTable, CiqualFood> {
  $$CiqualFoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipeItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: 'ciqual_foods__code__recipe_items__ciqual_code',
  );

  $$RecipeItemsTableProcessedTableManager get recipeItemsRefs {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.ciqualCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(_recipeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CiqualNutrientsTable, List<CiqualNutrient>>
  _ciqualNutrientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ciqualNutrients,
    aliasName: 'ciqual_foods__code__ciqual_nutrients__food_code',
  );

  $$CiqualNutrientsTableProcessedTableManager get ciqualNutrientsRefs {
    final manager = $$CiqualNutrientsTableTableManager(
      $_db,
      $_db.ciqualNutrients,
    ).filter((f) => f.foodCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(
      _ciqualNutrientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CiqualFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CiqualFoodsTable> {
  $$CiqualFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupCode => $composableBuilder(
    column: $table.groupCode,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeItemsRefs(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ciqualCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ciqualNutrientsRefs(
    Expression<bool> Function($$CiqualNutrientsTableFilterComposer f) f,
  ) {
    final $$CiqualNutrientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.ciqualNutrients,
      getReferencedColumn: (t) => t.foodCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualNutrientsTableFilterComposer(
            $db: $db,
            $table: $db.ciqualNutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CiqualFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CiqualFoodsTable> {
  $$CiqualFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupCode => $composableBuilder(
    column: $table.groupCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CiqualFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CiqualFoodsTable> {
  $$CiqualFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupCode =>
      $composableBuilder(column: $table.groupCode, builder: (column) => column);

  Expression<T> recipeItemsRefs<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ciqualCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ciqualNutrientsRefs<T extends Object>(
    Expression<T> Function($$CiqualNutrientsTableAnnotationComposer a) f,
  ) {
    final $$CiqualNutrientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.ciqualNutrients,
      getReferencedColumn: (t) => t.foodCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualNutrientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ciqualNutrients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CiqualFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CiqualFoodsTable,
          CiqualFood,
          $$CiqualFoodsTableFilterComposer,
          $$CiqualFoodsTableOrderingComposer,
          $$CiqualFoodsTableAnnotationComposer,
          $$CiqualFoodsTableCreateCompanionBuilder,
          $$CiqualFoodsTableUpdateCompanionBuilder,
          (CiqualFood, $$CiqualFoodsTableReferences),
          CiqualFood,
          PrefetchHooks Function({
            bool recipeItemsRefs,
            bool ciqualNutrientsRefs,
          })
        > {
  $$CiqualFoodsTableTableManager(_$AppDatabase db, $CiqualFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CiqualFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CiqualFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CiqualFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> groupCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CiqualFoodsCompanion(
                code: code,
                name: name,
                groupCode: groupCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                Value<String?> groupCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CiqualFoodsCompanion.insert(
                code: code,
                name: name,
                groupCode: groupCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CiqualFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recipeItemsRefs = false, ciqualNutrientsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeItemsRefs) db.recipeItems,
                    if (ciqualNutrientsRefs) db.ciqualNutrients,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeItemsRefs)
                        await $_getPrefetchedData<
                          CiqualFood,
                          $CiqualFoodsTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable: $$CiqualFoodsTableReferences
                              ._recipeItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CiqualFoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ciqualCode == item.code,
                              ),
                          typedResults: items,
                        ),
                      if (ciqualNutrientsRefs)
                        await $_getPrefetchedData<
                          CiqualFood,
                          $CiqualFoodsTable,
                          CiqualNutrient
                        >(
                          currentTable: table,
                          referencedTable: $$CiqualFoodsTableReferences
                              ._ciqualNutrientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CiqualFoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).ciqualNutrientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodCode == item.code,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CiqualFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CiqualFoodsTable,
      CiqualFood,
      $$CiqualFoodsTableFilterComposer,
      $$CiqualFoodsTableOrderingComposer,
      $$CiqualFoodsTableAnnotationComposer,
      $$CiqualFoodsTableCreateCompanionBuilder,
      $$CiqualFoodsTableUpdateCompanionBuilder,
      (CiqualFood, $$CiqualFoodsTableReferences),
      CiqualFood,
      PrefetchHooks Function({bool recipeItemsRefs, bool ciqualNutrientsRefs})
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      required String ingredientId,
      required String canonicalNameFr,
      Value<String?> canonicalNameEn,
      Value<String?> aliasesFr,
      Value<String?> aliasesEn,
      Value<String?> scientificName,
      Value<String?> kingdomOrOrigin,
      required String categoryLevel1,
      Value<String?> categoryLevel2,
      Value<String?> categoryLevel3,
      Value<String?> sourceOrganism,
      Value<String?> anatomicalPart,
      Value<String?> ingredientClass,
      Value<String?> rawOrIntermediate,
      Value<String?> processingState,
      Value<String?> physicalForm,
      Value<bool> fermented,
      Value<bool> dried,
      Value<bool> smoked,
      Value<bool> roasted,
      Value<bool> concentrated,
      Value<bool> alcoholic,
      Value<String?> genericAbvRange,
      Value<String?> countryOrRegionRelevance,
      Value<String?> foodonId,
      Value<String?> langualIds,
      Value<String?> foodex2Code,
      Value<String?> ciqualIds,
      Value<String?> usdaFdcIds,
      Value<String?> otherExternalIds,
      Value<String?> allergenTags,
      Value<String?> regulatoryNotes,
      Value<String?> sourceRefs,
      Value<double?> confidence,
      Value<String?> reviewStatus,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> ingredientId,
      Value<String> canonicalNameFr,
      Value<String?> canonicalNameEn,
      Value<String?> aliasesFr,
      Value<String?> aliasesEn,
      Value<String?> scientificName,
      Value<String?> kingdomOrOrigin,
      Value<String> categoryLevel1,
      Value<String?> categoryLevel2,
      Value<String?> categoryLevel3,
      Value<String?> sourceOrganism,
      Value<String?> anatomicalPart,
      Value<String?> ingredientClass,
      Value<String?> rawOrIntermediate,
      Value<String?> processingState,
      Value<String?> physicalForm,
      Value<bool> fermented,
      Value<bool> dried,
      Value<bool> smoked,
      Value<bool> roasted,
      Value<bool> concentrated,
      Value<bool> alcoholic,
      Value<String?> genericAbvRange,
      Value<String?> countryOrRegionRelevance,
      Value<String?> foodonId,
      Value<String?> langualIds,
      Value<String?> foodex2Code,
      Value<String?> ciqualIds,
      Value<String?> usdaFdcIds,
      Value<String?> otherExternalIds,
      Value<String?> allergenTags,
      Value<String?> regulatoryNotes,
      Value<String?> sourceRefs,
      Value<double?> confidence,
      Value<String?> reviewStatus,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipeItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: 'ingredients__ingredient_id__recipe_items__ingredient_id',
  );

  $$RecipeItemsTableProcessedTableManager get recipeItemsRefs {
    final manager = $$RecipeItemsTableTableManager($_db, $_db.recipeItems)
        .filter(
          (f) => f.ingredientId.ingredientId.sqlEquals(
            $_itemColumn<String>('ingredient_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_recipeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NutritionRecordsTable, List<NutritionRecord>>
  _nutritionRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nutritionRecords,
    aliasName: 'ingredients__ingredient_id__nutrition_records__ingredient_id',
  );

  $$NutritionRecordsTableProcessedTableManager get nutritionRecordsRefs {
    final manager =
        $$NutritionRecordsTableTableManager($_db, $_db.nutritionRecords).filter(
          (f) => f.ingredientId.ingredientId.sqlEquals(
            $_itemColumn<String>('ingredient_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _nutritionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $IngredientAromaCompoundsTable,
    List<IngredientAromaCompound>
  >
  _ingredientAromaCompoundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ingredientAromaCompounds,
    aliasName:
        'ingredients__ingredient_id__ingredient_aroma_compounds__ingredient_id',
  );

  $$IngredientAromaCompoundsTableProcessedTableManager
  get ingredientAromaCompoundsRefs {
    final manager =
        $$IngredientAromaCompoundsTableTableManager(
          $_db,
          $_db.ingredientAromaCompounds,
        ).filter(
          (f) => f.ingredientId.ingredientId.sqlEquals(
            $_itemColumn<String>('ingredient_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _ingredientAromaCompoundsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FunctionalIngredientsTable,
    List<FunctionalIngredient>
  >
  _functionalIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.functionalIngredients,
        aliasName:
            'ingredients__ingredient_id__functional_ingredients__ingredient_id',
      );

  $$FunctionalIngredientsTableProcessedTableManager
  get functionalIngredientsRefs {
    final manager =
        $$FunctionalIngredientsTableTableManager(
          $_db,
          $_db.functionalIngredients,
        ).filter(
          (f) => f.ingredientId.ingredientId.sqlEquals(
            $_itemColumn<String>('ingredient_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _functionalIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalNameFr => $composableBuilder(
    column: $table.canonicalNameFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalNameEn => $composableBuilder(
    column: $table.canonicalNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasesFr => $composableBuilder(
    column: $table.aliasesFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasesEn => $composableBuilder(
    column: $table.aliasesEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kingdomOrOrigin => $composableBuilder(
    column: $table.kingdomOrOrigin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryLevel1 => $composableBuilder(
    column: $table.categoryLevel1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryLevel2 => $composableBuilder(
    column: $table.categoryLevel2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryLevel3 => $composableBuilder(
    column: $table.categoryLevel3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceOrganism => $composableBuilder(
    column: $table.sourceOrganism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anatomicalPart => $composableBuilder(
    column: $table.anatomicalPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientClass => $composableBuilder(
    column: $table.ingredientClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOrIntermediate => $composableBuilder(
    column: $table.rawOrIntermediate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalForm => $composableBuilder(
    column: $table.physicalForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fermented => $composableBuilder(
    column: $table.fermented,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dried => $composableBuilder(
    column: $table.dried,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smoked => $composableBuilder(
    column: $table.smoked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get roasted => $composableBuilder(
    column: $table.roasted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get concentrated => $composableBuilder(
    column: $table.concentrated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alcoholic => $composableBuilder(
    column: $table.alcoholic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genericAbvRange => $composableBuilder(
    column: $table.genericAbvRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryOrRegionRelevance => $composableBuilder(
    column: $table.countryOrRegionRelevance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodonId => $composableBuilder(
    column: $table.foodonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get langualIds => $composableBuilder(
    column: $table.langualIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodex2Code => $composableBuilder(
    column: $table.foodex2Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ciqualIds => $composableBuilder(
    column: $table.ciqualIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usdaFdcIds => $composableBuilder(
    column: $table.usdaFdcIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherExternalIds => $composableBuilder(
    column: $table.otherExternalIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergenTags => $composableBuilder(
    column: $table.allergenTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regulatoryNotes => $composableBuilder(
    column: $table.regulatoryNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeItemsRefs(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nutritionRecordsRefs(
    Expression<bool> Function($$NutritionRecordsTableFilterComposer f) f,
  ) {
    final $$NutritionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.nutritionRecords,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.nutritionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ingredientAromaCompoundsRefs(
    Expression<bool> Function($$IngredientAromaCompoundsTableFilterComposer f)
    f,
  ) {
    final $$IngredientAromaCompoundsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ingredientId,
          referencedTable: $db.ingredientAromaCompounds,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientAromaCompoundsTableFilterComposer(
                $db: $db,
                $table: $db.ingredientAromaCompounds,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> functionalIngredientsRefs(
    Expression<bool> Function($$FunctionalIngredientsTableFilterComposer f) f,
  ) {
    final $$FunctionalIngredientsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ingredientId,
          referencedTable: $db.functionalIngredients,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FunctionalIngredientsTableFilterComposer(
                $db: $db,
                $table: $db.functionalIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalNameFr => $composableBuilder(
    column: $table.canonicalNameFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalNameEn => $composableBuilder(
    column: $table.canonicalNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesFr => $composableBuilder(
    column: $table.aliasesFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesEn => $composableBuilder(
    column: $table.aliasesEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kingdomOrOrigin => $composableBuilder(
    column: $table.kingdomOrOrigin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryLevel1 => $composableBuilder(
    column: $table.categoryLevel1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryLevel2 => $composableBuilder(
    column: $table.categoryLevel2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryLevel3 => $composableBuilder(
    column: $table.categoryLevel3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceOrganism => $composableBuilder(
    column: $table.sourceOrganism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anatomicalPart => $composableBuilder(
    column: $table.anatomicalPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientClass => $composableBuilder(
    column: $table.ingredientClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOrIntermediate => $composableBuilder(
    column: $table.rawOrIntermediate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalForm => $composableBuilder(
    column: $table.physicalForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fermented => $composableBuilder(
    column: $table.fermented,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dried => $composableBuilder(
    column: $table.dried,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smoked => $composableBuilder(
    column: $table.smoked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get roasted => $composableBuilder(
    column: $table.roasted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get concentrated => $composableBuilder(
    column: $table.concentrated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alcoholic => $composableBuilder(
    column: $table.alcoholic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genericAbvRange => $composableBuilder(
    column: $table.genericAbvRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryOrRegionRelevance => $composableBuilder(
    column: $table.countryOrRegionRelevance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodonId => $composableBuilder(
    column: $table.foodonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get langualIds => $composableBuilder(
    column: $table.langualIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodex2Code => $composableBuilder(
    column: $table.foodex2Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ciqualIds => $composableBuilder(
    column: $table.ciqualIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usdaFdcIds => $composableBuilder(
    column: $table.usdaFdcIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherExternalIds => $composableBuilder(
    column: $table.otherExternalIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergenTags => $composableBuilder(
    column: $table.allergenTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regulatoryNotes => $composableBuilder(
    column: $table.regulatoryNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalNameFr => $composableBuilder(
    column: $table.canonicalNameFr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalNameEn => $composableBuilder(
    column: $table.canonicalNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliasesFr =>
      $composableBuilder(column: $table.aliasesFr, builder: (column) => column);

  GeneratedColumn<String> get aliasesEn =>
      $composableBuilder(column: $table.aliasesEn, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kingdomOrOrigin => $composableBuilder(
    column: $table.kingdomOrOrigin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryLevel1 => $composableBuilder(
    column: $table.categoryLevel1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryLevel2 => $composableBuilder(
    column: $table.categoryLevel2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryLevel3 => $composableBuilder(
    column: $table.categoryLevel3,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceOrganism => $composableBuilder(
    column: $table.sourceOrganism,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anatomicalPart => $composableBuilder(
    column: $table.anatomicalPart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientClass => $composableBuilder(
    column: $table.ingredientClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawOrIntermediate => $composableBuilder(
    column: $table.rawOrIntermediate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physicalForm => $composableBuilder(
    column: $table.physicalForm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fermented =>
      $composableBuilder(column: $table.fermented, builder: (column) => column);

  GeneratedColumn<bool> get dried =>
      $composableBuilder(column: $table.dried, builder: (column) => column);

  GeneratedColumn<bool> get smoked =>
      $composableBuilder(column: $table.smoked, builder: (column) => column);

  GeneratedColumn<bool> get roasted =>
      $composableBuilder(column: $table.roasted, builder: (column) => column);

  GeneratedColumn<bool> get concentrated => $composableBuilder(
    column: $table.concentrated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alcoholic =>
      $composableBuilder(column: $table.alcoholic, builder: (column) => column);

  GeneratedColumn<String> get genericAbvRange => $composableBuilder(
    column: $table.genericAbvRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryOrRegionRelevance => $composableBuilder(
    column: $table.countryOrRegionRelevance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodonId =>
      $composableBuilder(column: $table.foodonId, builder: (column) => column);

  GeneratedColumn<String> get langualIds => $composableBuilder(
    column: $table.langualIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodex2Code => $composableBuilder(
    column: $table.foodex2Code,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ciqualIds =>
      $composableBuilder(column: $table.ciqualIds, builder: (column) => column);

  GeneratedColumn<String> get usdaFdcIds => $composableBuilder(
    column: $table.usdaFdcIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherExternalIds => $composableBuilder(
    column: $table.otherExternalIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergenTags => $composableBuilder(
    column: $table.allergenTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regulatoryNotes => $composableBuilder(
    column: $table.regulatoryNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> recipeItemsRefs<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> nutritionRecordsRefs<T extends Object>(
    Expression<T> Function($$NutritionRecordsTableAnnotationComposer a) f,
  ) {
    final $$NutritionRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.nutritionRecords,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ingredientAromaCompoundsRefs<T extends Object>(
    Expression<T> Function($$IngredientAromaCompoundsTableAnnotationComposer a)
    f,
  ) {
    final $$IngredientAromaCompoundsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ingredientId,
          referencedTable: $db.ingredientAromaCompounds,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IngredientAromaCompoundsTableAnnotationComposer(
                $db: $db,
                $table: $db.ingredientAromaCompounds,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> functionalIngredientsRefs<T extends Object>(
    Expression<T> Function($$FunctionalIngredientsTableAnnotationComposer a) f,
  ) {
    final $$FunctionalIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ingredientId,
          referencedTable: $db.functionalIngredients,
          getReferencedColumn: (t) => t.ingredientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FunctionalIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.functionalIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (Ingredient, $$IngredientsTableReferences),
          Ingredient,
          PrefetchHooks Function({
            bool recipeItemsRefs,
            bool nutritionRecordsRefs,
            bool ingredientAromaCompoundsRefs,
            bool functionalIngredientsRefs,
          })
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ingredientId = const Value.absent(),
                Value<String> canonicalNameFr = const Value.absent(),
                Value<String?> canonicalNameEn = const Value.absent(),
                Value<String?> aliasesFr = const Value.absent(),
                Value<String?> aliasesEn = const Value.absent(),
                Value<String?> scientificName = const Value.absent(),
                Value<String?> kingdomOrOrigin = const Value.absent(),
                Value<String> categoryLevel1 = const Value.absent(),
                Value<String?> categoryLevel2 = const Value.absent(),
                Value<String?> categoryLevel3 = const Value.absent(),
                Value<String?> sourceOrganism = const Value.absent(),
                Value<String?> anatomicalPart = const Value.absent(),
                Value<String?> ingredientClass = const Value.absent(),
                Value<String?> rawOrIntermediate = const Value.absent(),
                Value<String?> processingState = const Value.absent(),
                Value<String?> physicalForm = const Value.absent(),
                Value<bool> fermented = const Value.absent(),
                Value<bool> dried = const Value.absent(),
                Value<bool> smoked = const Value.absent(),
                Value<bool> roasted = const Value.absent(),
                Value<bool> concentrated = const Value.absent(),
                Value<bool> alcoholic = const Value.absent(),
                Value<String?> genericAbvRange = const Value.absent(),
                Value<String?> countryOrRegionRelevance = const Value.absent(),
                Value<String?> foodonId = const Value.absent(),
                Value<String?> langualIds = const Value.absent(),
                Value<String?> foodex2Code = const Value.absent(),
                Value<String?> ciqualIds = const Value.absent(),
                Value<String?> usdaFdcIds = const Value.absent(),
                Value<String?> otherExternalIds = const Value.absent(),
                Value<String?> allergenTags = const Value.absent(),
                Value<String?> regulatoryNotes = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> reviewStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion(
                ingredientId: ingredientId,
                canonicalNameFr: canonicalNameFr,
                canonicalNameEn: canonicalNameEn,
                aliasesFr: aliasesFr,
                aliasesEn: aliasesEn,
                scientificName: scientificName,
                kingdomOrOrigin: kingdomOrOrigin,
                categoryLevel1: categoryLevel1,
                categoryLevel2: categoryLevel2,
                categoryLevel3: categoryLevel3,
                sourceOrganism: sourceOrganism,
                anatomicalPart: anatomicalPart,
                ingredientClass: ingredientClass,
                rawOrIntermediate: rawOrIntermediate,
                processingState: processingState,
                physicalForm: physicalForm,
                fermented: fermented,
                dried: dried,
                smoked: smoked,
                roasted: roasted,
                concentrated: concentrated,
                alcoholic: alcoholic,
                genericAbvRange: genericAbvRange,
                countryOrRegionRelevance: countryOrRegionRelevance,
                foodonId: foodonId,
                langualIds: langualIds,
                foodex2Code: foodex2Code,
                ciqualIds: ciqualIds,
                usdaFdcIds: usdaFdcIds,
                otherExternalIds: otherExternalIds,
                allergenTags: allergenTags,
                regulatoryNotes: regulatoryNotes,
                sourceRefs: sourceRefs,
                confidence: confidence,
                reviewStatus: reviewStatus,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ingredientId,
                required String canonicalNameFr,
                Value<String?> canonicalNameEn = const Value.absent(),
                Value<String?> aliasesFr = const Value.absent(),
                Value<String?> aliasesEn = const Value.absent(),
                Value<String?> scientificName = const Value.absent(),
                Value<String?> kingdomOrOrigin = const Value.absent(),
                required String categoryLevel1,
                Value<String?> categoryLevel2 = const Value.absent(),
                Value<String?> categoryLevel3 = const Value.absent(),
                Value<String?> sourceOrganism = const Value.absent(),
                Value<String?> anatomicalPart = const Value.absent(),
                Value<String?> ingredientClass = const Value.absent(),
                Value<String?> rawOrIntermediate = const Value.absent(),
                Value<String?> processingState = const Value.absent(),
                Value<String?> physicalForm = const Value.absent(),
                Value<bool> fermented = const Value.absent(),
                Value<bool> dried = const Value.absent(),
                Value<bool> smoked = const Value.absent(),
                Value<bool> roasted = const Value.absent(),
                Value<bool> concentrated = const Value.absent(),
                Value<bool> alcoholic = const Value.absent(),
                Value<String?> genericAbvRange = const Value.absent(),
                Value<String?> countryOrRegionRelevance = const Value.absent(),
                Value<String?> foodonId = const Value.absent(),
                Value<String?> langualIds = const Value.absent(),
                Value<String?> foodex2Code = const Value.absent(),
                Value<String?> ciqualIds = const Value.absent(),
                Value<String?> usdaFdcIds = const Value.absent(),
                Value<String?> otherExternalIds = const Value.absent(),
                Value<String?> allergenTags = const Value.absent(),
                Value<String?> regulatoryNotes = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> reviewStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion.insert(
                ingredientId: ingredientId,
                canonicalNameFr: canonicalNameFr,
                canonicalNameEn: canonicalNameEn,
                aliasesFr: aliasesFr,
                aliasesEn: aliasesEn,
                scientificName: scientificName,
                kingdomOrOrigin: kingdomOrOrigin,
                categoryLevel1: categoryLevel1,
                categoryLevel2: categoryLevel2,
                categoryLevel3: categoryLevel3,
                sourceOrganism: sourceOrganism,
                anatomicalPart: anatomicalPart,
                ingredientClass: ingredientClass,
                rawOrIntermediate: rawOrIntermediate,
                processingState: processingState,
                physicalForm: physicalForm,
                fermented: fermented,
                dried: dried,
                smoked: smoked,
                roasted: roasted,
                concentrated: concentrated,
                alcoholic: alcoholic,
                genericAbvRange: genericAbvRange,
                countryOrRegionRelevance: countryOrRegionRelevance,
                foodonId: foodonId,
                langualIds: langualIds,
                foodex2Code: foodex2Code,
                ciqualIds: ciqualIds,
                usdaFdcIds: usdaFdcIds,
                otherExternalIds: otherExternalIds,
                allergenTags: allergenTags,
                regulatoryNotes: regulatoryNotes,
                sourceRefs: sourceRefs,
                confidence: confidence,
                reviewStatus: reviewStatus,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recipeItemsRefs = false,
                nutritionRecordsRefs = false,
                ingredientAromaCompoundsRefs = false,
                functionalIngredientsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeItemsRefs) db.recipeItems,
                    if (nutritionRecordsRefs) db.nutritionRecords,
                    if (ingredientAromaCompoundsRefs)
                      db.ingredientAromaCompounds,
                    if (functionalIngredientsRefs) db.functionalIngredients,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeItemsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._recipeItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.ingredientId,
                              ),
                          typedResults: items,
                        ),
                      if (nutritionRecordsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          NutritionRecord
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._nutritionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).nutritionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.ingredientId,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientAromaCompoundsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          IngredientAromaCompound
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._ingredientAromaCompoundsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientAromaCompoundsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.ingredientId,
                              ),
                          typedResults: items,
                        ),
                      if (functionalIngredientsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          FunctionalIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._functionalIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).functionalIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.ingredientId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (Ingredient, $$IngredientsTableReferences),
      Ingredient,
      PrefetchHooks Function({
        bool recipeItemsRefs,
        bool nutritionRecordsRefs,
        bool ingredientAromaCompoundsRefs,
        bool functionalIngredientsRefs,
      })
    >;
typedef $$RecipeItemsTableCreateCompanionBuilder =
    RecipeItemsCompanion Function({
      required String id,
      required String recipeId,
      required int position,
      required String kind,
      required String label,
      required double quantityG,
      Value<String?> ciqualCode,
      Value<String?> childRecipeId,
      Value<String?> ingredientId,
      Value<int> rowid,
    });
typedef $$RecipeItemsTableUpdateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> kind,
      Value<String> label,
      Value<double> quantityG,
      Value<String?> ciqualCode,
      Value<String?> childRecipeId,
      Value<String?> ingredientId,
      Value<int> rowid,
    });

final class $$RecipeItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeItemsTable, RecipeItem> {
  $$RecipeItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_items__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CiqualFoodsTable _ciqualCodeTable(_$AppDatabase db) => db.ciqualFoods
      .createAlias('recipe_items__ciqual_code__ciqual_foods__code');

  $$CiqualFoodsTableProcessedTableManager? get ciqualCode {
    final $_column = $_itemColumn<String>('ciqual_code');
    if ($_column == null) return null;
    final manager = $$CiqualFoodsTableTableManager(
      $_db,
      $_db.ciqualFoods,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ciqualCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecipesTable _childRecipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_items__child_recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager? get childRecipeId {
    final $_column = $_itemColumn<String>('child_recipe_id');
    if ($_column == null) return null;
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childRecipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) => db
      .ingredients
      .createAlias('recipe_items__ingredient_id__ingredients__ingredient_id');

  $$IngredientsTableProcessedTableManager? get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id');
    if ($_column == null) return null;
    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.ingredientId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityG => $composableBuilder(
    column: $table.quantityG,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CiqualFoodsTableFilterComposer get ciqualCode {
    final $$CiqualFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ciqualCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableFilterComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableFilterComposer get childRecipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityG => $composableBuilder(
    column: $table.quantityG,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CiqualFoodsTableOrderingComposer get ciqualCode {
    final $$CiqualFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ciqualCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableOrderingComposer get childRecipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get quantityG =>
      $composableBuilder(column: $table.quantityG, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CiqualFoodsTableAnnotationComposer get ciqualCode {
    final $$CiqualFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ciqualCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableAnnotationComposer get childRecipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeItemsTable,
          RecipeItem,
          $$RecipeItemsTableFilterComposer,
          $$RecipeItemsTableOrderingComposer,
          $$RecipeItemsTableAnnotationComposer,
          $$RecipeItemsTableCreateCompanionBuilder,
          $$RecipeItemsTableUpdateCompanionBuilder,
          (RecipeItem, $$RecipeItemsTableReferences),
          RecipeItem,
          PrefetchHooks Function({
            bool recipeId,
            bool ciqualCode,
            bool childRecipeId,
            bool ingredientId,
          })
        > {
  $$RecipeItemsTableTableManager(_$AppDatabase db, $RecipeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> quantityG = const Value.absent(),
                Value<String?> ciqualCode = const Value.absent(),
                Value<String?> childRecipeId = const Value.absent(),
                Value<String?> ingredientId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeItemsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                kind: kind,
                label: label,
                quantityG: quantityG,
                ciqualCode: ciqualCode,
                childRecipeId: childRecipeId,
                ingredientId: ingredientId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int position,
                required String kind,
                required String label,
                required double quantityG,
                Value<String?> ciqualCode = const Value.absent(),
                Value<String?> childRecipeId = const Value.absent(),
                Value<String?> ingredientId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeItemsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                kind: kind,
                label: label,
                quantityG: quantityG,
                ciqualCode: ciqualCode,
                childRecipeId: childRecipeId,
                ingredientId: ingredientId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recipeId = false,
                ciqualCode = false,
                childRecipeId = false,
                ingredientId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (recipeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recipeId,
                            referencedTable: $$RecipeItemsTableReferences
                                ._recipeIdTable(db),
                            referencedColumn: $$RecipeItemsTableReferences
                                ._recipeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (ciqualCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ciqualCode,
                            referencedTable: $$RecipeItemsTableReferences
                                ._ciqualCodeTable(db),
                            referencedColumn: $$RecipeItemsTableReferences
                                ._ciqualCodeTable(db)
                                .code,
                          ) as T;
                        }
                        if (childRecipeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.childRecipeId,
                            referencedTable: $$RecipeItemsTableReferences
                                ._childRecipeIdTable(db),
                            referencedColumn: $$RecipeItemsTableReferences
                                ._childRecipeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (ingredientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ingredientId,
                            referencedTable: $$RecipeItemsTableReferences
                                ._ingredientIdTable(db),
                            referencedColumn: $$RecipeItemsTableReferences
                                ._ingredientIdTable(db)
                                .ingredientId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RecipeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeItemsTable,
      RecipeItem,
      $$RecipeItemsTableFilterComposer,
      $$RecipeItemsTableOrderingComposer,
      $$RecipeItemsTableAnnotationComposer,
      $$RecipeItemsTableCreateCompanionBuilder,
      $$RecipeItemsTableUpdateCompanionBuilder,
      (RecipeItem, $$RecipeItemsTableReferences),
      RecipeItem,
      PrefetchHooks Function({
        bool recipeId,
        bool ciqualCode,
        bool childRecipeId,
        bool ingredientId,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String label,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeTagsTable, List<RecipeTag>>
  _recipeTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeTags,
    aliasName: 'tags__id__recipe_tags__tag_id',
  );

  $$RecipeTagsTableProcessedTableManager get recipeTagsRefs {
    final manager = $$RecipeTagsTableTableManager(
      $_db,
      $_db.recipeTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeTagsRefs(
    Expression<bool> Function($$RecipeTagsTableFilterComposer f) f,
  ) {
    final $$RecipeTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableFilterComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  Expression<T> recipeTagsRefs<T extends Object>(
    Expression<T> Function($$RecipeTagsTableAnnotationComposer a) f,
  ) {
    final $$RecipeTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool recipeTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => TagsCompanion(id: id, label: label, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String label,
            Value<int> rowid = const Value.absent(),
          }) => TagsCompanion.insert(id: id, label: label, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({recipeTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recipeTagsRefs) db.recipeTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipeTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, RecipeTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._recipeTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).recipeTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool recipeTagsRefs})
    >;
typedef $$RecipeTagsTableCreateCompanionBuilder = RecipeTagsCompanion Function({
  required String recipeId,
  required String tagId,
  Value<int> rowid,
});
typedef $$RecipeTagsTableUpdateCompanionBuilder = RecipeTagsCompanion Function({
  Value<String> recipeId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$RecipeTagsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeTagsTable, RecipeTag> {
  $$RecipeTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_tags__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('recipe_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeTagsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeTagsTable,
          RecipeTag,
          $$RecipeTagsTableFilterComposer,
          $$RecipeTagsTableOrderingComposer,
          $$RecipeTagsTableAnnotationComposer,
          $$RecipeTagsTableCreateCompanionBuilder,
          $$RecipeTagsTableUpdateCompanionBuilder,
          (RecipeTag, $$RecipeTagsTableReferences),
          RecipeTag,
          PrefetchHooks Function({bool recipeId, bool tagId})
        > {
  $$RecipeTagsTableTableManager(_$AppDatabase db, $RecipeTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> recipeId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeTagsCompanion(
                recipeId: recipeId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recipeId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => RecipeTagsCompanion.insert(
                recipeId: recipeId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$RecipeTagsTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$RecipeTagsTableReferences
                            ._recipeIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$RecipeTagsTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$RecipeTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeTagsTable,
      RecipeTag,
      $$RecipeTagsTableFilterComposer,
      $$RecipeTagsTableOrderingComposer,
      $$RecipeTagsTableAnnotationComposer,
      $$RecipeTagsTableCreateCompanionBuilder,
      $$RecipeTagsTableUpdateCompanionBuilder,
      (RecipeTag, $$RecipeTagsTableReferences),
      RecipeTag,
      PrefetchHooks Function({bool recipeId, bool tagId})
    >;
typedef $$CiqualNutrientsTableCreateCompanionBuilder =
    CiqualNutrientsCompanion Function({
      required String foodCode,
      required String nutrientKey,
      required double valuePer100g,
      Value<int> rowid,
    });
typedef $$CiqualNutrientsTableUpdateCompanionBuilder =
    CiqualNutrientsCompanion Function({
      Value<String> foodCode,
      Value<String> nutrientKey,
      Value<double> valuePer100g,
      Value<int> rowid,
    });

final class $$CiqualNutrientsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CiqualNutrientsTable, CiqualNutrient> {
  $$CiqualNutrientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CiqualFoodsTable _foodCodeTable(_$AppDatabase db) => db.ciqualFoods
      .createAlias('ciqual_nutrients__food_code__ciqual_foods__code');

  $$CiqualFoodsTableProcessedTableManager get foodCode {
    final $_column = $_itemColumn<String>('food_code')!;

    final manager = $$CiqualFoodsTableTableManager(
      $_db,
      $_db.ciqualFoods,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CiqualNutrientsTableFilterComposer
    extends Composer<_$AppDatabase, $CiqualNutrientsTable> {
  $$CiqualNutrientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nutrientKey => $composableBuilder(
    column: $table.nutrientKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valuePer100g => $composableBuilder(
    column: $table.valuePer100g,
    builder: (column) => ColumnFilters(column),
  );

  $$CiqualFoodsTableFilterComposer get foodCode {
    final $$CiqualFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableFilterComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CiqualNutrientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CiqualNutrientsTable> {
  $$CiqualNutrientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nutrientKey => $composableBuilder(
    column: $table.nutrientKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valuePer100g => $composableBuilder(
    column: $table.valuePer100g,
    builder: (column) => ColumnOrderings(column),
  );

  $$CiqualFoodsTableOrderingComposer get foodCode {
    final $$CiqualFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CiqualNutrientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CiqualNutrientsTable> {
  $$CiqualNutrientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nutrientKey => $composableBuilder(
    column: $table.nutrientKey,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valuePer100g => $composableBuilder(
    column: $table.valuePer100g,
    builder: (column) => column,
  );

  $$CiqualFoodsTableAnnotationComposer get foodCode {
    final $$CiqualFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodCode,
      referencedTable: $db.ciqualFoods,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CiqualFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.ciqualFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CiqualNutrientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CiqualNutrientsTable,
          CiqualNutrient,
          $$CiqualNutrientsTableFilterComposer,
          $$CiqualNutrientsTableOrderingComposer,
          $$CiqualNutrientsTableAnnotationComposer,
          $$CiqualNutrientsTableCreateCompanionBuilder,
          $$CiqualNutrientsTableUpdateCompanionBuilder,
          (CiqualNutrient, $$CiqualNutrientsTableReferences),
          CiqualNutrient,
          PrefetchHooks Function({bool foodCode})
        > {
  $$CiqualNutrientsTableTableManager(
    _$AppDatabase db,
    $CiqualNutrientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CiqualNutrientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CiqualNutrientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CiqualNutrientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> foodCode = const Value.absent(),
                Value<String> nutrientKey = const Value.absent(),
                Value<double> valuePer100g = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CiqualNutrientsCompanion(
                foodCode: foodCode,
                nutrientKey: nutrientKey,
                valuePer100g: valuePer100g,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String foodCode,
                required String nutrientKey,
                required double valuePer100g,
                Value<int> rowid = const Value.absent(),
              }) => CiqualNutrientsCompanion.insert(
                foodCode: foodCode,
                nutrientKey: nutrientKey,
                valuePer100g: valuePer100g,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CiqualNutrientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (foodCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodCode,
                        referencedTable: $$CiqualNutrientsTableReferences
                            ._foodCodeTable(db),
                        referencedColumn: $$CiqualNutrientsTableReferences
                            ._foodCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CiqualNutrientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CiqualNutrientsTable,
      CiqualNutrient,
      $$CiqualNutrientsTableFilterComposer,
      $$CiqualNutrientsTableOrderingComposer,
      $$CiqualNutrientsTableAnnotationComposer,
      $$CiqualNutrientsTableCreateCompanionBuilder,
      $$CiqualNutrientsTableUpdateCompanionBuilder,
      (CiqualNutrient, $$CiqualNutrientsTableReferences),
      CiqualNutrient,
      PrefetchHooks Function({bool foodCode})
    >;
typedef $$SyncEventsTableCreateCompanionBuilder = SyncEventsCompanion Function({
  required String id,
  required String deviceId,
  required String entityType,
  required String entityId,
  required String operation,
  required String payloadJson,
  required String createdAt,
  Value<String?> appliedAt,
  Value<int> rowid,
});
typedef $$SyncEventsTableUpdateCompanionBuilder = SyncEventsCompanion Function({
  Value<String> id,
  Value<String> deviceId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payloadJson,
  Value<String> createdAt,
  Value<String?> appliedAt,
  Value<int> rowid,
});

class $$SyncEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);
}

class $$SyncEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEventsTable,
          SyncEvent,
          $$SyncEventsTableFilterComposer,
          $$SyncEventsTableOrderingComposer,
          $$SyncEventsTableAnnotationComposer,
          $$SyncEventsTableCreateCompanionBuilder,
          $$SyncEventsTableUpdateCompanionBuilder,
          (
            SyncEvent,
            BaseReferences<_$AppDatabase, $SyncEventsTable, SyncEvent>,
          ),
          SyncEvent,
          PrefetchHooks Function()
        > {
  $$SyncEventsTableTableManager(_$AppDatabase db, $SyncEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEventsCompanion(
                id: id,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required String createdAt,
                Value<String?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEventsCompanion.insert(
                id: id,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEventsTable,
      SyncEvent,
      $$SyncEventsTableFilterComposer,
      $$SyncEventsTableOrderingComposer,
      $$SyncEventsTableAnnotationComposer,
      $$SyncEventsTableCreateCompanionBuilder,
      $$SyncEventsTableUpdateCompanionBuilder,
      (SyncEvent, BaseReferences<_$AppDatabase, $SyncEventsTable, SyncEvent>),
      SyncEvent,
      PrefetchHooks Function()
    >;
typedef $$IngredientStatesTableCreateCompanionBuilder =
    IngredientStatesCompanion Function({
      required String stateId,
      Value<int> rowid,
    });
typedef $$IngredientStatesTableUpdateCompanionBuilder =
    IngredientStatesCompanion Function({
      Value<String> stateId,
      Value<int> rowid,
    });

class $$IngredientStatesTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientStatesTable> {
  $$IngredientStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientStatesTable> {
  $$IngredientStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientStatesTable> {
  $$IngredientStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stateId =>
      $composableBuilder(column: $table.stateId, builder: (column) => column);
}

class $$IngredientStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientStatesTable,
          IngredientState,
          $$IngredientStatesTableFilterComposer,
          $$IngredientStatesTableOrderingComposer,
          $$IngredientStatesTableAnnotationComposer,
          $$IngredientStatesTableCreateCompanionBuilder,
          $$IngredientStatesTableUpdateCompanionBuilder,
          (
            IngredientState,
            BaseReferences<
              _$AppDatabase,
              $IngredientStatesTable,
              IngredientState
            >,
          ),
          IngredientState,
          PrefetchHooks Function()
        > {
  $$IngredientStatesTableTableManager(
    _$AppDatabase db,
    $IngredientStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> stateId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => IngredientStatesCompanion(stateId: stateId, rowid: rowid),
          createCompanionCallback:
              ({
                required String stateId,
                Value<int> rowid = const Value.absent(),
              }) => IngredientStatesCompanion.insert(
                stateId: stateId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientStatesTable,
      IngredientState,
      $$IngredientStatesTableFilterComposer,
      $$IngredientStatesTableOrderingComposer,
      $$IngredientStatesTableAnnotationComposer,
      $$IngredientStatesTableCreateCompanionBuilder,
      $$IngredientStatesTableUpdateCompanionBuilder,
      (
        IngredientState,
        BaseReferences<_$AppDatabase, $IngredientStatesTable, IngredientState>,
      ),
      IngredientState,
      PrefetchHooks Function()
    >;
typedef $$NutritionComponentsTableCreateCompanionBuilder =
    NutritionComponentsCompanion Function({
      required String componentId,
      Value<String?> canonicalName,
      Value<String?> synonyms,
      Value<String?> componentGroup,
      Value<String?> canonicalUnit,
      Value<String?> infoodsTagname,
      Value<String?> ciqualComponentId,
      Value<String?> usdaNutrientId,
      Value<String?> otherIds,
      Value<String?> definition,
      Value<String?> conversionNotes,
      Value<int> rowid,
    });
typedef $$NutritionComponentsTableUpdateCompanionBuilder =
    NutritionComponentsCompanion Function({
      Value<String> componentId,
      Value<String?> canonicalName,
      Value<String?> synonyms,
      Value<String?> componentGroup,
      Value<String?> canonicalUnit,
      Value<String?> infoodsTagname,
      Value<String?> ciqualComponentId,
      Value<String?> usdaNutrientId,
      Value<String?> otherIds,
      Value<String?> definition,
      Value<String?> conversionNotes,
      Value<int> rowid,
    });

class $$NutritionComponentsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionComponentsTable> {
  $$NutritionComponentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonyms => $composableBuilder(
    column: $table.synonyms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infoodsTagname => $composableBuilder(
    column: $table.infoodsTagname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ciqualComponentId => $composableBuilder(
    column: $table.ciqualComponentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usdaNutrientId => $composableBuilder(
    column: $table.usdaNutrientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherIds => $composableBuilder(
    column: $table.otherIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversionNotes => $composableBuilder(
    column: $table.conversionNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionComponentsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionComponentsTable> {
  $$NutritionComponentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonyms => $composableBuilder(
    column: $table.synonyms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infoodsTagname => $composableBuilder(
    column: $table.infoodsTagname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ciqualComponentId => $composableBuilder(
    column: $table.ciqualComponentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usdaNutrientId => $composableBuilder(
    column: $table.usdaNutrientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherIds => $composableBuilder(
    column: $table.otherIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversionNotes => $composableBuilder(
    column: $table.conversionNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionComponentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionComponentsTable> {
  $$NutritionComponentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get synonyms =>
      $composableBuilder(column: $table.synonyms, builder: (column) => column);

  GeneratedColumn<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get infoodsTagname => $composableBuilder(
    column: $table.infoodsTagname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ciqualComponentId => $composableBuilder(
    column: $table.ciqualComponentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usdaNutrientId => $composableBuilder(
    column: $table.usdaNutrientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherIds =>
      $composableBuilder(column: $table.otherIds, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversionNotes => $composableBuilder(
    column: $table.conversionNotes,
    builder: (column) => column,
  );
}

class $$NutritionComponentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionComponentsTable,
          NutritionComponent,
          $$NutritionComponentsTableFilterComposer,
          $$NutritionComponentsTableOrderingComposer,
          $$NutritionComponentsTableAnnotationComposer,
          $$NutritionComponentsTableCreateCompanionBuilder,
          $$NutritionComponentsTableUpdateCompanionBuilder,
          (
            NutritionComponent,
            BaseReferences<
              _$AppDatabase,
              $NutritionComponentsTable,
              NutritionComponent
            >,
          ),
          NutritionComponent,
          PrefetchHooks Function()
        > {
  $$NutritionComponentsTableTableManager(
    _$AppDatabase db,
    $NutritionComponentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionComponentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionComponentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NutritionComponentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> componentId = const Value.absent(),
                Value<String?> canonicalName = const Value.absent(),
                Value<String?> synonyms = const Value.absent(),
                Value<String?> componentGroup = const Value.absent(),
                Value<String?> canonicalUnit = const Value.absent(),
                Value<String?> infoodsTagname = const Value.absent(),
                Value<String?> ciqualComponentId = const Value.absent(),
                Value<String?> usdaNutrientId = const Value.absent(),
                Value<String?> otherIds = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> conversionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionComponentsCompanion(
                componentId: componentId,
                canonicalName: canonicalName,
                synonyms: synonyms,
                componentGroup: componentGroup,
                canonicalUnit: canonicalUnit,
                infoodsTagname: infoodsTagname,
                ciqualComponentId: ciqualComponentId,
                usdaNutrientId: usdaNutrientId,
                otherIds: otherIds,
                definition: definition,
                conversionNotes: conversionNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String componentId,
                Value<String?> canonicalName = const Value.absent(),
                Value<String?> synonyms = const Value.absent(),
                Value<String?> componentGroup = const Value.absent(),
                Value<String?> canonicalUnit = const Value.absent(),
                Value<String?> infoodsTagname = const Value.absent(),
                Value<String?> ciqualComponentId = const Value.absent(),
                Value<String?> usdaNutrientId = const Value.absent(),
                Value<String?> otherIds = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> conversionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionComponentsCompanion.insert(
                componentId: componentId,
                canonicalName: canonicalName,
                synonyms: synonyms,
                componentGroup: componentGroup,
                canonicalUnit: canonicalUnit,
                infoodsTagname: infoodsTagname,
                ciqualComponentId: ciqualComponentId,
                usdaNutrientId: usdaNutrientId,
                otherIds: otherIds,
                definition: definition,
                conversionNotes: conversionNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionComponentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionComponentsTable,
      NutritionComponent,
      $$NutritionComponentsTableFilterComposer,
      $$NutritionComponentsTableOrderingComposer,
      $$NutritionComponentsTableAnnotationComposer,
      $$NutritionComponentsTableCreateCompanionBuilder,
      $$NutritionComponentsTableUpdateCompanionBuilder,
      (
        NutritionComponent,
        BaseReferences<
          _$AppDatabase,
          $NutritionComponentsTable,
          NutritionComponent
        >,
      ),
      NutritionComponent,
      PrefetchHooks Function()
    >;
typedef $$NutritionRecordsTableCreateCompanionBuilder =
    NutritionRecordsCompanion Function({
      required String nutritionRecordId,
      required String ingredientId,
      Value<String?> ingredientStateId,
      Value<String?> sourceId,
      Value<String?> sourceFoodId,
      Value<String?> sourceFoodName,
      Value<String?> sourceVersion,
      Value<String?> sourceCountry,
      Value<String?> componentId,
      Value<String?> componentName,
      Value<String?> componentGroup,
      Value<double?> originalValue,
      Value<String?> originalUnit,
      Value<double?> normalizedValue,
      Value<String?> normalizedUnit,
      Value<String?> basis,
      Value<String?> valueQualifier,
      Value<String?> valueType,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<int?> sampleCount,
      Value<String?> analyticalMethod,
      Value<String?> derivationMethod,
      Value<String?> dataDate,
      Value<String?> retrievalDate,
      Value<String?> sourceUrl,
      Value<double?> confidence,
      Value<double?> mappingConfidence,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$NutritionRecordsTableUpdateCompanionBuilder =
    NutritionRecordsCompanion Function({
      Value<String> nutritionRecordId,
      Value<String> ingredientId,
      Value<String?> ingredientStateId,
      Value<String?> sourceId,
      Value<String?> sourceFoodId,
      Value<String?> sourceFoodName,
      Value<String?> sourceVersion,
      Value<String?> sourceCountry,
      Value<String?> componentId,
      Value<String?> componentName,
      Value<String?> componentGroup,
      Value<double?> originalValue,
      Value<String?> originalUnit,
      Value<double?> normalizedValue,
      Value<String?> normalizedUnit,
      Value<String?> basis,
      Value<String?> valueQualifier,
      Value<String?> valueType,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<int?> sampleCount,
      Value<String?> analyticalMethod,
      Value<String?> derivationMethod,
      Value<String?> dataDate,
      Value<String?> retrievalDate,
      Value<String?> sourceUrl,
      Value<double?> confidence,
      Value<double?> mappingConfidence,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$NutritionRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $NutritionRecordsTable, NutritionRecord> {
  $$NutritionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        'nutrition_records__ingredient_id__ingredients__ingredient_id',
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.ingredientId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NutritionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionRecordsTable> {
  $$NutritionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nutritionRecordId => $composableBuilder(
    column: $table.nutritionRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFoodId => $composableBuilder(
    column: $table.sourceFoodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFoodName => $composableBuilder(
    column: $table.sourceFoodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCountry => $composableBuilder(
    column: $table.sourceCountry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUnit => $composableBuilder(
    column: $table.originalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedUnit => $composableBuilder(
    column: $table.normalizedUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueQualifier => $composableBuilder(
    column: $table.valueQualifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivationMethod => $composableBuilder(
    column: $table.derivationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataDate => $composableBuilder(
    column: $table.dataDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retrievalDate => $composableBuilder(
    column: $table.retrievalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionRecordsTable> {
  $$NutritionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nutritionRecordId => $composableBuilder(
    column: $table.nutritionRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFoodId => $composableBuilder(
    column: $table.sourceFoodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFoodName => $composableBuilder(
    column: $table.sourceFoodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCountry => $composableBuilder(
    column: $table.sourceCountry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUnit => $composableBuilder(
    column: $table.originalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedUnit => $composableBuilder(
    column: $table.normalizedUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueQualifier => $composableBuilder(
    column: $table.valueQualifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivationMethod => $composableBuilder(
    column: $table.derivationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataDate => $composableBuilder(
    column: $table.dataDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retrievalDate => $composableBuilder(
    column: $table.retrievalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionRecordsTable> {
  $$NutritionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nutritionRecordId => $composableBuilder(
    column: $table.nutritionRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceFoodId => $composableBuilder(
    column: $table.sourceFoodId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFoodName => $composableBuilder(
    column: $table.sourceFoodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceCountry => $composableBuilder(
    column: $table.sourceCountry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentGroup => $composableBuilder(
    column: $table.componentGroup,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalUnit => $composableBuilder(
    column: $table.originalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedUnit => $composableBuilder(
    column: $table.normalizedUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get basis =>
      $composableBuilder(column: $table.basis, builder: (column) => column);

  GeneratedColumn<String> get valueQualifier => $composableBuilder(
    column: $table.valueQualifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get derivationMethod => $composableBuilder(
    column: $table.derivationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataDate =>
      $composableBuilder(column: $table.dataDate, builder: (column) => column);

  GeneratedColumn<String> get retrievalDate => $composableBuilder(
    column: $table.retrievalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NutritionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionRecordsTable,
          NutritionRecord,
          $$NutritionRecordsTableFilterComposer,
          $$NutritionRecordsTableOrderingComposer,
          $$NutritionRecordsTableAnnotationComposer,
          $$NutritionRecordsTableCreateCompanionBuilder,
          $$NutritionRecordsTableUpdateCompanionBuilder,
          (NutritionRecord, $$NutritionRecordsTableReferences),
          NutritionRecord,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$NutritionRecordsTableTableManager(
    _$AppDatabase db,
    $NutritionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> nutritionRecordId = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String?> ingredientStateId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> sourceFoodId = const Value.absent(),
                Value<String?> sourceFoodName = const Value.absent(),
                Value<String?> sourceVersion = const Value.absent(),
                Value<String?> sourceCountry = const Value.absent(),
                Value<String?> componentId = const Value.absent(),
                Value<String?> componentName = const Value.absent(),
                Value<String?> componentGroup = const Value.absent(),
                Value<double?> originalValue = const Value.absent(),
                Value<String?> originalUnit = const Value.absent(),
                Value<double?> normalizedValue = const Value.absent(),
                Value<String?> normalizedUnit = const Value.absent(),
                Value<String?> basis = const Value.absent(),
                Value<String?> valueQualifier = const Value.absent(),
                Value<String?> valueType = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<int?> sampleCount = const Value.absent(),
                Value<String?> analyticalMethod = const Value.absent(),
                Value<String?> derivationMethod = const Value.absent(),
                Value<String?> dataDate = const Value.absent(),
                Value<String?> retrievalDate = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> mappingConfidence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionRecordsCompanion(
                nutritionRecordId: nutritionRecordId,
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                sourceId: sourceId,
                sourceFoodId: sourceFoodId,
                sourceFoodName: sourceFoodName,
                sourceVersion: sourceVersion,
                sourceCountry: sourceCountry,
                componentId: componentId,
                componentName: componentName,
                componentGroup: componentGroup,
                originalValue: originalValue,
                originalUnit: originalUnit,
                normalizedValue: normalizedValue,
                normalizedUnit: normalizedUnit,
                basis: basis,
                valueQualifier: valueQualifier,
                valueType: valueType,
                minValue: minValue,
                maxValue: maxValue,
                sampleCount: sampleCount,
                analyticalMethod: analyticalMethod,
                derivationMethod: derivationMethod,
                dataDate: dataDate,
                retrievalDate: retrievalDate,
                sourceUrl: sourceUrl,
                confidence: confidence,
                mappingConfidence: mappingConfidence,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nutritionRecordId,
                required String ingredientId,
                Value<String?> ingredientStateId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> sourceFoodId = const Value.absent(),
                Value<String?> sourceFoodName = const Value.absent(),
                Value<String?> sourceVersion = const Value.absent(),
                Value<String?> sourceCountry = const Value.absent(),
                Value<String?> componentId = const Value.absent(),
                Value<String?> componentName = const Value.absent(),
                Value<String?> componentGroup = const Value.absent(),
                Value<double?> originalValue = const Value.absent(),
                Value<String?> originalUnit = const Value.absent(),
                Value<double?> normalizedValue = const Value.absent(),
                Value<String?> normalizedUnit = const Value.absent(),
                Value<String?> basis = const Value.absent(),
                Value<String?> valueQualifier = const Value.absent(),
                Value<String?> valueType = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<int?> sampleCount = const Value.absent(),
                Value<String?> analyticalMethod = const Value.absent(),
                Value<String?> derivationMethod = const Value.absent(),
                Value<String?> dataDate = const Value.absent(),
                Value<String?> retrievalDate = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> mappingConfidence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionRecordsCompanion.insert(
                nutritionRecordId: nutritionRecordId,
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                sourceId: sourceId,
                sourceFoodId: sourceFoodId,
                sourceFoodName: sourceFoodName,
                sourceVersion: sourceVersion,
                sourceCountry: sourceCountry,
                componentId: componentId,
                componentName: componentName,
                componentGroup: componentGroup,
                originalValue: originalValue,
                originalUnit: originalUnit,
                normalizedValue: normalizedValue,
                normalizedUnit: normalizedUnit,
                basis: basis,
                valueQualifier: valueQualifier,
                valueType: valueType,
                minValue: minValue,
                maxValue: maxValue,
                sampleCount: sampleCount,
                analyticalMethod: analyticalMethod,
                derivationMethod: derivationMethod,
                dataDate: dataDate,
                retrievalDate: retrievalDate,
                sourceUrl: sourceUrl,
                confidence: confidence,
                mappingConfidence: mappingConfidence,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NutritionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ingredientId,
                        referencedTable: $$NutritionRecordsTableReferences
                            ._ingredientIdTable(db),
                        referencedColumn: $$NutritionRecordsTableReferences
                            ._ingredientIdTable(db)
                            .ingredientId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NutritionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionRecordsTable,
      NutritionRecord,
      $$NutritionRecordsTableFilterComposer,
      $$NutritionRecordsTableOrderingComposer,
      $$NutritionRecordsTableAnnotationComposer,
      $$NutritionRecordsTableCreateCompanionBuilder,
      $$NutritionRecordsTableUpdateCompanionBuilder,
      (NutritionRecord, $$NutritionRecordsTableReferences),
      NutritionRecord,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$IngredientAromaCompoundsTableCreateCompanionBuilder =
    IngredientAromaCompoundsCompanion Function({
      required String ingredientId,
      Value<String?> ingredientStateId,
      required String compoundId,
      Value<String?> presenceStatus,
      Value<double?> concentration,
      Value<String?> concentrationUnit,
      Value<double?> concentrationMin,
      Value<double?> concentrationMax,
      Value<String?> analyticalMethod,
      Value<String?> matrix,
      Value<String?> processState,
      Value<String?> sourceRef,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<int> rowid,
    });
typedef $$IngredientAromaCompoundsTableUpdateCompanionBuilder =
    IngredientAromaCompoundsCompanion Function({
      Value<String> ingredientId,
      Value<String?> ingredientStateId,
      Value<String> compoundId,
      Value<String?> presenceStatus,
      Value<double?> concentration,
      Value<String?> concentrationUnit,
      Value<double?> concentrationMin,
      Value<double?> concentrationMax,
      Value<String?> analyticalMethod,
      Value<String?> matrix,
      Value<String?> processState,
      Value<String?> sourceRef,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<int> rowid,
    });

final class $$IngredientAromaCompoundsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IngredientAromaCompoundsTable,
          IngredientAromaCompound
        > {
  $$IngredientAromaCompoundsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        'ingredient_aroma_compounds__ingredient_id__ingredients__ingredient_id',
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.ingredientId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngredientAromaCompoundsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientAromaCompoundsTable> {
  $$IngredientAromaCompoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundId => $composableBuilder(
    column: $table.compoundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get concentrationMin => $composableBuilder(
    column: $table.concentrationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get concentrationMax => $composableBuilder(
    column: $table.concentrationMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matrix => $composableBuilder(
    column: $table.matrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processState => $composableBuilder(
    column: $table.processState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAromaCompoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientAromaCompoundsTable> {
  $$IngredientAromaCompoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundId => $composableBuilder(
    column: $table.compoundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get concentrationMin => $composableBuilder(
    column: $table.concentrationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get concentrationMax => $composableBuilder(
    column: $table.concentrationMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matrix => $composableBuilder(
    column: $table.matrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processState => $composableBuilder(
    column: $table.processState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAromaCompoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientAromaCompoundsTable> {
  $$IngredientAromaCompoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundId => $composableBuilder(
    column: $table.compoundId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get concentrationMin => $composableBuilder(
    column: $table.concentrationMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get concentrationMax => $composableBuilder(
    column: $table.concentrationMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analyticalMethod => $composableBuilder(
    column: $table.analyticalMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matrix =>
      $composableBuilder(column: $table.matrix, builder: (column) => column);

  GeneratedColumn<String> get processState => $composableBuilder(
    column: $table.processState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngredientAromaCompoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientAromaCompoundsTable,
          IngredientAromaCompound,
          $$IngredientAromaCompoundsTableFilterComposer,
          $$IngredientAromaCompoundsTableOrderingComposer,
          $$IngredientAromaCompoundsTableAnnotationComposer,
          $$IngredientAromaCompoundsTableCreateCompanionBuilder,
          $$IngredientAromaCompoundsTableUpdateCompanionBuilder,
          (IngredientAromaCompound, $$IngredientAromaCompoundsTableReferences),
          IngredientAromaCompound,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$IngredientAromaCompoundsTableTableManager(
    _$AppDatabase db,
    $IngredientAromaCompoundsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientAromaCompoundsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientAromaCompoundsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientAromaCompoundsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ingredientId = const Value.absent(),
                Value<String?> ingredientStateId = const Value.absent(),
                Value<String> compoundId = const Value.absent(),
                Value<String?> presenceStatus = const Value.absent(),
                Value<double?> concentration = const Value.absent(),
                Value<String?> concentrationUnit = const Value.absent(),
                Value<double?> concentrationMin = const Value.absent(),
                Value<double?> concentrationMax = const Value.absent(),
                Value<String?> analyticalMethod = const Value.absent(),
                Value<String?> matrix = const Value.absent(),
                Value<String?> processState = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientAromaCompoundsCompanion(
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                compoundId: compoundId,
                presenceStatus: presenceStatus,
                concentration: concentration,
                concentrationUnit: concentrationUnit,
                concentrationMin: concentrationMin,
                concentrationMax: concentrationMax,
                analyticalMethod: analyticalMethod,
                matrix: matrix,
                processState: processState,
                sourceRef: sourceRef,
                evidenceType: evidenceType,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ingredientId,
                Value<String?> ingredientStateId = const Value.absent(),
                required String compoundId,
                Value<String?> presenceStatus = const Value.absent(),
                Value<double?> concentration = const Value.absent(),
                Value<String?> concentrationUnit = const Value.absent(),
                Value<double?> concentrationMin = const Value.absent(),
                Value<double?> concentrationMax = const Value.absent(),
                Value<String?> analyticalMethod = const Value.absent(),
                Value<String?> matrix = const Value.absent(),
                Value<String?> processState = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientAromaCompoundsCompanion.insert(
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                compoundId: compoundId,
                presenceStatus: presenceStatus,
                concentration: concentration,
                concentrationUnit: concentrationUnit,
                concentrationMin: concentrationMin,
                concentrationMax: concentrationMax,
                analyticalMethod: analyticalMethod,
                matrix: matrix,
                processState: processState,
                sourceRef: sourceRef,
                evidenceType: evidenceType,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientAromaCompoundsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ingredientId,
                        referencedTable:
                            $$IngredientAromaCompoundsTableReferences
                                ._ingredientIdTable(db),
                        referencedColumn:
                            $$IngredientAromaCompoundsTableReferences
                                ._ingredientIdTable(db)
                                .ingredientId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IngredientAromaCompoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientAromaCompoundsTable,
      IngredientAromaCompound,
      $$IngredientAromaCompoundsTableFilterComposer,
      $$IngredientAromaCompoundsTableOrderingComposer,
      $$IngredientAromaCompoundsTableAnnotationComposer,
      $$IngredientAromaCompoundsTableCreateCompanionBuilder,
      $$IngredientAromaCompoundsTableUpdateCompanionBuilder,
      (IngredientAromaCompound, $$IngredientAromaCompoundsTableReferences),
      IngredientAromaCompound,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$FlavorCompatibilityTableCreateCompanionBuilder =
    FlavorCompatibilityCompanion Function({
      required String recordId,
      Value<int?> combinationSize,
      Value<String?> ingredientIds,
      Value<String?> ingredientNames,
      Value<String?> context,
      Value<String?> processContext,
      Value<String?> observedOrPredicted,
      Value<double?> aromaSimilarity,
      Value<double?> aromaComplement,
      Value<double?> aromaContrast,
      Value<double?> tasteBalance,
      Value<double?> culinarySupport,
      Value<double?> sensorySupport,
      Value<double?> dominanceRisk,
      Value<double?> maskingRisk,
      Value<double?> noveltyScore,
      Value<double?> overallScore,
      Value<double?> confidence,
      Value<String?> keyCompounds,
      Value<String?> keyDescriptors,
      Value<String?> bridgeIngredients,
      Value<String?> evidenceRefs,
      Value<String?> modelVersion,
      Value<String?> explanation,
      Value<int> rowid,
    });
typedef $$FlavorCompatibilityTableUpdateCompanionBuilder =
    FlavorCompatibilityCompanion Function({
      Value<String> recordId,
      Value<int?> combinationSize,
      Value<String?> ingredientIds,
      Value<String?> ingredientNames,
      Value<String?> context,
      Value<String?> processContext,
      Value<String?> observedOrPredicted,
      Value<double?> aromaSimilarity,
      Value<double?> aromaComplement,
      Value<double?> aromaContrast,
      Value<double?> tasteBalance,
      Value<double?> culinarySupport,
      Value<double?> sensorySupport,
      Value<double?> dominanceRisk,
      Value<double?> maskingRisk,
      Value<double?> noveltyScore,
      Value<double?> overallScore,
      Value<double?> confidence,
      Value<String?> keyCompounds,
      Value<String?> keyDescriptors,
      Value<String?> bridgeIngredients,
      Value<String?> evidenceRefs,
      Value<String?> modelVersion,
      Value<String?> explanation,
      Value<int> rowid,
    });

class $$FlavorCompatibilityTableFilterComposer
    extends Composer<_$AppDatabase, $FlavorCompatibilityTable> {
  $$FlavorCompatibilityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get combinationSize => $composableBuilder(
    column: $table.combinationSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientIds => $composableBuilder(
    column: $table.ingredientIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientNames => $composableBuilder(
    column: $table.ingredientNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processContext => $composableBuilder(
    column: $table.processContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observedOrPredicted => $composableBuilder(
    column: $table.observedOrPredicted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aromaSimilarity => $composableBuilder(
    column: $table.aromaSimilarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aromaComplement => $composableBuilder(
    column: $table.aromaComplement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aromaContrast => $composableBuilder(
    column: $table.aromaContrast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tasteBalance => $composableBuilder(
    column: $table.tasteBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get culinarySupport => $composableBuilder(
    column: $table.culinarySupport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorySupport => $composableBuilder(
    column: $table.sensorySupport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dominanceRisk => $composableBuilder(
    column: $table.dominanceRisk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maskingRisk => $composableBuilder(
    column: $table.maskingRisk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get noveltyScore => $composableBuilder(
    column: $table.noveltyScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyCompounds => $composableBuilder(
    column: $table.keyCompounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyDescriptors => $composableBuilder(
    column: $table.keyDescriptors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bridgeIngredients => $composableBuilder(
    column: $table.bridgeIngredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceRefs => $composableBuilder(
    column: $table.evidenceRefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlavorCompatibilityTableOrderingComposer
    extends Composer<_$AppDatabase, $FlavorCompatibilityTable> {
  $$FlavorCompatibilityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get combinationSize => $composableBuilder(
    column: $table.combinationSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientIds => $composableBuilder(
    column: $table.ingredientIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientNames => $composableBuilder(
    column: $table.ingredientNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processContext => $composableBuilder(
    column: $table.processContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observedOrPredicted => $composableBuilder(
    column: $table.observedOrPredicted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aromaSimilarity => $composableBuilder(
    column: $table.aromaSimilarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aromaComplement => $composableBuilder(
    column: $table.aromaComplement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aromaContrast => $composableBuilder(
    column: $table.aromaContrast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tasteBalance => $composableBuilder(
    column: $table.tasteBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get culinarySupport => $composableBuilder(
    column: $table.culinarySupport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorySupport => $composableBuilder(
    column: $table.sensorySupport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dominanceRisk => $composableBuilder(
    column: $table.dominanceRisk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maskingRisk => $composableBuilder(
    column: $table.maskingRisk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get noveltyScore => $composableBuilder(
    column: $table.noveltyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyCompounds => $composableBuilder(
    column: $table.keyCompounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyDescriptors => $composableBuilder(
    column: $table.keyDescriptors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bridgeIngredients => $composableBuilder(
    column: $table.bridgeIngredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceRefs => $composableBuilder(
    column: $table.evidenceRefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlavorCompatibilityTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlavorCompatibilityTable> {
  $$FlavorCompatibilityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<int> get combinationSize => $composableBuilder(
    column: $table.combinationSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientIds => $composableBuilder(
    column: $table.ingredientIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientNames => $composableBuilder(
    column: $table.ingredientNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get processContext => $composableBuilder(
    column: $table.processContext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observedOrPredicted => $composableBuilder(
    column: $table.observedOrPredicted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aromaSimilarity => $composableBuilder(
    column: $table.aromaSimilarity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aromaComplement => $composableBuilder(
    column: $table.aromaComplement,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aromaContrast => $composableBuilder(
    column: $table.aromaContrast,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tasteBalance => $composableBuilder(
    column: $table.tasteBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get culinarySupport => $composableBuilder(
    column: $table.culinarySupport,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sensorySupport => $composableBuilder(
    column: $table.sensorySupport,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dominanceRisk => $composableBuilder(
    column: $table.dominanceRisk,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maskingRisk => $composableBuilder(
    column: $table.maskingRisk,
    builder: (column) => column,
  );

  GeneratedColumn<double> get noveltyScore => $composableBuilder(
    column: $table.noveltyScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyCompounds => $composableBuilder(
    column: $table.keyCompounds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyDescriptors => $composableBuilder(
    column: $table.keyDescriptors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bridgeIngredients => $composableBuilder(
    column: $table.bridgeIngredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceRefs => $composableBuilder(
    column: $table.evidenceRefs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );
}

class $$FlavorCompatibilityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlavorCompatibilityTable,
          FlavorCompatibilityData,
          $$FlavorCompatibilityTableFilterComposer,
          $$FlavorCompatibilityTableOrderingComposer,
          $$FlavorCompatibilityTableAnnotationComposer,
          $$FlavorCompatibilityTableCreateCompanionBuilder,
          $$FlavorCompatibilityTableUpdateCompanionBuilder,
          (
            FlavorCompatibilityData,
            BaseReferences<
              _$AppDatabase,
              $FlavorCompatibilityTable,
              FlavorCompatibilityData
            >,
          ),
          FlavorCompatibilityData,
          PrefetchHooks Function()
        > {
  $$FlavorCompatibilityTableTableManager(
    _$AppDatabase db,
    $FlavorCompatibilityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlavorCompatibilityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlavorCompatibilityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FlavorCompatibilityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> recordId = const Value.absent(),
                Value<int?> combinationSize = const Value.absent(),
                Value<String?> ingredientIds = const Value.absent(),
                Value<String?> ingredientNames = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<String?> processContext = const Value.absent(),
                Value<String?> observedOrPredicted = const Value.absent(),
                Value<double?> aromaSimilarity = const Value.absent(),
                Value<double?> aromaComplement = const Value.absent(),
                Value<double?> aromaContrast = const Value.absent(),
                Value<double?> tasteBalance = const Value.absent(),
                Value<double?> culinarySupport = const Value.absent(),
                Value<double?> sensorySupport = const Value.absent(),
                Value<double?> dominanceRisk = const Value.absent(),
                Value<double?> maskingRisk = const Value.absent(),
                Value<double?> noveltyScore = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> keyCompounds = const Value.absent(),
                Value<String?> keyDescriptors = const Value.absent(),
                Value<String?> bridgeIngredients = const Value.absent(),
                Value<String?> evidenceRefs = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlavorCompatibilityCompanion(
                recordId: recordId,
                combinationSize: combinationSize,
                ingredientIds: ingredientIds,
                ingredientNames: ingredientNames,
                context: context,
                processContext: processContext,
                observedOrPredicted: observedOrPredicted,
                aromaSimilarity: aromaSimilarity,
                aromaComplement: aromaComplement,
                aromaContrast: aromaContrast,
                tasteBalance: tasteBalance,
                culinarySupport: culinarySupport,
                sensorySupport: sensorySupport,
                dominanceRisk: dominanceRisk,
                maskingRisk: maskingRisk,
                noveltyScore: noveltyScore,
                overallScore: overallScore,
                confidence: confidence,
                keyCompounds: keyCompounds,
                keyDescriptors: keyDescriptors,
                bridgeIngredients: bridgeIngredients,
                evidenceRefs: evidenceRefs,
                modelVersion: modelVersion,
                explanation: explanation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recordId,
                Value<int?> combinationSize = const Value.absent(),
                Value<String?> ingredientIds = const Value.absent(),
                Value<String?> ingredientNames = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<String?> processContext = const Value.absent(),
                Value<String?> observedOrPredicted = const Value.absent(),
                Value<double?> aromaSimilarity = const Value.absent(),
                Value<double?> aromaComplement = const Value.absent(),
                Value<double?> aromaContrast = const Value.absent(),
                Value<double?> tasteBalance = const Value.absent(),
                Value<double?> culinarySupport = const Value.absent(),
                Value<double?> sensorySupport = const Value.absent(),
                Value<double?> dominanceRisk = const Value.absent(),
                Value<double?> maskingRisk = const Value.absent(),
                Value<double?> noveltyScore = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> keyCompounds = const Value.absent(),
                Value<String?> keyDescriptors = const Value.absent(),
                Value<String?> bridgeIngredients = const Value.absent(),
                Value<String?> evidenceRefs = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlavorCompatibilityCompanion.insert(
                recordId: recordId,
                combinationSize: combinationSize,
                ingredientIds: ingredientIds,
                ingredientNames: ingredientNames,
                context: context,
                processContext: processContext,
                observedOrPredicted: observedOrPredicted,
                aromaSimilarity: aromaSimilarity,
                aromaComplement: aromaComplement,
                aromaContrast: aromaContrast,
                tasteBalance: tasteBalance,
                culinarySupport: culinarySupport,
                sensorySupport: sensorySupport,
                dominanceRisk: dominanceRisk,
                maskingRisk: maskingRisk,
                noveltyScore: noveltyScore,
                overallScore: overallScore,
                confidence: confidence,
                keyCompounds: keyCompounds,
                keyDescriptors: keyDescriptors,
                bridgeIngredients: bridgeIngredients,
                evidenceRefs: evidenceRefs,
                modelVersion: modelVersion,
                explanation: explanation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlavorCompatibilityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlavorCompatibilityTable,
      FlavorCompatibilityData,
      $$FlavorCompatibilityTableFilterComposer,
      $$FlavorCompatibilityTableOrderingComposer,
      $$FlavorCompatibilityTableAnnotationComposer,
      $$FlavorCompatibilityTableCreateCompanionBuilder,
      $$FlavorCompatibilityTableUpdateCompanionBuilder,
      (
        FlavorCompatibilityData,
        BaseReferences<
          _$AppDatabase,
          $FlavorCompatibilityTable,
          FlavorCompatibilityData
        >,
      ),
      FlavorCompatibilityData,
      PrefetchHooks Function()
    >;
typedef $$FunctionalIngredientsTableCreateCompanionBuilder =
    FunctionalIngredientsCompanion Function({
      required String ingredientId,
      required String ingredientStateId,
      Value<double?> temperatureReferenceC,
      Value<double?> waterContent,
      Value<double?> fatContent,
      Value<double?> proteinContent,
      Value<double?> starchContent,
      Value<double?> sugarContent,
      Value<double?> fiberContent,
      Value<double?> pectinContent,
      Value<double?> alcoholContent,
      Value<double?> saltContent,
      Value<double?> mineralContent,
      Value<double?> ph,
      Value<double?> titratableAcidity,
      Value<double?> waterActivity,
      Value<double?> brix,
      Value<double?> densityGPerMl,
      Value<double?> particleSizeUm,
      Value<String?> solubility,
      Value<double?> oilHoldingCapacityGG,
      Value<double?> waterHoldingCapacityGG,
      Value<String?> emulsifyingCapacity,
      Value<String?> foamingCapacity,
      Value<String?> gelationCapability,
      Value<String?> thickeningCapability,
      Value<String?> hygroscopicity,
      Value<String?> thermalStability,
      Value<String?> freezeThawStability,
      Value<String?> oxidationSensitivity,
      Value<String?> sourceRefs,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<String?> validityConditions,
      Value<int> rowid,
    });
typedef $$FunctionalIngredientsTableUpdateCompanionBuilder =
    FunctionalIngredientsCompanion Function({
      Value<String> ingredientId,
      Value<String> ingredientStateId,
      Value<double?> temperatureReferenceC,
      Value<double?> waterContent,
      Value<double?> fatContent,
      Value<double?> proteinContent,
      Value<double?> starchContent,
      Value<double?> sugarContent,
      Value<double?> fiberContent,
      Value<double?> pectinContent,
      Value<double?> alcoholContent,
      Value<double?> saltContent,
      Value<double?> mineralContent,
      Value<double?> ph,
      Value<double?> titratableAcidity,
      Value<double?> waterActivity,
      Value<double?> brix,
      Value<double?> densityGPerMl,
      Value<double?> particleSizeUm,
      Value<String?> solubility,
      Value<double?> oilHoldingCapacityGG,
      Value<double?> waterHoldingCapacityGG,
      Value<String?> emulsifyingCapacity,
      Value<String?> foamingCapacity,
      Value<String?> gelationCapability,
      Value<String?> thickeningCapability,
      Value<String?> hygroscopicity,
      Value<String?> thermalStability,
      Value<String?> freezeThawStability,
      Value<String?> oxidationSensitivity,
      Value<String?> sourceRefs,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<String?> validityConditions,
      Value<int> rowid,
    });

final class $$FunctionalIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FunctionalIngredientsTable,
          FunctionalIngredient
        > {
  $$FunctionalIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
        'functional_ingredients__ingredient_id__ingredients__ingredient_id',
      );

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<String>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.ingredientId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FunctionalIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $FunctionalIngredientsTable> {
  $$FunctionalIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureReferenceC => $composableBuilder(
    column: $table.temperatureReferenceC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterContent => $composableBuilder(
    column: $table.waterContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatContent => $composableBuilder(
    column: $table.fatContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinContent => $composableBuilder(
    column: $table.proteinContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get starchContent => $composableBuilder(
    column: $table.starchContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarContent => $composableBuilder(
    column: $table.sugarContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberContent => $composableBuilder(
    column: $table.fiberContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pectinContent => $composableBuilder(
    column: $table.pectinContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alcoholContent => $composableBuilder(
    column: $table.alcoholContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saltContent => $composableBuilder(
    column: $table.saltContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mineralContent => $composableBuilder(
    column: $table.mineralContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get titratableAcidity => $composableBuilder(
    column: $table.titratableAcidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterActivity => $composableBuilder(
    column: $table.waterActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brix => $composableBuilder(
    column: $table.brix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get densityGPerMl => $composableBuilder(
    column: $table.densityGPerMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get particleSizeUm => $composableBuilder(
    column: $table.particleSizeUm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solubility => $composableBuilder(
    column: $table.solubility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oilHoldingCapacityGG => $composableBuilder(
    column: $table.oilHoldingCapacityGG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterHoldingCapacityGG => $composableBuilder(
    column: $table.waterHoldingCapacityGG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emulsifyingCapacity => $composableBuilder(
    column: $table.emulsifyingCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foamingCapacity => $composableBuilder(
    column: $table.foamingCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gelationCapability => $composableBuilder(
    column: $table.gelationCapability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thickeningCapability => $composableBuilder(
    column: $table.thickeningCapability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hygroscopicity => $composableBuilder(
    column: $table.hygroscopicity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thermalStability => $composableBuilder(
    column: $table.thermalStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freezeThawStability => $composableBuilder(
    column: $table.freezeThawStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oxidationSensitivity => $composableBuilder(
    column: $table.oxidationSensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validityConditions => $composableBuilder(
    column: $table.validityConditions,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FunctionalIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $FunctionalIngredientsTable> {
  $$FunctionalIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureReferenceC => $composableBuilder(
    column: $table.temperatureReferenceC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterContent => $composableBuilder(
    column: $table.waterContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatContent => $composableBuilder(
    column: $table.fatContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinContent => $composableBuilder(
    column: $table.proteinContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get starchContent => $composableBuilder(
    column: $table.starchContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarContent => $composableBuilder(
    column: $table.sugarContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberContent => $composableBuilder(
    column: $table.fiberContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pectinContent => $composableBuilder(
    column: $table.pectinContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alcoholContent => $composableBuilder(
    column: $table.alcoholContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saltContent => $composableBuilder(
    column: $table.saltContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mineralContent => $composableBuilder(
    column: $table.mineralContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get titratableAcidity => $composableBuilder(
    column: $table.titratableAcidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterActivity => $composableBuilder(
    column: $table.waterActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brix => $composableBuilder(
    column: $table.brix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get densityGPerMl => $composableBuilder(
    column: $table.densityGPerMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get particleSizeUm => $composableBuilder(
    column: $table.particleSizeUm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solubility => $composableBuilder(
    column: $table.solubility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oilHoldingCapacityGG => $composableBuilder(
    column: $table.oilHoldingCapacityGG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterHoldingCapacityGG => $composableBuilder(
    column: $table.waterHoldingCapacityGG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emulsifyingCapacity => $composableBuilder(
    column: $table.emulsifyingCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foamingCapacity => $composableBuilder(
    column: $table.foamingCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gelationCapability => $composableBuilder(
    column: $table.gelationCapability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thickeningCapability => $composableBuilder(
    column: $table.thickeningCapability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hygroscopicity => $composableBuilder(
    column: $table.hygroscopicity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thermalStability => $composableBuilder(
    column: $table.thermalStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freezeThawStability => $composableBuilder(
    column: $table.freezeThawStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oxidationSensitivity => $composableBuilder(
    column: $table.oxidationSensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validityConditions => $composableBuilder(
    column: $table.validityConditions,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FunctionalIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FunctionalIngredientsTable> {
  $$FunctionalIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ingredientStateId => $composableBuilder(
    column: $table.ingredientStateId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureReferenceC => $composableBuilder(
    column: $table.temperatureReferenceC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterContent => $composableBuilder(
    column: $table.waterContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatContent => $composableBuilder(
    column: $table.fatContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinContent => $composableBuilder(
    column: $table.proteinContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get starchContent => $composableBuilder(
    column: $table.starchContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugarContent => $composableBuilder(
    column: $table.sugarContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberContent => $composableBuilder(
    column: $table.fiberContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pectinContent => $composableBuilder(
    column: $table.pectinContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alcoholContent => $composableBuilder(
    column: $table.alcoholContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saltContent => $composableBuilder(
    column: $table.saltContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mineralContent => $composableBuilder(
    column: $table.mineralContent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ph =>
      $composableBuilder(column: $table.ph, builder: (column) => column);

  GeneratedColumn<double> get titratableAcidity => $composableBuilder(
    column: $table.titratableAcidity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterActivity => $composableBuilder(
    column: $table.waterActivity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brix =>
      $composableBuilder(column: $table.brix, builder: (column) => column);

  GeneratedColumn<double> get densityGPerMl => $composableBuilder(
    column: $table.densityGPerMl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get particleSizeUm => $composableBuilder(
    column: $table.particleSizeUm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get solubility => $composableBuilder(
    column: $table.solubility,
    builder: (column) => column,
  );

  GeneratedColumn<double> get oilHoldingCapacityGG => $composableBuilder(
    column: $table.oilHoldingCapacityGG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterHoldingCapacityGG => $composableBuilder(
    column: $table.waterHoldingCapacityGG,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emulsifyingCapacity => $composableBuilder(
    column: $table.emulsifyingCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foamingCapacity => $composableBuilder(
    column: $table.foamingCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gelationCapability => $composableBuilder(
    column: $table.gelationCapability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thickeningCapability => $composableBuilder(
    column: $table.thickeningCapability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hygroscopicity => $composableBuilder(
    column: $table.hygroscopicity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thermalStability => $composableBuilder(
    column: $table.thermalStability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freezeThawStability => $composableBuilder(
    column: $table.freezeThawStability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oxidationSensitivity => $composableBuilder(
    column: $table.oxidationSensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validityConditions => $composableBuilder(
    column: $table.validityConditions,
    builder: (column) => column,
  );

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FunctionalIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FunctionalIngredientsTable,
          FunctionalIngredient,
          $$FunctionalIngredientsTableFilterComposer,
          $$FunctionalIngredientsTableOrderingComposer,
          $$FunctionalIngredientsTableAnnotationComposer,
          $$FunctionalIngredientsTableCreateCompanionBuilder,
          $$FunctionalIngredientsTableUpdateCompanionBuilder,
          (FunctionalIngredient, $$FunctionalIngredientsTableReferences),
          FunctionalIngredient,
          PrefetchHooks Function({bool ingredientId})
        > {
  $$FunctionalIngredientsTableTableManager(
    _$AppDatabase db,
    $FunctionalIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FunctionalIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FunctionalIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FunctionalIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ingredientId = const Value.absent(),
                Value<String> ingredientStateId = const Value.absent(),
                Value<double?> temperatureReferenceC = const Value.absent(),
                Value<double?> waterContent = const Value.absent(),
                Value<double?> fatContent = const Value.absent(),
                Value<double?> proteinContent = const Value.absent(),
                Value<double?> starchContent = const Value.absent(),
                Value<double?> sugarContent = const Value.absent(),
                Value<double?> fiberContent = const Value.absent(),
                Value<double?> pectinContent = const Value.absent(),
                Value<double?> alcoholContent = const Value.absent(),
                Value<double?> saltContent = const Value.absent(),
                Value<double?> mineralContent = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<double?> titratableAcidity = const Value.absent(),
                Value<double?> waterActivity = const Value.absent(),
                Value<double?> brix = const Value.absent(),
                Value<double?> densityGPerMl = const Value.absent(),
                Value<double?> particleSizeUm = const Value.absent(),
                Value<String?> solubility = const Value.absent(),
                Value<double?> oilHoldingCapacityGG = const Value.absent(),
                Value<double?> waterHoldingCapacityGG = const Value.absent(),
                Value<String?> emulsifyingCapacity = const Value.absent(),
                Value<String?> foamingCapacity = const Value.absent(),
                Value<String?> gelationCapability = const Value.absent(),
                Value<String?> thickeningCapability = const Value.absent(),
                Value<String?> hygroscopicity = const Value.absent(),
                Value<String?> thermalStability = const Value.absent(),
                Value<String?> freezeThawStability = const Value.absent(),
                Value<String?> oxidationSensitivity = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> validityConditions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FunctionalIngredientsCompanion(
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                temperatureReferenceC: temperatureReferenceC,
                waterContent: waterContent,
                fatContent: fatContent,
                proteinContent: proteinContent,
                starchContent: starchContent,
                sugarContent: sugarContent,
                fiberContent: fiberContent,
                pectinContent: pectinContent,
                alcoholContent: alcoholContent,
                saltContent: saltContent,
                mineralContent: mineralContent,
                ph: ph,
                titratableAcidity: titratableAcidity,
                waterActivity: waterActivity,
                brix: brix,
                densityGPerMl: densityGPerMl,
                particleSizeUm: particleSizeUm,
                solubility: solubility,
                oilHoldingCapacityGG: oilHoldingCapacityGG,
                waterHoldingCapacityGG: waterHoldingCapacityGG,
                emulsifyingCapacity: emulsifyingCapacity,
                foamingCapacity: foamingCapacity,
                gelationCapability: gelationCapability,
                thickeningCapability: thickeningCapability,
                hygroscopicity: hygroscopicity,
                thermalStability: thermalStability,
                freezeThawStability: freezeThawStability,
                oxidationSensitivity: oxidationSensitivity,
                sourceRefs: sourceRefs,
                evidenceType: evidenceType,
                confidence: confidence,
                validityConditions: validityConditions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ingredientId,
                required String ingredientStateId,
                Value<double?> temperatureReferenceC = const Value.absent(),
                Value<double?> waterContent = const Value.absent(),
                Value<double?> fatContent = const Value.absent(),
                Value<double?> proteinContent = const Value.absent(),
                Value<double?> starchContent = const Value.absent(),
                Value<double?> sugarContent = const Value.absent(),
                Value<double?> fiberContent = const Value.absent(),
                Value<double?> pectinContent = const Value.absent(),
                Value<double?> alcoholContent = const Value.absent(),
                Value<double?> saltContent = const Value.absent(),
                Value<double?> mineralContent = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<double?> titratableAcidity = const Value.absent(),
                Value<double?> waterActivity = const Value.absent(),
                Value<double?> brix = const Value.absent(),
                Value<double?> densityGPerMl = const Value.absent(),
                Value<double?> particleSizeUm = const Value.absent(),
                Value<String?> solubility = const Value.absent(),
                Value<double?> oilHoldingCapacityGG = const Value.absent(),
                Value<double?> waterHoldingCapacityGG = const Value.absent(),
                Value<String?> emulsifyingCapacity = const Value.absent(),
                Value<String?> foamingCapacity = const Value.absent(),
                Value<String?> gelationCapability = const Value.absent(),
                Value<String?> thickeningCapability = const Value.absent(),
                Value<String?> hygroscopicity = const Value.absent(),
                Value<String?> thermalStability = const Value.absent(),
                Value<String?> freezeThawStability = const Value.absent(),
                Value<String?> oxidationSensitivity = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> validityConditions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FunctionalIngredientsCompanion.insert(
                ingredientId: ingredientId,
                ingredientStateId: ingredientStateId,
                temperatureReferenceC: temperatureReferenceC,
                waterContent: waterContent,
                fatContent: fatContent,
                proteinContent: proteinContent,
                starchContent: starchContent,
                sugarContent: sugarContent,
                fiberContent: fiberContent,
                pectinContent: pectinContent,
                alcoholContent: alcoholContent,
                saltContent: saltContent,
                mineralContent: mineralContent,
                ph: ph,
                titratableAcidity: titratableAcidity,
                waterActivity: waterActivity,
                brix: brix,
                densityGPerMl: densityGPerMl,
                particleSizeUm: particleSizeUm,
                solubility: solubility,
                oilHoldingCapacityGG: oilHoldingCapacityGG,
                waterHoldingCapacityGG: waterHoldingCapacityGG,
                emulsifyingCapacity: emulsifyingCapacity,
                foamingCapacity: foamingCapacity,
                gelationCapability: gelationCapability,
                thickeningCapability: thickeningCapability,
                hygroscopicity: hygroscopicity,
                thermalStability: thermalStability,
                freezeThawStability: freezeThawStability,
                oxidationSensitivity: oxidationSensitivity,
                sourceRefs: sourceRefs,
                evidenceType: evidenceType,
                confidence: confidence,
                validityConditions: validityConditions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FunctionalIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ingredientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ingredientId,
                        referencedTable: $$FunctionalIngredientsTableReferences
                            ._ingredientIdTable(db),
                        referencedColumn: $$FunctionalIngredientsTableReferences
                            ._ingredientIdTable(db)
                            .ingredientId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FunctionalIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FunctionalIngredientsTable,
      FunctionalIngredient,
      $$FunctionalIngredientsTableFilterComposer,
      $$FunctionalIngredientsTableOrderingComposer,
      $$FunctionalIngredientsTableAnnotationComposer,
      $$FunctionalIngredientsTableCreateCompanionBuilder,
      $$FunctionalIngredientsTableUpdateCompanionBuilder,
      (FunctionalIngredient, $$FunctionalIngredientsTableReferences),
      FunctionalIngredient,
      PrefetchHooks Function({bool ingredientId})
    >;
typedef $$InteractionRulesTableCreateCompanionBuilder =
    InteractionRulesCompanion Function({
      required String ruleId,
      Value<String?> ruleFamily,
      Value<String?> reactantOrComponentIds,
      Value<String?> ingredientConstraints,
      Value<String?> compositionConstraints,
      Value<String?> processConstraints,
      Value<double?> phMin,
      Value<double?> phMax,
      Value<double?> temperatureMin,
      Value<double?> temperatureMax,
      Value<double?> timeMin,
      Value<double?> timeMax,
      Value<double?> waterActivityMin,
      Value<double?> waterActivityMax,
      Value<String?> shearConstraints,
      Value<String?> orderConstraints,
      Value<String?> predictedEffect,
      Value<String?> effectDirection,
      Value<String?> effectMagnitude,
      Value<String?> outputProperty,
      Value<String?> equationOrLogic,
      Value<String?> sourceRefs,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<bool?> extrapolationAllowed,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$InteractionRulesTableUpdateCompanionBuilder =
    InteractionRulesCompanion Function({
      Value<String> ruleId,
      Value<String?> ruleFamily,
      Value<String?> reactantOrComponentIds,
      Value<String?> ingredientConstraints,
      Value<String?> compositionConstraints,
      Value<String?> processConstraints,
      Value<double?> phMin,
      Value<double?> phMax,
      Value<double?> temperatureMin,
      Value<double?> temperatureMax,
      Value<double?> timeMin,
      Value<double?> timeMax,
      Value<double?> waterActivityMin,
      Value<double?> waterActivityMax,
      Value<String?> shearConstraints,
      Value<String?> orderConstraints,
      Value<String?> predictedEffect,
      Value<String?> effectDirection,
      Value<String?> effectMagnitude,
      Value<String?> outputProperty,
      Value<String?> equationOrLogic,
      Value<String?> sourceRefs,
      Value<String?> evidenceType,
      Value<double?> confidence,
      Value<bool?> extrapolationAllowed,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$InteractionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $InteractionRulesTable> {
  $$InteractionRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleFamily => $composableBuilder(
    column: $table.ruleFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactantOrComponentIds => $composableBuilder(
    column: $table.reactantOrComponentIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientConstraints => $composableBuilder(
    column: $table.ingredientConstraints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compositionConstraints => $composableBuilder(
    column: $table.compositionConstraints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processConstraints => $composableBuilder(
    column: $table.processConstraints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phMin => $composableBuilder(
    column: $table.phMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phMax => $composableBuilder(
    column: $table.phMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timeMin => $composableBuilder(
    column: $table.timeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timeMax => $composableBuilder(
    column: $table.timeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterActivityMin => $composableBuilder(
    column: $table.waterActivityMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterActivityMax => $composableBuilder(
    column: $table.waterActivityMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shearConstraints => $composableBuilder(
    column: $table.shearConstraints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderConstraints => $composableBuilder(
    column: $table.orderConstraints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictedEffect => $composableBuilder(
    column: $table.predictedEffect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectDirection => $composableBuilder(
    column: $table.effectDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectMagnitude => $composableBuilder(
    column: $table.effectMagnitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputProperty => $composableBuilder(
    column: $table.outputProperty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equationOrLogic => $composableBuilder(
    column: $table.equationOrLogic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get extrapolationAllowed => $composableBuilder(
    column: $table.extrapolationAllowed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InteractionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $InteractionRulesTable> {
  $$InteractionRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleFamily => $composableBuilder(
    column: $table.ruleFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactantOrComponentIds => $composableBuilder(
    column: $table.reactantOrComponentIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientConstraints => $composableBuilder(
    column: $table.ingredientConstraints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compositionConstraints => $composableBuilder(
    column: $table.compositionConstraints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processConstraints => $composableBuilder(
    column: $table.processConstraints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phMin => $composableBuilder(
    column: $table.phMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phMax => $composableBuilder(
    column: $table.phMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timeMin => $composableBuilder(
    column: $table.timeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timeMax => $composableBuilder(
    column: $table.timeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterActivityMin => $composableBuilder(
    column: $table.waterActivityMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterActivityMax => $composableBuilder(
    column: $table.waterActivityMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shearConstraints => $composableBuilder(
    column: $table.shearConstraints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderConstraints => $composableBuilder(
    column: $table.orderConstraints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictedEffect => $composableBuilder(
    column: $table.predictedEffect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectDirection => $composableBuilder(
    column: $table.effectDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectMagnitude => $composableBuilder(
    column: $table.effectMagnitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputProperty => $composableBuilder(
    column: $table.outputProperty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equationOrLogic => $composableBuilder(
    column: $table.equationOrLogic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get extrapolationAllowed => $composableBuilder(
    column: $table.extrapolationAllowed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InteractionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InteractionRulesTable> {
  $$InteractionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get ruleFamily => $composableBuilder(
    column: $table.ruleFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reactantOrComponentIds => $composableBuilder(
    column: $table.reactantOrComponentIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientConstraints => $composableBuilder(
    column: $table.ingredientConstraints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compositionConstraints => $composableBuilder(
    column: $table.compositionConstraints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processConstraints => $composableBuilder(
    column: $table.processConstraints,
    builder: (column) => column,
  );

  GeneratedColumn<double> get phMin =>
      $composableBuilder(column: $table.phMin, builder: (column) => column);

  GeneratedColumn<double> get phMax =>
      $composableBuilder(column: $table.phMax, builder: (column) => column);

  GeneratedColumn<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get timeMin =>
      $composableBuilder(column: $table.timeMin, builder: (column) => column);

  GeneratedColumn<double> get timeMax =>
      $composableBuilder(column: $table.timeMax, builder: (column) => column);

  GeneratedColumn<double> get waterActivityMin => $composableBuilder(
    column: $table.waterActivityMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterActivityMax => $composableBuilder(
    column: $table.waterActivityMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shearConstraints => $composableBuilder(
    column: $table.shearConstraints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderConstraints => $composableBuilder(
    column: $table.orderConstraints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get predictedEffect => $composableBuilder(
    column: $table.predictedEffect,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectDirection => $composableBuilder(
    column: $table.effectDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectMagnitude => $composableBuilder(
    column: $table.effectMagnitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outputProperty => $composableBuilder(
    column: $table.outputProperty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equationOrLogic => $composableBuilder(
    column: $table.equationOrLogic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRefs => $composableBuilder(
    column: $table.sourceRefs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get extrapolationAllowed => $composableBuilder(
    column: $table.extrapolationAllowed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InteractionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InteractionRulesTable,
          InteractionRule,
          $$InteractionRulesTableFilterComposer,
          $$InteractionRulesTableOrderingComposer,
          $$InteractionRulesTableAnnotationComposer,
          $$InteractionRulesTableCreateCompanionBuilder,
          $$InteractionRulesTableUpdateCompanionBuilder,
          (
            InteractionRule,
            BaseReferences<
              _$AppDatabase,
              $InteractionRulesTable,
              InteractionRule
            >,
          ),
          InteractionRule,
          PrefetchHooks Function()
        > {
  $$InteractionRulesTableTableManager(
    _$AppDatabase db,
    $InteractionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InteractionRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InteractionRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InteractionRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ruleId = const Value.absent(),
                Value<String?> ruleFamily = const Value.absent(),
                Value<String?> reactantOrComponentIds = const Value.absent(),
                Value<String?> ingredientConstraints = const Value.absent(),
                Value<String?> compositionConstraints = const Value.absent(),
                Value<String?> processConstraints = const Value.absent(),
                Value<double?> phMin = const Value.absent(),
                Value<double?> phMax = const Value.absent(),
                Value<double?> temperatureMin = const Value.absent(),
                Value<double?> temperatureMax = const Value.absent(),
                Value<double?> timeMin = const Value.absent(),
                Value<double?> timeMax = const Value.absent(),
                Value<double?> waterActivityMin = const Value.absent(),
                Value<double?> waterActivityMax = const Value.absent(),
                Value<String?> shearConstraints = const Value.absent(),
                Value<String?> orderConstraints = const Value.absent(),
                Value<String?> predictedEffect = const Value.absent(),
                Value<String?> effectDirection = const Value.absent(),
                Value<String?> effectMagnitude = const Value.absent(),
                Value<String?> outputProperty = const Value.absent(),
                Value<String?> equationOrLogic = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<bool?> extrapolationAllowed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionRulesCompanion(
                ruleId: ruleId,
                ruleFamily: ruleFamily,
                reactantOrComponentIds: reactantOrComponentIds,
                ingredientConstraints: ingredientConstraints,
                compositionConstraints: compositionConstraints,
                processConstraints: processConstraints,
                phMin: phMin,
                phMax: phMax,
                temperatureMin: temperatureMin,
                temperatureMax: temperatureMax,
                timeMin: timeMin,
                timeMax: timeMax,
                waterActivityMin: waterActivityMin,
                waterActivityMax: waterActivityMax,
                shearConstraints: shearConstraints,
                orderConstraints: orderConstraints,
                predictedEffect: predictedEffect,
                effectDirection: effectDirection,
                effectMagnitude: effectMagnitude,
                outputProperty: outputProperty,
                equationOrLogic: equationOrLogic,
                sourceRefs: sourceRefs,
                evidenceType: evidenceType,
                confidence: confidence,
                extrapolationAllowed: extrapolationAllowed,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ruleId,
                Value<String?> ruleFamily = const Value.absent(),
                Value<String?> reactantOrComponentIds = const Value.absent(),
                Value<String?> ingredientConstraints = const Value.absent(),
                Value<String?> compositionConstraints = const Value.absent(),
                Value<String?> processConstraints = const Value.absent(),
                Value<double?> phMin = const Value.absent(),
                Value<double?> phMax = const Value.absent(),
                Value<double?> temperatureMin = const Value.absent(),
                Value<double?> temperatureMax = const Value.absent(),
                Value<double?> timeMin = const Value.absent(),
                Value<double?> timeMax = const Value.absent(),
                Value<double?> waterActivityMin = const Value.absent(),
                Value<double?> waterActivityMax = const Value.absent(),
                Value<String?> shearConstraints = const Value.absent(),
                Value<String?> orderConstraints = const Value.absent(),
                Value<String?> predictedEffect = const Value.absent(),
                Value<String?> effectDirection = const Value.absent(),
                Value<String?> effectMagnitude = const Value.absent(),
                Value<String?> outputProperty = const Value.absent(),
                Value<String?> equationOrLogic = const Value.absent(),
                Value<String?> sourceRefs = const Value.absent(),
                Value<String?> evidenceType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<bool?> extrapolationAllowed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionRulesCompanion.insert(
                ruleId: ruleId,
                ruleFamily: ruleFamily,
                reactantOrComponentIds: reactantOrComponentIds,
                ingredientConstraints: ingredientConstraints,
                compositionConstraints: compositionConstraints,
                processConstraints: processConstraints,
                phMin: phMin,
                phMax: phMax,
                temperatureMin: temperatureMin,
                temperatureMax: temperatureMax,
                timeMin: timeMin,
                timeMax: timeMax,
                waterActivityMin: waterActivityMin,
                waterActivityMax: waterActivityMax,
                shearConstraints: shearConstraints,
                orderConstraints: orderConstraints,
                predictedEffect: predictedEffect,
                effectDirection: effectDirection,
                effectMagnitude: effectMagnitude,
                outputProperty: outputProperty,
                equationOrLogic: equationOrLogic,
                sourceRefs: sourceRefs,
                evidenceType: evidenceType,
                confidence: confidence,
                extrapolationAllowed: extrapolationAllowed,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InteractionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InteractionRulesTable,
      InteractionRule,
      $$InteractionRulesTableFilterComposer,
      $$InteractionRulesTableOrderingComposer,
      $$InteractionRulesTableAnnotationComposer,
      $$InteractionRulesTableCreateCompanionBuilder,
      $$InteractionRulesTableUpdateCompanionBuilder,
      (
        InteractionRule,
        BaseReferences<_$AppDatabase, $InteractionRulesTable, InteractionRule>,
      ),
      InteractionRule,
      PrefetchHooks Function()
    >;
typedef $$ProcessOperationsTableCreateCompanionBuilder =
    ProcessOperationsCompanion Function({
      required String opId,
      Value<String?> family,
      Value<String?> name,
      Value<double?> tMinC,
      Value<double?> tMaxC,
      Value<double?> durationMin,
      Value<String?> pressure,
      Value<double?> shearRateS1,
      Value<String?> mixingRpm,
      Value<double?> energyInput,
      Value<double?> coolingRate,
      Value<double?> heatingRate,
      Value<double?> targetPh,
      Value<double?> targetAw,
      Value<double?> targetBrix,
      Value<double?> particleSizeTargetUm,
      Value<String?> oxygenExposure,
      Value<String?> atmosphere,
      Value<int?> orderIndex,
      Value<String?> additionMode,
      Value<double?> restTime,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ProcessOperationsTableUpdateCompanionBuilder =
    ProcessOperationsCompanion Function({
      Value<String> opId,
      Value<String?> family,
      Value<String?> name,
      Value<double?> tMinC,
      Value<double?> tMaxC,
      Value<double?> durationMin,
      Value<String?> pressure,
      Value<double?> shearRateS1,
      Value<String?> mixingRpm,
      Value<double?> energyInput,
      Value<double?> coolingRate,
      Value<double?> heatingRate,
      Value<double?> targetPh,
      Value<double?> targetAw,
      Value<double?> targetBrix,
      Value<double?> particleSizeTargetUm,
      Value<String?> oxygenExposure,
      Value<String?> atmosphere,
      Value<int?> orderIndex,
      Value<String?> additionMode,
      Value<double?> restTime,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$ProcessOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessOperationsTable> {
  $$ProcessOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tMinC => $composableBuilder(
    column: $table.tMinC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tMaxC => $composableBuilder(
    column: $table.tMaxC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shearRateS1 => $composableBuilder(
    column: $table.shearRateS1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mixingRpm => $composableBuilder(
    column: $table.mixingRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyInput => $composableBuilder(
    column: $table.energyInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coolingRate => $composableBuilder(
    column: $table.coolingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heatingRate => $composableBuilder(
    column: $table.heatingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPh => $composableBuilder(
    column: $table.targetPh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAw => $composableBuilder(
    column: $table.targetAw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetBrix => $composableBuilder(
    column: $table.targetBrix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get particleSizeTargetUm => $composableBuilder(
    column: $table.particleSizeTargetUm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oxygenExposure => $composableBuilder(
    column: $table.oxygenExposure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get atmosphere => $composableBuilder(
    column: $table.atmosphere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionMode => $composableBuilder(
    column: $table.additionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProcessOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessOperationsTable> {
  $$ProcessOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tMinC => $composableBuilder(
    column: $table.tMinC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tMaxC => $composableBuilder(
    column: $table.tMaxC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shearRateS1 => $composableBuilder(
    column: $table.shearRateS1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mixingRpm => $composableBuilder(
    column: $table.mixingRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyInput => $composableBuilder(
    column: $table.energyInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coolingRate => $composableBuilder(
    column: $table.coolingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heatingRate => $composableBuilder(
    column: $table.heatingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPh => $composableBuilder(
    column: $table.targetPh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAw => $composableBuilder(
    column: $table.targetAw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetBrix => $composableBuilder(
    column: $table.targetBrix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get particleSizeTargetUm => $composableBuilder(
    column: $table.particleSizeTargetUm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oxygenExposure => $composableBuilder(
    column: $table.oxygenExposure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get atmosphere => $composableBuilder(
    column: $table.atmosphere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionMode => $composableBuilder(
    column: $table.additionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProcessOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessOperationsTable> {
  $$ProcessOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get tMinC =>
      $composableBuilder(column: $table.tMinC, builder: (column) => column);

  GeneratedColumn<double> get tMaxC =>
      $composableBuilder(column: $table.tMaxC, builder: (column) => column);

  GeneratedColumn<double> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pressure =>
      $composableBuilder(column: $table.pressure, builder: (column) => column);

  GeneratedColumn<double> get shearRateS1 => $composableBuilder(
    column: $table.shearRateS1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mixingRpm =>
      $composableBuilder(column: $table.mixingRpm, builder: (column) => column);

  GeneratedColumn<double> get energyInput => $composableBuilder(
    column: $table.energyInput,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coolingRate => $composableBuilder(
    column: $table.coolingRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heatingRate => $composableBuilder(
    column: $table.heatingRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetPh =>
      $composableBuilder(column: $table.targetPh, builder: (column) => column);

  GeneratedColumn<double> get targetAw =>
      $composableBuilder(column: $table.targetAw, builder: (column) => column);

  GeneratedColumn<double> get targetBrix => $composableBuilder(
    column: $table.targetBrix,
    builder: (column) => column,
  );

  GeneratedColumn<double> get particleSizeTargetUm => $composableBuilder(
    column: $table.particleSizeTargetUm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oxygenExposure => $composableBuilder(
    column: $table.oxygenExposure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get atmosphere => $composableBuilder(
    column: $table.atmosphere,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionMode => $composableBuilder(
    column: $table.additionMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get restTime =>
      $composableBuilder(column: $table.restTime, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ProcessOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessOperationsTable,
          ProcessOperation,
          $$ProcessOperationsTableFilterComposer,
          $$ProcessOperationsTableOrderingComposer,
          $$ProcessOperationsTableAnnotationComposer,
          $$ProcessOperationsTableCreateCompanionBuilder,
          $$ProcessOperationsTableUpdateCompanionBuilder,
          (
            ProcessOperation,
            BaseReferences<
              _$AppDatabase,
              $ProcessOperationsTable,
              ProcessOperation
            >,
          ),
          ProcessOperation,
          PrefetchHooks Function()
        > {
  $$ProcessOperationsTableTableManager(
    _$AppDatabase db,
    $ProcessOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String?> family = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double?> tMinC = const Value.absent(),
                Value<double?> tMaxC = const Value.absent(),
                Value<double?> durationMin = const Value.absent(),
                Value<String?> pressure = const Value.absent(),
                Value<double?> shearRateS1 = const Value.absent(),
                Value<String?> mixingRpm = const Value.absent(),
                Value<double?> energyInput = const Value.absent(),
                Value<double?> coolingRate = const Value.absent(),
                Value<double?> heatingRate = const Value.absent(),
                Value<double?> targetPh = const Value.absent(),
                Value<double?> targetAw = const Value.absent(),
                Value<double?> targetBrix = const Value.absent(),
                Value<double?> particleSizeTargetUm = const Value.absent(),
                Value<String?> oxygenExposure = const Value.absent(),
                Value<String?> atmosphere = const Value.absent(),
                Value<int?> orderIndex = const Value.absent(),
                Value<String?> additionMode = const Value.absent(),
                Value<double?> restTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessOperationsCompanion(
                opId: opId,
                family: family,
                name: name,
                tMinC: tMinC,
                tMaxC: tMaxC,
                durationMin: durationMin,
                pressure: pressure,
                shearRateS1: shearRateS1,
                mixingRpm: mixingRpm,
                energyInput: energyInput,
                coolingRate: coolingRate,
                heatingRate: heatingRate,
                targetPh: targetPh,
                targetAw: targetAw,
                targetBrix: targetBrix,
                particleSizeTargetUm: particleSizeTargetUm,
                oxygenExposure: oxygenExposure,
                atmosphere: atmosphere,
                orderIndex: orderIndex,
                additionMode: additionMode,
                restTime: restTime,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                Value<String?> family = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double?> tMinC = const Value.absent(),
                Value<double?> tMaxC = const Value.absent(),
                Value<double?> durationMin = const Value.absent(),
                Value<String?> pressure = const Value.absent(),
                Value<double?> shearRateS1 = const Value.absent(),
                Value<String?> mixingRpm = const Value.absent(),
                Value<double?> energyInput = const Value.absent(),
                Value<double?> coolingRate = const Value.absent(),
                Value<double?> heatingRate = const Value.absent(),
                Value<double?> targetPh = const Value.absent(),
                Value<double?> targetAw = const Value.absent(),
                Value<double?> targetBrix = const Value.absent(),
                Value<double?> particleSizeTargetUm = const Value.absent(),
                Value<String?> oxygenExposure = const Value.absent(),
                Value<String?> atmosphere = const Value.absent(),
                Value<int?> orderIndex = const Value.absent(),
                Value<String?> additionMode = const Value.absent(),
                Value<double?> restTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessOperationsCompanion.insert(
                opId: opId,
                family: family,
                name: name,
                tMinC: tMinC,
                tMaxC: tMaxC,
                durationMin: durationMin,
                pressure: pressure,
                shearRateS1: shearRateS1,
                mixingRpm: mixingRpm,
                energyInput: energyInput,
                coolingRate: coolingRate,
                heatingRate: heatingRate,
                targetPh: targetPh,
                targetAw: targetAw,
                targetBrix: targetBrix,
                particleSizeTargetUm: particleSizeTargetUm,
                oxygenExposure: oxygenExposure,
                atmosphere: atmosphere,
                orderIndex: orderIndex,
                additionMode: additionMode,
                restTime: restTime,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProcessOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessOperationsTable,
      ProcessOperation,
      $$ProcessOperationsTableFilterComposer,
      $$ProcessOperationsTableOrderingComposer,
      $$ProcessOperationsTableAnnotationComposer,
      $$ProcessOperationsTableCreateCompanionBuilder,
      $$ProcessOperationsTableUpdateCompanionBuilder,
      (
        ProcessOperation,
        BaseReferences<
          _$AppDatabase,
          $ProcessOperationsTable,
          ProcessOperation
        >,
      ),
      ProcessOperation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeImagesTableTableManager get recipeImages =>
      $$RecipeImagesTableTableManager(_db, _db.recipeImages);
  $$RecipeStepsTableTableManager get recipeSteps =>
      $$RecipeStepsTableTableManager(_db, _db.recipeSteps);
  $$CiqualFoodsTableTableManager get ciqualFoods =>
      $$CiqualFoodsTableTableManager(_db, _db.ciqualFoods);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$RecipeItemsTableTableManager get recipeItems =>
      $$RecipeItemsTableTableManager(_db, _db.recipeItems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$RecipeTagsTableTableManager get recipeTags =>
      $$RecipeTagsTableTableManager(_db, _db.recipeTags);
  $$CiqualNutrientsTableTableManager get ciqualNutrients =>
      $$CiqualNutrientsTableTableManager(_db, _db.ciqualNutrients);
  $$SyncEventsTableTableManager get syncEvents =>
      $$SyncEventsTableTableManager(_db, _db.syncEvents);
  $$IngredientStatesTableTableManager get ingredientStates =>
      $$IngredientStatesTableTableManager(_db, _db.ingredientStates);
  $$NutritionComponentsTableTableManager get nutritionComponents =>
      $$NutritionComponentsTableTableManager(_db, _db.nutritionComponents);
  $$NutritionRecordsTableTableManager get nutritionRecords =>
      $$NutritionRecordsTableTableManager(_db, _db.nutritionRecords);
  $$IngredientAromaCompoundsTableTableManager get ingredientAromaCompounds =>
      $$IngredientAromaCompoundsTableTableManager(
        _db,
        _db.ingredientAromaCompounds,
      );
  $$FlavorCompatibilityTableTableManager get flavorCompatibility =>
      $$FlavorCompatibilityTableTableManager(_db, _db.flavorCompatibility);
  $$FunctionalIngredientsTableTableManager get functionalIngredients =>
      $$FunctionalIngredientsTableTableManager(_db, _db.functionalIngredients);
  $$InteractionRulesTableTableManager get interactionRules =>
      $$InteractionRulesTableTableManager(_db, _db.interactionRules);
  $$ProcessOperationsTableTableManager get processOperations =>
      $$ProcessOperationsTableTableManager(_db, _db.processOperations);
}
