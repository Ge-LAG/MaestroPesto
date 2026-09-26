// Allergènes à déclaration obligatoire (règlement UE 1169/2011,
// annexe II) : libellés français des étiquettes `allergen_tags` du
// référentiel Phase 1, dans l'ordre de l'annexe.

const Map<String, String> kAllergenLabelsFr = {
  'gluten': 'gluten',
  'crustaceans': 'crustacés',
  'eggs': 'œufs',
  'fish': 'poissons',
  'peanuts': 'arachides',
  'soy': 'soja',
  'soybeans': 'soja',
  'milk': 'lait',
  'nuts': 'fruits à coque',
  'celery': 'céleri',
  'mustard': 'moutarde',
  'sesame': 'sésame',
  'sulphites': 'sulfites',
  'sulfites': 'sulfites',
  'lupin': 'lupin',
  'mollusks': 'mollusques',
  'molluscs': 'mollusques',
};

/// Libellé français d'une étiquette d'allergène (l'étiquette brute si
/// elle est inconnue).
String allergenLabelFr(String tag) =>
    kAllergenLabelsFr[tag.trim().toLowerCase()] ?? tag.trim();

/// Rang d'affichage (ordre de l'annexe II ; inconnus en dernier).
int allergenRank(String tag) {
  final i = kAllergenLabelsFr.keys.toList().indexOf(tag.trim().toLowerCase());
  return i == -1 ? 999 : i;
}
