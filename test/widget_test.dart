import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:styfi/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StyfiApp());

    // Verify that the app starts. 
    // We look for a widget likely to be on the login screen.
    // If your app starts with a different screen, this test might need adjustment,
    // but at least it will compile and run the app structure correctly.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}