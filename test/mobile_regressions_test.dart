import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misfin/src/controller.dart';
import 'package:misfin/src/screens/import_screen.dart';
import 'package:misfin/src/screens/onboarding_screen.dart';
import 'package:misfin/src/storage.dart';
import 'package:misfin/src/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('el onboarding movil no desborda ni tapa el texto',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = MisFinController(const MisFinStore());
    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);

    for (var step = 0; step < 3; step++) {
      await tester.tap(find.text('Continuar').last);
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Desbordamiento al entrar al paso ${step + 2}',
      );
    }

    final message = find.text(
      'Tus animalitos estaran contigo para animarte a ahorrar con calma y constancia.',
    );
    expect(message, findsOneWidget);
    final messageRect = tester.getRect(message);

    for (final element in find.byType(AnimatedAnimalSticker).evaluate()) {
      final box = element.renderObject! as RenderBox;
      final animalRect = box.localToGlobal(Offset.zero) & box.size;
      expect(animalRect.overlaps(messageRect), isFalse);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('una cantidad simple se puede registrar desde Importar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = MisFinController(const MisFinStore());
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ImportScreen(controller: controller))),
    );
    await tester.pump(const Duration(milliseconds: 800));

    await tester.enterText(find.byType(TextField), '100000');
    await tester.pump();

    final buttonFinder = find.widgetWithText(FilledButton, 'Registrar gasto');
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.expenses, hasLength(1));
    expect(controller.expenses.single.amount, 100000);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('un gasto manual guarda monto y banco desde el unico recuadro',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = MisFinController(const MisFinStore());
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ImportScreen(controller: controller))),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Agregar gasto manualmente'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '45.000 Bancolombia');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar gasto'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.expenses, hasLength(1));
    expect(controller.expenses.single.amount, 45000);
    expect(controller.expenses.single.bank, 'Bancolombia');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('escribir monto y banco no guarda antes de terminar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = MisFinController(const MisFinStore());
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ImportScreen(controller: controller))),
    );
    await tester.pump(const Duration(milliseconds: 800));

    final importField = find.byType(TextField).first;
    await tester.enterText(importField, '100000 Bancolombia');
    await tester.pump(const Duration(milliseconds: 600));

    expect(controller.expenses, isEmpty);
    expect(tester.widget<TextField>(importField).controller!.text,
        '100000 Bancolombia');
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Registrar gasto'),
          )
          .onPressed,
      isNotNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
