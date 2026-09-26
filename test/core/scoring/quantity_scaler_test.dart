import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/scoring/quantity_scaler.dart';

void main() {
  String s(String raw, double f) => QuantityScaler.scale(raw, f);

  test('facteur 1 : quantité strictement inchangée', () {
    expect(s('1,5 kg', 1), '1,5 kg');
    expect(s('une pincée', 1), 'une pincée');
  });

  test('masses et volumes métriques', () {
    expect(s('250 g', 2), '500 g');
    expect(s('1,5 kg', 2 / 3), '1 kg');
    expect(s('50 cl', 0.5), '25 cl');
    expect(s('3 g', 1 / 3), '1 g');
    expect(s('5 g', 0.3), '1,5 g');
  });

  test('unités culinaires, fractions et plages', () {
    expect(s('2 c. à soupe', 2), '4 c. à soupe');
    expect(s('1/2 c. à café', 2), '1 c. à café');
    expect(s('1 1/2 tasse', 2), '3 tasses');
    expect(s('½ citron', 2), '1 citron');
    expect(s('2-3 gousses', 2), '4-6 gousses');
    expect(s('2 à 3 brins', 2), '4-6 brins');
  });

  test('pièces : arrondi au quart ou au demi, accord du pluriel', () {
    expect(s('1 gousse', 2), '2 gousses');
    expect(s('3 pièces', 1 / 3), '1 pièce');
    expect(s('4 pièces', 4 / 6), '2,5 pièces');
    expect(s('1 pièce', 0.25), '0,25 pièce');
    expect(s('une pincée', 3), '3 pincées');
    expect(s('2 poireaux', 0.5), '1 poireau');
    expect(s('1 bouquet', 2), '2 bouquets');
    expect(s('1 jus', 2), '2 jus');
  });

  test('sans nombre : inchangé', () {
    expect(s('sel', 2), 'sel');
    expect(s('QS', 3), 'QS');
    expect(s('', 2), '');
  });
}
