// Phase 10 Lot A/G — catalogue canonique des nutriments.
//
// Source unique des libellés affichés, des unités, des groupes
// d'affichage et des valeurs de référence réglementaires :
//
// - VNR vitamines et minéraux : règlement (UE) n° 1169/2011, annexe
//   XIII partie A (valeurs nutritionnelles de référence, adulte).
// - AR énergie et macronutriments : même règlement, annexe XIII
//   partie B (apports de référence, 8 400 kJ / 2 000 kcal).
// - Fibres : pas d'AR réglementaire — repère ANSES adulte (30 g/j),
//   signalé comme tel.
//
// Les tags canoniques sont ceux produits par
// `NutritionRepository.canonicalMicroTag` : ils unifient les tags du
// dictionnaire Phase 2 et les codes INFOODS Ciqual 2025.

import 'package:meta/meta.dart';

/// Groupe d'affichage d'un micronutriment.
enum NutrientGroup { mineral, vitamin, lipid, carbohydrate, other }

/// Fiche d'un nutriment canonique.
@immutable
class NutrientInfo {
  const NutrientInfo({
    required this.tag,
    required this.labelFr,
    required this.labelEn,
    required this.unit,
    required this.group,
    this.referenceIntake,
    this.referenceSource,
  });

  /// Tag canonique (ex. `VITA`, `FE`).
  final String tag;
  final String labelFr;
  final String labelEn;

  /// Unité de la valeur pour 100 g (g, mg, µg).
  final String unit;
  final NutrientGroup group;

  /// Valeur de référence journalière adulte, dans [unit] (null si
  /// aucune référence réglementaire ou repère officiel).
  final double? referenceIntake;

  /// Origine de [referenceIntake] (affichée en info-bulle).
  final String? referenceSource;
}

const String kVnrSource = 'VNR, règlement (UE) 1169/2011, annexe XIII';
const String kArSource = 'AR, règlement (UE) 1169/2011, annexe XIII';
const String kAnsesFiberSource = 'Repère ANSES adulte (30 g/j)';

/// Apports de référence (AR) énergie et macronutriments, adulte.
abstract final class ReferenceIntakes {
  static const double energyKcal = 2000;
  static const double energyKj = 8400;
  static const double fats = 70;
  static const double saturatedFats = 20;
  static const double carbs = 260;
  static const double sugars = 90;
  static const double proteins = 50;
  static const double salt = 6;

  /// Repère ANSES (non réglementaire).
  static const double fiber = 30;
}

