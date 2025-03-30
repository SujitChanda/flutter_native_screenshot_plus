import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus.dart';
import 'package:flutter/services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Tests', () {
    final FlutterNativeScreenshotPlus plugin = FlutterNativeScreenshotPlus();

    testWidgets('Test screenshot capture returns valid path', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Test Content')),
        ),
      ));

      // Wait for rendering to complete
      await tester.pumpAndSettle();

      try {
        final String? path = await plugin.takeScreenshot();

        expect(path, isNotNull);
        expect(path!.isNotEmpty, isTrue);
        expect(path.endsWith('.png'), isTrue);
      } on PlatformException catch (e) {
        fail('PlatformException occurred: ${e.message}');
      }
    });

    testWidgets('Test multiple rapid screenshots', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Multiple Screenshot Test')),
        ),
      ));
          await tester.pumpAndSettle();

      // Take 3 screenshots in quick succession
      for (int i = 1; i <= 3; i++) {
        final String? path = await plugin.takeScreenshot();
        expect(path, isNotNull);
        expect(path!.contains('screenshot_'), isTrue);
        expect(path.endsWith('.png'), isTrue);
      }
    });

    testWidgets('Test screenshot contains actual content', (WidgetTester tester) async {
      const testText = 'Screenshot Test Content';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(child: Text(testText)),
        ),
      ));
      await tester.pumpAndSettle();

      final String? path = await plugin.takeScreenshot();
      expect(path, isNotNull);

      // In a real test environment, you might verify the screenshot file exists
      // or even do image verification (would require additional packages)
    });
  });
}