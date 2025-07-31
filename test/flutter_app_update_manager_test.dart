
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

import 'flutter_app_update_manager_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot
])
void main() {
  group('AppUpdateManager', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      // Set up the mock chain to avoid null errors
      when(mockFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
    });

    testWidgets('shows update dialog for new version',
        (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'test_app',
        packageName: 'com.example.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'build_signature',
        installerStore: 'com.android.vending',
      );

      // Set up test-specific data for the snapshot
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({
        'versions': [
          {'version': '1.0.0', 'forceUpdate': false}
        ],
        'discontinuedVersions': [],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppUpdateManager(context: context, firestore: mockFirestore)
                      .checkForUpdate();
                },
                child: const Text('Check for Update'),
              );
            },
          ),
        ),
      );

      // Find the button and tap it.
      await tester.tap(find.byType(ElevatedButton));
      // Rebuild the widget after the state has changed.
      await tester.pumpAndSettle();

      // Verify that the update dialog is shown.
      expect(find.text('Update Available'), findsOneWidget);
    });
  });
}
