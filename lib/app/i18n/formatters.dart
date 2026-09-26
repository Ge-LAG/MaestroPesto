// Formats numériques français de l'interface (virgule décimale).
//
// Toute valeur affichée passe par ces fonctions : « 0,37 g », « 43,2 % »,
// « 0,73 » — jamais de point décimal dans l'UI.

/// [value] avec [digits] décimales et une virgule décimale.
String fmtNum(num value, [int digits = 1]) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');

/// Précision adaptée à l'ordre de grandeur : 2 décimales sous 1,
/// 1 décimale sous 10, entier au-delà.
String fmtAuto(num value) =>
    fmtNum(value, value.abs() < 1 ? 2 : (value.abs() < 10 ? 1 : 0));

/// Comme [fmtAuto] sans zéros décimaux inutiles (« 2 », « 1,5 »).
String fmtCompact(num value) {
  final s = fmtAuto(value);
  if (!s.contains(',')) return s;
  return s.replaceFirst(RegExp(r',?0+$'), '');
}
