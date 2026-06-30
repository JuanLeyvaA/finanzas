import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misfin/src/models.dart';
import 'package:misfin/src/widgets.dart';

void main() {
  testWidgets('el encabezado cabe en un iPhone 16e', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: AnimalSectionBanner(
                title: 'Junio de 2026',
                subtitle:
                    'Cindy, tu resumen del mes se actualiza en vivo mientras registras gastos.',
                currency: AppCurrency.cop,
                animals: ['🐱', '🦊', '🐼', '🐢', '🐰', '🐤'],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
