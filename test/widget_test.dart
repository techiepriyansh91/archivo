import 'package:archivo/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the Slice 0 placeholder', (tester) async {
    await tester.pumpWidget(const ArchivoApp());

    expect(find.text('archivo'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
