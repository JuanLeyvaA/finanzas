import 'package:flutter_test/flutter_test.dart';
import 'package:misfin/src/models.dart';
import 'package:misfin/src/parser.dart';

void main() {
  const parser = MisFinParser();

  test('detecta el valor de la compra y no los ultimos digitos', () {
    final draft = parser.parse(
      'Bancolombia: compra aprobada con tarjeta *1234 por COP 45.000 en MERCADO CENTRAL.',
    );

    expect(draft.amount, 45000);
    expect(draft.bank, 'Bancolombia');
    expect(draft.canAutoImport, isTrue);
  });

  test('no importa automaticamente una compra rechazada', () {
    final draft = parser.parse(
      'Nu: compra rechazada por COP 80.000 en TIENDA UNO.',
    );

    expect(draft.amount, 80000);
    expect(draft.canAutoImport, isFalse);
    expect(draft.hint, contains('rechazado'));
  });

  test('no registra dinero recibido como gasto', () {
    final draft = parser.parse(
      'Nequi: recibiste una transferencia por COP 150.000.',
    );

    expect(draft.amount, 150000);
    expect(draft.canAutoImport, isFalse);
    expect(draft.hint, contains('dinero recibido'));
  });

  test('detecta una divisa distinta para pedir confirmacion', () {
    final draft = parser.parse(
      'BBVA compra aprobada por USD 25.50 en BOOK STORE.',
    );

    expect(draft.detectedCurrency, AppCurrency.usd);
    expect(draft.hasCurrencyMismatch(AppCurrency.cop), isTrue);
  });

  test('permite registrar una cantidad escrita sin texto adicional', () {
    final draft = parser.parse('100000');

    expect(draft.amount, 100000);
    expect(draft.canAutoImport, isFalse);
  });

  test('mantiene el monto mientras se escribe el banco manualmente', () {
    final partialDraft = parser.parse('100000 B');
    final completeDraft = parser.parse('100000 Bancolombia');

    expect(partialDraft.amount, 100000);
    expect(partialDraft.canAutoImport, isFalse);
    expect(completeDraft.amount, 100000);
    expect(completeDraft.bank, 'Bancolombia');
    expect(completeDraft.canAutoImport, isFalse);
  });
}
