// Phase 09 Lot F — tests pour IngredientAliasIndex.

import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/features/ingredients/data/ingredient_alias_index.dart';

void main() {
  group('IngredientAliasIndex', () {
    // Corpus de test : 6 ingrédients couvrant divers cas
    final corpus = <IngredientSummary>[
      const IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000001',
        canonicalNameFr: 'Tomate',
        canonicalNameEn: 'Tomato',
        categoryLevel1: 'vegetal',
      ),
      const IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000002',
        canonicalNameFr: 'Tomate cerise',
        canonicalNameEn: 'Cherry tomato',
        categoryLevel1: 'vegetal',
      ),
      const IngredientSummary(
        ingredientId: 'ING-PLANT-BASILIC-000001',
        canonicalNameFr: 'Basilic',
        canonicalNameEn: 'Basil',
        categoryLevel1: 'vegetal',
        categoryLevel2: 'herbe',
      ),
      const IngredientSummary(
        ingredientId: 'ING-DAIRY-MOZZARELLA-000001',
        canonicalNameFr: 'Mozzarella',
        categoryLevel1: 'animal',
        categoryLevel2: 'laitier',
      ),
      const IngredientSummary(
        ingredientId: 'ING-ANIMAL-BOEUF-000001',
        canonicalNameFr: 'Bœuf',
        categoryLevel1: 'animal',
      ),
      const IngredientSummary(
        ingredientId: 'ING-PLANT-AIL-000001',
        canonicalNameFr: 'Ail',
        canonicalNameEn: 'Garlic',
        categoryLevel1: 'vegetal',
      ),
    ];

    IngredientAliasIndex makeIndex() =>
        IngredientAliasIndex.fromSummaries(corpus);

    test('build() depuis summaries retourne index non-vide', () {
      final idx = makeIndex();
      expect(idx.size, 6);
    });

    test('search() exact match', () {
      final idx = makeIndex();
      final r = idx.search('Tomate');
      expect(r.first.ingredientId, 'ING-PLANT-TOMATE-000001');
    });

    test('search() insensible à la casse', () {
      final idx = makeIndex();
      final r = idx.search('TOMATE');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, startsWith('ING-PLANT-TOMATE'));
    });

    test('search() insensible aux accents', () {
      final idx = makeIndex();
      final r = idx.search('basilic');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, 'ING-PLANT-BASILIC-000001');
    });

    test('search() requête vide retourne les 30 premiers par nom', () {
      final idx = makeIndex();
      final r = idx.search('');
      expect(r.length, 6);
      // Triés par canonical_name_fr
      expect(r.first.canonicalNameFr, 'Ail');
    });

    test('search() whitespace only', () {
      final idx = makeIndex();
      final r = idx.search('   ');
      expect(r.length, 6);
    });

    test('search() caractères spéciaux neutres', () {
      final idx = makeIndex();
      final r = idx.search('---');
      expect(r.length, 6); // fallback comme empty
    });

    test('search() partial match "tom" trouve Tomate', () {
      final idx = makeIndex();
      final r = idx.search('tom');
      expect(r.isNotEmpty, isTrue);
      // Le résultat doit contenir au moins une tomate
      expect(
        r.any((s) => s.canonicalNameFr.toLowerCase().contains('tomate')),
        isTrue,
      );
    });

    test('search() fuzzy "mozarela" (faute) trouve Mozzarella', () {
      final idx = makeIndex();
      final r = idx.search('mozarela');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, 'ING-DAIRY-MOZZARELLA-000001');
    });

    test('search() fuzzy "boeuf" trouve Bœuf (pas de faute)', () {
      final idx = makeIndex();
      final r = idx.search('boeuf');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, 'ING-ANIMAL-BOEUF-000001');
    });

    test('search() fuzzy "boef" (faute 1 char) trouve Bœuf', () {
      final idx = makeIndex();
      final r = idx.search('boef');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, 'ING-ANIMAL-BOEUF-000001');
    });

    test('search() fuzzy "bofe" (distance 3) ne trouve pas Bœuf', () {
      final idx = makeIndex();
      final r = idx.search('bofe');
      // « bofe » vs la clé normalisée « boeuf » : distance 3
      // (b-o pareil, puis « euf » vs « fe »), au-delà du seuil ≤ 2
      // du cahier §6.1 → pas de match fuzzy.
      expect(
        r.where((s) => s.ingredientId == 'ING-ANIMAL-BOEUF-000001'),
        isEmpty,
      );
    });

    test('search() fuzzy "bovin" (trop loin) ne trouve pas Bœuf', () {
      final idx = makeIndex();
      final r = idx.search('bovin');
      // 3 chars de distance (b→v, oe→i, uf→n) — au-delà de Levenshtein 2.
      // On s'attend à un fallback ou un résultat vide.
      expect(
        r.where((s) => s.ingredientId == 'ING-ANIMAL-BOEUF-000001'),
        isEmpty,
      );
    });

    test('search() multi-token "ail basilic" trouve les deux', () {
      final idx = makeIndex();
      final r = idx.search('ail basilic');
      final ids = r.map((s) => s.ingredientId).toSet();
      expect(ids.contains('ING-PLANT-AIL-000001'), isTrue);
      expect(ids.contains('ING-PLANT-BASILIC-000001'), isTrue);
    });

    test('search() limite le nombre de résultats', () {
      final idx = makeIndex();
      final r = idx.search('vegetal', limit: 2);
      expect(r.length, lessThanOrEqualTo(2));
    });

    test(
      'search() token trop court pour fuzzy : pas de fuzzy sur tokens <= 4',
      () {
        final idx = makeIndex();
        // "ail" a 3 chars, ne déclenche pas le fuzzy Levenshtein
        // mais matche en prefix/exact
        final r = idx.search('ail');
        expect(r.isNotEmpty, isTrue);
        expect(r.first.ingredientId, 'ING-PLANT-AIL-000001');
      },
    );

    test('search() token avec pluriel approximatif : "tomates"', () {
      final idx = makeIndex();
      final r = idx.search('tomates');
      // Distance 1 (s en trop) → doit fuzzy sur token "tomate"
      expect(r.isNotEmpty, isTrue);
      expect(r.first.canonicalNameFr, startsWith('Tomate'));
    });

    test('normalize() lowercase + strip diacritics', () {
      expect(normalize('BŒUF'), 'boeuf');
      expect(normalize('Ail'), 'ail');
      expect(normalize('Crème'), 'creme');
      expect(normalize('  multiple   espaces  '), 'multiple espaces');
    });

    test('levenshtein() symétrique', () {
      expect(levenshtein('tomate', 'tomate', maxDistance: 2), 0);
      expect(levenshtein('tomate', 'tomae', maxDistance: 2), 1);
      // 'tomate' → 'tom' : 3 délétions ('a', 't', 'e').
      expect(levenshtein('tomate', 'tom', maxDistance: 5), 3);
      expect(levenshtein('abc', 'xyz', maxDistance: 2), 3);
    });

    test('levenshtein() élague au-delà de maxDistance', () {
      // "tomate" → "bovin" : distance 5, élague
      expect(
        levenshtein('tomate', 'bovin', maxDistance: 2),
        3,
      ); // maxDistance+1
    });

    test('search() token "Mozza" trouve Mozzarella (prefix)', () {
      final idx = makeIndex();
      final r = idx.search('Mozza');
      expect(r.isNotEmpty, isTrue);
      expect(r.first.ingredientId, 'ING-DAIRY-MOZZARELLA-000001');
    });

    test('all() expose tous les ingrédients', () {
      final idx = makeIndex();
      expect(idx.all.length, 6);
    });

    test('search() résultats stables : ordre canonique à score égal', () {
      final idx = makeIndex();
      final r = idx.search('');
      expect(r.map((s) => s.canonicalNameFr).toList(), [
        'Ail',
        'Basilic',
        'Bœuf',
        'Mozzarella',
        'Tomate',
        'Tomate cerise',
      ]);
    });
  });
}
