import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_update_manager_example/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(MyHomePage), findsOneWidget);
  });
} 