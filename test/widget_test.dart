import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:presuco/src/presuco_app.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const PresuCoApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
