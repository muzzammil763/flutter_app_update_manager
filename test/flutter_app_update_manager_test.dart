
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

void main() {
  group('AppUpdateManager', () {
    testWidgets('should create AppUpdateManager with default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppUpdateManager(
                      context: context,
                      androidId: 'com.example.test',
                      iosId: '123456789',
                      appName: 'TestApp',
                    ).checkForUpdate();
                  },
                  child: Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should create AppUpdateManager with custom dialog style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppUpdateManager(
                      context: context,
                      androidId: 'com.example.test',
                      iosId: '123456789',
                      appName: 'TestApp',
                      dialogStyle: DialogStyle.modernStyle,
                    ).checkForUpdate();
                  },
                  child: Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should create AppUpdateManager with custom dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppUpdateManager(
                      context: context,
                      androidId: 'com.example.test',
                      iosId: '123456789',
                      appName: 'TestApp',
                      dialogStyle: DialogStyle.custom,
                      customDialog: TestCustomDialog(),
                    ).checkForUpdate();
                  },
                  child: Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}

class TestCustomDialog implements CustomUpdateDialog {
  @override
  Widget build(BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  }) {
    return AlertDialog(
      title: Text('Custom Update Dialog'),
      content: Text('This is a custom dialog for $appName'),
      actions: [
        if (!isForceUpdate && onLater != null)
          TextButton(
            onPressed: onLater,
            child: Text('Custom Later'),
          ),
        ElevatedButton(
          onPressed: onUpdate,
          child: Text('Custom Update Button'),
        ),
      ],
    );
  }
}