/// Catalogue des micronutriments et constituants détaillés.
abstract final class NutrientCatalog {
  static const Map<String, NutrientInfo> entries = {
    // Minéraux.
    'CA': NutrientInfo(
      tag: 'CA',
      labelFr: 'Calcium',
      labelEn: 'Calcium',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 800,
      referenceSource: kVnrSource,
    ),
    'FE': NutrientInfo(
      tag: 'FE',
      labelFr: 'Fer',
      labelEn: 'Iron',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 14,
      referenceSource: kVnrSource,
    ),
    'MG': NutrientInfo(
      tag: 'MG',
      labelFr: 'Magnésium',
      labelEn: 'Magnesium',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 375,
      referenceSource: kVnrSource,
    ),
    'P': NutrientInfo(
      tag: 'P',
      labelFr: 'Phosphore',
      labelEn: 'Phosphorus',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 700,
      referenceSource: kVnrSource,
    ),
    'K': NutrientInfo(
      tag: 'K',
      labelFr: 'Potassium',
      labelEn: 'Potassium',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 2000,
      referenceSource: kVnrSource,
    ),
    'ZN': NutrientInfo(
      tag: 'ZN',
      labelFr: 'Zinc',
      labelEn: 'Zinc',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 10,
      referenceSource: kVnrSource,
    ),
    'CU': NutrientInfo(
      tag: 'CU',
      labelFr: 'Cuivre',
      labelEn: 'Copper',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 1,
      referenceSource: kVnrSource,
    ),
    'MN': NutrientInfo(
      tag: 'MN',
      labelFr: 'Manganèse',
      labelEn: 'Manganese',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 2,
      referenceSource: kVnrSource,
    ),
    'SE': NutrientInfo(
      tag: 'SE',
      labelFr: 'Sélénium',
      labelEn: 'Selenium',
      unit: 'µg',
      group: NutrientGroup.mineral,
      referenceIntake: 55,
      referenceSource: kVnrSource,
    ),
    'I': NutrientInfo(
      tag: 'I',
      labelFr: 'Iode',
      labelEn: 'Iodine',
      unit: 'µg',
      group: NutrientGroup.mineral,
      referenceIntake: 150,
      referenceSource: kVnrSource,
    ),
    'CL': NutrientInfo(
      tag: 'CL',
      labelFr: 'Chlorure',
      labelEn: 'Chloride',
      unit: 'mg',
      group: NutrientGroup.mineral,
      referenceIntake: 800,
      referenceSource: kVnrSource,
    ),
    // Vitamines.
    'VITA': NutrientInfo(
      tag: 'VITA',
      labelFr: 'Vitamine A (équivalents rétinol)',
      labelEn: 'Vitamin A (retinol activity eq.)',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 800,
      referenceSource: kVnrSource,
    ),
    'CAROTENE_B': NutrientInfo(
      tag: 'CAROTENE_B',
      labelFr: 'Bêta-carotène',
      labelEn: 'Beta-carotene',
      unit: 'µg',
      group: NutrientGroup.vitamin,
    ),
    'VITD': NutrientInfo(
      tag: 'VITD',
      labelFr: 'Vitamine D',
      labelEn: 'Vitamin D',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 5,
      referenceSource: kVnrSource,
    ),
    'VITE': NutrientInfo(
      tag: 'VITE',
      labelFr: 'Vitamine E',
      labelEn: 'Vitamin E',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 12,
      referenceSource: kVnrSource,
    ),
    'VITK': NutrientInfo(
      tag: 'VITK',
      labelFr: 'Vitamine K',
      labelEn: 'Vitamin K',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 75,
      referenceSource: kVnrSource,
    ),
    'VITC': NutrientInfo(
      tag: 'VITC',
      labelFr: 'Vitamine C',
      labelEn: 'Vitamin C',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 80,
      referenceSource: kVnrSource,
    ),
    'THIAMIN': NutrientInfo(
      tag: 'THIAMIN',
      labelFr: 'Vitamine B1 (thiamine)',
      labelEn: 'Thiamin (B1)',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 1.1,
      referenceSource: kVnrSource,
    ),
    'RIBOFLAVINE': NutrientInfo(
      tag: 'RIBOFLAVINE',
      labelFr: 'Vitamine B2 (riboflavine)',
      labelEn: 'Riboflavin (B2)',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 1.4,
      referenceSource: kVnrSource,
    ),
    'NIACINE': NutrientInfo(
      tag: 'NIACINE',
      labelFr: 'Vitamine B3 (niacine)',
      labelEn: 'Niacin (B3)',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 16,
      referenceSource: kVnrSource,
    ),
    'VITB5': NutrientInfo(
      tag: 'VITB5',
      labelFr: 'Vitamine B5 (acide pantothénique)',
      labelEn: 'Pantothenic acid (B5)',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 6,
      referenceSource: kVnrSource,
    ),
    'VITB6': NutrientInfo(
      tag: 'VITB6',
      labelFr: 'Vitamine B6',
      labelEn: 'Vitamin B6',
      unit: 'mg',
      group: NutrientGroup.vitamin,
      referenceIntake: 1.4,
      referenceSource: kVnrSource,
    ),
    'FOLATES': NutrientInfo(
      tag: 'FOLATES',
      labelFr: 'Vitamine B9 (folates)',
      labelEn: 'Folate (B9)',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 200,
      referenceSource: kVnrSource,
    ),
    'VITB12': NutrientInfo(
      tag: 'VITB12',
      labelFr: 'Vitamine B12',
      labelEn: 'Vitamin B12',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 2.5,
      referenceSource: kVnrSource,
    ),
    'BIOTINE': NutrientInfo(
      tag: 'BIOTINE',
      labelFr: 'Vitamine B8 (biotine)',
      labelEn: 'Biotin (B8)',
      unit: 'µg',
      group: NutrientGroup.vitamin,
      referenceIntake: 50,
      referenceSource: kVnrSource,
    ),
    'CHOLINE': NutrientInfo(
      tag: 'CHOLINE',
      labelFr: 'Choline',
      labelEn: 'Choline',
      unit: 'mg',
      group: NutrientGroup.vitamin,
    ),
    // Lipides détaillés.
    'AG_MONO': NutrientInfo(
      tag: 'AG_MONO',
      labelFr: 'AG mono-insaturés',
      labelEn: 'Monounsaturated FA',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'AG_POLY': NutrientInfo(
      tag: 'AG_POLY',
      labelFr: 'AG poly-insaturés',
      labelEn: 'Polyunsaturated FA',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'OMEGA3': NutrientInfo(
      tag: 'OMEGA3',
      labelFr: 'Oméga-3 totaux',
      labelEn: 'Omega-3 (total)',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'OMEGA6': NutrientInfo(
      tag: 'OMEGA6',
      labelFr: 'Oméga-6 totaux',
      labelEn: 'Omega-6 (total)',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'ALA': NutrientInfo(
      tag: 'ALA',
      labelFr: 'Acide alpha-linolénique (ALA, oméga-3)',
      labelEn: 'Alpha-linolenic acid (ALA)',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'LA': NutrientInfo(
      tag: 'LA',
      labelFr: 'Acide linoléique (LA, oméga-6)',
      labelEn: 'Linoleic acid (LA)',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'EPA': NutrientInfo(
      tag: 'EPA',
      labelFr: 'EPA (oméga-3 à longue chaîne)',
      labelEn: 'EPA',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'DHA': NutrientInfo(
      tag: 'DHA',
      labelFr: 'DHA (oméga-3 à longue chaîne)',
      labelEn: 'DHA',
      unit: 'g',
      group: NutrientGroup.lipid,
    ),
    'CHOLEST': NutrientInfo(
      tag: 'CHOLEST',
      labelFr: 'Cholestérol',
      labelEn: 'Cholesterol',
      unit: 'mg',
      group: NutrientGroup.lipid,
    ),
    // Glucides détaillés.
    'STARCH': NutrientInfo(
      tag: 'STARCH',
      labelFr: 'Amidon',
      labelEn: 'Starch',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'SACCHAROSE': NutrientInfo(
      tag: 'SACCHAROSE',
      labelFr: 'Saccharose',
      labelEn: 'Sucrose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'GLUCOSE': NutrientInfo(
      tag: 'GLUCOSE',
      labelFr: 'Glucose',
      labelEn: 'Glucose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'FRUCTOSE': NutrientInfo(
      tag: 'FRUCTOSE',
      labelFr: 'Fructose',
      labelEn: 'Fructose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'LACTOSE': NutrientInfo(
      tag: 'LACTOSE',
      labelFr: 'Lactose',
      labelEn: 'Lactose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'MALTOSE': NutrientInfo(
      tag: 'MALTOSE',
      labelFr: 'Maltose',
      labelEn: 'Maltose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'GALACTOSE': NutrientInfo(
      tag: 'GALACTOSE',
      labelFr: 'Galactose',
      labelEn: 'Galactose',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'POLYOLS': NutrientInfo(
      tag: 'POLYOLS',
      labelFr: 'Polyols',
      labelEn: 'Polyols',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'FIBRES_SOL': NutrientInfo(
      tag: 'FIBRES_SOL',
      labelFr: 'Fibres solubles',
      labelEn: 'Soluble fibre',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    'FIBRES_INS': NutrientInfo(
      tag: 'FIBRES_INS',
      labelFr: 'Fibres insolubles',
      labelEn: 'Insoluble fibre',
      unit: 'g',
      group: NutrientGroup.carbohydrate,
    ),
    // Autres constituants.
    'ACIDES_ORGANIQUES': NutrientInfo(
      tag: 'ACIDES_ORGANIQUES',
      labelFr: 'Acides organiques',
      labelEn: 'Organic acids',
      unit: 'g',
      group: NutrientGroup.other,
    ),
    'CENDRES': NutrientInfo(
      tag: 'CENDRES',
      labelFr: 'Cendres (minéraux totaux)',
      labelEn: 'Ash',
      unit: 'g',
      group: NutrientGroup.other,
    ),
    'CAFFEINE': NutrientInfo(
      tag: 'CAFFEINE',
      labelFr: 'Caféine',
      labelEn: 'Caffeine',
      unit: 'mg',
      group: NutrientGroup.other,
    ),
    'THEOBROMINE': NutrientInfo(
      tag: 'THEOBROMINE',
      labelFr: 'Théobromine',
      labelEn: 'Theobromine',
      unit: 'mg',
      group: NutrientGroup.other,
    ),
    'POLYPHENOLS': NutrientInfo(
      tag: 'POLYPHENOLS',
      labelFr: 'Polyphénols totaux',
      labelEn: 'Total polyphenols',
      unit: 'mg',
      group: NutrientGroup.other,
    ),
  };

  /// Fiche d'un tag canonique (null si inconnu).
  static NutrientInfo? of(String tag) => entries[tag];

  /// Part (0..∞) de la valeur de référence couverte par [value] pour le
  /// tag donné. Null quand le nutriment n'a pas de référence.
  static double? shareOfReference(String tag, double value) {
    final ri = entries[tag]?.referenceIntake;
    if (ri == null || ri <= 0) return null;
    return value / ri;
  }
}
