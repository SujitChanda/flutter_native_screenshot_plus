import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_native_screenshot_plus');
  final methodChannelImpl = MethodChannelFlutterNativeScreenshotPlus();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('takeScreenshot returns path', () async {
    const fakePath = 'fake/path/screenshot.png';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
          (MethodCall methodCall) async {
        if (methodCall.method == 'takeScreenshot') {
          return fakePath;
        }
        return null;
      },
    );

    expect(await methodChannelImpl.takeScreenshot(), fakePath);
  });

  test('takeScreenshot throws PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
          (MethodCall methodCall) async {
        if (methodCall.method == 'takeScreenshot') {
          throw PlatformException(
            code: 'ERROR',
            message: 'Failed to capture screenshot',
          );
        }
        return null;
      },
    );

    expect(
          () => methodChannelImpl.takeScreenshot(),
      throwsA(isA<PlatformException>()),
    );
  });
}