import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/features/privacy/presentation/screens/collected_info_screen.dart';
import 'package:keeauth/features/privacy/presentation/screens/privacy_detail_screen.dart';
import 'package:keeauth/features/privacy/presentation/screens/sdk_list_screen.dart';

/// Enlarges the test viewport so lazily-built list items are all rendered.
void useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 8000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('CollectedInfoScreen', () {
    testWidgets('renders each information type with its fields', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: CollectedInfoScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('2FA secrets & account information'),
        findsOneWidget,
      );
      expect(find.text('Purpose'), findsWidgets);
      expect(find.text('Collection method'), findsWidgets);
      expect(find.text('Retention'), findsWidgets);
      expect(find.text('Deletion'), findsWidgets);
    });
  });

  group('SdkListScreen', () {
    testWidgets('lists embedded SDKs and their sharing status', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: SdkListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Google ML Kit (Barcode Scanning)'), findsOneWidget);
      expect(find.text('SQLCipher for Android'), findsOneWidget);
      expect(find.text('AndroidX / Android Support Library'), findsOneWidget);
      expect(find.text('Sharing'), findsWidgets);
      expect(find.text('Not shared'), findsWidgets);
    });
  });

  group('PrivacyDetailScreen', () {
    testWidgets('renders structured sections without raw markers', (
      tester,
    ) async {
      useTallViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: PrivacyDetailScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2. Sensitive Personal Information'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);

      // The sensitive-information paragraph must carry the purpose/method/scope
      // wording as plain text (emphasis is applied via spans, not markers).
      final selectable = tester.widgetList<SelectableText>(
        find.byType(SelectableText),
      );
      final plain = selectable
          .map((widget) => widget.textSpan?.toPlainText() ?? '')
          .join('\n');
      expect(plain, contains('Purpose:'));
      expect(plain, contains('Method:'));
      expect(plain, contains('Scope:'));
    });
  });
}
