import 'package:flutter_test/flutter_test.dart';
import 'package:misfin/src/automation_payload.dart';

void main() {
  test('crea un enlace nativo de automatizacion', () {
    final uri = buildAutomationUri(
      text: 'Compra por COP 45.000',
    );

    expect(uri.scheme, 'misfin');
    expect(uri.host, 'import');
    expect(extractAutomationText(uri), 'Compra por COP 45.000');
  });
}
