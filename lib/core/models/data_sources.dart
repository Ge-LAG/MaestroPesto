// Registre des sources de données de l'application (page « Sources des
// données »). Chaque valeur affichée cite sa source au plus près
// (nutrition, pH, densités, accords) ; ce registre en donne l'éditeur,
// la version, la licence et l'usage dans l'application.

/// Statut de réutilisation d'une source.
enum SourceLicense {
  publicDomain('Domaine public'),
  cc0('CC0 1.0 (domaine public)'),
  etalab('Licence Ouverte Etalab 2.0'),
  officialText('Texte officiel, réutilisation libre'),
  openAccess('Libre accès, faits cités'),
  internal('Base métier interne');

  const SourceLicense(this.labelFr);
  final String labelFr;
}

class DataSource {
  const DataSource({
    required this.id,
    required this.name,
    required this.publisher,
    required this.version,
    required this.license,
    required this.usage,
    this.url,
  });

  final String id;
  final String name;
  final String publisher;
  final String version;
  final SourceLicense license;

  /// Ce que l'application en tire.
  final String usage;
  final String? url;
}

const List<DataSource> kDataSources = [
  DataSource(
    id: 'ciqual',
    name: 'Table de composition nutritionnelle Ciqual',
    publisher: 'ANSES',
    version: '2025-11-03',
    license: SourceLicense.etalab,
    usage:
        'Composition nutritionnelle de la majorité des ingrédients (énergie, '
        'macronutriments, minéraux, vitamines), profils cuits mesurés, '
        'code de confiance par valeur.',
    url: 'https://ciqual.anses.fr/',
  ),
  DataSource(
    id: 'usda_fdc',
    name: 'FoodData Central — SR Legacy et Foundation Foods',
    publisher: 'USDA, Agricultural Research Service',
    version: 'SR Legacy 04/2018 ; Foundation Foods 04/2026',
    license: SourceLicense.cc0,
    usage:
        'Nutrition des ingrédients absents de Ciqual (glucides hors fibres '
        'et énergie recalculés selon le règlement UE 1169/2011) ; poids '
        'réels des portions (cuillère, tasse, pièce, gousse, brin) pour la '
        'conversion des quantités.',
    url: 'https://fdc.nal.usda.gov/',
  ),
  DataSource(
    id: 'usda_retention',
    name: 'Table of Nutrient Retention Factors, Release 6',
    publisher: 'USDA',
    version: '2007 (fichier Ag Data Commons)',
    license: SourceLicense.cc0,
    usage:
        'Rétention des vitamines et minéraux à la cuisson, par groupe '
        'd’aliments et mode de cuisson (moyenne des catégories USDA '
        'correspondantes), quand aucun profil cuit mesuré n’existe.',
    url:
        'https://catalog.data.gov/dataset/usda-table-of-nutrient-retention-'
        'factors-release-6-2007',
  ),
  DataSource(
    id: 'bognar',
    name:
        'Tables on weight yield of food and retention factors of food '
        'constituents for the calculation of nutrient composition of cooked '
        'foods',
    publisher: 'A. Bognár, Bundesforschungsanstalt für Ernährung',
    version: '2002',
    license: SourceLicense.openAccess,
    usage: 'Rendements de cuisson (perte ou prise de poids) par groupe.',
  ),
  DataSource(
    id: 'fda_ph',
    name: 'Approximate pH of Foods and Food Products',
    publisher: 'U.S. FDA / CFSAN',
    version: 'avril 2007',
    license: SourceLicense.publicDomain,
    usage:
        'pH mesuré des ingrédients (plages citées) ; les autres pH sont des '
        'estimations par catégorie, signalées comme telles.',
  ),
  DataSource(
    id: 'fda_aw',
    name: 'Water Activity (aw) in Foods — Inspection Technical Guide n° 39',
    publisher: 'U.S. FDA',
    version: '1984',
    license: SourceLicense.publicDomain,
    usage:
        'Seuils d’activité de l’eau pour la croissance microbienne et '
        'contrôle de l’estimation (sauce soja).',
    url:
        'https://www.fda.gov/inspections-compliance-enforcement-and-'
        'criminal-investigations/inspection-technical-guides/'
        'water-activity-aw-foods',
  ),
  DataSource(
    id: 'escoffier',
    name: 'A Guide to Modern Cookery (Le Guide culinaire)',
    publisher: 'A. Escoffier — Project Gutenberg n° 71395',
    version: 'Londres, 1907',
    license: SourceLicense.publicDomain,
    usage:
        'Accords culinaires observés : paires d’ingrédients réunies dans '
        'au moins 6 des 5 000 recettes, nettement plus souvent que le '
        'hasard (lift ≥ 1,5).',
    url: 'https://www.gutenberg.org/ebooks/71395',
  ),
  DataSource(
    id: 'eu_1169',
    name: 'Règlement (UE) n° 1169/2011 (information des consommateurs)',
    publisher: 'Union européenne — EUR-Lex',
    version: 'version consolidée',
    license: SourceLicense.officialText,
    usage:
        'Coefficients énergétiques (annexe XIV), apports de référence '
        '(annexe XIII), allergènes à déclaration obligatoire (annexe II).',
    url: 'https://eur-lex.europa.eu/eli/reg/2011/1169/oj',
  ),
  DataSource(
    id: 'eu_1924',
    name: 'Règlement (CE) n° 1924/2006 (allégations nutritionnelles)',
    publisher: 'Union européenne — EUR-Lex',
    version: 'version consolidée',
    license: SourceLicense.officialText,
    usage: 'Conditions des allégations indicatives (« source de », « riche en »…).',
    url: 'https://eur-lex.europa.eu/eli/reg/2006/1924/oj',
  ),
  DataSource(
    id: 'nutriscore',
    name: 'Nutri-Score — algorithme 2023 (aliments généraux)',
    publisher: 'Santé publique France',
    version: '2023',
    license: SourceLicense.openAccess,
    usage: 'Nutri-Score estimé des recettes (indicatif, non officiel).',
    url: 'https://www.santepubliquefrance.fr/',
  ),
  DataSource(
    id: 'anses_reperes',
    name: 'Repères nutritionnels (répartition de l’énergie)',
    publisher: 'ANSES',
    version: '2016',
    license: SourceLicense.openAccess,
    usage: 'Repères de répartition protéines / lipides / glucides.',
    url: 'https://www.anses.fr/',
  ),
  DataSource(
    id: 'nacl_osmotic',
    name: 'Coefficients osmotiques du chlorure de sodium à 25 °C',
    publisher: 'Données physico-chimiques tabulées (Robinson et Stokes)',
    version: '1959',
    license: SourceLicense.openAccess,
    usage: 'Activité de l’eau des mélanges salés (saumures, sauces).',
  ),
  DataSource(
    id: 'metier',
    name: 'Bases métier MaestroPesto (phases 1 à 4)',
    publisher: 'Projet MaestroPesto',
    version: 'référentiel de 603 ingrédients',
    license: SourceLicense.internal,
    usage:
        'Référentiel des ingrédients, profils aromatiques, règles '
        'fonctionnelles et cas expérimentaux ; règles curatées par catégorie '
        '(estimations signalées comme telles dans l’application).',
  ),
];
